module RDF::Raptor
  ##
  # RDF/XML support.
  #
  # @example Requiring the `RDF::Raptor` module
  #   require 'rdf/raptor'
  #
  # @example Parsing RDF statements from an RDF/XML file
  #   RDF::Reader.open("input.rdf") do |reader|
  #     reader.each_statement do |statement|
  #       puts statement.inspect
  #     end
  #   end
  #
  # @example Serializing RDF statements into an RDF/XML file
  #   RDF::Writer.open("output.rdf") do |writer|
  #     graph.each_statement do |statement|
  #       writer << statement
  #     end
  #   end
  #
  # @see http://www.w3.org/TR/REC-rdf-syntax/
  module RDFXML
    ##
    # RDF/XML format specification.
    #
    # @example Obtaining an RDF/XML format class
    #   RDF::Format.for(:rdfxml)       #=> RDF::Raptor::RDFXML::Format
    #   RDF::Format.for("input.rdf")
    #   RDF::Format.for(:file_name      => "input.rdf")
    #   RDF::Format.for(:file_extension => "rdf")
    #   RDF::Format.for(:content_type   => "application/rdf+xml")
    #
    class Format < RDF::Format
      extend RDF::Raptor::Format
      
      content_type     'application/rdf+xml', :extension => :rdf
      content_encoding 'utf-8'
      rapper_format    :rdfxml

      reader { RDF::Raptor::RDFXML::Reader }
      writer { RDF::Raptor::RDFXML::Writer }
      
      def self.detect(sample)
        # Raptor guess is not fully supported
        sample.match(/<(\w+:)?(RDF)/)
      end
    end # Format

    ##
    # RDF/XML parser.
    #
    # @example Obtaining an RDF/XML reader class
    #   RDF::Reader.for(:rdfxml)       #=> RDF::Raptor::RDFXML::Reader
    #   RDF::Reader.for("input.rdf")
    #   RDF::Reader.for(:file_name      => "input.rdf")
    #   RDF::Reader.for(:file_extension => "rdf")
    #   RDF::Reader.for(:content_type   => "application/rdf+xml")
    #
    # @example Parsing RDF statements from an RDF/XML file
    #   RDF::Reader.open("input.rdf") do |reader|
    #     reader.each_statement do |statement|
    #       puts statement.inspect
    #     end
    #   end
    #
    class Reader < RDF::Raptor::Reader
      format RDF::Raptor::RDFXML::Format
    end # Reader

    ##
    # RDF/XML serializer.
    #
    # @example Obtaining an RDF/XML writer class
    #   RDF::Writer.for(:rdfxml)       #=> RDF::Raptor::RDFXML::Writer
    #   RDF::Writer.for("output.rdf")
    #   RDF::Writer.for(:file_name      => "output.rdf")
    #   RDF::Writer.for(:file_extension => "rdf")
    #   RDF::Writer.for(:content_type   => "application/rdf+xml")
    #
    # @example Serializing RDF statements into an RDF/XML file
    #   RDF::Writer.open("output.rdf") do |writer|
    #     graph.each_statement do |statement|
    #       writer << statement
    #     end
    #   end
    #
    class Writer < RDF::Raptor::Writer
      format RDF::Raptor::RDFXML::Format
    end # Writer
  end # RDFXML
end # RDF::Raptor
