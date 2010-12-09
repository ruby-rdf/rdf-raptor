require 'tempfile'

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
    module_function :version

    ##
    # CLI reader implementation.
    class Reader < RDF::Reader
      ##
      # Initializes the CLI reader instance.
      #
      # @param  [IO, File, RDF::URI, String] input
      # @param  [Hash{Symbol => Object}] options
      #   any additional options (see `RDF::Reader#initialize`)
      # @option options [String, #to_s] :base_uri ("file:///dev/stdin")
      # @yield  [reader] `self`
      # @yieldparam  [RDF::Reader] reader
      # @yieldreturn [void] ignored
      def initialize(input = $stdin, options = {}, &block)
        raise RDF::ReaderError, "`rapper` binary not found" unless RDF::Raptor.available?

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
              # process to feed `rapper`
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

        @options = options
        @reader = RDF::NTriples::Reader.new(@rapper, @options).extend(Extensions)

        if block_given?
          case block.arity
            when 0 then instance_eval(&block)
            else block.call(self)
          end
        end
      end

    protected

      ##
      # @return [Array(RDF::Resource, RDF::URI, RDF::Term)]
      # @see    RDF::Reader#read_triple
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

      ##
      # Extensions for `RDF::NTriples::Reader`.
      module Extensions
        NODEID = RDF::NTriples::Reader::NODEID
        GENID  = /^genid\d+$/

        ##
        # Generates fresh random identifiers for Raptor's `_:genid[0-9]+`
        # blank nodes, while preserving any user-specified blank node
        # identifiers verbatim.
        #
        # @private
        # @see RDF::NTriples::Reader#read_node
        # @see https://github.com/bendiken/rdf-raptor/issues/#issue/9
        def read_node
          if node_id = match(NODEID)
            @nodes ||= {}
            @nodes[node_id] ||= RDF::Node.new(GENID === node_id ? nil : node_id)
          end
        end
      end
    end # Reader

    ##
    # CLI writer implementation.
    class Writer < RDF::Writer
      ##
      # Initializes the CLI writer instance.
      #
      # @param  [IO, File]               output
      # @param  [Hash{Symbol => Object}] options
      #   any additional options (see `RDF::Writer#initialize`)
      # @yield  [writer] `self`
      # @yieldparam  [RDF::Writer] writer
      # @yieldreturn [void]
      def initialize(output = $stdout, options = {}, &block)
        raise RDF::WriterError, "`rapper` binary not found" unless RDF::Raptor.available?

        format = self.class.format.rapper_format
        case output
          when File, IO, StringIO, Tempfile
            @command = "#{RAPPER} -q -i turtle -o #{format} file:///dev/stdin"
            @command << " '#{options[:base_uri]}'" if options.has_key?(:base_uri)
            @rapper  = IO.popen(@command, 'rb+')
          else
            raise ArgumentError, "unsupported output type: #{output.inspect}"
        end
        @writer = RDF::NTriples::Writer.new(@rapper, options)
        super(output, options, &block)
      end

    protected

      ##
      # @return [void]
      # @see    RDF::Writer#write_prologue
      def write_prologue
        super
      end

      ##
      # @param  [RDF::Resource] subject
      # @param  [RDF::URI]      predicate
      # @param  [RDF::Term]     object
      # @return [void]
      # @see    RDF::Writer#write_triple
      def write_triple(subject, predicate, object)
        output_transit(false)
        @writer.write_triple(subject, predicate, object)
        output_transit(false)
      end

      ##
      # @return [void]
      # @see    RDF::Writer#write_epilogue
      def write_epilogue
        @rapper.close_write unless @rapper.closed?
        output_transit(true)
      end

      ##
      # Feeds any available `rapper` output to the destination.
      #
      # @param  [Boolean] may_block
      # @return [void]
      def output_transit(may_block)
        unless @rapper.closed?
          chunk_size = @options[:chunk_size] || 4096 # bytes
          begin
            loop do
              @output.write(may_block ? @rapper.readpartial(chunk_size) : @rapper.read_nonblock(chunk_size))
            end
          rescue EOFError => e
            @rapper.close
          rescue Errno::EAGAIN, Errno::EINTR
            # eat
          end
        end
      end
    end # Writer
  end # CLI
end # RDF::Raptor
