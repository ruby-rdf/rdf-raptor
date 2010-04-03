module RDF::Raptor
  ##
  # A command-line interface to Raptor's `rapper` utility.
  module CLI
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
        raise RDF::ReaderError.new("`rapper` binary not found") unless RDF::Raptor.available?

        format = self.class.format.rapper_format
        case input
          when RDF::URI, %r(^(file|http|https|ftp)://)
            @command = "#{RAPPER} -q -i #{format} -o ntriples #{input}"
            @command << " #{options[:base_uri]}" if options.has_key?(:base_uri)
            @rapper  = IO.popen(@command, 'rb')
          when File
            @command = "#{RAPPER} -q -i #{format} -o ntriples #{File.expand_path(input.path)}"
            @command << " #{options[:base_uri]}" if options.has_key?(:base_uri)
            @rapper  = IO.popen(@command, 'rb')
          else # IO, String
            @command = "#{RAPPER} -q -i #{format} -o ntriples file:///dev/stdin"
            @command << " #{options[:base_uri]}" if options.has_key?(:base_uri)
            @rapper  = IO.popen(@command, 'rb+')
            @rapper.write(input.respond_to?(:read) ? input.read : input.to_s)
            @rapper.close_write
        end
        @reader = RDF::NTriples::Reader.new(@rapper, options, &block)
      end

      protected

      ##
      # @return [Array]
      def read_triple
        @reader.read_triple
      end
    end

    ##
    # Writer implementation.
    module Writer
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
end
