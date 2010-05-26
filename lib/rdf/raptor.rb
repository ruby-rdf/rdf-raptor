require 'rdf'

module RDF
  ##
  # **`RDF::Raptor`** is a Raptor RDF Parser wrapper for RDF.rb.
  #
  # * {RDF::Raptor::RDFXML} provides support for the standard
  #   machine-readable RDF/XML format.
  # * {RDF::Raptor::Turtle} provides support for the popular
  #   human-readable Turtle format.
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
  # @example Obtaining an RDF/XML format class
  #   RDF::Format.for(:rdfxml)       #=> RDF::Raptor::RDFXML::Format
  #   RDF::Format.for("input.rdf")
  #   RDF::Format.for(:file_name      => "input.rdf")
  #   RDF::Format.for(:file_extension => "rdf")
  #   RDF::Format.for(:content_type   => "application/rdf+xml")
  #
  # @example Obtaining a Turtle format class
  #   RDF::Format.for(:turtle)       #=> RDF::Raptor::Turtle::Format
  #   RDF::Format.for("input.ttl")
  #   RDF::Format.for(:file_name      => "input.ttl")
  #   RDF::Format.for(:file_extension => "ttl")
  #   RDF::Format.for(:content_type   => "text/turtle")
  #
  # @example Obtaining an RDFa format class
  #   RDF::Format.for(:rdfa)       #=> RDF::Raptor::RDFa::Format
  #   RDF::Format.for("input.html")
  #   RDF::Format.for(:file_name      => "input.html")
  #   RDF::Format.for(:file_extension => "html")
  #   RDF::Format.for(:content_type   => "application/xhtml+xml")
  #
  # {RDF::Raptor} includes an ffi implementation, which loads
  # the libraptor library into the ruby process, and a cli
  # implementation, which uses the rapper command line tool
  # in a subprocess.  The ffi implementation is used unless
  # libraptor library is not found, or the RDF_RAPTOR_ENGINE
  # environment variable is set to 'cli'.
  #
  # If the libraptor library is in the standard library search
  # path, and the rapper command is in the standard command
  # search path, all should be well.  If either is in a
  # non-standard location, set the RDF_RAPTOR_LIBPATH and/or
  # RDF_RAPTOR_BINPATH appropriately before requiring rdf/raptor.
  #
  # @see http://rdf.rubyforge.org/
  # @see http://librdf.org/raptor/
  # @see http://wiki.github.com/ffi/ffi/
  #
  # @author [Arto Bendiken](http://ar.to/)
  # @author [John Fieber](http://github.com/jfieber)
  module Raptor
    LIBRAPTOR = ENV['RDF_RAPTOR_LIBPATH'] || 'libraptor'  unless const_defined?(:LIBRAPTOR)
    RAPPER    = ENV['RDF_RAPTOR_BINPATH'] || 'rapper'     unless const_defined?(:RAPPER)

    require 'rdf/raptor/version'
    begin
      # Try ffi implementation
      raise LoadError if ENV['RDF_RAPTOR_ENGINE'] == 'cli' # override
      require 'rdf/raptor/ffi'
      include RDF::Raptor::FFI
      extend RDF::Raptor::FFI
    rescue LoadError => e
      # cli fallback
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

    ##
    # Format base class.
    class Format < RDF::Format
      ##
      # @overload rapper_format
      #
      # @overload rapper_format(format)
      #   @param  [Symbol] format
      #
      # @return [void]
      def self.rapper_format(format = nil)
        unless format
          @rapper_format
        else
          @rapper_format = format
        end
      end
    end

    require 'rdf/raptor/rdfxml'
    require 'rdf/raptor/turtle'
    require 'rdf/raptor/rdfa'
    require 'rdf/raptor/graphviz'
  end # module Raptor
end # module RDF
