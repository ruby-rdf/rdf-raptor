require File.join(File.dirname(__FILE__), '../spec_helper')
require 'rdf/spec/format'
require 'rdf/spec/reader'
require 'rdf/spec/writer'

describe RDF::Raptor::NTriples::Format do
  before(:each) do
    @format_class = RDF::Raptor::NTriples::Format
  end
  
  # @see lib/rdf/spec/format.rb in rdf-spec
  include RDF_Format
  
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
    @input = %q(<http://rubygems.org/gems/rdf> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://usefulinc.com/ns/doap#Project> .
    <http://rubygems.org/gems/rdf> <http://usefulinc.com/ns/doap#name> "RDF.rb" .
    )
    @reader = RDF::Raptor::NTriples::Reader.new(@input)
  end
  
  # @see lib/rdf/spec/reader.rb in rdf-spec
  include RDF_Reader
  
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
  
  it 'should yield statements' do
    inner = mock("inner")
    inner.should_receive(:called).with(RDF::Statement).twice
    @reader.each_statement do |statement|
      inner.called(statement.class)
    end
  end
  
  it 'should yield raw statements' do
    @reader.each_statement(:raw => true) do |statement|
      statement.should be_a RDF::Raptor::FFI::V2::Statement
    end
  end
  
  it "should yield triples" do
    inner = mock("inner")
    inner.should_receive(:called).with(RDF::URI, RDF::URI, RDF::URI).once
    inner.should_receive(:called).with(RDF::URI, RDF::URI, RDF::Literal).once
    @reader.each_triple do |subject, predicate, object|
      inner.called(subject.class, predicate.class, object.class)
    end
  end
  
  it "should open and parse a file" do
    RDF::Reader.open("etc/doap.nt") do |reader|
      reader.should be_a subject.class
      reader.count.should be > 0
    end
  end
  
  it "should parse a URI" do
    reader = RDF::Raptor::NTriples::Reader.new
    result = reader.parse("http://dbpedia.org/data/Michael_Jackson.ntriples")
    result.should == 0
  end
  
  it "should parse a String" do
    reader = RDF::Raptor::NTriples::Reader.new
    result = reader.parse(@input)
    result.should == 0
  end
end

describe RDF::Raptor::NTriples::Writer do
  before(:each) do
    @writer_class = RDF::Raptor::NTriples::Writer
    @writer = RDF::Raptor::NTriples::Writer.new
  end
  
  # @see lib/rdf/spec/writer.rb in rdf-spec
  include RDF_Writer

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

describe RDF::Raptor::NTriples do
  before :all do
    @testfile = 'test.nt'
  end

  before :each do
    @reader = RDF::Raptor::NTriples::Reader
    @writer = RDF::Raptor::NTriples::Writer
  end

  context "when writing" do
    before :all do
      s = RDF::URI("http://rubygems.org/gems/rdf")
      p = RDF::DC.creator
      o = RDF::URI("http://ar.to/#self")
      @stmt = RDF::Statement.new(s, p, o)
      @stmt_string = "<http://rubygems.org/gems/rdf> <http://purl.org/dc/terms/creator> <http://ar.to/#self> ."
      @graph = RDF::Graph.new
      @graph << @stmt
    end

=begin
    it "should correctly format statements" do
      @writer.new.format_statement(@stmt).should == @stmt_string
    end

    context "should correctly format blank nodes" do
      specify {@writer.new.format_node(RDF::Node.new('foobar')).should == '_:foobar'}
      specify {@writer.new.format_node(RDF::Node.new('')).should_not == '_:'}
    end

    it "should correctly format URI references" do
      @writer.new.format_uri(RDF::URI('http://rdf.rubyforge.org/')).should == '<http://rdf.rubyforge.org/>'
    end

    it "should correctly format plain literals" do
      @writer.new.format_literal(RDF::Literal.new('Hello, world!')).should == '"Hello, world!"'
    end

    it "should correctly format language-tagged literals" do
      @writer.new.format_literal(RDF::Literal.new('Hello, world!', :language => :en)).should == '"Hello, world!"@en'
    end

    it "should correctly format datatyped literals" do
      @writer.new.format_literal(RDF::Literal.new(3.1415)).should == '"3.1415"^^<http://www.w3.org/2001/XMLSchema#double>'
    end
=end

    it "should output statements to a string buffer" do
      output = @writer.buffer { |writer| writer << @stmt }
      output.should == "#{@stmt_string}\n"
    end

    it "should dump statements to a string buffer" do
      output = StringIO.new
      @writer.dump(@graph, output)
      output.string.should == "#{@stmt_string}\n"
    end

    it "should dump arrays of statements to a string buffer" do
      output = StringIO.new
      @writer.dump(@graph.to_a, output)
      output.string.should == "#{@stmt_string}\n"
    end

    it "should dump statements to a file" do
      require 'tmpdir' # for Dir.tmpdir
      @writer.dump(@graph, filename = File.join(Dir.tmpdir, "test.nt"))
      File.read(filename).should == "#{@stmt_string}\n"
      File.unlink(filename)
    end
  end
end