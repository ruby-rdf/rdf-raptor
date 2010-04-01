module RDF::Raptor
  ##
  # RDF/XML support.
  #
  # @see http://www.w3.org/TR/REC-rdf-syntax/
  module RDFXML
    ##
    # RDF/XML format specification.
    class Format < RDF::Raptor::Format
      content_type     'application/rdf+xml', :extension => :rdf
      content_encoding 'utf-8'
      rapper_format    :rdfxml

      reader { RDF::Raptor::RDFXML::Reader }
      writer { RDF::Raptor::RDFXML::Writer }
    end

    ##
    # RDF/XML parser.
    class Reader < RDF::Raptor::Reader
      format RDF::Raptor::RDFXML::Format
    end

    ##
    # RDF/XML serializer.
    class Writer < RDF::Raptor::Writer
      format RDF::Raptor::RDFXML::Format
    end
  end
end
