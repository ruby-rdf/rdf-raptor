require File.join(File.dirname(__FILE__), '../spec_helper')
require 'rdf/spec/format'
require 'rdf/spec/reader'
require 'rdf/spec/writer'

describe RDF::Raptor::Graphviz::Format do
  it_behaves_like 'an RDF::Format' do
    let(:format_class) {RDF::Raptor::Graphviz::Format}
  end
  
  it "should be discoverable" do
    formats = [
      RDF::Format.for(:graphviz),
      RDF::Format.for("output.dot"),
      RDF::Format.for(file_name:      "output.dot"),
      RDF::Format.for(file_extension: "dot"),
      RDF::Format.for(content_type:   "text/vnd.graphviz"),
    ]
    formats.each { |format| expect(format).to eq(RDF::Raptor::Graphviz::Format) }
  end
end

describe RDF::Raptor::Graphviz::Writer do
  it_behaves_like 'an RDF::Writer' do
    let(:writer) {RDF::Raptor::Graphviz::Writer.new}
  end

  it "should return :graphviz for to_sym" do
    expect(described_class.to_sym).to eq(:graphviz)
  end
  
  it "should be discoverable" do
    writers = [
      RDF::Writer.for(:graphviz),
      RDF::Writer.for("output.dot"),
      RDF::Writer.for(file_name:      "output.dot"),
      RDF::Writer.for(file_extension: "dot"),
      RDF::Writer.for(content_type:   "text/vnd.graphviz"),
    ]
    writers.each { |writer| expect(writer).to eq(RDF::Raptor::Graphviz::Writer) }
  end
end
