module RDF::Raptor
  ##
  # Writer base class.
  class Writer < RDF::Writer
    ##
    # @param  [IO, File]               output
    # @param  [Hash{Symbol => Object}] options
    # @yield  [writer]
    # @yieldparam [RDF::Writer] writer
    def initialize(output = $stdout, options = {}, &block)
      raise RDF::WriterError.new("`rapper` binary not found") unless RDF::Raptor.available?

      format = self.class.format.rapper_format
      case output
        when File, IO
          @command = "#{RAPPER} -q -i ntriples -o #{format} file:///dev/stdin"
          @command << " #{options[:base_uri]}" if options.has_key?(:base_uri)
          @rapper  = IO.popen(@command, 'rb+')
        else
          raise ArgumentError.new("unsupported output type: #{output.inspect}")
      end
      @writer = RDF::NTriples::Writer.new(@rapper, options)
      super(output, options, &block)
    end

    protected

    ##
    # @return [void]
    def write_prologue
      super
    end

    ##
    # @param  [RDF::Resource] subject
    # @param  [RDF::URI]      predicate
    # @param  [RDF::Value]    object
    # @return [void]
    def write_triple(subject, predicate, object)
      @writer.write_triple(subject, predicate, object)
    end

    ##
    # @return [void]
    def write_epilogue
      @rapper.close_write
      begin
        chunk_size = @options[:chunk_size] || 4096 # bytes
        loop do
          @output.write(@rapper.readpartial(chunk_size))
        end
      rescue EOFError => e
        # we're all done
      end
    end
  end
end
