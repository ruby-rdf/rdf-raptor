require File.join(File.dirname(__FILE__), '../spec_helper')
require 'rdf/spec/format'
require 'rdf/spec/reader'
require 'rdf/spec/writer'

describe RDF::Raptor::NTriples::Format do
  before(:each) do
    # Remove RDF::NTriples if loaded
    subclasses = RDF::Format.class_variable_get(:@@subclasses)
    if subclasses.map(&:to_s).include?("RDF::NTriples::Format")
      RDF::Format.class_variable_set(:@@subclasses, subclasses - [RDF::NTriples::Format])
      RDF::Format.class_variable_get(:@@content_types).values.each {|v| v.delete(RDF::NTriples::Format)}
      RDF::Format.class_variable_get(:@@file_extensions).values.each {|v| v.delete(RDF::NTriples::Format)}
    end
  end

  it_behaves_like 'an RDF::Format' do
    let(:format_class) {RDF::Raptor::NTriples::Format}
  end
  
  it "should be discoverable" do
    formats = [
      RDF::Format.for(:ntriples),
      RDF::Format.for("input.nt"),
      RDF::Format.for(file_name:      "input.nt"),
      RDF::Format.for(file_extension: "nt"),
      RDF::Format.for(content_type:   "text/plain"),
      RDF::Format.for(content_type:   "application/n-triples"),
    ]
    formats.each { |format| expect(format).to eq(described_class) }
  end
  
  describe ".detect" do
    {
      ntriples: "<a> <b> <c> .",
      literal: '<a> <b> "literal" .',
      multi_line: %(<a>\n  <b>\n  "literal"\n .),
    }.each do |sym, str|
      it "detects #{sym}" do
        expect(described_class.detect(str)).to be true
      end
    end

    {
      nquads:        "<a> <b> <c> <d> . ",
      nq_literal:    '<a> <b> "literal" <d> .',
      nq_multi_line: %(<a>\n  <b>\n  "literal"\n <d>\n .),
      turtle:        "@prefix foo: <bar> .\n foo:a foo:b <c> .",
      trig:          "{<a> <b> <c> .}",
      rdfxml:        '<rdf:RDF about="foo"></rdf:RDF>',
      n3:            '@prefix foo: <bar> .\nfoo:bar = {<a> <b> <c>} .',
    }.each do |sym, str|
      it "does not detect #{sym}" do
        expect(described_class.detect(str)).to be false
      end
    end
  end
end

describe RDF::Raptor::NTriples::Reader do
  before(:each) do
    # Remove RDF::NTriples if loaded
    subclasses = RDF::Format.class_variable_get(:@@subclasses)
    if subclasses.map(&:to_s).include?("RDF::NTriples::Format")
      RDF::Format.class_variable_set(:@@subclasses, subclasses - [RDF::NTriples::Format])
      RDF::Format.class_variable_get(:@@content_types).values.each {|v| v.delete(RDF::NTriples::Format)}
      RDF::Format.class_variable_get(:@@file_extensions).values.each {|v| v.delete(RDF::NTriples::Format)}
    end
  end

  let(:reader) {RDF::Raptor::NTriples::Reader.new(reader_input)}
  let(:reader_input) {%q(
    <http://rubygems.org/gems/rdf> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://usefulinc.com/ns/doap#Project> .
    <http://rubygems.org/gems/rdf> <http://usefulinc.com/ns/doap#name> "RDF.rb" .
  )}
  let(:reader_count) {2}
  it_behaves_like 'an RDF::Reader' do
    around(:each) do |example|
      pending("validation") if example.description.include?('invalidates given invalid input and validate: true')
     example.run
    end
  end
  
  it "should return :ntriples for to_sym" do
    expect(described_class.to_sym).to eq(:ntriples)
  end
  
  it "should be discoverable" do
    readers = [
      RDF::Reader.for(:ntriples),
      RDF::Reader.for("input.nt"),
      RDF::Reader.for(file_name:      "input.nt"),
      RDF::Reader.for(file_extension: "nt"),
      RDF::Reader.for(content_type:   "text/plain"),
      RDF::Reader.for(content_type:   "application/n-triples"),
    ]
    readers.each { |reader| expect(reader).to eq(RDF::Raptor::NTriples::Reader) }
  end
  
  it 'should yield statements' do
    inner = double("inner")
    expect(inner).to receive(:called).with(RDF::Statement).twice
    reader.each_statement do |statement|
      inner.called(statement.class)
    end
  end
  
  it 'should yield raw statements' do
    reader.each_statement(raw: true) do |statement|
      expect(statement).to be_a RDF::Raptor::FFI::V2::Statement
    end
  end
  
  it "should yield triples" do
    inner = double("inner")
    expect(inner).to receive(:called).with(RDF::URI, RDF::URI, RDF::URI).once
    expect(inner).to receive(:called).with(RDF::URI, RDF::URI, RDF::Literal).once
    reader.each_triple do |subject, predicate, object|
      inner.called(subject.class, predicate.class, object.class)
    end
  end
  
  it "should open and parse a file" do
    RDF::Reader.open(File.expand_path("../../../etc/doap.nt", __FILE__)) do |reader|
      expect(reader).to be_a subject.class
      expect(reader.count).to be > 0
    end
  end
  
  it "should parse a URI" do
    reader = RDF::Raptor::NTriples::Reader.new
    result = reader.parse("http://dbpedia.org/data/Michael_Jackson.ntriples")
    expect(result).to eq(0)
  end
  
  it "should parse a String" do
    reader = RDF::Raptor::NTriples::Reader.new
    result = reader.parse(reader_input)
    expect(result).to eq(0)
  end
