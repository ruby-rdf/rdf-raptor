require File.join(File.dirname(__FILE__), '../spec_helper')
require 'rdf/spec/format'
require 'rdf/spec/reader'
require 'rdf/spec/writer'

describe RDF::Raptor::RDFXML::Format do
  it_behaves_like 'an RDF::Format' do
    let(:format_class) {RDF::Raptor::RDFXML::Format}
  end
  
  it "should be discoverable" do
    formats = [
      RDF::Format.for(:rdfxml),
      RDF::Format.for("input.rdf"),
      RDF::Format.for(file_name:      "input.rdf"),
      RDF::Format.for(file_extension: "rdf"),
      RDF::Format.for(content_type:   "application/rdf+xml"),
    ]
    formats.each { |format| expect(format).to eq(RDF::Raptor::RDFXML::Format) }
  end
end

describe RDF::Raptor::RDFXML::Reader do
  let!(:doap) {File.expand_path("../../../etc/doap.xml", __FILE__)}
  let!(:doap_count) {41}

  it_behaves_like 'an RDF::Reader' do
    around(:each) do |example|
      pending("validation") if example.description.include?('invalidates given invalid input and validate: true')
     example.run
    end
    let(:reader) {RDF::Raptor::RDFXML::Reader.new}
    let(:reader_input) {File.read(doap)}
    let(:reader_count) {doap_count}
  end
  
  it "should be discoverable" do
    readers = [
      RDF::Reader.for(:rdfxml),
      RDF::Reader.for("input.rdf"),
      RDF::Reader.for(file_name:      "input.rdf"),
      RDF::Reader.for(file_extension: "rdf"),
      RDF::Reader.for(content_type:   "application/rdf+xml"),
    ]
    readers.each { |reader| expect(reader).to eq(RDF::Raptor::RDFXML::Reader) }
  end
  
  context 'interface' do
    subject {
      RDF::Raptor::RDFXML::Reader.new(%q(<?xml version="1.0" ?>
        <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
        xmlns:ex="http://www.example.org/" xml:lang="en" xml:base="http://www.example.org/foo">
          <ex:Thing rdf:about="http://example.org/joe" ex:name="bar">
            <ex:belongsTo rdf:resource="http://tommorris.org/" />
            <ex:sampleText rdf:datatype="http://www.w3.org/2001/XMLSchema#string">foo</ex:sampleText>
          </ex:Thing>
        </rdf:RDF>))
    }

    it "should return reader" do
      is_expected.to be_a(RDF::Raptor::RDFXML::Reader)
    end

    it "should yield statements" do
      inner = double("inner")
      expect(inner).to receive(:called).with(RDF::Statement).exactly(4).times
      subject.each_statement do |statement|
        inner.called(statement.class)
      end
    end

    it "should yield triples" do
      inner = double("inner")
      expect(inner).to receive(:called).with(RDF::URI, RDF::URI, RDF::URI).twice
      expect(inner).to receive(:called).with(RDF::URI, RDF::URI, RDF::Literal).twice
      subject.each_triple do |subject, predicate, object|
        inner.called(subject.class, predicate.class, object.class)
      end
    end

    it "reads prefixes" do
      subject.each_triple.map {}
      expect(subject.prefixes[:rdf]).to eq(RDF)
      expect(subject.prefixes[:ex]).to eq(RDF::URI.new('http://www.example.org/'))
    end
    
    it "opens and parses a file" do
      RDF::Reader.open("etc/doap.xml") do |reader|
        expect(reader).to be_a subject.class
        expect(reader.statements.count).to_not be_zero
        expect(reader.prefixes[:doap]).to eq(RDF::URI("http://usefulinc.com/ns/doap#"))
      end
    end
  end
end

describe RDF::Raptor::RDFXML::Writer do
  it_behaves_like 'an RDF::Writer' do
    let(:writer) {RDF::Raptor::RDFXML::Writer.new}
  end
  
  it "should be discoverable" do
    writers = [
      RDF::Writer.for(:rdfxml),
      RDF::Writer.for("output.rdf"),
      RDF::Writer.for(file_name:      "output.rdf"),
      RDF::Writer.for(file_extension: "rdf"),
      RDF::Writer.for(content_type:   "application/rdf+xml"),
    ]
    writers.each { |writer| expect(writer).to eq(RDF::Raptor::RDFXML::Writer) }
  end
end
