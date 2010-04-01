module RDF::Raptor
  ##
  # RDF/XML support.
  module RDFXML
    ##
    # RDF/XML format specification.
    class Format < RDF::Format
      content_type     'application/rdf+xml', :extension => :rdf
      content_encoding 'utf-8'

      reader { RDF::Raptor::RDFXML::Reader }
      writer { RDF::Raptor::RDFXML::Writer }
    end

    ##
    # RDF/XML parser.
    class Reader < RDF::Reader
      format RDF::Raptor::RDFXML::Format
    end

    ##
    # RDF/XML serializer.
    class Writer < RDF::Writer
      format RDF::Raptor::RDFXML::Format
    end
  end
end
