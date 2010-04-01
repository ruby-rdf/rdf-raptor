module RDF::Raptor
  ##
  # Turtle support.
  #
  # @see http://www.w3.org/TeamSubmission/turtle/
  module Turtle
    ##
    # Turtle format specification.
    class Format < RDF::Raptor::Format
      content_type     'text/turtle', :extension => :ttl
      content_encoding 'utf-8'
      rapper_format    :turtle

      reader { RDF::Raptor::Turtle::Reader }
      writer { RDF::Raptor::Turtle::Writer }
    end

    ##
    # Turtle parser.
    class Reader < RDF::Raptor::Reader
      format RDF::Raptor::Turtle::Format
    end

    ##
    # Turtle serializer.
    class Writer < RDF::Raptor::Writer
      format RDF::Raptor::Turtle::Format
    end
  end
end