end

describe RDF::Raptor::NTriples::Writer do
  before(:each) do
    # Remove RDF::NTriples if loaded
    subclasses = RDF::Format.class_variable_get(:@@subclasses)
    if subclasses.map(&:to_s).include?("RDF::NTriples::Format")
      RDF::Format.class_variable_set(:@@subclasses, subclasses - [RDF::NTriples::Format])
      RDF::Format.class_variable_get(:@@content_types).values.each {|v| v.delete(RDF::NTriples::Format)}
      RDF::Format.class_variable_get(:@@file_extensions).values.each {|v| v.delete(RDF::NTriples::Format)}
      RDF.send(:remove_constant, :NTriples)
    end
  end

  it_behaves_like 'an RDF::Writer' do
    let(:writer) {RDF::Raptor::NTriples::Writer.new}
  end

  it "should return :ntriples for to_sym" do
    expect(described_class.to_sym).to eq(:ntriples)
  end
  
  it "should be discoverable" do
    writers = [
      RDF::Writer.for(:ntriples),
      RDF::Writer.for("output.nt"),
      RDF::Writer.for(file_name:      "output.nt"),
      RDF::Writer.for(file_extension: "nt"),
      RDF::Writer.for(content_type:   "text/plain"),
      RDF::Writer.for(content_type:   "application/n-triples"),
    ]
    writers.each { |writer| expect(writer).to eq(RDF::Raptor::NTriples::Writer) }
  end
end

describe RDF::Raptor::NTriples do
  let(:reader) {RDF::Raptor::NTriples::Reader}
  let(:writer) {RDF::Raptor::NTriples::Writer}
  let(:statement) {
    RDF::Statement.new(
      RDF::URI("http://rubygems.org/gems/rdf"),
      RDF::URI("http://purl.org/dc/terms/creator"),
      RDF::URI("http://ar.to/#self"))
  }
  let(:stmt_string) {"<http://rubygems.org/gems/rdf> <http://purl.org/dc/terms/creator> <http://ar.to/#self> .\n"}
  let(:graph) {RDF::Graph.new {|g| g << statement}}

  context "when writing" do
=begin
    it "should correctly format statements" do
      writer.new.format_statement(statement).should == stmt_string
    end

    context "should correctly format blank nodes" do
      specify {writer.new.format_node(RDF::Node.new('foobar')).should == '_:foobar'}
      specify {writer.new.format_node(RDF::Node.new('')).should_not == '_:'}
    end

    it "should correctly format URI references" do
      writer.new.format_uri(RDF::URI('http://rubgems.org/gems/rdf/')).should == '<http://rubgems.org/gems/rdf/>'
    end

    it "should correctly format plain literals" do
      writer.new.format_literal(RDF::Literal.new('Hello, world!')).should == '"Hello, world!"'
    end

    it "should correctly format language-tagged literals" do
      writer.new.format_literal(RDF::Literal.new('Hello, world!', language: :en)).should == '"Hello, world!"@en'
    end

    it "should correctly format datatyped literals" do
      writer.new.format_literal(RDF::Literal.new(3.1415)).should == '"3.1415"^^<http://www.w3.org/2001/XMLSchema#double>'
    end
=end

    it "should output statements to a string buffer" do
      output = writer.buffer { |w| w << statement }
      expect(output).to eq(stmt_string)
    end

    it "should dump statements to a string buffer" do
      output = StringIO.new
      writer.dump(graph, output)
      expect(output.string).to eq(stmt_string)
    end

    it "should dump arrays of statements to a string buffer" do
      output = StringIO.new
      writer.dump(graph.to_a, output)
      expect(output.string).to eq(stmt_string)
    end

    it "should dump statements to a file" do
      require 'tmpdir' # for Dir.tmpdir
      writer.dump(graph, filename = File.join(Dir.tmpdir, "test.nt"))
      expect(File.read(filename)).to eq(stmt_string)
      File.unlink(filename)
    end
  end
end
