module RDF::Raptor
  ##
  # Format base class.
  class Format < RDF::Format
    ##
    # @overload rapper_format
    #
    # @overload rapper_format(format)
    #   @param  [Symbol] format
    #
    # @return [void]
    def self.rapper_format(format = nil)
      unless format
        @rapper_format
      else
        @rapper_format = format
      end
    end
  end
end
