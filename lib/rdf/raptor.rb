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
  # @see http://rdf.rubyforge.org/
  # @see http://librdf.org/raptor/
  #
  # @author [Arto Bendiken](http://ar.to/)
  module Raptor
    ENGINE    = (ENV['RDF_RAPTOR_ENGINE'] || :cli).to_sym unless const_defined?(:ENGINE)
    LIBRAPTOR = ENV['RDF_RAPTOR_LIBPATH'] || 'libraptor'  unless const_defined?(:LIBRAPTOR)
    RAPPER    = ENV['RDF_RAPTOR_BINPATH'] || 'rapper'     unless const_defined?(:RAPPER)

    require 'rdf/raptor/version'
    require 'rdf/raptor/cli'
    require 'rdf/raptor/ffi' if ENGINE == :ffi

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
    # Returns the installed `rapper` version number, or `nil` if `rapper` is
    # not available.
    #
    # @example
    #   RDF::Raptor.version  #=> "1.4.21"
    #
    # @return [String]
    def self.version
      if `#{RAPPER} --version 2>/dev/null` =~ /^(\d+)\.(\d+)\.(\d+)/
        [$1, $2, $3].join('.')
      end
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

    ##
    # Reader base class.
    class Reader < RDF::Reader
      include RDF::Raptor::CLI::Reader if ENGINE == :cli
      include RDF::Raptor::FFI::Reader if ENGINE == :ffi
    end

    ##
    # Writer base class.
    class Writer < RDF::Writer
      include RDF::Raptor::CLI::Writer if ENGINE == :cli
      include RDF::Raptor::FFI::Writer if ENGINE == :ffi
    end

    require 'rdf/raptor/rdfxml'
    require 'rdf/raptor/turtle'
    require 'rdf/raptor/rdfa'
  end # module Raptor
end # module RDF
