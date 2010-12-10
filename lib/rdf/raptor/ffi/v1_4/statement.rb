module RDF::Raptor::FFI::V1_4
  ##
  # @see http://librdf.org/raptor/api-1.4/raptor-section-triples.html
  class Statement < ::FFI::Struct
    include RDF::Raptor::FFI
    layout :subject, :pointer,
           :subject_type, :int,
           :predicate, :pointer,
           :predicate_type, :int,
           :object, :pointer,
           :object_type, :int,
           :object_literal_datatype, :pointer,
           :object_literal_language, :pointer

    ##
    # @param  [FFI::Pointer] ptr
    # @param  [#create_node] factory
    def initialize(ptr = nil, factory = nil)
      super(ptr)
      @factory = factory if factory
    end

    ##
    # Releases `libraptor` memory associated with this structure.
    #
    # @param  [FFI::Pointer] ptr
    # @return [void]
    def self.release(ptr)
      raptor_free_memory(ptr) unless ptr.null?
    end

    # @return [Object]
    attr_accessor :id

    # @return [RDF::Resource]
    attr_accessor :context

    ##
    # @return [RDF::Resource]
    def subject
      @subject ||= case self[:subject_type]
        when RAPTOR_IDENTIFIER_TYPE_ANONYMOUS
          @factory.create_node(self[:subject].read_string)
        when RAPTOR_IDENTIFIER_TYPE_RESOURCE
          @factory.create_uri(V1_4.raptor_uri_as_string(self[:subject]))
      end
    end

    ##
    # Sets the subject term from an `RDF::Resource`.
    #
    # @param  [RDF::Resource] value
    # @return [void]
    def subject=(resource)
      @subject = nil
      case resource
        when RDF::Node
          self[:subject_type] = RAPTOR_IDENTIFIER_TYPE_ANONYMOUS
          self[:subject] = V1_4.raptor_new_string(resource.id.to_s)
        when RDF::URI
          self[:subject_type] = RAPTOR_IDENTIFIER_TYPE_RESOURCE
          self[:subject] = V1_4.raptor_new_uri(resource.to_s)
        else
          raise ArgumentError, "subject term must be an RDF::Node or RDF::URI"
      end
      @subject = resource
    end

    ##
    # @return [String]
    def subject_as_string
      V1_4.raptor_statement_part_as_string(
        self[:subject],
        self[:subject_type],
        nil, nil)
    end

    ##
    # @return [RDF::URI]
    def predicate
      @predicate ||= case self[:predicate_type]
        when RAPTOR_IDENTIFIER_TYPE_RESOURCE
          RDF::URI.intern(V1_4.raptor_uri_as_string(self[:predicate]))
      end
    end

    ##
    # Sets the predicate term from an `RDF::URI`.
    #
    # @param  [RDF::URI] value
    # @return [void]
    def predicate=(uri)
      @predicate = nil
      raise ArgumentError, "predicate term must be an RDF::URI" unless uri.is_a?(RDF::URI)
      self[:predicate_type] = RAPTOR_IDENTIFIER_TYPE_RESOURCE
      self[:predicate] = V1_4.raptor_new_uri(uri.to_s)
      @predicate = uri
    end

    ##
    # @return [String]
    def predicate_as_string
      V1_4.raptor_statement_part_as_string(
        self[:predicate],
        self[:predicate_type],
        nil, nil)
    end

    ##
    # @return [RDF::Term]
    def object
      @object ||= case self[:object_type]
        when RAPTOR_IDENTIFIER_TYPE_ANONYMOUS
          @factory.create_node(self[:object].read_string)
        when RAPTOR_IDENTIFIER_TYPE_RESOURCE
          @factory.create_uri(V1_4.raptor_uri_as_string(self[:object]))
        when RAPTOR_IDENTIFIER_TYPE_LITERAL
          str = self[:object].read_string.unpack('U*').pack('U*')
          case
            when !self[:object_literal_language].null?
              RDF::Literal.new(str, :language => self[:object_literal_language].read_string)
            when !self[:object_literal_datatype].null?
              RDF::Literal.new(str, :datatype => V1_4.raptor_uri_as_string(self[:object_literal_datatype]))
            else
              RDF::Literal.new(str)
          end
      end
    end

    ##
    # Sets the object term from an `RDF::Term`.
    #
    # The value must be one of `RDF::Resource` or `RDF::Literal`.
    #
    # @param  [RDF::Term] value
    # @return [void]
    def object=(value)
      @object = nil
      case value
        when RDF::Node
          self[:object_type] = RAPTOR_IDENTIFIER_TYPE_ANONYMOUS
          self[:object] = V1_4.raptor_new_string(value.id.to_s)
        when RDF::URI
          self[:object_type] = RAPTOR_IDENTIFIER_TYPE_RESOURCE
          self[:object] = V1_4.raptor_new_uri(value.to_s)
        when RDF::Literal
          self[:object_type] = RAPTOR_IDENTIFIER_TYPE_LITERAL
          self[:object] = V1_4.raptor_new_string(value.value)
          self[:object_literal_datatype] = V1_4.raptor_new_uri(value.datatype.to_s) if value.datatype
          self[:object_literal_language] = V1_4.raptor_new_string(value.language.to_s) if value.language?
        else
          raise ArgumentError, "object term must be an RDF::Node, RDF::URI, or RDF::Literal"
      end
      @object = value
    end

    ##
    # @return [String]
    def object_as_string
      V1_4.raptor_statement_part_as_string(
        self[:object],
        self[:object_type],
        self[:object_literal_datatype],
        self[:object_literal_language])
    end

    ##
    # @return [Array(RDF::Resource, RDF::URI, RDF::Term)]
    # @see    RDF::Statement#to_triple
    def to_triple
      [subject, predicate, object]
    end

    ##
    # @return [Array(RDF::Resource, RDF::URI, RDF::Term, nil)]
    # @see    RDF::Statement#to_quad
    def to_quad
      [subject, predicate, object, context]
    end

    ##
    # @return [RDF::Statement]
    def to_rdf
      RDF::Statement.new(subject, predicate, object, :context => context)
    end

    ##
    # @return [void]
    def reset!
      @subject = @predicate = @object = @context = nil
    end

    ##
    # Releases `libraptor` memory associated with this structure.
    #
    # @return [void]
    def free
      if self[:subject_type].nonzero? && !(self[:subject].null?)
        self[:subject] = case self[:subject_type]
          when RAPTOR_IDENTIFIER_TYPE_ANONYMOUS
            V1_4.raptor_free_string(self[:subject])
          when RAPTOR_IDENTIFIER_TYPE_RESOURCE
            V1_4.raptor_free_uri(self[:subject])
        end
        self[:subject_type] = RAPTOR_IDENTIFIER_TYPE_UNKNOWN
      end

      if self[:predicate_type].nonzero? && !(self[:predicate].null?)
        self[:predicate] = V1_4.raptor_free_uri(self[:predicate])
        self[:predicate_type] = RAPTOR_IDENTIFIER_TYPE_UNKNOWN
      end

      if self[:object_type].nonzero? && !(self[:object].null?)
        self[:object] = case self[:object_type]
          when RAPTOR_IDENTIFIER_TYPE_ANONYMOUS
            V1_4.raptor_free_string(self[:object])
          when RAPTOR_IDENTIFIER_TYPE_RESOURCE
            V1_4.raptor_free_uri(self[:object])
          when RAPTOR_IDENTIFIER_TYPE_LITERAL
            V1_4.raptor_free_string(self[:object])
            unless self[:object_literal_datatype].null?
              self[:object_literal_datatype] = V1_4.raptor_free_uri(self[:object_literal_datatype])
            end
            unless self[:object_literal_language].null?
              self[:object_literal_language] = V1_4.raptor_free_string(self[:object_literal_language])
            end
        end
        self[:object_type] = RAPTOR_IDENTIFIER_TYPE_UNKNOWN
      end
    end
    alias_method :release, :free
  end # Statement
end # RDF::Raptor::FFI::V1_4
