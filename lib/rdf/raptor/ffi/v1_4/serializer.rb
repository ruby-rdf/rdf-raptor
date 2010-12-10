module RDF::Raptor::FFI::V1_4
  ##
  # This class provides the functionality of turning RDF triples into
  # syntaxes - RDF serializing.
  #
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
    def initialize(ptr_or_name)
      ptr = case ptr_or_name
        when FFI::Pointer then ptr_or_name
        when Symbol       then V1_4.raptor_new_serializer(ptr_or_name.to_s)
        when String       then V1_4.raptor_new_serializer(ptr_or_name)
        else nil
      end
      raise ArgumentError, "invalid argument: #{ptr_or_name.inspect}" if ptr.nil? || ptr.null?
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

    ##
    # @param  [Proc] handler
    # @return [void]
    def error_handler=(handler)
      V1_4.raptor_serializer_set_error_handler(self, self, handler)
    end

    ##
    # @param  [Proc] handler
    # @return [void]
    def warning_handler=(handler)
      V1_4.raptor_serializer_set_warning_handler(self, self, handler)
    end
  end # Serializer
end # RDF::Raptor::FFI::V1_4
