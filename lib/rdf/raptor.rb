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
    autoload :VERSION, 'rdf/raptor/version'
  end # module Raptor
end # module RDF
