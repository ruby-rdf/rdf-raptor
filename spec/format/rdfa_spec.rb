require File.join(File.dirname(__FILE__), '../spec_helper')
require 'rdf/spec/format'
require 'rdf/spec/reader'
require 'rdf/spec/writer'

describe RDF::Raptor::RDFa::Format do
  before(:each) do
    @format_class = RDF::Raptor::RDFa::Format
  end
  
  # @see lib/rdf/spec/format.rb in rdf-spec
  include RDF_Format
  
  it "should be discoverable" do
    formats = [
      RDF::Format.for(:rdfa),
      RDF::Format.for("input.html"),
      RDF::Format.for(:file_name      => "input.html"),
      RDF::Format.for(:file_extension => "html"),
      RDF::Format.for(:content_type   => "application/xhtml+xml"),
    ]
    formats.each { |format| format.should == RDF::Raptor::RDFa::Format }
  end
end

describe RDF::Raptor::RDFa::Reader do
  before(:each) do
    @reader = RDF::Raptor::RDFa::Reader.new
  end
  
  # @see lib/rdf/spec/reader.rb in rdf-spec
  include RDF_Reader
  
  it "should return :rdfa for to_sym" do
    @reader.class.to_sym.should == :rdfa
  end
  
  it "should be discoverable" do
    readers = [
      RDF::Reader.for(:rdfa),
      RDF::Reader.for("input.html"),
      RDF::Reader.for(:file_name      => "input.html"),
      RDF::Reader.for(:file_extension => "html"),
      RDF::Reader.for(:content_type   => "application/xhtml+xml"),
    ]
    readers.each { |reader| reader.should == RDF::Raptor::RDFa::Reader }
  end
end