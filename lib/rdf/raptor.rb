require 'rdf' # @see http://rubygems.org/gems/rdf
require 'rdf/raptor/format'

module RDF
  ##
  # **`RDF::Raptor`** is a Raptor RDF Parser plugin for RDF.rb.
  #
  # * {RDF::Raptor::NTriples} provides support for the standard
  #   machine-readable N-Triples format.
  # * {RDF::Raptor::Turtle} provides support for the popular
  #   human-readable Turtle format.
  # * {RDF::Raptor::RDFXML} provides support for the standard
  #   machine-readable RDF/XML format.
  # * {RDF::Raptor::RDFa} provides support for extracting
  #   RDF statements from XHTML+RDFa documents.
  # * {RDF::Raptor::Graphviz} provides support for serializing
  #   RDF statements to the Graphviz DOT format.
  #
  # @example Requiring the `RDF::Raptor` module
  #   require 'rdf/raptor'
  #
  # @example Checking whether Raptor is installed
  #   RDF::Raptor.available?         #=> true
  #
  # @example Obtaining the Raptor version number
  #   RDF::Raptor.version            #=> "1.4.21"
  #
  # @example Obtaining the Raptor engine
  #   RDF::Raptor::ENGINE            #=> :ffi
  #
  # @example Obtaining an N-Triples format class
  #   RDF::Format.for(:ntriples)     #=> RDF::Raptor::NTriples::Format
  #   RDF::Format.for("input.nt")
  #   RDF::Format.for(:file_name      => "input.nt")
  #   RDF::Format.for(:file_extension => "nt")
  #   RDF::Format.for(:content_type   => "text/plain")
  #
  # @example Obtaining a Turtle format class
  #   RDF::Format.for(:turtle)       #=> RDF::Raptor::Turtle::Format
  #   RDF::Format.for("input.ttl")
  #   RDF::Format.for(:file_name      => "input.ttl")
  #   RDF::Format.for(:file_extension => "ttl")
  #   RDF::Format.for(:content_type   => "text/turtle")
  #
  # @example Obtaining an RDF/XML format class
  #   RDF::Format.for(:rdfxml)       #=> RDF::Raptor::RDFXML::Format
  #   RDF::Format.for("input.rdf")
  #   RDF::Format.for(:file_name      => "input.rdf")
  #   RDF::Format.for(:file_extension => "rdf")
  #   RDF::Format.for(:content_type   => "application/rdf+xml")
  #
  # @example Obtaining an RDFa format class
  #   RDF::Format.for(:rdfa)       #=> RDF::Raptor::RDFa::Format
  #   RDF::Format.for("input.html")
  #   RDF::Format.for(:file_name      => "input.html")
  #   RDF::Format.for(:file_extension => "html")
  #   RDF::Format.for(:content_type   => "application/xhtml+xml")
  #
  # {RDF::Raptor} includes an FFI implementation, which loads the
  # `libraptor` library into the Ruby process, as well as a CLI
  # implementation, which drives the `rapper` command-line tool in a
  # sub-process.
  #
  # The FFI implementation is used by default unless the `libraptor` library
  # cannot be found, or if the `RDF_RAPTOR_ENGINE` environment variable is
  # explicitly set to `'cli'`.
  #
  # If the `libraptor` library is in the standard library search path, and
  # the `rapper` command is in the standard command search path, all should
  # be well and work fine out of the box. However, if either is in a
  # non-standard location, be sure to set the `RDF_RAPTOR_LIBPATH` and/or
  # `RDF_RAPTOR_BINPATH` environment variables appropriately before
  # requiring `rdf/raptor`.
  #
  # @see http://rdf.rubyforge.org/
  # @see http://librdf.org/raptor/
  # @see http://wiki.github.com/ffi/ffi/
  #
  # @author [Arto Bendiken](http://github.com/bendiken)
  # @author [John Fieber](http://github.com/jfieber)
  module Raptor
    LIBRAPTOR = ENV['RDF_RAPTOR_LIBPATH'] || 'libraptor2'  unless const_defined?(:LIBRAPTOR)
    RAPPER    = ENV['RDF_RAPTOR_BINPATH'] || 'rapper'     unless const_defined?(:RAPPER)

    require 'rdf/raptor/version'
    begin
      # Try FFI implementation
      raise LoadError if ENV['RDF_RAPTOR_ENGINE'] == 'cli' # override
      require 'rdf/raptor/ffi'
      include RDF::Raptor::FFI
      extend RDF::Raptor::FFI
    rescue LoadError => e
      # CLI fallback
      require 'rdf/raptor/cli'
      include RDF::Raptor::CLI
      extend RDF::Raptor::CLI
    end

    ##
    # Returns `true` if the `rapper` binary is available.
    #
    # @example
    #   RDF::Raptor.available?  #=> true
    #
    # @return [Boolean]
    def self.available?
      !!version
    end

    require 'rdf/raptor/ntriples'
    require 'rdf/raptor/turtle'
    require 'rdf/raptor/rdfxml'
    require 'rdf/raptor/rdfa'
    require 'rdf/raptor/graphviz'
  end # Raptor
end # RDF
