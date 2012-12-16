require 'bundler/setup'
require 'rdf/raptor'

100.times do
  RDF::Reader.open("etc/doap.ttl").each {|s| s.inspect}
end