module RDF::Raptor::FFI::V1
  ##
  # This class provides the functionality of turning syntaxes into RDF
  # triples - RDF parsing.
  #
  # @see http://librdf.org/raptor/api-1.4/raptor-section-parser.html
  class Parser < ::FFI::ManagedStruct
    include RDF::Raptor::FFI
    layout :world, :pointer # the actual layout is private

    ##
    # @overload initialize(ptr)
    #   @param  [FFI::Pointer] ptr
    #
    # @overload initialize(name)
    #   @param  [Symbol, String] name
    #
    def initialize(ptr_or_name)
      ptr = case ptr_or_name
        when FFI::Pointer then ptr_or_name
        when Symbol       then V1.raptor_new_parser(ptr_or_name.to_s)
        when String       then V1.raptor_new_parser(ptr_or_name)
        else nil
      end
      raise ArgumentError, "invalid argument: #{ptr_or_name.inspect}" if ptr.nil? || ptr.null?
      super(ptr)
    end

    ##
    # Releases `libraptor` memory associated with this structure.
    #
    # @param  [FFI::Pointer] ptr
    # @return [void]
    def self.release(ptr)
      V1.raptor_free_parser(ptr)
    end

    ##
    # @param  [Proc] handler
    # @return [void]
    def error_handler=(handler)
      V1.raptor_set_error_handler(self, self, handler)
    end

    ##
    # @param  [Proc] handler
    # @return [void]
    def warning_handler=(handler)
      V1.raptor_set_warning_handler(self, self, handler)
    end

    ##
    # @param  [Proc] handler
    # @return [void]
    def statement_handler=(handler)
      V1.raptor_set_statement_handler(self, self, handler)
    end

    ##
    # @param  [Object] input
    #   the input to parse
    # @param  [Hash{Symbol => Object}] options
    #   any additional options for parsing
    # @option options [String, #to_s] :base_uri (nil)
    #   the base URI to use when resolving relative URIs
    # @yield  [parser, statement]
    #   each statement in the input
    # @yieldparam  [FFI::Pointer] parser
    # @yieldparam  [FFI::Pointer] statement
    # @yieldreturn [void] ignored
    # @return [void]
    def parse(input, options = {}, &block)
      case input
        when RDF::URI, %r(^(file|https|http|ftp)://)
          parse_url(input, options, &block)
        when File, Tempfile
          parse_file(input, options, &block)
        when IO, StringIO
          parse_stream(input, options, &block)
        when String
          parse_buffer(input, options, &block)
        else
          raise ArgumentError, "don't know how to parse #{input.inspect}"
      end
    end

    ##
    # @param  [RDF::URI, String, #to_s] url
    #   the input URL to parse
    # @param  [Hash{Symbol => Object}] options
    #   any additional options for parsing (see {#parse})
    # @yield  [parser, statement]
    #   each statement in the input
    # @yieldparam  [FFI::Pointer] parser
    # @yieldparam  [FFI::Pointer] statement
    # @yieldreturn [void] ignored
    # @return [void]
    def parse_url(url, options = {}, &block)
      self.statement_handler = block if block_given?

      data_url = V1::URI.new((url.respond_to?(:to_uri) ? url.to_uri : url).to_s)
      base_uri = options[:base_uri].to_s.empty? ? nil : V1::URI.new(options[:base_uri].to_s)

      result = V1.raptor_parse_uri(self, data_url, base_uri)
      # TODO: error handling if result.nonzero?
    end
    alias_method :parse_uri, :parse_url

    ##
    # @param  [File, Tempfile, #path] file
    #   the input file to parse
    # @param  [Hash{Symbol => Object}] options
    #   any additional options for parsing (see {#parse})
    # @yield  [parser, statement]
    #   each statement in the input
    # @yieldparam  [FFI::Pointer] parser
    # @yieldparam  [FFI::Pointer] statement
    # @yieldreturn [void] ignored
    # @return [void]
    def parse_file(file, options = {}, &block)
      self.statement_handler = block if block_given?

      data_url = V1::URI.new("file://#{File.expand_path(file.path)}")
      base_uri = options[:base_uri].to_s.empty? ? nil : V1::URI.new(options[:base_uri].to_s)

      result = V1.raptor_parse_file(self, data_url, base_uri)
      # TODO: error handling if result.nonzero?
    end

    ##
    # @param  [IO, StringIO, #read] stream
    #   the input stream to parse
    # @param  [Hash{Symbol => Object}] options
    #   any additional options for parsing (see {#parse})
    # @yield  [parser, statement]
    #   each statement in the input
    # @yieldparam  [FFI::Pointer] parser
    # @yieldparam  [FFI::Pointer] statement
    # @yieldreturn [void] ignored
    # @return [void]
    def parse_stream(stream, options = {}, &block)
      # TODO: read in chunks instead of everything in one go
      parse_buffer(stream.read, options, &block)
    end

    ##
    # @param  [String, #to_str] buffer
    #   the input buffer to parse
    # @param  [Hash{Symbol => Object}] options
    #   any additional options for parsing (see {#parse})
    # @yield  [parser, statement]
    #   each statement in the input
    # @yieldparam  [FFI::Pointer] parser
    # @yieldparam  [FFI::Pointer] statement
    # @yieldreturn [void] ignored
    # @return [void]
    def parse_buffer(buffer, options = {}, &block)
      self.statement_handler = block if block_given?

      buffer = buffer.to_str
      base_uri = (options[:base_uri] || 'file:///dev/stdin').to_s

      result = V1.raptor_start_parse(self, base_uri)
      # TODO: error handling if result.nonzero?
      result = V1.raptor_parse_chunk(self, buffer, buffer.bytesize, 0)
      # TODO: error handling if result.nonzero?
      V1.raptor_parse_chunk(self, nil, 0, 1) # EOF
    end
  end # Parser
end # RDF::Raptor::FFI::V1
