module RDF::Raptor::FFI::V1_4
  ##
  # @see http://librdf.org/raptor/api-1.4/raptor-section-serializer.html
  class Serializer < ::FFI::ManagedStruct
    include RDF::Raptor::FFI
    layout :world, :pointer # the actual layout is private

    ##
    # @overload initialize(ptr)
    #   @param  [FFI::Pointer] ptr
    #
    # @overload initialize(name)
    #   @param  [Symbol, String] name
    #
    def initialize(name)
      ptr = case name
        when FFI::Pointer then name
        when Symbol       then V1_4.raptor_new_serializer(name.to_s)
        when String       then V1_4.raptor_new_serializer(name)
        else nil
      end
      raise ArgumentError, "invalid argument: #{name.inspect}" if ptr.nil? || ptr.null?
      super(ptr)
    end

    ##
    # Releases `libraptor` memory associated with this structure.
    #
    # @param  [FFI::Pointer] ptr
    # @return [void]
    def self.release(ptr)
      V1_4.raptor_free_serializer(ptr)
    end
  end # Serializer
end # RDF::Raptor::FFI::V1_4
