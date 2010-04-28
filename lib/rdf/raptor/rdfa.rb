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
    #   RDF::Format.for(:file_name      => "input.html")
    #   RDF::Format.for(:file_extension => "html")
    #   RDF::Format.for(:content_type   => "application/xhtml+xml")
    #
    class Format < RDF::Raptor::Format
      content_type     'application/xhtml+xml', :extension => :html
      content_encoding 'utf-8'
      rapper_format    :rdfa

      reader { RDF::Raptor::RDFa::Reader }
    end

    ##
    # RDFa extractor.
    #
    # @example Obtaining an RDFa reader class
    #   RDF::Reader.for(:rdfa)         #=> RDF::Raptor::RDFa::Reader
    #   RDF::Reader.for("input.html")
    #   RDF::Reader.for(:file_name      => "input.html")
    #   RDF::Reader.for(:file_extension => "html")
    #   RDF::Reader.for(:content_type   => "application/xhtml+xml")
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
    end
  end
end
