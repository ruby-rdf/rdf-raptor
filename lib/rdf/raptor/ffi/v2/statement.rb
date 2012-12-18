module RDF::Raptor::FFI::V2
  ##
  # @see http://librdf.org/raptor/api-1.4/raptor-section-triples.html
  class Statement < ::FFI::Struct
    include RDF::Raptor::FFI
    layout  :world, :pointer,
            :usage, :int,
            :subject, :pointer,
            :predicate, :pointer,
            :object, :pointer,
            :graph, :pointer

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
    # @return [void]
    def release
      V2.raptor_free_statement(ptr) unless ptr.null?
    end

    # @return [Object]
    attr_accessor :id

    # @return [RDF::Resource]
    attr_accessor :context

    ##
    # @return [RDF::Resource]
    def subject
      @subject ||= V2::Term.new(self[:subject], @factory).value
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
          self[:subject] = V2.raptor_new_term_from_blank(V2.world, resource.id.to_s)
        when RDF::URI
          self[:subject] = V2.raptor_new_term_from_uri_string(V2.world, resource.to_s)
        else
          raise ArgumentError, "subject term must be an RDF::Node or RDF::URI"
      end
      @subject = resource
    end

    ##
    # @return [RDF::URI]
    def predicate
      @predicate ||= V2::Term.new(self[:predicate], @factory).value
    end

    ##
    # Sets the predicate term from an `RDF::URI`.
    #
    # @param  [RDF::URI] value
    # @return [void]
    def predicate=(uri)
      @predicate = nil
      raise ArgumentError, "predicate term must be an RDF::URI" unless uri.is_a?(RDF::URI)
      self[:predicate] = V2.raptor_new_term_from_uri_string(V2.world, uri.to_s)
      @predicate = uri
    end

    ##
    # @return [RDF::Term]
    def object
      @object ||= V2::Term.new(self[:object], @factory).value
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
          self[:object] = V2.raptor_new_term_from_blank(V2.world, value.id.to_s)
        when RDF::URI
          self[:object] = V2.raptor_new_term_from_uri_string(V2.world, value.to_s)
        when RDF::Literal
          self[:object] = V2.raptor_new_term_from_literal(V2.world, value.to_s,
            value.datatype? ? V2.raptor_new_uri(value.datatype.to_s) : nil,
            value.language? ? V2.raptor_new_string(value.language.to_s) : nil)
        else
          raise ArgumentError, "object term must be an RDF::Node, RDF::URI, or RDF::Literal"
      end
      @object = value
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
      V2.raptor_free_statement(self)
      @subject = @predicate = @object = nil # Allow GC to start
    end
    alias_method :release, :free
  end # Statement
end # RDF::Raptor::FFI::V2
