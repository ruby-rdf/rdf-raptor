require 'tempfile'
require 'ffi' # @see http://rubygems.org/gems/ffi

module RDF::Raptor
  ##
  # A foreign-function interface (FFI) to `libraptor`.
  #
  # @see http://librdf.org/raptor/api/
  # @see http://librdf.org/raptor/libraptor.html
  module FFI
    autoload :V1, 'rdf/raptor/ffi/v1'
    autoload :V2, 'rdf/raptor/ffi/v2'

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
      V2.raptor_version_string.freeze
    end

    ##
    # FFI reader implementation.
    class Reader < RDF::Reader
      include RDF::Util::Logger

      ##
      # Initializes the FFI reader instance.
      #
      # @param  [IO, File, RDF::URI, String] input
      # @param  [Hash{Symbol => Object}] options
      #   any additional options (see `RDF::Reader#initialize`)
      # @option options [String, #to_s]  :base_uri ("file:///dev/stdin")
      # @yield  [reader] `self`
      # @yieldparam  [RDF::Reader] reader
      # @yieldreturn [void] ignored
      def initialize(input = $stdin, **options, &block)
        @format = self.class.format.rapper_format
        @parser = V2::Parser.new(@format)
        @parser.error_handler = ERROR_HANDLER
        @parser.warning_handler = WARNING_HANDLER
        
        @parser.namespace_handler = Proc.new do |user_data, raptor_namespace|
          namespace = V2::Namespace.new(raptor_namespace)
          prefix(namespace.prefix, namespace.uri) if namespace.prefix_length > 0
        end

        super
      end

      ERROR_HANDLER = Proc.new do |user_data, locator, message|
        line = V2.raptor_locator_line(locator)
        log_error(message, lineno: line)
      end

      WARNING_HANDLER = Proc.new do |user_data, locator, message|
        line = V2.raptor_locator_line(locator)
        log_warn(message, lineno: line)
      end

      ##
      # The Raptor parser instance.
      #
      # @return [V2::Parser]
      attr_reader :parser

      ##
      # @yield [statement]
      # @yieldparam  [RDF::Statement] statement
      # @yieldreturn [void] ignored
      # @see   RDF::Reader#each_statement
      def each_statement(**options, &block)
        if block_given?
          if options[:raw]
            # this is up to an order of magnitude faster...
            parse(@input) do |parser, statement|
              block.call(V2::Statement.new(statement, self))
            end
          else
            parse(@input) do |parser, statement|
              block.call(V2::Statement.new(statement, self).to_rdf)
            end
          end

          if validate? && log_statistics[:error]
            raise RDF::ReaderError, "Errors found during processing"
          end
        end
        enum_for(:each_statement, **options)
      end
      alias_method :each, :each_statement

      ##
      # @yield [triple]
      # @yieldparam  [Array(RDF::Resource, RDF::URI, RDF::Term)] triple
      # @yieldreturn [void] ignored
      # @see   RDF::Reader#each_triple
      def each_triple(&block)
        if block_given?
          each_statement do |statement|
            block.call(*statement.to_triple)
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
      # @yieldreturn [void] ignored
      # @return [void]
      def parse(input, &block)
        @parser.parse(input, **@options, &block)
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
      include RDF::Util::Logger

      ##
      # Initializes the FFI writer instance.
      #
      # @param  [IO, File] output
      # @param  [Hash{Symbol => Object}] options
      #   any additional options (see `RDF::Writer#initialize`)
      # @yield  [writer] `self`
      # @yieldparam  [RDF::Writer] writer
      # @yieldreturn [void] ignored
      def initialize(output = $stdout, **options, &block)
        @format = self.class.format.rapper_format
        @serializer = V2::Serializer.new(@format)
        @serializer.error_handler   = ERROR_HANDLER
        @serializer.warning_handler = WARNING_HANDLER
        @serializer.start_to(output, **options)
        super
      end

      ERROR_HANDLER = Proc.new do |user_data, locator, message|
        log_error(message)
      end

      WARNING_HANDLER = Proc.new do |user_data, locator, message|
        log_warn(message)
      end

      ##
      # The Raptor serializer instance.
      #
      # @return [V2::Serializer]
      attr_reader :serializer

      def self.serialize(value)
        output = StringIO.new
        writer = new(output)
        case value
        when nil then nil
        when FalseClass then value.to_s
        when RDF::Statement
          writer.write_triple(statement.subject, statement.predicate, statement.object)
        when RDF::Term
          writer.write_term(value)
        else
          raise ArgumentError, "expected an RDF::Statement or RDF::Term, but got #{value.inspect}"
        end

        output.to_s
      end

      ##
      # @param  [RDF::Resource] subject
      # @param  [RDF::URI]      predicate
      # @param  [RDF::Term]     object
      # @return [void]
      # @see    RDF::Writer#write_triple
      def write_triple(subject, predicate, object)
        @serializer.serialize_triple(subject, predicate, object)
      end

      def write_term(value)
        raise NotImplementedError
      end

      ##
      # @return [void]
      # @see    RDF::Writer#write_prologue
      def write_prologue
        @serializer.prefix(self.prefixes)
        super
      end

      ##
      # @return [void]
      # @see    RDF::Writer#write_epilogue
      def write_epilogue
        @serializer.finish
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
