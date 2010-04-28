Raptor RDF Parser Wrapper for RDF.rb
====================================

This is an [RDF.rb][] plugin that adds support for parsing/serializing
[RDF/XML][] and [Turtle][] data using the [Raptor RDF Parser][Raptor]
library.

* <http://github.com/bendiken/rdf-raptor>
* <http://lists.w3.org/Archives/Public/public-rdf-ruby/2010Apr/0003.html>

Features
--------

* Requires the [Raptor][] library and utilities to be available.
* Based on the [`rapper`][rapper] command-line utility bundled with Raptor.
* Parses and serializes RDF data from/into the RDF/XML or Turtle formats.
* Provides serialization format autodetection for RDF/XML and Turtle.
* Compatible with any operating system supported by Raptor and Ruby.
* Compatible with MRI 1.8.x, 1.9.x and JRuby (tested with JRuby 1.4).

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

* [RDF.rb](http://rubygems.org/gems/rdf) (>= 0.1.9)
* [Raptor][] (>= 1.4.16), specifically the `rapper` binary

Installation
------------

The recommended installation method is via [RubyGems](http://rubygems.org/).
To install the latest official release of the `RDF::Raptor` gem, do:

    % [sudo] gem install rdf-raptor

To install the required [Raptor][] command-line tools themselves, look for a
`raptor` or `raptor-utils` package in your platform's package management
system. Here follow installation instructions for the Mac and the most
common Linux and BSD distributions:

    % [sudo] port install raptor             # Mac OS X with MacPorts
    % [sudo] fink install raptor-bin         # Mac OS X with Fink
    % [sudo] aptitude install raptor-utils   # Ubuntu / Debian
    % [sudo] yum install raptor              # Fedora / CentOS / RHEL
    % [sudo] zypper install raptor           # openSUSE
    % [sudo] emerge raptor                   # Gentoo Linux
    % [sudo] pacman -S raptor                # Arch Linux
    % [sudo] pkg_add -r raptor               # FreeBSD
    % [sudo] pkg_add raptor                  # OpenBSD / NetBSD

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
[rapper]:   http://librdf.org/raptor/rapper.html
