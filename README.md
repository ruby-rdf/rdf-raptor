Raptor RDF Parser Wrapper for RDF.rb
====================================

This is an [RDF.rb][] plugin that adds support for parsing/serializing
[RDF/XML][] and [Turtle][] data using the [Raptor RDF Parser][Raptor]
library.

* <http://github.com/bendiken/rdf-raptor>

Examples
--------

    require 'rdf/raptor'

### Parsing an RDF/XML file

    RDF::Reader.open('http://datagraph.org/jhacker/foaf.rdf') do |reader|
      reader.each_statement do |statement|
        puts statement.inspect
      end
    end

### Parsing a Turtle file

    RDF::Reader.open('http://datagraph.org/jhacker/foaf.ttl') do |reader|
      reader.each_statement do |statement|
        puts statement.inspect
      end
    end

Documentation
-------------

<http://rdf.rubyforge.org/raptor/>

* {RDF::Raptor}
  * {RDF::Raptor::RDFXML}
  * {RDF::Raptor::Turtle}

Dependencies
------------

* [RDF.rb](http://rubygems.org/gems/rdf) (>= 0.1.3)
* [Raptor](http://librdf.org/raptor/) (>= 1.4.21)

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
