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
    # @param  [FFI::Pointer] pointer
    # @param  [#create_node] factory
    def initialize(pointer = nil, factory = nil)
      super(pointer)
      @factory = factory if factory

      # Objects we need to keep a Ruby reference to so they don't get
      # garbage collected out from under the C code we pass them to.
      @mp = {}

      # Raptor object references we need to explicitly free when `#release`
      # is called.
      @raptor_uri_list = []
    end

    ##
    # Releases `libraptor` memory associated with this struct.
    #
    # Use of the object after calling this will most likely cause a
    # crash. This is kind of ugly.
    #
    # @return [void]
    def release
      if pointer.kind_of?(::FFI::MemoryPointer) && !pointer.null?
        pointer.free
      end
      while uri = @raptor_uri_list.pop
        V1_4.raptor_free_uri(uri) unless uri.nil? || uri.null?
      end
    end

    ##
    # @return [RDF::Resource]
    def subject
      @subject ||= case self[:subject_type]
        when RAPTOR_IDENTIFIER_TYPE_RESOURCE
          @factory.create_uri(V1_4.raptor_uri_to_string(self[:subject]))
        when RAPTOR_IDENTIFIER_TYPE_ANONYMOUS
          @factory.create_node(self[:subject].read_string)
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
          self[:subject] = @mp[:subject] = ::FFI::MemoryPointer.from_string(resource.id.to_s)
          self[:subject_type] = RAPTOR_IDENTIFIER_TYPE_ANONYMOUS
        when RDF::URI
          self[:subject] = @mp[:subject] = @raptor_uri_list.push(V1_4.raptor_new_uri(resource.to_s)).last
          self[:subject_type] = RAPTOR_IDENTIFIER_TYPE_RESOURCE
        else
          raise ArgumentError, "subject must be of kind RDF::Node or RDF::URI"
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
          RDF::URI.intern(V1_4.raptor_uri_to_string(self[:predicate]))
      end
    end

    ##
    # Sets the predicate term from an `RDF::URI`.
    #
    # @param  [RDF::URI] value
    # @return [void]
    def predicate=(uri)
      @predicate = nil
      raise ArgumentError, "predicate must be a kind of RDF::URI" unless uri.kind_of?(RDF::URI)
      self[:predicate] = @raptor_uri_list.push(V1_4.raptor_new_uri(uri.to_s)).last
      self[:predicate_type] = RAPTOR_IDENTIFIER_TYPE_RESOURCE
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
        when RAPTOR_IDENTIFIER_TYPE_RESOURCE
          @factory.create_uri(V1_4.raptor_uri_to_string(self[:object]))
        when RAPTOR_IDENTIFIER_TYPE_ANONYMOUS
          @factory.create_node(self[:object].read_string)
        when RAPTOR_IDENTIFIER_TYPE_LITERAL
          str = self[:object].read_string.unpack('U*').pack('U*')
          case
            when self[:object_literal_language] && !self[:object_literal_language].null?
              RDF::Literal.new(str, :language => self[:object_literal_language].read_string)
            when self[:object_literal_datatype] && !self[:object_literal_datatype].null?
              RDF::Literal.new(str, :datatype => V1_4.raptor_uri_to_string(self[:object_literal_datatype]))
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
          self[:object] = @mp[:object] = ::FFI::MemoryPointer.from_string(value.id.to_s)
          self[:object_type] = RAPTOR_IDENTIFIER_TYPE_ANONYMOUS
        when RDF::URI
          self[:object] = @mp[:object] = @raptor_uri_list.push(V1_4.raptor_new_uri(value.to_s)).last
          self[:object_type] = RAPTOR_IDENTIFIER_TYPE_RESOURCE
        when RDF::Literal
          self[:object_type] = RAPTOR_IDENTIFIER_TYPE_LITERAL
          self[:object] = @mp[:object] = ::FFI::MemoryPointer.from_string(value.value)
          self[:object_literal_datatype] = if value.datatype
            @raptor_uri_list.push(V1_4.raptor_new_uri(value.datatype.to_s)).last
          else
            nil
          end
          self[:object_literal_language] = @mp[:object_literal_language] = if value.language?
            ::FFI::MemoryPointer.from_string(value.language.to_s)
          else
            nil
          end
        else
          raise ArgumentError, "object must be of type RDF::Node, RDF::URI or RDF::Literal"
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
      [subject, predicate, object, nil]
    end
  end # Statement
end # RDF::Raptor::FFI::V1_4
