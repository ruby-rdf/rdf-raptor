module RDF::Raptor
  ##
  # Reader base class.
  class Reader < RDF::Reader
    require 'rdf/raptor/cli'
    include RDF::Raptor::CLI::Reader
  end
end
