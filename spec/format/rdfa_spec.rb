require File.join(File.dirname(__FILE__), '../spec_helper')
require 'rdf/spec/format'
require 'rdf/spec/reader'
require 'rdf/spec/writer'

describe RDF::Raptor::RDFa::Format do
  it_behaves_like 'an RDF::Format' do
    let(:format_class) {RDF::Raptor::RDFa::Format}
  end
  
  it "should be discoverable" do
    formats = [
      RDF::Format.for(:rdfa),
      RDF::Format.for("input.html"),
      RDF::Format.for(file_name:      "input.html"),
      RDF::Format.for(file_extension: "html"),
      RDF::Format.for(content_type:   "application/xhtml+xml"),
    ]
    formats.each { |format| expect(format).to eq(RDF::Raptor::RDFa::Format) }
  end
end

describe RDF::Raptor::RDFa::Reader do
  let!(:doap) {File.expand_path("../../../etc/doap.html", __FILE__)}
  let!(:doap_count) {27}

  # @see lib/rdf/spec/reader.rb in rdf-spec
  #it_behaves_like 'an RDF::Reader', skip: "Travis reports wrong statement" do
  #  let(:reader) {RDF::Raptor::RDFa::Reader.new(@reader_input)}
  #  let(:reader_input) {File.read(doap)}
  #  let(:reader_count) {doap_count}
  #end

  it "should return :rdfa for to_sym" do
    expect(described_class.to_sym).to eq(:rdfa)
  end
  
  it "should be discoverable" do
    readers = [
      RDF::Reader.for(:rdfa),
      RDF::Reader.for("input.html"),
      RDF::Reader.for(file_name:      "input.html"),
      RDF::Reader.for(file_extension: "html"),
      RDF::Reader.for(content_type:   "application/xhtml+xml"),
    ]
    readers.each { |reader| expect(reader).to eq(RDF::Raptor::RDFa::Reader) }
  end
  
  context "when opening and parsing a file" do
    let(:reader) { RDF::Reader.open("etc/doap.html") }
    after { reader.close }
    
    specify { expect(reader).to be_a subject.class }
    specify { expect(reader.statements.to_a).to_not be_empty }
    
    it "reads xml namespaces" do
      reader.statements.to_a
      expect(reader.prefixes[:foaf]).to eq(RDF::URI("http://xmlns.com/foaf/0.1/"))
    end

    it "reads HTML5 prefixes" do
      pending 'libraptor does not support prefixes for HTML 5 + RDFa 1.1'
      expect(reader.prefixes[:doap]).to eq(RDF::URI("http://usefulinc.com/ns/doap#"))
    end
  end
end
