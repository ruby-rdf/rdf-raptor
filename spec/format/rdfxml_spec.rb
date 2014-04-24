require File.join(File.dirname(__FILE__), '../spec_helper')
require 'rdf/spec/format'
require 'rdf/spec/reader'
require 'rdf/spec/writer'

describe RDF::Raptor::RDFXML::Format do
  before :each do
    @format_class = RDF::Raptor::RDFXML::Format
  end

  include RDF_Format
  
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

describe RDF::Raptor::RDFXML::Reader do
  let!(:doap) {File.expand_path("../../../etc/doap.xml", __FILE__)}
  let!(:doap_count) {20}

  before(:each) do
    @reader_input = File.read(doap)
    @reader = RDF::Raptor::RDFXML::Reader.new(@reader_input)
    @reader_count = doap_count
  end

  include RDF_Reader
  
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
  
  context :interface do
    before(:each) do
      @reader = RDF::Raptor::RDFXML::Reader.new(%q(<?xml version="1.0" ?>
        <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
        xmlns:ex="http://www.example.org/" xml:lang="en" xml:base="http://www.example.org/foo">
          <ex:Thing rdf:about="http://example.org/joe" ex:name="bar">
            <ex:belongsTo rdf:resource="http://tommorris.org/" />
            <ex:sampleText rdf:datatype="http://www.w3.org/2001/XMLSchema#string">foo</ex:sampleText>
          </ex:Thing>
        </rdf:RDF>))
    end

    it "should return reader" do
      @reader.should be_a(RDF::Raptor::RDFXML::Reader)
    end

    it "should yield statements" do
      inner = double("inner")
      inner.should_receive(:called).with(RDF::Statement).exactly(4).times
      @reader.each_statement do |statement|
        inner.called(statement.class)
      end
    end

    it "should yield triples" do
      inner = double("inner")
      inner.should_receive(:called).with(RDF::URI, RDF::URI, RDF::URI).twice
      inner.should_receive(:called).with(RDF::URI, RDF::URI, RDF::Literal).twice
      @reader.each_triple do |subject, predicate, object|
        inner.called(subject.class, predicate.class, object.class)
      end
    end

    it "reads prefixes" do
      @reader.each_triple.map {}
      expect(@reader.prefixes[:rdf]).to eq(RDF)
      expect(@reader.prefixes[:ex]).to eq(RDF::URI.new('http://www.example.org/'))
    end
    
    it "opens and parses a file" do
      RDF::Reader.open("etc/doap.xml") do |reader|
        expect(reader).to be_a subject.class
        expect(reader.statements.count).to_not be_zero
        expect(reader.prefixes[:doap]).to eq(RDF::DOAP)
      end
    end
  end
end

describe RDF::Raptor::RDFXML::Writer do
  before(:each) do
    @graph = RDF::Graph.new
    @writer = RDF::Raptor::RDFXML::Writer.new(StringIO.new)
    @writer_class = RDF::Raptor::RDFXML::Writer
  end
  
  include RDF_Writer
  
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
