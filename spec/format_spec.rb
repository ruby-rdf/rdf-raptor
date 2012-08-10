require File.join(File.dirname(__FILE__), 'spec_helper')
require 'rdf/spec/format'

describe RDF::Raptor::NTriples::Format do
  before(:each) do
    @format_class = RDF::Raptor::NTriples::Format
  end
  
  # @see lib/rdf/spec/format.rb in rdf-spec
  it_should_behave_like RDF_Format
  
  it "should be discoverable" do
    formats = [
      RDF::Format.for(:ntriples),
      RDF::Format.for("input.nt"),
      RDF::Format.for(:file_name      => "input.nt"),
      RDF::Format.for(:file_extension => "nt"),
      RDF::Format.for(:content_type   => "text/plain"),
      RDF::Format.for(:content_type   => "application/n-triples"),
    ]
    formats.each { |format| format.should == RDF::Raptor::NTriples::Format }
  end
end

describe RDF::Raptor::RDFXML::Format do
  it "should be discoverable" do
    formats = [
      RDF::Format.for(:rdfxml),
      RDF::Format.for("input.rdf"),
      RDF::Format.for(:file_name      => "input.rdf"),
      RDF::Format.for(:file_extension => "rdf"),
      RDF::Format.for(:content_type   => "application/rdf+xml"),
    ]
    formats.each { |format| format.should == RDF::Raptor::RDFXML::Format }
  end
end

describe RDF::Raptor::Turtle::Format do
  it "should be discoverable" do
    formats = [
      RDF::Format.for(:turtle),
      RDF::Format.for("input.ttl"),
      RDF::Format.for(:file_name      => "input.ttl"),
      RDF::Format.for(:file_extension => "ttl"),
      RDF::Format.for(:content_type   => "text/turtle"),
    ]
    formats.each { |format| format.should == RDF::Raptor::Turtle::Format }
  end
end

describe RDF::Raptor::RDFa::Format do
  it "should be discoverable" do
    formats = [
      RDF::Format.for(:rdfa),
      RDF::Format.for("input.html"),
      RDF::Format.for(:file_name      => "input.html"),
      RDF::Format.for(:file_extension => "html"),
      RDF::Format.for(:content_type   => "application/xhtml+xml"),
    ]
    formats.each { |format| format.should == RDF::Raptor::RDFa::Format }
  end
end

describe RDF::Raptor::Graphviz::Format do
  it "should be discoverable" do
    formats = [
      RDF::Format.for(:graphviz),
      RDF::Format.for("output.dot"),
      RDF::Format.for(:file_name      => "output.dot"),
      RDF::Format.for(:file_extension => "dot"),
      RDF::Format.for(:content_type   => "text/vnd.graphviz"),
    ]
    formats.each { |format| format.should == RDF::Raptor::Graphviz::Format }
  end
end
