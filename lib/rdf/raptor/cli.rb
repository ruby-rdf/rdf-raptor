module RDF::Raptor
  ##
  # A command-line interface to Raptor's `rapper` utility.
  module CLI

    ENGINE = :cli

    ##
    # Returns the installed `rapper` version number, or `nil` if `rapper` is
    # not available.
    #
    # @example
    #   RDF::Raptor.version  #=> "1.4.21"
    #
    # @return [String]
    def version
      if `#{RAPPER} --version 2>/dev/null` =~ /^(\d+)\.(\d+)\.(\d+)/
        [$1, $2, $3].join('.')
      end
    end

    ##
    # Reader implementation.
    class Reader < RDF::Reader
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
            @command = "#{RAPPER} -q -i #{format} -o ntriples '#{input}'"
            @command << " '#{options[:base_uri]}'" if options.has_key?(:base_uri)
            @rapper  = IO.popen(@command, 'rb')
          when File, Tempfile
            @command = "#{RAPPER} -q -i #{format} -o ntriples '#{File.expand_path(input.path)}'"
            @command << " '#{options[:base_uri]}'" if options.has_key?(:base_uri)
            @rapper  = IO.popen(@command, 'rb')
          else # IO, String
            @command = "#{RAPPER} -q -i #{format} -o ntriples file:///dev/stdin"
            @command << " '#{options[:base_uri]}'" if options.has_key?(:base_uri)
            @rapper  = IO.popen(@command, 'rb+')
            pid = fork do
              # process to feed rapper
              begin
                @rapper.close_read
                if input.respond_to?(:read)
                  buf = String.new
                  while input.read(8192, buf)
                    @rapper.write(buf)
                  end
                else
                  @rapper.write(input.to_s)
                end
                @rapper.close_write
              ensure
                Process.exit
              end
            end
            Process.detach(pid)
            @rapper.close_write
        end
        @reader = RDF::NTriples::Reader.new(@rapper, options, &block)
      end

      protected

      ##
      # @return [Array]
      def read_triple
        raise EOFError if @rapper.closed?
        begin
          triple = @reader.read_triple
        rescue EOFError
          @rapper.close
          raise
        end
        triple
      end

    end

    ##
    # Writer implementation.
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
          when File, IO, StringIO, Tempfile
            @command = "#{RAPPER} -q -i turtle -o #{format} file:///dev/stdin"
            @command << " '#{options[:base_uri]}'" if options.has_key?(:base_uri)
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
        output_transit(false)
        @writer.write_triple(subject, predicate, object)
        output_transit(false)
      end

      ##
      # @return [void]
      def write_epilogue
        @rapper.close_write unless @rapper.closed?
        output_transit(true)
      end

      ##
      # Feed any available rapper output to the destination.
      # @return [void]
      def output_transit(block)
        unless @rapper.closed?
          chunk_size = @options[:chunk_size] || 4096 # bytes
          begin
            loop do
              @output.write(block ? @rapper.readpartial(chunk_size) : @rapper.read_nonblock(chunk_size))
            end
          rescue EOFError => e
            @rapper.close
          rescue Errno::EAGAIN, Errno::EINTR
            # eat
          end
        end
      end

    end
  end
end
