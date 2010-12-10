require 'tempfile'
require 'ffi' # @see http://rubygems.org/gems/ffi

module RDF::Raptor
  ##
  # A foreign-function interface (FFI) to `libraptor`.
  #
  # @see http://librdf.org/raptor/api/
  # @see http://librdf.org/raptor/libraptor.html
  module FFI
    autoload :V1_4, 'rdf/raptor/ffi/v1_4'

    ENGINE = :ffi

    ##
    # Returns the installed `libraptor` version number, or `nil` if
    # `libraptor` is not available.
    #
    # @example
    #   RDF::Raptor.version  #=> "1.4.21"
    #
    # @return [String] an "x.y.z" version string
    def version
      [V1_4.raptor_version_major,
       V1_4.raptor_version_minor,
       V1_4.raptor_version_release].join('.').freeze
    end
    module_function :version

    ##
    # FFI reader implementation.
    class Reader < RDF::Reader
      ##
      # @param  [IO, File, RDF::URI, String] input
      # @param  [Hash{Symbol => Object}]     options
      # @option (options) [String, #to_s]    :base_uri ("file:///dev/stdin")
      # @yield  [reader]
      # @yieldparam [RDF::Reader] reader
      def initialize(input = $stdin, options = {}, &block)
        @format = self.class.format.rapper_format
        @parser = V1_4::Parser.new(@format)
        @parser.error_handler   = ERROR_HANDLER
        @parser.warning_handler = WARNING_HANDLER
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
      # @yieldparam  [RDF::Statement] statement
      # @yieldreturn [void] ignored
      # @see   RDF::Reader#each_statement
      def each_statement(options = {}, &block)
        if block_given?
          if options[:raw]
            # this is up to an order of magnitude faster...
            parse(@input) do |parser, statement|
              block.call(V1_4::Statement.new(statement, self))
            end
          else
            parse(@input) do |parser, statement|
              block.call(V1_4::Statement.new(statement, self).to_statement)
            end
          end
        end
        enum_for(:each_statement, options)
      end
      alias_method :each, :each_statement

      ##
      # @yield [triple]
      # @yieldparam  [Array(RDF::Resource, RDF::URI, RDF::Term)] triple
      # @yieldreturn [void] ignored
      # @see   RDF::Reader#each_triple
      def each_triple(&block)
        if block_given?
          parse(@input) do |parser, statement|
            block.call(V1_4::Statement.new(statement, self).to_triple)
          end
        end
        enum_for(:each_triple)
      end

      ##
      # @private
      # @param  [RDF::URI, File, Tempfile, IO, StringIO] input
      #   the input stream
      # @yield  [parser, statement]
      #   each statement in the input stream
      # @yieldparam  [FFI::Pointer] parser
      # @yieldparam  [FFI::Pointer] statement
      # @return [void]
      def parse(input, &block)
        @parser.statement_handler = block
        case input
          when RDF::URI, %r(^(file|http|https|ftp)://)
            begin
              data_url = V1_4.raptor_new_uri(input.to_s)
              base_uri = @options[:base_uri].to_s.empty? ? nil : V1_4.raptor_new_uri(@options[:base_uri].to_s)
              unless (result = V1_4.raptor_parse_uri(@parser, data_url, base_uri)).zero?
                # TODO: error handling
              end
            ensure
              V1_4.raptor_free_uri(base_uri) if base_uri
              V1_4.raptor_free_uri(data_url) if data_url
            end

          when File, Tempfile
            begin
              data_url = V1_4.raptor_new_uri("file://#{File.expand_path(input.path)}")
              base_uri = @options[:base_uri].to_s.empty? ? nil : V1_4.raptor_new_uri(@options[:base_uri].to_s)
              unless (result = V1_4.raptor_parse_file(@parser, data_url, base_uri)).zero?
                # TODO: error handling
              end
            ensure
              V1_4.raptor_free_uri(base_uri) if base_uri
              V1_4.raptor_free_uri(data_url) if data_url
            end

          else # IO, String
            base_uri = (@options[:base_uri] || 'file:///dev/stdin').to_s
            unless (result = V1_4.raptor_start_parse(@parser, base_uri)).zero?
              # TODO: error handling
            end
            # TODO: read in chunks instead of everything in one go:
            unless (result = V1_4.raptor_parse_chunk(@parser, buffer = input.read, buffer.size, 0)).zero?
              # TODO: error handling
            end
            V1_4.raptor_parse_chunk(@parser, nil, 0, 1) # EOF
        end
      end

      GENID = /^genid\d+$/

      ##
      # @param  [String] uri_str
      # @return [RDF::URI]
      def create_uri(uri_str)
        RDF::URI.intern(uri_str)
      end

      ##
      # @param  [String] node_id
      # @return [RDF::Node]
      def create_node(node_id)
        @nodes ||= {}
        @nodes[node_id] ||= RDF::Node.new(GENID === node_id ? nil : node_id)
      end
    end # Reader

    ##
    # FFI writer implementation.
    class Writer < RDF::Writer
      ERROR_HANDLER = Proc.new do |user_data, locator, message|
        raise RDF::WriterError, message
      end

      WARNING_HANDLER = Proc.new do |user_data, locator, message|
        # $stderr.puts "warning"
      end

      ##
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
      # @param  [RDF::Term]     object
      # @return [void]
      # @see    RDF::Writer#write_triple
      def write_triple(subject, predicate, object)
        raptor_statement = V1_4::Statement.new
        raptor_statement.subject   = subject
        raptor_statement.predicate = predicate
        raptor_statement.object    = object
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
      # @see    RDF::Writer#write_epilogue
      def write_epilogue
        unless V1_4.raptor_serialize_end(@serializer).zero?
          raise RDF::WriterError, "raptor_serialize_end failed"
        end
        super
      end
    end # Writer

    ##
    # @private
    module LibC
      extend ::FFI::Library
      ffi_lib ::FFI::Library::LIBC
      attach_function :strlen, [:pointer], :size_t
    end # LibC
  end # FFI
end # RDF::Raptor
