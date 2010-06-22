require File.join(File.dirname(__FILE__), 'spec_helper')

describe RDF::Raptor::RDFXML::Writer do
  it "should be discoverable" do
    writers = [
      RDF::Writer.for(:rdfxml),
      RDF::Writer.for("output.rdf"),
      RDF::Writer.for(:file_name      => "output.rdf"),
      RDF::Writer.for(:file_extension => "rdf"),
      RDF::Writer.for(:content_type   => "application/rdf+xml"),
    ]
    writers.each { |writer| writer.should == RDF::Raptor::RDFXML::Writer }
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
