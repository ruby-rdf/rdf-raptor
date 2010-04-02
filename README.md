Raptor RDF Parser Wrapper for RDF.rb
====================================

This is an [RDF.rb][] plugin that adds support for parsing/serializing
[RDF/XML][] and [Turtle][] data using the [Raptor RDF Parser][Raptor]
library.

* <http://github.com/bendiken/rdf-raptor>

Examples
--------

    require 'rdf/raptor'

### Ensuring Raptor is installed and obtaining the version number

    RDF::Raptor.available?         #=> true
    RDF::Raptor.version            #=> "1.4.21"

### Parsing RDF statements from an RDF/XML file

    RDF::Reader.open("http://datagraph.org/jhacker/foaf.rdf") do |reader|
      reader.each_statement do |statement|
        puts statement.inspect
      end
    end

### Parsing RDF statements from a Turtle file

    RDF::Reader.open("http://datagraph.org/jhacker/foaf.ttl") do |reader|
      reader.each_statement do |statement|
        puts statement.inspect
      end
    end

### Serializing RDF statements into an RDF/XML file

    data = RDF::Repository.load("http://datagraph.org/jhacker/foaf.nt")
    
    RDF::Writer.open("output.rdf") do |writer|
      data.each_statement do |statement|
        writer << statement
      end
    end

### Serializing RDF statements into a Turtle file

    data = RDF::Repository.load("http://datagraph.org/jhacker/foaf.nt")
    
    RDF::Writer.open("output.ttl") do |writer|
      data.each_statement do |statement|
        writer << statement
      end
    end

### Obtaining the RDF/XML format specification class

    RDF::Format.for(:rdfxml)       #=> RDF::Raptor::RDFXML::Format
    RDF::Format.for("input.rdf")
    RDF::Format.for(:file_name      => "input.rdf")
    RDF::Format.for(:file_extension => "rdf")
    RDF::Format.for(:content_type   => "application/rdf+xml")

### Obtaining the Turtle format specification class

    RDF::Format.for(:turtle)       #=> RDF::Raptor::Turtle::Format
    RDF::Format.for("input.ttl")
    RDF::Format.for(:file_name      => "input.ttl")
    RDF::Format.for(:file_extension => "ttl")
    RDF::Format.for(:content_type   => "text/turtle")

Documentation
-------------

<http://rdf.rubyforge.org/raptor/>

* {RDF::Raptor}
  * {RDF::Raptor::RDFXML}
  * {RDF::Raptor::Turtle}

Dependencies
------------

* [RDF.rb](http://rubygems.org/gems/rdf) (>= 0.1.3)
* [Raptor](http://librdf.org/raptor/) (>= 1.4.21),
  specifically the `rapper` binary

Installation
------------

The recommended installation method is via RubyGems. To install the latest
official release, do:

    % [sudo] gem install rdf-raptor

Download
--------

To get a local working copy of the development repository, do:

    % git clone git://github.com/bendiken/rdf-raptor.git

Alternatively, you can download the latest development version as a tarball
as follows:

    % wget http://github.com/bendiken/rdf-raptor/tarball/master

Author
------

* [Arto Bendiken](mailto:arto.bendiken@gmail.com) - <http://ar.to/>

License
-------

`RDF::Raptor` is free and unencumbered public domain software. For more
information, see <http://unlicense.org/> or the accompanying UNLICENSE file.

[RDF.rb]:   http://rdf.rubyforge.org/
[RDF/XML]:  http://www.w3.org/TR/REC-rdf-syntax/
[Turtle]:   http://en.wikipedia.org/wiki/Turtle_(syntax)
[Raptor]:   http://librdf.org/raptor/
