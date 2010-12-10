module RDF::Raptor::FFI::V1_4
  ##
  # Raptor has a `raptor_uri` class which must be used for manipulating and
  # passing URI references. The default internal implementation uses `char*`
  # strings for URIs, manipulating them and constructing them.
  #
  # @see http://librdf.org/raptor/api-1.4/raptor-section-uri.html
  class URI < ::FFI::ManagedStruct
    include RDF::Raptor::FFI
    include RDF::Resource
    layout :string, [:char, 1] # a safe dummy layout, since it is \0-terminated

    ##
    # @overload initialize(ptr)
    #   @param  [FFI::Pointer] ptr
    #
    # @overload initialize(name)
    #   @param  [RDF::URI, String] name
    #
    def initialize(ptr_or_name)
      ptr = case ptr_or_name
        when FFI::Pointer then ptr_or_name
        when RDF::URI     then V1_4.raptor_new_uri(ptr_or_name.to_s)
        when String       then V1_4.raptor_new_uri(ptr_or_name)
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
      V1_4.raptor_free_uri(ptr)
    end

    ##
    # @return [Boolean] `true`
    def uri?
      true
    end

    ##
    # @return [URI] a copy of `self`
    def dup
      copy = self.class.new(V1_4.raptor_uri_copy(self))
      copy.taint if tainted?
      copy
    end

    ##
    # @return [URI] a copy of `self`
    def clone
      copy = self.class.new(V1_4.raptor_uri_copy(self))
      copy.taint  if tainted?
      copy.freeze if frozen?
      copy
    end

    ##
    # @return [Integer]
    def length
      LibC.strlen(self)
    end
    alias_method :size, :length

    ##
    # @return [Boolean] `true` or `false`
    def ==(other)
      return true if self.equal?(other)
      case other
        when self.class
          !(V1_4.raptor_uri_equals(self, other).zero?)
        when RDF::URI, String
          to_str == other.to_str
        else false
      end
    end
    alias_method :===, :==

    ##
    # @return [Boolean] `true` or `false`
    def eql?(other)
      return true if self.equal?(other)
      other.is_a?(self.class) && !(V1_4.raptor_uri_equals(self, other).zero?)
    end

    ##
    # @return [Fixnum]
    def hash
      to_str.hash
    end

    ##
    # @return [String] the URI string
    def to_str
      V1_4.raptor_uri_as_string(self)
    end
    alias_method :to_s, :to_str

    ##
    # @return [RDF::URI]
    def to_rdf
      RDF::URI.intern(to_str)
    end
    alias_method :to_uri, :to_rdf
  end # URI
end # RDF::Raptor::FFI::V1_4
