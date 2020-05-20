module RDF::Raptor::FFI::V2
  ##
  # @see https://librdf.org/raptor/api-1.4/raptor-section-triples.html
  class Term < ::FFI::Struct
    include RDF::Raptor::FFI
    
    class LiteralValue < ::FFI::Struct
      include RDF::Raptor::FFI
      
      layout  :string, :string,
              :string_len, :int,
              :datatype, :pointer,
              :language, :string,
              :language_len, :char
      
      def to_str
        self[:string].unpack('U*').pack('U*')
      end
      
      def language
        unless self[:language].nil? or self[:language].empty?
          self[:language]
        end
      end
      
      def datatype
        if self[:datatype] && !self[:datatype].null?
          RDF::URI.intern(V2.raptor_uri_to_string(self[:datatype]))
        end
      end
      
      def to_rdf
        str = self.to_str
        case
          when language = self.language
            RDF::Literal.new(str, language: language)
          when datatype = self.datatype
            RDF::Literal.new(str, datatype: datatype)
          else
            RDF::Literal.new(str)
        end
      end
    end
    
    class BlankValue < ::FFI::Struct
      layout :string, :string,
              :string_len, :int
      
      def to_str
        self[:string]
      end
    end

    class Value < ::FFI::Union
      include RDF::Raptor::FFI
      
      layout :uri, :pointer,
             :literal, LiteralValue,
             :blank, BlankValue
    end

    layout  :world, :pointer,
            :usage, :int,
            :type, :int,
            :value, Value
    ##
    # @param  [FFI::Pointer] ptr
    # @param  [#create_node] factory
    def initialize(ptr = nil, factory = nil)
      super(ptr)
      @factory = factory if factory
    end
    
    def value
      case self[:type]
        when RAPTOR_TERM_TYPE_BLANK
          @factory.create_node(self[:value][:blank].to_str)
        when RAPTOR_TERM_TYPE_URI
          @factory.create_uri(V2.raptor_uri_as_string(self[:value][:uri]))
        when RAPTOR_TERM_TYPE_LITERAL
          self[:value][:literal].to_rdf
      end
    end

    ##
    # Releases `libraptor` memory associated with this structure.
    #
    # @param  [FFI::Pointer] ptr
    # @return [void]
    def release(ptr = nil)
      V2.raptor_free_term(self) unless ptr.null?
    end
    
  end # Term
end # RDF::Raptor::FFI::V2
