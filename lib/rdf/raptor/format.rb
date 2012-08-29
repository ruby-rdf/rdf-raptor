module RDF
  module Raptor
    ##
    # RDF::Raptor::Format mixin.
    module Format
      ##
      # @overload rapper_format
      #
      # @overload rapper_format(format)
      #   @param  [Symbol] format
      #
      # @return [void]
      def rapper_format(format = nil)
        unless format
          @rapper_format
        else
          @rapper_format = format
        end
      end
      
      def detect(sample)
        parser_name = RDF::Raptor::FFI::V1.raptor_guess_parser_name(nil, nil, sample, sample.length, nil)
        parser_name == rapper_format.to_s
      end
    end # Format
  end
end