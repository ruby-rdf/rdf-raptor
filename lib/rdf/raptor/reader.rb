module RDF::Raptor
  ##
  # Reader base class.
  class Reader < RDF::Reader
    ##
    # @param  [IO, File, RDF::URI, String] input
    # @param  [Hash{Symbol => Object}]     options
    # @yield  [reader]
    # @yieldparam [RDF::Reader] reader
    def initialize(input = $stdin, options = {}, &block)
      raise RDF::ReaderError.new("`rapper` binary not found") unless RDF::Raptor.available?

      format = self.class.format.rapper_format
      case input
        when RDF::URI, %r(^(file|http|https|ftp)://)
          @command = "#{RAPPER} -q -i #{format} -o ntriples #{input}"
          @rapper  = IO.popen(@command, 'rb')
        when File
          @command = "#{RAPPER} -q -i #{format} -o ntriples #{File.expand_path(input.path)}"
          @rapper  = IO.popen(@command, 'rb')
        else # IO, String
          @command = "#{RAPPER} -q -i #{format} -o ntriples file:///dev/stdin"
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
end
