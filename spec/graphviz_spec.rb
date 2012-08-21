require File.join(File.dirname(__FILE__), 'spec_helper')
require 'rdf/spec/format'
require 'rdf/spec/reader'
require 'rdf/spec/writer'

describe RDF::Raptor::Graphviz::Format do
  before(:each) do
    @format_class = RDF::Raptor::Graphviz::Format
  end
  
  # @see lib/rdf/spec/format.rb in rdf-spec
  it_should_behave_like RDF_Format
  
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

describe RDF::Raptor::Graphviz::Writer do
  before(:each) do
    @writer_class = RDF::Raptor::Graphviz::Writer
    @writer = RDF::Raptor::Graphviz::Writer.new
  end
  
  # @see lib/rdf/spec/writer.rb in rdf-spec
  it_should_behave_like RDF_Writer

  it "should return :graphviz for to_sym" do
    @writer_class.to_sym.should == :graphviz
  end
  
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