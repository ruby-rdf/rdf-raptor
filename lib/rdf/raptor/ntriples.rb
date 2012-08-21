module RDF::Raptor
  ##
  # N-Triples support.
  #
  # @example Requiring the `RDF::Raptor` module
  #   require 'rdf/raptor'
  #
  # @example Parsing RDF statements from an N-Triples file
  #   RDF::Reader.open("input.nt") do |reader|
  #     reader.each_statement do |statement|
  #       puts statement.inspect
  #     end
  #   end
  #
  # @example Serializing RDF statements into an N-Triples file
  #   RDF::Writer.open("output.nt") do |writer|
  #     graph.each_statement do |statement|
  #       writer << statement
  #     end
  #   end
  #
  # @see http://www.w3.org/TR/rdf-testcases/#ntriples
  module NTriples
    ##
    # N-Triples format specification.
    #
    # @example Obtaining an N-Triples format class
    #   RDF::Format.for(:ntriples)       #=> RDF::Raptor::NTriples::Format
    #   RDF::Format.for("input.nt")
    #   RDF::Format.for(:file_name      => "input.nt")
    #   RDF::Format.for(:file_extension => "nt")
    #   RDF::Format.for(:content_type   => "text/plain")
    #
    class Format < RDF::Format
      extend RDF::Raptor::Format
      
      content_type     'application/n-triples', :extension => :nt, :alias => ['text/plain']
      content_encoding 'utf-8'
      rapper_format    :ntriples

      reader { RDF::Raptor::NTriples::Reader }
      writer { RDF::Raptor::NTriples::Writer }
    end # Format

    ##
    # N-Triples parser.
    #
    # @example Obtaining an N-Triples reader class
    #   RDF::Reader.for(:ntriples)       #=> RDF::Raptor::NTriples::Reader
    #   RDF::Reader.for("input.nt")
    #   RDF::Reader.for(:file_name      => "input.nt")
    #   RDF::Reader.for(:file_extension => "nt")
    #   RDF::Reader.for(:content_type   => "text/plain")
    #
    # @example Parsing RDF statements from an N-Triples file
    #   RDF::Reader.open("input.nt") do |reader|
    #     reader.each_statement do |statement|
    #       puts statement.inspect
    #     end
    #   end
    #
    class Reader < RDF::Raptor::Reader
      format RDF::Raptor::NTriples::Format
    end # Reader

    ##
    # N-Triples serializer.
    #
    # @example Obtaining an N-Triples writer class
    #   RDF::Writer.for(:ntriples)       #=> RDF::Raptor::NTriples::Writer
    #   RDF::Writer.for("output.nt")
    #   RDF::Writer.for(:file_name      => "output.nt")
    #   RDF::Writer.for(:file_extension => "nt")
    #   RDF::Writer.for(:content_type   => "text/plain")
    #
    # @example Serializing RDF statements into an N-Triples file
    #   RDF::Writer.open("output.nt") do |writer|
    #     graph.each_statement do |statement|
    #       writer << statement
    #     end
    #   end
    #
    class Writer < RDF::Raptor::Writer
      format RDF::Raptor::NTriples::Format
    end # Writer
  end # NTriples
end # RDF::Raptor
