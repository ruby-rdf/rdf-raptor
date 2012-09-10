module RDF::Raptor::FFI::V2
  ##
  # @see http://librdf.org/raptor/api-1.4/raptor-section-triples.html
  class Term < ::FFI::ManagedStruct
    include RDF::Raptor::FFI
    
    class LiteralValue < ::FFI::Struct
      include RDF::Raptor::FFI
      
      layout  :string, :string,
              :string_len, :int,
              :datatype, V2::URI,
              :language, :string,
              :language_len, :char
      
      def to_str
        self[:string].unpack('U*').pack('U*')
      end
      
      def language
        if self[:language] && !self[:language].null?
          self[:language]
        end
      end
      
      def datatype
        if self[:datatype] && !self[:datatype].null? && self[:datatype].to_s
          self[:datatype].to_rdf
        end
      end
      
      def to_rdf
        str = self.to_str
        case
          when language = self.language
            RDF::Literal.new(str, :language => language)
          when datatype = self.datatype
            RDF::Literal.new(str, :datatype => datatype)
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
      
      layout :uri, V2::URI,
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
          @factory.create_uri(self[:value][:uri].to_str)
        when RAPTOR_TERM_TYPE_LITERAL
          self[:value][:literal].to_rdf
      end
    end

    ##
    # Releases `libraptor` memory associated with this structure.
    #
    # @param  [FFI::Pointer] ptr
    # @return [void]
    def self.release(ptr)
      raptor_free_memory(ptr) unless ptr.null?
    end
    
  end # Term
end # RDF::Raptor::FFI::V2
