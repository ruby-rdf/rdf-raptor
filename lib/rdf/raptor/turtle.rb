module RDF::Raptor
  ##
  # Turtle support.
  #
  # @example Requiring the `RDF::Raptor` module
  #   require 'rdf/raptor'
  #
  # @example Parsing RDF statements from a Turtle file
  #   RDF::Reader.open("input.ttl") do |reader|
  #     reader.each_statement do |statement|
  #       puts statement.inspect
  #     end
  #   end
  #
  # @example Serializing RDF statements into a Turtle file
  #   RDF::Writer.open("output.ttl") do |writer|
  #     graph.each_statement do |statement|
  #       writer << statement
  #     end
  #   end
  #
  # @see http://www.w3.org/TeamSubmission/turtle/
  module Turtle
    ##
    # Turtle format specification.
    #
    # @example Obtaining a Turtle format class
    #   RDF::Format.for(:turtle)       #=> RDF::Raptor::Turtle::Format
    #   RDF::Format.for("input.ttl")
    #   RDF::Format.for(:file_name      => "input.ttl")
    #   RDF::Format.for(:file_extension => "ttl")
    #   RDF::Format.for(:content_type   => "text/turtle")
    #
    class Format < RDF::Format
      extend RDF::Raptor::Format
      
      content_type     'text/turtle', :aliases => ['application/x-turtle', 'application/turtle'], :extension => :ttl
      content_encoding 'utf-8'
      rapper_format    :turtle

      reader { RDF::Raptor::Turtle::Reader }
      writer { RDF::Raptor::Turtle::Writer }
    end # Format

    ##
    # Turtle parser.
    #
    # @example Obtaining a Turtle reader class
    #   RDF::Reader.for(:turtle)       #=> RDF::Raptor::Turtle::Reader
    #   RDF::Reader.for("input.ttl")
    #   RDF::Reader.for(:file_name      => "input.ttl")
    #   RDF::Reader.for(:file_extension => "ttl")
    #   RDF::Reader.for(:content_type   => "text/turtle")
    #
    # @example Parsing RDF statements from a Turtle file
    #   RDF::Reader.open("input.ttl") do |reader|
    #     reader.each_statement do |statement|
    #       puts statement.inspect
    #     end
    #   end
    #
    class Reader < RDF::Raptor::Reader
      format RDF::Raptor::Turtle::Format
    end # Reader

    ##
    # Turtle serializer.
    #
    # @example Obtaining a Turtle writer class
    #   RDF::Writer.for(:turtle)       #=> RDF::Raptor::Turtle::Writer
    #   RDF::Writer.for("output.ttl")
    #   RDF::Writer.for(:file_name      => "output.ttl")
    #   RDF::Writer.for(:file_extension => "ttl")
    #   RDF::Writer.for(:content_type   => "text/turtle")
    #
    # @example Serializing RDF statements into a Turtle file
    #   RDF::Writer.open("output.ttl") do |writer|
    #     graph.each_statement do |statement|
    #       writer << statement
    #     end
    #   end
    #
    class Writer < RDF::Raptor::Writer
      format RDF::Raptor::Turtle::Format
    end # Writer
  end # Turtle
end # RDF::Raptor
