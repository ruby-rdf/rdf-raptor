module RDF::Raptor
  ##
  # Writer base class.
  class Writer < RDF::Writer
    require 'rdf/raptor/cli'
    include RDF::Raptor::CLI::Writer
  end
end
