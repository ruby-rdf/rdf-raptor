require 'rdf'

module RDF
  ##
  # **`RDF::Raptor`** is a Raptor RDF Parser wrapper for RDF.rb.
  #
  # @example Requiring the `RDF::Raptor` module
  #   require 'rdf/raptor'
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
