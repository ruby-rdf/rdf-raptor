require File.join(File.dirname(__FILE__), '../spec_helper')
require 'rdf/spec/format'
require 'rdf/spec/reader'
require 'rdf/spec/writer'

describe RDF::Raptor::Turtle::Format do
  before(:each) do
    @format_class = RDF::Raptor::Turtle::Format
  end
  
  # @see lib/rdf/spec/format.rb in rdf-spec
  include RDF_Format
  
  it "should be discoverable" do
    formats = [
      RDF::Format.for(:turtle),
      RDF::Format.for("input.ttl"),
      RDF::Format.for(:file_name      => "input.ttl"),
      RDF::Format.for(:file_extension => "ttl"),
      RDF::Format.for(:content_type   => "text/turtle"),
    ]
    formats.each { |format| format.should == RDF::Raptor::Turtle::Format }
  end
end

describe RDF::Raptor::Turtle::Reader do
  before(:each) do
    @reader = RDF::Raptor::Turtle::Reader.new
  end
  
  # @see lib/rdf/spec/reader.rb in rdf-spec
  include RDF_Reader
  
  it "should return :turtle for to_sym" do
    @reader.class.to_sym.should == :turtle
  end
  
  it "should be discoverable" do
    readers = [
      RDF::Reader.for(:turtle),
      RDF::Reader.for("input.ttl"),
      RDF::Reader.for(:file_name      => "input.ttl"),
      RDF::Reader.for(:file_extension => "ttl"),
      RDF::Reader.for(:content_type   => "text/turtle"),
    ]
    readers.each { |reader| reader.should == RDF::Raptor::Turtle::Reader }
  end
  
  it "opens and parses a file" do
    RDF::Reader.open("etc/doap.ttl") do |reader|
      expect(reader).to be_a subject.class
      expect(reader).to_not be_empty
      expect(reader.prefixes[:doap]).to eq(RDF::DOAP)
    end
  end
end

describe RDF::Raptor::Turtle::Writer do
  before(:each) do
    @writer_class = RDF::Raptor::Turtle::Writer
    @writer = RDF::Raptor::Turtle::Writer.new
  end
  
  # @see lib/rdf/spec/writer.rb in rdf-spec
  include RDF_Writer

  it "should return :ttl for to_sym" do
    @writer_class.to_sym.should == :turtle
  end
  
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

  it "should not use pname URIs without prefix" do
    input = %(<http://xmlns.com/foaf/0.1/b> <http://xmlns.com/foaf/0.1/c> <http://xmlns.com/foaf/0.1/d> .)
    serialize(input, nil,
      [%r(^<http://xmlns.com/foaf/0.1/b>\s+<http://xmlns.com/foaf/0.1/c>\s+<http://xmlns.com/foaf/0.1/d> \.$)],
      :prefixes => { }
    )
  end

  it "should use pname URIs with prefix" do
    input = %(<http://xmlns.com/foaf/0.1/b> <http://xmlns.com/foaf/0.1/c> <http://xmlns.com/foaf/0.1/d> .)
    serialize(input, nil,
      [%r(^@prefix foaf: <http://xmlns.com/foaf/0.1/> \.$),
      %r(^foaf:b\s+foaf:c\s+foaf:d \.$)],
      :prefixes => { :foaf => RDF::FOAF}
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
    g = parse(ntstr, :base_uri => base, :prefixes => prefixes, :validate => false)
    @debug = []
    result = RDF::Raptor::Turtle::Writer.buffer(options.merge(:base_uri => base, :prefixes => prefixes)) do |writer|
      writer << g
    end
    
    regexps.each do |re|
      expect(result).to match(re)
    end
    
    result
  end
end