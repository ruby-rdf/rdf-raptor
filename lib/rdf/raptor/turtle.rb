module RDF::Raptor
  ##
  # Turtle support.
  module Turtle
    ##
    # Turtle format specification.
    class Format < RDF::Format
      content_type     'text/turtle', :extension => :ttl
      content_encoding 'utf-8'

      reader { RDF::Raptor::Turtle::Reader }
      writer { RDF::Raptor::Turtle::Writer }
    end

    ##
    # Turtle parser.
    class Reader < RDF::Reader
      format RDF::Raptor::Turtle::Format
    end

    ##
    # Turtle serializer.
    class Writer < RDF::Writer
      format RDF::Raptor::Turtle::Format
    end
  end
end
