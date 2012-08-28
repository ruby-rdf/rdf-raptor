module RDF::Raptor::FFI::V2
  ##
  # This class provides the functionality of turning syntaxes into RDF
  # triples - RDF parsing.
  #
  # @see http://librdf.org/raptor/api-1.4/raptor-section-parser.html
  class Parser < ::FFI::ManagedStruct
    include RDF::Raptor::FFI
    layout :world, :pointer # the actual layout is private

    # The default base URI
    #BASE_URI    = 'file:///dev/stdin'
    BASE_URI = V2::URI.new('file:///dev/stdin')

    # The maximum chunk size for `#parse_stream`
    BUFFER_SIZE = 64 * 1024

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
        when Symbol       then V2.raptor_new_parser(V2.world, ptr_or_name.to_s)
        when String       then V2.raptor_new_parser(V2.world, ptr_or_name)
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
      V2.raptor_free_parser(ptr)
    end

    ##
    # @param  [Proc] handler
    # @return [void]
    def error_handler=(handler)
      #V2.raptor_set_error_handler(self, self, handler)
    end

    ##
    # @param  [Proc] handler
    # @return [void]
    def warning_handler=(handler)
      #V2.raptor_set_warning_handler(self, self, handler)
    end

    ##
    # @param  [Proc] handler
    # @return [void]
    def statement_handler=(handler)
      V2.raptor_parser_set_statement_handler(self, self, handler)
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

      data_url = V2::URI.new((url.respond_to?(:to_uri) ? url.to_uri : url).to_s)
      base_uri = options[:base_uri].to_s.empty? ? nil : V2::URI.new(options[:base_uri].to_s)

      result = V2.raptor_parser_parse_uri(self, data_url, base_uri)
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

      data_url = V2::URI.new("file://#{File.expand_path(file.path)}")
      base_uri = options[:base_uri].to_s.empty? ? nil : V2::URI.new(options[:base_uri].to_s)

      result = V2.raptor_parser_parse_file(self, data_url, base_uri)
      # TODO: error handling if result.nonzero?
    end

    ##
    # @param  [IO, StringIO, #readpartial] stream
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
      self.statement_handler = block if block_given?

      begin
        parse_start!((options[:base_uri] || BASE_URI).to_s)
        loop do
          parse_chunk(stream.sysread(BUFFER_SIZE))
        end
      rescue EOFError => e
        parse_end!
      end
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

      parse_start!((options[:base_uri] || BASE_URI).to_s)
      parse_chunk(buffer.to_str)
      parse_end!
    end

    ##
    # @private
    # @param  [String] base_uri
    # @return [void]
    def parse_start!(base_uri = BASE_URI)
      result = V2.raptor_parser_parse_start(self, base_uri)
      # TODO: error handling if result.nonzero?
    end

    ##
    # @private
    # @param  [String] buffer
    #   the input chunk to parse
    # @return [void]
    def parse_chunk(buffer)
      result = V2.raptor_parser_parse_chunk(self, buffer, buffer.bytesize, 0)
      # TODO: error handling if result.nonzero?
    end

    ##
    # @private
    # @return [void]
    def parse_end!
      result = V2.raptor_parser_parse_chunk(self, NULL, 0, 1) # EOF
    end
  end # Parser
end # RDF::Raptor::FFI::V2
