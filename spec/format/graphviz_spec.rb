require File.join(File.dirname(__FILE__), '../spec_helper')
require 'rdf/spec/format'
require 'rdf/spec/reader'
require 'rdf/spec/writer'

describe RDF::Raptor::Graphviz::Format do
  before(:each) do
    @format_class = RDF::Raptor::Graphviz::Format
  end
  
  # @see lib/rdf/spec/format.rb in rdf-spec
  include RDF_Format
  
  it "should be discoverable" do
    formats = [
      RDF::Format.for(:graphviz),
      RDF::Format.for("output.dot"),
      RDF::Format.for(:file_name      => "output.dot"),
      RDF::Format.for(:file_extension => "dot"),
      RDF::Format.for(:content_type   => "text/vnd.graphviz"),
    ]
    formats.each { |format| expect(format).to eq(RDF::Raptor::Graphviz::Format) }
  end
end

describe RDF::Raptor::Graphviz::Writer do
  before(:each) do
    @writer_class = RDF::Raptor::Graphviz::Writer
    @writer = RDF::Raptor::Graphviz::Writer.new
  end
  
  # @see lib/rdf/spec/writer.rb in rdf-spec
  include RDF_Writer

  it "should return :graphviz for to_sym" do
    expect(@writer_class.to_sym).to eq(:graphviz)
  end
  
  it "should be discoverable" do
    writers = [
      RDF::Writer.for(:graphviz),
      RDF::Writer.for("output.dot"),
      RDF::Writer.for(:file_name      => "output.dot"),
      RDF::Writer.for(:file_extension => "dot"),
      RDF::Writer.for(:content_type   => "text/vnd.graphviz"),
    ]
    writers.each { |writer| expect(writer).to eq(RDF::Raptor::Graphviz::Writer) }
  end
end

describe RDF::Raptor::Graphviz::Reader do
  before(:each) do
    @reader = RDF::Raptor::Graphviz::Reader.new
  end
  
  # Raptor has no implementation for a Graphviz reader
  it "should raise a NoMethodError" do
    expect {@reader.open}.to raise_error(NoMethodError)
  end
end
