module RDF::Raptor
  ##
  # Reader base class.
  class Reader < RDF::Reader
    ##
    def initialize(input = $stdin, options = {}, &block)
      format = self.class.format.rapper_format
      case input
        when RDF::URI, %r(^(file|http|https|ftp)://)
          @command = "rapper -q -i #{format} -o ntriples #{input}"
          @rapper  = IO.popen(@command, 'rb')
        when File
          @command = "rapper -q -i #{format} -o ntriples #{File.expand_path(input.path)}"
          @rapper  = IO.popen(@command, 'rb')
        else # IO, String
          @command = "rapper -q -i #{format} -o ntriples file:///dev/stdin"
          @rapper  = IO.popen(@command, 'rb+')
          @rapper.write(input.respond_to?(:read) ? input.read : input.to_s)
          @rapper.close_write
      end
      @reader = RDF::NTriples::Reader.new(@rapper, options, &block)
    end

    ##
    # @return [Array]
    def read_triple
      @reader.read_triple
    end
  end
end
