require 'ffi'

module RDF::Raptor
  ##
  # A foreign-function interface (FFI) to `libraptor`.
  #
  # @see http://librdf.org/raptor/api/
  # @see http://librdf.org/raptor/libraptor.html
  module FFI
    ##
    # Reader implementation.
    module Reader
      ##
      # @param  [IO, File, RDF::URI, String] input
      # @param  [Hash{Symbol => Object}]     options
      # @option (options) [String, #to_s]    :base_uri ("file:///dev/stdin")
      # @yield  [reader]
      # @yieldparam [RDF::Reader] reader
      def initialize(input = $stdin, options = {}, &block)
        @format = self.class.format.rapper_format
        super
      end

      ERROR_HANDLER = Proc.new do |user_data, locator, message|
        line = V1_4.raptor_locator_line(locator)
        raise RDF::ReaderError, line > -1 ? "Line #{line}: #{message}" : message
      end

      WARNING_HANDLER = Proc.new do |user_data, locator, message|
        # line = V1_4.raptor_locator_line(locator)
        # $stderr.puts line > -1 ? "Line #{line}: #{message}" : message
      end


      ##
      # @yield [statement]
      # @yieldparam [RDF::Statement] statement
      def each_statement(&block)
        each_triple do |triple|
          block.call(RDF::Statement.new(*triple))
        end
      end

      ##
      # @yield [triple]
      # @yieldparam [Array(RDF::Resource, RDF::URI, RDF::Value)] triple
      def each_triple(&block)
        statement_handler = Proc.new do |user_data, statement|
          triple = V1_4::Statement.new(statement).to_triple
          block.call(triple)
        end

        V1_4.with_parser(:name => @format) do |parser|
          V1_4.raptor_set_error_handler(parser, nil, ERROR_HANDLER)
          V1_4.raptor_set_warning_handler(parser, nil, WARNING_HANDLER)
          V1_4.raptor_set_statement_handler(parser, nil, statement_handler)
          case @input
            when RDF::URI, %r(^(file|http|https|ftp)://)
              begin
                data_url = V1_4.raptor_new_uri(@input.to_s)
                base_uri = @options[:base_uri].to_s.empty? ? nil : V1_4.raptor_new_uri(@options[:base_uri].to_s)
                unless (result = V1_4.raptor_parse_uri(parser, data_url, base_uri)).zero?
                  # TODO: error handling
                end
              ensure
                V1_4.raptor_free_uri(base_uri) if base_uri
                V1_4.raptor_free_uri(data_url) if data_url
              end

            when File, Tempfile
              begin
                data_url = V1_4.raptor_new_uri("file://#{File.expand_path(@input.path)}")
                base_uri = @options[:base_uri].to_s.empty? ? nil : V1_4.raptor_new_uri(@options[:base_uri].to_s)
                unless (result = V1_4.raptor_parse_file(parser, data_url, base_uri)).zero?
                  # TODO: error handling
                end
              ensure
                V1_4.raptor_free_uri(base_uri) if base_uri
                V1_4.raptor_free_uri(data_url) if data_url
              end

            else # IO, String
              base_uri = (@options[:base_uri] || 'file:///dev/stdin').to_s
              unless (result = V1_4.raptor_start_parse(parser, base_uri)).zero?
                # TODO: error handling
              end
              # TODO: read in chunks instead of everything in one go:
              unless (result = V1_4.raptor_parse_chunk(parser, buffer = @input.read, buffer.size, 0)).zero?
                # TODO: error handling
              end
              V1_4.raptor_parse_chunk(parser, nil, 0, 1) # EOF
          end
        end

      end

      alias_method :each, :each_statement
    end

    ##
    # Writer implementation.
    module Writer

      ERROR_HANDLER = Proc.new do |user_data, locator, message|
        raise RDF::WriterError, message
      end

      WARNING_HANDLER = Proc.new do |user_data, locator, message|
        # $stderr.puts "warning"
      end

      def initialize(output = $stdout, options = {}, &block)
        raise ArgumentError, "Block required" unless block_given?  # Can we work without this?
        @format = self.class.format.rapper_format
        begin
          # make a serializer
          @serializer = V1_4.raptor_new_serializer((@format || :rdfxml).to_s)
          raise RDF::WriterError, "raptor_new_serializer failed" if @serializer.nil?
          V1_4.raptor_serializer_set_error_handler(@serializer, nil, ERROR_HANDLER)
          V1_4.raptor_serializer_set_warning_handler(@serializer, nil, WARNING_HANDLER)
          base_uri = options[:base_uri].to_s.empty? ? nil : V1_4.raptor_new_uri(options[:base_uri].to_s)

          # make an iostream
          handler = V1_4::IOStreamHandler.new
          handler.rubyio = output
          raptor_iostream = V1_4.raptor_new_iostream_from_handler2(nil, handler)

          # connect the two
          unless V1_4.raptor_serialize_start_to_iostream(@serializer, base_uri, raptor_iostream).zero?
            raise RDF::WriterError, "raptor_serialize_start_to_iostream failed"
          end
          super
        ensure
          V1_4.raptor_free_iostream(raptor_iostream) if raptor_iostream
          V1_4.raptor_free_uri(base_uri) if base_uri
          V1_4.raptor_free_serializer(@serializer) if @serializer
        end
      end

      ##
      # @param  [RDF::Resource] subject
      # @param  [RDF::URI]      predicate
      # @param  [RDF::Value]    object
      # @return [void]
      def write_triple(subject, predicate, object)
        raptor_statement = V1_4::Statement.new
        raptor_statement.subject = subject
        raptor_statement.predicate = predicate
        raptor_statement.object = object
        begin
          unless V1_4.raptor_serialize_statement(@serializer, raptor_statement.to_ptr).zero?
            raise RDF::WriterError, "raptor_serialize_statement failed"
          end
        ensure
          raptor_statement.release
          raptor_statement = nil
        end
      end

      ##
      # @return [void]
      def write_epilogue
        unless V1_4.raptor_serialize_end(@serializer).zero?
          raise RDF::WriterError, "raptor_serialize_end failed"
        end
        super
      end

    end


    ##
    # Helper methods for FFI modules.
    module Base
      def define_pointer(name)
        self.class.send(:define_method, name) { :pointer }
      end
    end

    ##
    # A foreign-function interface (FFI) to `libraptor` 1.4.x.
    #
    # @see http://librdf.org/raptor/libraptor.html
    module V1_4

      ##
      # @param  [Hash{Symbol => Object}] options
      # @option (options) [String, #to_s] :name (:rdfxml)
      # @yield  [parser]
      # @yieldparam [FFI::Pointer] parser
      # @return [void]
      def self.with_parser(options = {}, &block)
        begin
          parser = raptor_new_parser((options[:name] || :rdfxml).to_s)
          block.call(parser)
        ensure
          raptor_free_parser(parser) if parser
        end
      end


      extend Base
      extend ::FFI::Library
      ffi_lib LIBRAPTOR

      # TODO: Ideally this would be an enum, but the JRuby FFI (as of
      # version 1.4.0) has problems with enums as part of structs:
      #   `Unknown field type: #<FFI::Enum> (ArgumentError)`
      RAPTOR_IDENTIFIER_TYPE_RESOURCE  = 1
      RAPTOR_IDENTIFIER_TYPE_ANONYMOUS = 2
      RAPTOR_IDENTIFIER_TYPE_LITERAL   = 5

      # @see http://librdf.org/raptor/api/raptor-section-triples.html
      class Statement < ::FFI::Struct
        layout :subject, :pointer,
               :subject_type, :int,
               :predicate, :pointer,
               :predicate_type, :int,
               :object, :pointer,
               :object_type, :int,
               :object_literal_datatype, :pointer,
               :object_literal_language, :pointer

        def initialize(*args)
          super
          # Objects we need to keep a Ruby reference
          # to so they don't get garbage collected out from under
          # the C code we pass them to.
          @mp = {}

          # Raptor object references we we need to explicitly free
          # when release is called
          @raptor_uri_list = []
        end

        ##
        # Release raptor memory associated with this struct.
        # Use of the object after calling this will most likely
        # cause a crash.  This is kind of ugly.
        def release
          if pointer.kind_of?(::FFI::MemoryPointer) && !pointer.null?
            pointer.free
          end
          while uri = @raptor_uri_list.pop
            V1_4.raptor_free_uri(uri) unless uri.nil? || uri.null?
          end
        end

        ##
        # @return [RDF::Resource]
        def subject
          @subject ||= case self[:subject_type]
            when RAPTOR_IDENTIFIER_TYPE_RESOURCE
              RDF::URI.new(V1_4.raptor_uri_to_string(self[:subject]))
            when RAPTOR_IDENTIFIER_TYPE_ANONYMOUS
              RDF::Node.new(self[:subject].read_string)
          end
        end

        ##
        # Set the subject from an RDF::Resource
        # @param  [RDF::Resource] value
        def subject=(resource)
          @subject = nil
          case resource
          when RDF::Node
            self[:subject] = @mp[:subject] = ::FFI::MemoryPointer.from_string(resource.id.to_s)
            self[:subject_type] = RAPTOR_IDENTIFIER_TYPE_ANONYMOUS
          when RDF::URI
            self[:subject] = @mp[:subject] = @raptor_uri_list.push(V1_4.raptor_new_uri(resource.to_s)).last
            self[:subject_type] = RAPTOR_IDENTIFIER_TYPE_RESOURCE
          else
            raise ArgumentError, "subject must be of kind RDF::Node or RDF::URI"
          end
          @subject = resource
        end

        ##
        # @return [String]
        def subject_as_string
          V1_4.raptor_statement_part_as_string(
            self[:subject],
            self[:subject_type],
            nil, nil)
        end

        ##
        # @return [RDF::URI]
        def predicate
          @predicate ||= case self[:predicate_type]
            when RAPTOR_IDENTIFIER_TYPE_RESOURCE
              RDF::URI.new(V1_4.raptor_uri_to_string(self[:predicate]))
          end
        end

        ##
        # Set the predicate from an RDF::URI
        # @param  [RDF::URI] value
        def predicate=(uri)
          @predicate = nil
          raise ArgumentError, "predicate must be a kind of RDF::URI" unless uri.kind_of?(RDF::URI)
          self[:predicate] = @raptor_uri_list.push(V1_4.raptor_new_uri(uri.to_s)).last
          self[:predicate_type] = RAPTOR_IDENTIFIER_TYPE_RESOURCE
          @predicate = uri
        end

        ##
        # @return [String]
        def predicate_as_string
          V1_4.raptor_statement_part_as_string(
            self[:predicate],
            self[:predicate_type],
            nil, nil)
        end

        ##
        # @return [RDF::Value]
        def object
          @object ||= case self[:object_type]
            when RAPTOR_IDENTIFIER_TYPE_RESOURCE
              RDF::URI.new(V1_4.raptor_uri_to_string(self[:object]))
            when RAPTOR_IDENTIFIER_TYPE_ANONYMOUS
              RDF::Node.new(self[:object].read_string)
            when RAPTOR_IDENTIFIER_TYPE_LITERAL
              case
                when self[:object_literal_language] && !self[:object_literal_language].null?
                  RDF::Literal.new(self[:object].read_string, :language => self[:object_literal_language].read_string)
                when self[:object_literal_datatype] && !self[:object_literal_datatype].null?
                  RDF::Literal.new(self[:object].read_string, :datatype => V1_4.raptor_uri_to_string(self[:object_literal_datatype]))
                else
                  RDF::Literal.new(self[:object].read_string)
              end
          end
        end

        ##
        # Set the object from an RDF::Value.
        # Value must be one of RDF::Resource or RDF::Literal.
        # @param  [RDF::Value] value
        def object=(value)
          @object = nil
          case value
          when RDF::Node
            self[:object] = @mp[:object] = ::FFI::MemoryPointer.from_string(value.id.to_s)
            self[:object_type] = RAPTOR_IDENTIFIER_TYPE_ANONYMOUS
          when RDF::URI
            self[:object] = @mp[:object] = @raptor_uri_list.push(V1_4.raptor_new_uri(value.to_s)).last
            self[:object_type] = RAPTOR_IDENTIFIER_TYPE_RESOURCE
          when RDF::Literal
            self[:object_type] = RAPTOR_IDENTIFIER_TYPE_LITERAL
            self[:object] = @mp[:object] = ::FFI::MemoryPointer.from_string(value.value)
            self[:object_literal_datatype] = if value.datatype
              @raptor_uri_list.push(V1_4.raptor_new_uri(value.datatype.to_s)).last
            else
              nil
            end
            self[:object_literal_language] = @mp[:object_literal_language] = if value.language?
              ::FFI::MemoryPointer.from_string(value.language.to_s)
            else
              nil
            end
          else
            raise ArgumentError, "object must be of type RDF::Node, RDF::URI or RDF::Literal"
          end
          @object = value
        end

        ##
        # @return [String]
        def object_as_string
          V1_4.raptor_statement_part_as_string(
            self[:object],
            self[:object_type],
            self[:object_literal_datatype],
            self[:object_literal_language])
        end

        ##
        # @return [Array(RDF::Resource, RDF::URI, RDF::Value)]
        def to_triple
          [subject, predicate, object]
        end

        ##
        # @return [Array(RDF::Resource, RDF::URI, RDF::Value, nil)]
        def to_quad
          [subject, predicate, object, nil]
        end

      end

      # @see http://librdf.org/raptor/api/tutorial-initialising-finishing.html
      attach_function :raptor_init, [], :void
      attach_function :raptor_finish, [], :void

      # @see http://librdf.org/raptor/api/raptor-section-locator.html
      define_pointer  :raptor_locator
      attach_function :raptor_locator_line, [raptor_locator], :int
      attach_function :raptor_locator_column, [raptor_locator], :int
      attach_function :raptor_locator_byte, [raptor_locator], :int

      # @see http://librdf.org/raptor/api/raptor-section-general.html
      attach_variable :raptor_version_major, :int
      attach_variable :raptor_version_minor, :int
      attach_variable :raptor_version_release, :int
      attach_variable :raptor_version_decimal, :int
      callback        :raptor_message_handler, [:pointer, raptor_locator, :string], :void

      # @see http://librdf.org/raptor/api/raptor-section-uri.html
      define_pointer  :raptor_uri
      attach_function :raptor_new_uri, [:string], raptor_uri
      attach_function :raptor_uri_as_string, [raptor_uri], :string
      attach_function :raptor_uri_to_string, [raptor_uri], :string
      attach_function :raptor_uri_print, [raptor_uri, :pointer], :void
      attach_function :raptor_free_uri, [raptor_uri], :void

      # @see http://librdf.org/raptor/api/raptor-section-triples.html
      define_pointer  :raptor_identifier
      define_pointer  :raptor_statement
      attach_function :raptor_statement_compare, [raptor_statement, raptor_statement], :int
      attach_function :raptor_print_statement, [raptor_statement, :pointer], :void
      attach_function :raptor_print_statement_as_ntriples, [:pointer, :pointer], :void
      attach_function :raptor_statement_part_as_string, [:pointer, :int, raptor_uri, :string], :string

      # @see http://librdf.org/raptor/api/raptor-section-parser.html
      callback :raptor_statement_handler, [:pointer, raptor_statement], :void
      define_pointer  :raptor_parser
      attach_function :raptor_new_parser, [:string], raptor_parser
      attach_function :raptor_set_error_handler, [raptor_parser, :pointer, :raptor_message_handler], :void
      attach_function :raptor_set_warning_handler, [raptor_parser, :pointer, :raptor_message_handler], :void
      attach_function :raptor_set_statement_handler, [raptor_parser, :pointer, :raptor_statement_handler], :void
      attach_function :raptor_parse_file, [raptor_parser, raptor_uri, raptor_uri], :int
      attach_function :raptor_parse_file_stream, [raptor_parser, :pointer, :string, raptor_uri], :int
      attach_function :raptor_parse_uri, [raptor_parser, raptor_uri, raptor_uri], :int
      attach_function :raptor_start_parse, [raptor_parser, :string], :int
      attach_function :raptor_parse_chunk, [raptor_parser, :string, :size_t, :int], :int
      attach_function :raptor_get_mime_type, [raptor_parser], :string
      attach_function :raptor_set_parser_strict, [raptor_parser, :int], :void
      attach_function :raptor_get_need_base_uri, [raptor_parser], :int
      attach_function :raptor_free_parser, [raptor_parser], :void

      # @see http://librdf.org/raptor/api/raptor-section-iostream.html
      define_pointer  :raptor_iostream
      callback        :raptor_iostream_init_func, [:pointer], :int
      callback        :raptor_iostream_finish_func, [:pointer], :void
      callback        :raptor_iostream_write_byte_func, [:pointer, :int], :int
      callback        :raptor_iostream_write_bytes_func, [:pointer, :pointer, :size_t, :size_t], :int
      callback        :raptor_iostream_write_end_func, [:pointer], :void
      callback        :raptor_iostream_read_bytes_func, [:pointer, :pointer, :size_t, :size_t], :int
      callback        :raptor_iostream_read_eof_func, [:pointer], :int
      attach_function :raptor_new_iostream_from_handler2, [:pointer, :pointer], raptor_iostream
      attach_function :raptor_free_iostream, [raptor_iostream], :void

      class IOStreamHandler < ::FFI::Struct
        layout :version, :int,
               :init, :raptor_iostream_init_func,
               :finish, :raptor_iostream_finish_func,
               :write_byte, :raptor_iostream_write_byte_func,
               :write_bytes, :raptor_iostream_write_bytes_func,
               :write_end, :raptor_iostream_write_end_func,
               :read_bytes, :raptor_iostream_read_bytes_func,
               :read_eof, :raptor_iostream_read_eof_func

        attr_accessor :rubyio

        def initialize(*args)
          super
          # Keep a ruby land reference to our procs so they don't
          # get snatched by GC.
          @procs = {}

          self[:version] = 2

          # @procs[:init] = self[:init] = Proc.new do |context|
          #   $stderr.puts("#{self.class}: init")
          # end
          # @procs[:finish] = self[:finish] = Proc.new do |context|
          #   $stderr.puts("#{self.class}: finish")
          # end
          @procs[:write_byte] = self[:write_byte] = Proc.new do |context, byte|
            begin
              @rubyio.putc(byte)
            rescue
              return 1
            end
            0
          end
          @procs[:write_bytes] = self[:write_bytes] = Proc.new do |context, data, size, nmemb|
            begin
              @rubyio.write(data.read_string(size * nmemb))
            rescue
              return 1
            end
            0
          end
          # @procs[:write_end] = self[:write_end] = Proc.new do |context|
          #   $stderr.puts("#{self.class}: write_end")
          # end
          # @procs[:read_bytes] = self[:read_bytes] = Proc.new do |context, data, size, nmemb|
          #   $stderr.puts("#{self.class}: read_bytes")
          # end
          # @procs[:read_eof] = self[:read_eof] = Proc.new do |context|
          #   $stderr.puts("#{self.class}: read_eof")
          # end
        end
      end

      # @see http://librdf.org/raptor/api/raptor-section-xml-namespace.html
      define_pointer  :raptor_namespace

      # @see http://librdf.org/raptor/api/raptor-section-serializer.html
      define_pointer  :raptor_serializer
      attach_function :raptor_new_serializer, [:string], raptor_serializer
      attach_function :raptor_free_serializer, [raptor_serializer], :void
      attach_function :raptor_serialize_start_to_iostream, [raptor_serializer, raptor_uri, raptor_iostream], :int
      attach_function :raptor_serialize_start_to_filename, [raptor_serializer, :string], :int
      attach_function :raptor_serialize_statement, [raptor_serializer, raptor_statement], :int
      attach_function :raptor_serialize_end, [raptor_serializer], :int
      attach_function :raptor_serializer_set_error_handler, [raptor_serializer, :pointer, :raptor_message_handler], :void
      attach_function :raptor_serializer_set_warning_handler, [raptor_serializer, :pointer, :raptor_message_handler], :void

      # Initialize the world
      # We do this exactly once and never release because we can't delegate
      # any memory management to the ruby GC.
      # Internally raptor_init/raptor_finish work with ref-counts.
      raptor_init

    end
  end
end

