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
end