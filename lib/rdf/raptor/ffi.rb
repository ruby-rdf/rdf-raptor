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
        @parser = Proc.new do |user_data, statement|
          triple = V1_4::Statement.new(statement).to_triple
          block.call(triple)
        end

        V1_4.with_world do |world|
          V1_4.with_parser(:name => @format) do |parser|
            V1_4.raptor_set_statement_handler(parser, nil, @parser)
            case @input
              when RDF::URI, %r(^(file|http|https|ftp)://)
                begin
                  data_url = V1_4.raptor_new_uri(@input.to_s)
                  base_uri = @options.has_key?(:base_uri) ? V1_4.raptor_new_uri(@options[:base_uri].to_s) : nil
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
                  base_uri = @options.has_key?(:base_uri) ? V1_4.raptor_new_uri(@options[:base_uri].to_s) : nil
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

        @parser = nil
      end

      alias_method :each, :each_statement
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
      # @option (options) [Boolean] :init (true)
      # @yield  [world]
      # @yieldparam [FFI::Pointer] world
      # @return [void]
      def self.with_world(options = {}, &block)
        options = {:init => true}.merge(options)
        begin
          raptor_init if options[:init]
          raptor_world_open(world = raptor_new_world)
          block.call(world)
        ensure
          raptor_free_world(world) if world
          raptor_finish if options[:init]
        end
      end

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
               :object_literal_language, :string

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
                when self[:object_literal_language]
                  RDF::Literal.new(self[:object].read_string, :language => self[:object_literal_language])
                when self[:object_literal_datatype] && !self[:object_literal_datatype].null?
                  RDF::Literal.new(self[:object].read_string, :datatype => V1_4.raptor_uri_to_string(self[:object_literal_datatype]))
                else
                  RDF::Literal.new(self[:object].read_string)
              end
          end
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

      # @see http://librdf.org/raptor/api/raptor-section-world.html
      define_pointer  :raptor_world
      attach_function :raptor_new_world, [], raptor_world
      attach_function :raptor_world_open, [raptor_world], :int
      attach_function :raptor_free_world, [raptor_world], :void

      # @see http://librdf.org/raptor/api/raptor-section-uri.html
      define_pointer  :raptor_uri
      attach_function :raptor_new_uri, [:string], raptor_uri
      attach_function :raptor_uri_as_string, [raptor_uri], :string
      attach_function :raptor_uri_to_string, [raptor_uri], :string
      attach_function :raptor_uri_print, [raptor_uri, :pointer], :void
      attach_function :raptor_free_uri, [raptor_uri], :void

      # @see http://librdf.org/raptor/api/raptor-section-triples.html
      define_pointer  :raptor_statement
      attach_function :raptor_statement_compare, [raptor_statement, raptor_statement], :int
      attach_function :raptor_print_statement, [raptor_statement, :pointer], :void
      attach_function :raptor_print_statement_as_ntriples, [:pointer, :pointer], :void
      attach_function :raptor_statement_part_as_string, [:pointer, :int, raptor_uri, :string], :string

      # @see http://librdf.org/raptor/api/raptor-section-parser.html
      callback :raptor_statement_handler, [:pointer, raptor_statement], :void
      define_pointer  :raptor_parser
      attach_function :raptor_new_parser, [:string], raptor_parser
      attach_function :raptor_set_statement_handler, [raptor_parser, :pointer, :raptor_statement_handler], :void
      attach_function :raptor_parse_file, [raptor_parser, raptor_uri, raptor_uri], :int
      attach_function :raptor_parse_file_stream, [raptor_parser, :pointer, :string, raptor_uri], :int
      attach_function :raptor_parse_uri, [raptor_parser, raptor_uri, raptor_uri], :int
      attach_function :raptor_start_parse, [raptor_parser, :string], :int
      attach_function :raptor_parse_chunk, [raptor_parser, :string, :size_t, :int], :int
      attach_function :raptor_get_mime_type, [raptor_parser], :string
      attach_function :raptor_set_parser_strict, [raptor_parser, :int], :void
      attach_function :raptor_get_need_base_uri, [raptor_parser], :int
      attach_function :raptor_parser_get_world, [raptor_parser], raptor_world
      attach_function :raptor_free_parser, [raptor_parser], :void
    end
  end
end
