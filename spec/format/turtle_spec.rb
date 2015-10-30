require File.join(File.dirname(__FILE__), '../spec_helper')
require 'rdf/spec/format'
require 'rdf/spec/reader'
require 'rdf/spec/writer'

describe RDF::Raptor::Turtle::Format do
  it_behaves_like 'an RDF::Format' do
    let(:format_class) {RDF::Raptor::Turtle::Format}
  end
  
  it "should be discoverable" do
    formats = [
      RDF::Format.for(:turtle),
      RDF::Format.for("input.ttl"),
      RDF::Format.for(file_name:      "input.ttl"),
      RDF::Format.for(file_extension: "ttl"),
      RDF::Format.for(content_type:   "text/turtle"),
    ]
    formats.each { |format| expect(format).to eq(RDF::Raptor::Turtle::Format) }
  end
end

describe RDF::Raptor::Turtle::Reader do
  let!(:doap) {File.expand_path("../../../etc/doap.ttl", __FILE__)}
  let!(:doap_count) {45}

  it_behaves_like 'an RDF::Reader' do
    let(:reader) {RDF::Raptor::Turtle::Reader.new(reader_input)}
    let(:reader_input) {File.read(doap)}
    let(:reader_count) {doap_count}
  end
  
  it "should return :turtle for to_sym" do
    expect(described_class.to_sym).to eq(:turtle)
  end
  
  it "should be discoverable" do
    readers = [
      RDF::Reader.for(:turtle),
      RDF::Reader.for("input.ttl"),
      RDF::Reader.for(file_name:      "input.ttl"),
      RDF::Reader.for(file_extension: "ttl"),
      RDF::Reader.for(content_type:   "text/turtle"),
    ]
    readers.each { |reader| expect(reader).to eq(RDF::Raptor::Turtle::Reader) }
  end
  
  it "opens and parses a file" do
    RDF::Reader.open("etc/doap.ttl") do |reader|
      expect(reader).to be_a subject.class
      expect(reader.statements.count).to_not be_zero
      expect(reader.prefixes[:doap]).to eq(RDF::URI("http://usefulinc.com/ns/doap#"))
    end
  end
end

describe RDF::Raptor::Turtle::Writer do
  it_behaves_like 'an RDF::Writer' do
    let(:writer) {RDF::Raptor::Turtle::Writer.new}
  end

  it "should return :ttl for to_sym" do
    expect(described_class.to_sym).to eq(:turtle)
  end
  
  it "should be discoverable" do
    writers = [
      RDF::Writer.for(:turtle),
      RDF::Writer.for("output.ttl"),
      RDF::Writer.for(file_name:      "output.ttl"),
      RDF::Writer.for(file_extension: "ttl"),
      RDF::Writer.for(content_type:   "text/turtle"),
    ]
    writers.each { |writer| expect(writer).to eq(RDF::Raptor::Turtle::Writer) }
  end

  it "should not use pname URIs without prefix" do
    input = %(<http://xmlns.com/foaf/0.1/b> <http://xmlns.com/foaf/0.1/c> <http://xmlns.com/foaf/0.1/d> .)
    serialize(input, nil,
      [%r(^<http://xmlns.com/foaf/0.1/b>\s+<http://xmlns.com/foaf/0.1/c>\s+<http://xmlns.com/foaf/0.1/d> \.$)],
      prefixes: { }
    )
  end

  it "should use pname URIs with prefix" do
    input = %(<http://xmlns.com/foaf/0.1/b> <http://xmlns.com/foaf/0.1/c> <http://xmlns.com/foaf/0.1/d> .)
    serialize(input, nil,
      [%r(^@prefix foaf: <http://xmlns.com/foaf/0.1/> \.$),
      %r(^foaf:b\s+foaf:c\s+foaf:d \.$)],
      prefixes: { foaf: "http://xmlns.com/foaf/0.1/"}
    )
  end

  def parse(input, options = {})
    graph = RDF::Graph.new
    RDF::Raptor::Turtle::Reader.new(input, options).each do |statement|
      graph << statement
    end
    graph
  end

  # Serialize ntstr to a string and compare against regexps
  def serialize(ntstr, base = nil, regexps = [], options = {})
    prefixes = options[:prefixes] || {nil => ""}
    g = parse(ntstr, base_uri: base, prefixes: prefixes, validate: false)
    @debug = []
    result = RDF::Raptor::Turtle::Writer.buffer(options.merge(base_uri: base, prefixes: prefixes)) do |writer|
      writer << g
    end
    
    regexps.each do |re|
      expect(result).to match(re)
    end
    
    result
  end
end