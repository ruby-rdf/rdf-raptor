module RDF::Raptor::FFI::V1
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
        when Symbol       then V1.raptor_new_serializer(ptr_or_name.to_s)
        when String       then V1.raptor_new_serializer(ptr_or_name)
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
      V1.raptor_free_serializer(ptr)
    end

    ##
    # @param  [Proc] handler
    # @return [void]
    def error_handler=(handler)
      V1.raptor_serializer_set_error_handler(self, self, handler)
    end

    ##
    # @param  [Proc] handler
    # @return [void]
    def warning_handler=(handler)
      V1.raptor_serializer_set_warning_handler(self, self, handler)
    end

    ##
    # @param  [Object] output
    #   where output should be written to
    # @param  [Hash{Symbol => Object}] options
    #   any additional options for serializing
    # @option options [String, #to_s] :base_uri (nil)
    #   the base URI to use when resolving relative URIs
    # @return [void]
    def start_to(output, options = {})
      if output.respond_to?(:write)
        start_to_stream(output, options)
       else
        raise ArgumentError, "don't know how to serialize to #{output.inspect}"
      end
    end

    ##
    # @param  [IO, StringIO] stream
    # @param  [Hash{Symbol => Object}] options
    #   any additional options for serializing (see {#start_to})
    # @return [void]
    def start_to_stream(stream, options = {})
      iostream = V1::IOStream.new(V1::IOStreamHandler.new(stream))
      start_to_iostream(iostream, options)
    end

    ##
    # @param  [V1::IOStream] iostream
    # @param  [Hash{Symbol => Object}] options
    #   any additional options for serializing (see {#start_to})
    # @return [void]
    def start_to_iostream(iostream, options = {})
      @iostream = iostream # prevents premature GC
      @base_uri = options[:base_uri].to_s.empty? ? nil : V1::URI.new(options[:base_uri].to_s)
      if V1.raptor_serialize_start_to_iostream(self, @base_uri, @iostream).nonzero?
        raise RDF::WriterError, "raptor_serialize_start_to_iostream() failed"
      end
    end

    ##
    # @return [void]
    def finish
      if V1.raptor_serialize_end(self).nonzero?
        raise RDF::WriterError, "raptor_serialize_end() failed"
      end
      @iostream = @base_uri = nil # allows GC
    end

    ##
    # @param  [RDF::Resource] subject
    # @param  [RDF::URI]      predicate
    # @param  [RDF::Term]     object
    # @return [void]
    def serialize_triple(subject, predicate, object)
      raptor_statement = V1::Statement.new
      raptor_statement.subject   = subject
      raptor_statement.predicate = predicate
      raptor_statement.object    = object
      begin
        serialize_raw_statement(raptor_statement)
      ensure
        raptor_statement.release
        raptor_statement = nil
      end
    end

    ##
    # @param  [V1::Statement] statement
    # @return [void]
    def serialize_raw_statement(statement)
      if V1.raptor_serialize_statement(self, statement).nonzero?
        raise RDF::WriterError, "raptor_serialize_statement() failed"
      end
    end
  end # Serializer
end # RDF::Raptor::FFI::V1
