module RDF::Raptor::FFI::V2
  ##
  # @see http://librdf.org/raptor/api/raptor2-section-xml-namespace.html
  class Namespace < ::FFI::Struct
    include RDF::Raptor::FFI
    # @see https://github.com/dajobe/raptor/blob/f4b2597d4279dcb283bf5c32e5435696fd28a8ec/src/raptor_internal.h#L428
    layout  :next, :pointer,
            :nstack, :pointer,
            :prefix, :string,
            :prefix_length, :int,
            :uri, :pointer,
            :depth, :int,
            :is_xml, :int,
            :is_rdf_ms, :int,
            :is_rdf_schema, :int

    def prefix
      self[:prefix].to_s
    end

    def prefix_length
      self[:prefix_length]
    end

    def uri
      RDF::URI.new(V2.raptor_uri_as_string(self[:uri]))
    end

    ##
    # Releases `libraptor` memory associated with this structure.
    #
    # @return [void]
    def free
      V2.raptor_free_namespace(self) unless ptr.null?
    end
    alias_method :release, :free
  end
end