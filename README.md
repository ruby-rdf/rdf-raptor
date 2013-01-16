Raptor RDF Parser Plugin for RDF.rb
===================================
[![Build Status](https://secure.travis-ci.org/ruby-rdf/rdf-raptor.png?branch=master)](http://travis-ci.org/ruby-rdf/rdf-raptor)

This is an [RDF.rb][] plugin that adds support for parsing/serializing [NTriples][]
[RDF/XML][], [Turtle][] and [RDFa][] data using the [Raptor RDF Parser][Raptor]
library.

* <http://github.com/ruby-rdf/rdf-raptor>
* <http://blog.datagraph.org/2010/04/parsing-rdf-with-ruby>

Features
--------

* Uses the fast [Raptor][] C library.
* Parses and serializes RDF data from/into the RDF/XML or Turtle formats.
* Extracts RDF statements from XHTML+RDFa documents.
* Provides serialization format autodetection for RDF/XML, Turtle and RDFa.
* Compatible with any operating system supported by Raptor and Ruby.
* Compatible with MRI 1.8.x, 1.9.x, REE, JRuby and Rubinius (1.8 and 1.9 mode).

Examples
--------

    require 'rdf/raptor'

### Ensuring Raptor is installed and obtaining the version number

    RDF::Raptor.available?         #=> true
    RDF::Raptor.version            #=> "2.0.8"

### Parsing RDF statements from an NTriples file

    RDF::Reader.open("http://datagraph.org/jhacker/foaf.nt") do |reader|
      reader.each_statement do |statement|
        puts statement.inspect
      end
    end

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

### Extracting RDF statements from an HTML+RDFa document

    RDF::Reader.open(url = "http://bblfish.net/", :format => :rdfa, :base_uri => url) do |reader|
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

### Obtaining the NTriples format specification class

    RDF::Format.for(:ntriples)      #=> RDF::Raptor::NTriples::Format
    RDF::Format.for("input.nt")
    RDF::Format.for(:file_name      => "input.nt")
    RDF::Format.for(:file_extension => "nt")
    RDF::Format.for(:content_type   => "application/n-triples")

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

### Obtaining the RDFa format specification class

    RDF::Format.for(:rdfa)         #=> RDF::Raptor::RDFa::Format
    RDF::Format.for("input.html")
    RDF::Format.for(:file_name      => "input.html")
    RDF::Format.for(:file_extension => "html")
    RDF::Format.for(:content_type   => "application/xhtml+xml")

Documentation
-------------

<http://rdf.rubyforge.org/raptor/>

* {RDF::Raptor}
  * {RDF::Raptor::NTriples}
  * {RDF::Raptor::Turtle}
  * {RDF::Raptor::RDFXML}
  * {RDF::Raptor::RDFa}
  * {RDF::Raptor::Graphviz}

Dependencies
------------

* [RDF.rb](http://rubygems.org/gems/rdf) (>= 0.3.8)
* [FFI](http://rubygems.org/gems/ffi) (>= 1.0.0)
* [Raptor][] (>= 2.0), the `libraptor` library or the `rapper` binary

Installation
------------

The recommended installation method is via [RubyGems](http://rubygems.org/).
To install the latest official release of the `RDF::Raptor` gem, do:

    % [sudo] gem install rdf-raptor

To install the required [Raptor][] command-line tools themselves, look for a
`raptor` or `raptor-utils` package in your platform's package management
system. For your convenience, here follow installation instructions for the
Mac and the most common Linux and BSD distributions:

    % [sudo] port install raptor             # Mac OS X with MacPorts
    % [sudo] fink install raptor-bin         # Mac OS X with Fink
    % brew install raptor                    # Mac OS X with Homebrew
    % [sudo] aptitude install raptor-utils   # Ubuntu / Debian with aptitude
    % [sudo] apt-get install libraptor2-0    # Ubuntu / Debian with apt-get
    % [sudo] yum install raptor              # Fedora / CentOS / RHEL
    % [sudo] zypper install raptor           # openSUSE
    % [sudo] emerge raptor                   # Gentoo Linux
    % [sudo] pacman -S raptor                # Arch Linux
    % [sudo] pkg_add -r raptor               # FreeBSD
    % [sudo] pkg_add raptor                  # OpenBSD / NetBSD

Download
--------

To get a local working copy of the development repository, do:

    % git clone git://github.com/ruby-rdf/rdf-raptor.git

Alternatively, download the latest development version as a tarball as
follows:

    % wget http://github.com/ruby-rdf/rdf-raptor/tarball/master

Mailing List
------------

* <http://lists.w3.org/Archives/Public/public-rdf-ruby/>

Authors
-------

* [Arto Bendiken](http://github.com/bendiken) - <http://ar.to/>
* [John Fieber](http://github.com/jfieber) - <http://github.com/jfieber>

Contributors
------------

* [Ben Lavender](http://github.com/bhuga) - <http://bhuga.net/>
* [David Butler](http://github.com/dwbutler)
* [Gregg Kellogg](http://github.com/gkellogg) - <http://greggkellogg.net/>

License
-------

This is free and unencumbered public domain software. For more information,
see <http://unlicense.org/> or the accompanying {file:UNLICENSE} file.

[RDF.rb]:   http://rdf.rubyforge.org/
[NTriples]: http://en.wikipedia.org/wiki/N-Triples
[RDF/XML]:  http://www.w3.org/TR/REC-rdf-syntax/
[Turtle]:   http://en.wikipedia.org/wiki/Turtle_(syntax)
[RDFa]:     http://rdfa.info/
[Raptor]:   http://librdf.org/raptor/
[rapper]:   http://librdf.org/raptor/rapper.html
