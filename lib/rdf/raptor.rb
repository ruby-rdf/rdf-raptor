require 'rdf'

module RDF
  ##
  # **`RDF::Raptor`** is a Raptor RDF Parser wrapper for RDF.rb.
  #
  # * {RDF::Raptor::RDFXML} provides support for the standard
  #   machine-readable RDF/XML format.
  # * {RDF::Raptor::Turtle} provides support for the popular
  #   human-readable Turtle format.
  #
  # @example Requiring the `RDF::Raptor` module
  #   require 'rdf/raptor'
  #
  # @example Obtaining an RDF/XML format class
  #   RDF::Format.for(:rdfxml)       #=> RDF::Raptor::RDFXML::Format
  #   RDF::Format.for("input.rdf")
  #   RDF::Format.for(:file_name      => "input.rdf")
  #   RDF::Format.for(:file_extension => "rdf")
  #   RDF::Format.for(:content_type   => "application/rdf+xml")
  #
  # @example Obtaining a Turtle format class
  #   RDF::Format.for(:turtle)       #=> RDF::Raptor::Turtle::Format
  #   RDF::Format.for("input.ttl")
  #   RDF::Format.for(:file_name      => "input.ttl")
  #   RDF::Format.for(:file_extension => "ttl")
  #   RDF::Format.for(:content_type   => "text/turtle")
  #
  # @see http://rdf.rubyforge.org/
  # @see http://librdf.org/raptor/
  #
  # @author [Arto Bendiken](http://ar.to/)
  module Raptor
    require 'rdf/raptor/version'
    require 'rdf/raptor/format'
    require 'rdf/raptor/reader'
    require 'rdf/raptor/writer'
    require 'rdf/raptor/rdfxml'
    require 'rdf/raptor/turtle'
  end # module Raptor
end # module RDF
