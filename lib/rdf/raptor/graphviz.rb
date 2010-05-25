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
    # @see http://www.iana.org/assignments/media-types/text/vnd.graphviz
    #
    # @example Obtaining a Graphviz format class
    #   RDF::Format.for(:gaphviz)       #=> RDF::Raptor::Graphviz::Format
    #   RDF::Format.for("input.gv")
    #   RDF::Format.for(:file_name      => "input.gv")
    #   RDF::Format.for(:file_extension => "gv")
    #   RDF::Format.for(:content_type   => "text/vnd.graphviz")
    #
    class Format < RDF::Raptor::Format
      content_type     'text/vnd.graphviz', :aliases => ['application/x-graphviz', 'text/x-graphviz'], :extension => :gv
      content_encoding 'utf-8'
      rapper_format    :dot

      writer { RDF::Raptor::Graphviz::Writer }
    end

    ##
    # Graphviz serializer.
    #
    # @example Obtaining a Graphviz writer class
    #   RDF::Writer.for(:graphviz)       #=> RDF::Raptor::Graphviz::Writer
    #   RDF::Writer.for("output.gv")
    #   RDF::Writer.for(:file_name      => "output.gv")
    #   RDF::Writer.for(:file_extension => "gv")
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
