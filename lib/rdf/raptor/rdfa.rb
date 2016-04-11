module RDF::Raptor
  ##
  # RDFa support.
  #
  # @example Requiring the `RDF::Raptor` module
  #   require 'rdf/raptor'
  #
  # @example Extracting RDF statements from an XHTML+RDFa file
  #   RDF::Reader.open("input.html") do |reader|
  #     reader.each_statement do |statement|
  #       puts statement.inspect
  #     end
  #   end
  #
  # @see http://rdfa.info/
  module RDFa
    ##
    # RDFa format specification.
    #
    # @example Obtaining an RDFa format class
    #   RDF::Format.for(:rdfa)         #=> RDF::Raptor::RDFa::Format
    #   RDF::Format.for("input.html")
    #   RDF::Format.for(file_name:      "input.html")
    #   RDF::Format.for(file_extension: "html")
    #   RDF::Format.for(content_type:   "application/xhtml+xml")
    #
    class Format < RDF::Format
      extend RDF::Raptor::Format
      
      content_type     'text/html',
        aliases: %w(application/xhtml+xml image/svg+xml),
        extensions: [:html, :xhtml, :svg]
      content_encoding 'utf-8'
      rapper_format    :rdfa

      reader { RDF::Raptor::RDFa::Reader }

      ##
      # Sample detection to see if it matches RDFa (not RDF/XML or Microdata)
      #
      # Use a text sample to detect the format of an input file. Sub-classes implement
      # a matcher sufficient to detect probably format matches, including disambiguating
      # between other similar formats.
      #
      # @param [String] sample Beginning several bytes (~ 1K) of input.
      # @return [Boolean]
      def self.detect(sample)
        (sample.match(/<[^>]*(about|resource|prefix|typeof|property|vocab)\s*="[^>]*>/m) ||
         sample.match(/<[^>]*DOCTYPE\s+html[^>]*>.*xmlns:/im)
        ) && !sample.match(/<(\w+:)?(RDF)/)
      end

      def self.symbols
        [:rdfa, :lite, :html, :xhtml, :svg]
      end
    end # Format

    ##
    # RDFa extractor.
    #
    # @example Obtaining an RDFa reader class
    #   RDF::Reader.for(:rdfa)         #=> RDF::Raptor::RDFa::Reader
    #   RDF::Reader.for("input.html")
    #   RDF::Reader.for(file_name:      "input.html")
    #   RDF::Reader.for(file_extension: "html")
    #   RDF::Reader.for(content_type:   "application/xhtml+xml")
    #
    # @example Extracting RDF statements from an XHTML+RDFa file
    #   RDF::Reader.open("input.html") do |reader|
    #     reader.each_statement do |statement|
    #       puts statement.inspect
    #     end
    #   end
    #
    class Reader < RDF::Raptor::Reader
      format RDF::Raptor::RDFa::Format
    end # Reader
  end # RDFa
end # RDF::Raptor
