require File.join(File.dirname(__FILE__), 'spec_helper')
require 'rdf/spec/reader'

describe RDF::Raptor::NTriples::Reader do
  before(:each) do
    @reader = RDF::Raptor::NTriples::Reader.new
  end
  
  # @see lib/rdf/spec/reader.rb in rdf-spec
  it_should_behave_like RDF_Reader
  
  it "should return :ntriples for to_sym" do
    @reader.class.to_sym.should == :ntriples
  end
  
  it "should be discoverable" do
    readers = [
      #RDF::Reader.for(:ntriples), # This is broken until the RDF gem can be patched to support overriding the :ntriples format
      RDF::Reader.for("input.nt"),
      RDF::Reader.for(:file_name      => "input.nt"),
      RDF::Reader.for(:file_extension => "nt"),
      RDF::Reader.for(:content_type   => "text/plain"),
      RDF::Reader.for(:content_type   => "application/n-triples"),
    ]
    readers.each { |reader| reader.should == RDF::Raptor::NTriples::Reader }
  end
end

describe RDF::Raptor::RDFXML::Reader do
  it "should be discoverable" do
    readers = [
      RDF::Reader.for(:rdfxml),
      RDF::Reader.for("input.rdf"),
      RDF::Reader.for(:file_name      => "input.rdf"),
      RDF::Reader.for(:file_extension => "rdf"),
      RDF::Reader.for(:content_type   => "application/rdf+xml"),
    ]
    readers.each { |reader| reader.should == RDF::Raptor::RDFXML::Reader }
  end
end

describe RDF::Raptor::Turtle::Reader do
  it "should be discoverable" do
    readers = [
      RDF::Reader.for(:turtle),
      RDF::Reader.for("input.ttl"),
      RDF::Reader.for(:file_name      => "input.ttl"),
      RDF::Reader.for(:file_extension => "ttl"),
      RDF::Reader.for(:content_type   => "text/turtle"),
    ]
    readers.each { |reader| reader.should == RDF::Raptor::Turtle::Reader }
  end
end

describe RDF::Raptor::RDFa::Reader do
  it "should be discoverable" do
    readers = [
      RDF::Reader.for(:rdfa),
      RDF::Reader.for("input.html"),
      RDF::Reader.for(:file_name      => "input.html"),
      RDF::Reader.for(:file_extension => "html"),
      RDF::Reader.for(:content_type   => "application/xhtml+xml"),
    ]
    readers.each { |reader| reader.should == RDF::Raptor::RDFa::Reader }
  end
end
