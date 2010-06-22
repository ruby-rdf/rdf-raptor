module RDF::Raptor
  ##
  # Graphviz support.
  #
  # @example Requiring the `RDF::Raptor` module
  #   require 'rdf/raptor'
  #
  # @example Serializing RDF statements into a Graphviz file
  #   RDF::Writer.open("output.dot") do |writer|
  #     graph.each_statement do |statement|
  #       writer << statement
  #     end
  #   end
  #
  module Graphviz
    ##
    # Graphviz format specification.
    #
    # @example Obtaining a Graphviz format class
    #   RDF::Format.for(:graphviz)     #=> RDF::Raptor::Graphviz::Format
    #   RDF::Format.for("output.dot")
    #   RDF::Format.for(:file_name      => "output.dot")
    #   RDF::Format.for(:file_extension => "dot")
    #   RDF::Format.for(:content_type   => "text/vnd.graphviz")
    #
    # @see http://www.iana.org/assignments/media-types/text/vnd.graphviz
    class Format < RDF::Raptor::Format
      content_type     'text/vnd.graphviz', :aliases => ['application/x-graphviz', 'text/x-graphviz'], :extension => :dot # TODO: also .gv
      content_encoding 'utf-8'
      rapper_format    :dot

      writer { RDF::Raptor::Graphviz::Writer }
    end

    ##
    # Graphviz serializer.
    #
    # @example Obtaining a Graphviz writer class
    #   RDF::Writer.for(:graphviz)     #=> RDF::Raptor::Graphviz::Writer
    #   RDF::Writer.for("output.dot")
    #   RDF::Writer.for(:file_name      => "output.dot")
    #   RDF::Writer.for(:file_extension => "dot")
    #   RDF::Writer.for(:content_type   => "text/vnd.graphviz")
    #
    # @example Serializing RDF statements into a Graphviz file
    #   RDF::Writer.open("output.dot") do |writer|
    #     graph.each_statement do |statement|
    #       writer << statement
    #     end
    #   end
    #
    class Writer < RDF::Raptor::Writer
      format RDF::Raptor::Graphviz::Format
    end
  end
end
