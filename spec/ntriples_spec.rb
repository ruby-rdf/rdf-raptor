require File.join(File.dirname(__FILE__), 'spec_helper')
require 'rdf/spec/format'
require 'rdf/spec/reader'
require 'rdf/spec/writer'

describe RDF::Raptor::NTriples::Format do
  before(:each) do
    @format_class = RDF::Raptor::NTriples::Format
  end
  
  # @see lib/rdf/spec/format.rb in rdf-spec
  it_should_behave_like RDF_Format
  
  it "should be discoverable" do
    formats = [
      RDF::Format.for(:ntriples),
      RDF::Format.for("input.nt"),
      RDF::Format.for(:file_name      => "input.nt"),
      RDF::Format.for(:file_extension => "nt"),
      RDF::Format.for(:content_type   => "text/plain"),
      RDF::Format.for(:content_type   => "application/n-triples"),
    ]
    formats.each { |format| format.should == @format_class }
  end
  
  {
    :ntriples => "<a> <b> <c> .",
    :literal => '<a> <b> "literal" .',
    :multi_line => %(<a>\n  <b>\n  "literal"\n .),
  }.each do |sym, str|
    it "detects #{sym}" do
      @format_class.for {str}.should == @format_class
    end
  end
  
  describe ".detect" do
    {
      :ntriples => "<a> <b> <c> .",
      :literal => '<a> <b> "literal" .',
      :multi_line => %(<a>\n  <b>\n  "literal"\n .),
    }.each do |sym, str|
      it "detects #{sym}" do
        @format_class.detect(str).should be_true
      end
    end

    {
      :nquads        => "<a> <b> <c> <d> . ",
      :nq_literal    => '<a> <b> "literal" <d> .',
      :nq_multi_line => %(<a>\n  <b>\n  "literal"\n <d>\n .),
      :turtle        => "@prefix foo: <bar> .\n foo:a foo:b <c> .",
      :trig          => "{<a> <b> <c> .}",
      :rdfxml        => '<rdf:RDF about="foo"></rdf:RDF>',
      :n3            => '@prefix foo: <bar> .\nfoo:bar = {<a> <b> <c>} .',
    }.each do |sym, str|
      it "does not detect #{sym}" do
        @format_class.detect(str).should be_false
      end
    end
  end
end

describe RDF::Raptor::NTriples::Reader do
  before(:each) do
    @reader = RDF::Raptor::NTriples::Reader.new
  end
  
  # @see lib/rdf/spec/reader.rb in rdf-spec
  it_should_behave_like RDF_Reader
  
  it "should return :ntriples for to_sym" do
    @reader.class.to_sym.should == :ntriples
  end
  
  it "should be discoverable" do
    readers = [
      #RDF::Reader.for(:ntriples), # This is broken until the RDF gem can be patched to support overriding the :ntriples format
      RDF::Reader.for("input.nt"),
      RDF::Reader.for(:file_name      => "input.nt"),
      RDF::Reader.for(:file_extension => "nt"),
      RDF::Reader.for(:content_type   => "text/plain"),
      RDF::Reader.for(:content_type   => "application/n-triples"),
    ]
    readers.each { |reader| reader.should == RDF::Raptor::NTriples::Reader }
  end
end

describe RDF::Raptor::NTriples::Writer do
  before(:each) do
    @writer_class = RDF::NTriples::Writer
    @writer = RDF::NTriples::Writer.new
  end
  
  # @see lib/rdf/spec/writer.rb in rdf-spec
  it_should_behave_like RDF_Writer

  it "should return :ntriples for to_sym" do
    @writer_class.to_sym.should == :ntriples
  end
  
  it "should be discoverable" do
    writers = [
      RDF::Writer.for(:ntriples),
      RDF::Writer.for("output.nt"),
      RDF::Writer.for(:file_name      => "output.nt"),
      RDF::Writer.for(:file_extension => "nt"),
      RDF::Writer.for(:content_type   => "text/plain"),
      RDF::Writer.for(:content_type   => "application/n-triples"),
    ]
    writers.each { |writer| writer.should == RDF::Raptor::NTriples::Writer }
  end
end