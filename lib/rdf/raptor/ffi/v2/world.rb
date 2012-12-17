module RDF::Raptor::FFI::V2
  class World < ::FFI::AutoPointer
    include RDF::Raptor::FFI

    def initialize()
      ptr = V2.raptor_new_world_internal(V2.raptor_version_decimal)
      super(ptr, self.class.method(:release))
    end

    ##
    # Releases `libraptor` memory associated with this structure.
    #
    # @param  [FFI::Pointer] ptr
    # @return [void]
    def self.release(ptr)
      V2.raptor_free_world(ptr)
    end

  end # World
end # RDF::Raptor::FFI::V2
