require File.join(File.dirname(__FILE__), 'spec_helper')
require 'rdf/spec/writer'

describe RDF::Raptor::NTriples::Writer do
  before(:each) do
    @writer_class = RDF::NTriples::Writer
    @writer = RDF::NTriples::Writer.new
  end
  
  # @see lib/rdf/spec/writer.rb in rdf-spec
  it_should_behave_like RDF_Writer

  it "should return :ntriples for to_sym" do
    @writer_class.to_sym.should == :ntriples
  end
  
  it "should be discoverable" do
    writers = [
      RDF::Writer.for(:ntriples),
      RDF::Writer.for("output.nt"),
      RDF::Writer.for(:file_name      => "output.nt"),
      RDF::Writer.for(:file_extension => "nt"),
      RDF::Writer.for(:content_type   => "text/plain"),
      RDF::Writer.for(:content_type   => "application/n-triples"),
    ]
    writers.each { |writer| writer.should == RDF::Raptor::NTriples::Writer }
  end
end

describe RDF::Raptor::Turtle::Writer do
  it "should be discoverable" do
    writers = [
      RDF::Writer.for(:turtle),
      RDF::Writer.for("output.ttl"),
      RDF::Writer.for(:file_name      => "output.ttl"),
      RDF::Writer.for(:file_extension => "ttl"),
      RDF::Writer.for(:content_type   => "text/turtle"),
    ]
    writers.each { |writer| writer.should == RDF::Raptor::Turtle::Writer }
  end
end

describe RDF::Raptor::Graphviz::Writer do
  it "should be discoverable" do
    writers = [
      RDF::Writer.for(:graphviz),
      RDF::Writer.for("output.dot"),
      RDF::Writer.for(:file_name      => "output.dot"),
      RDF::Writer.for(:file_extension => "dot"),
      RDF::Writer.for(:content_type   => "text/vnd.graphviz"),
    ]
    writers.each { |writer| writer.should == RDF::Raptor::Graphviz::Writer }
  end
end
