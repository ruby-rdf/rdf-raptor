module RDF::Raptor::FFI
  ##
  # A foreign-function interface (FFI) to `libraptor` 2.x.
  #
  # @see http://librdf.org/raptor/libraptor.html
  module V2
    autoload :IOStream,        'rdf/raptor/ffi/v2/iostream'
    autoload :IOStreamHandler, 'rdf/raptor/ffi/v2/iostream_handler'
    autoload :Parser,          'rdf/raptor/ffi/v2/parser'
    autoload :Serializer,      'rdf/raptor/ffi/v2/serializer'
    autoload :Statement,       'rdf/raptor/ffi/v2/statement'
    autoload :URI,             'rdf/raptor/ffi/v2/uri'
    autoload :Term,            'rdf/raptor/ffi/v2/term'

    extend ::FFI::Library
    ffi_lib RDF::Raptor::LIBRAPTOR

    # TODO: Ideally this would be an enum, but the JRuby FFI (as of
    # version 1.4.0) has problems with enums as part of structs:
    #   `Unknown field type: #<FFI::Enum> (ArgumentError)`
    RAPTOR_TERM_TYPE_UNKNOWN  = 0
    RAPTOR_TERM_TYPE_URI      = 1
    RAPTOR_TERM_TYPE_LITERAL  = 2
    RAPTOR_TERM_TYPE_BLANK    = 4

    # @see http://librdf.org/raptor/api/tutorial-initialising-finishing.html
    typedef :pointer, :raptor_world
    typedef :int, :raptor_version
    attach_function :raptor_new_world_internal, [:raptor_version], :raptor_world
    attach_function :raptor_free_world, [], :void
    attach_function :raptor_alloc_memory, [:size_t], :pointer
    attach_function :raptor_calloc_memory, [:size_t, :size_t], :pointer
    attach_function :raptor_free_memory, [:pointer], :void

    # @see http://librdf.org/raptor/api-1.4/raptor-section-locator.html
    typedef :pointer, :raptor_locator
    attach_function :raptor_locator_line, [:raptor_locator], :int
    attach_function :raptor_locator_column, [:raptor_locator], :int
    attach_function :raptor_locator_byte, [:raptor_locator], :int

    # @see http://librdf.org/raptor/api-1.4/raptor-section-general.html
    attach_variable :raptor_version_string, :string
    attach_variable :raptor_version_major, :int
    attach_variable :raptor_version_minor, :int
    attach_variable :raptor_version_release, :int
    attach_variable :raptor_version_decimal, :int
    callback        :raptor_message_handler, [:pointer, :raptor_locator, :string], :void

    # @see http://librdf.org/raptor/api-1.4/raptor-section-uri.html
    typedef :pointer, :raptor_uri
    attach_function :raptor_new_uri, [:raptor_world, :string], :raptor_uri
    attach_function :raptor_uri_copy, [:raptor_uri], :raptor_uri
    attach_function :raptor_uri_equals, [:raptor_uri, :raptor_uri], :int
    attach_function :raptor_uri_as_string, [:raptor_uri], :string
    attach_function :raptor_uri_to_string, [:raptor_uri], :string
    attach_function :raptor_uri_print, [:raptor_uri, :pointer], :void
    attach_function :raptor_free_uri, [:raptor_uri], :void

    # @see http://librdf.org/raptor/api/raptor2-section-triples.html
    typedef :int,     :raptor_identifier_type
    typedef :pointer, :raptor_identifier
    typedef :pointer, :raptor_statement
    attach_function :raptor_statement_compare, [:raptor_statement, :raptor_statement], :int
    attach_function :raptor_statement_print, [:raptor_statement, :pointer], :void
    attach_function :raptor_statement_print_as_ntriples, [:pointer, :pointer], :void
    #attach_function :raptor_statement_part_as_string, [:pointer, :raptor_identifier_type, :raptor_uri, :pointer], :string
    attach_function :raptor_free_statement, [:raptor_statement], :void
    typedef :pointer, :raptor_term
    typedef :string, :literal
    typedef :pointer, :datatype
    typedef :string, :language
    typedef :string, :blank
    attach_function :raptor_term_to_string, [:raptor_term], :string
    attach_function :raptor_new_term_from_uri, [:raptor_world, :raptor_uri], :raptor_term
    attach_function :raptor_new_term_from_uri_string, [:raptor_world, :string], :raptor_term
    attach_function :raptor_new_term_from_literal, [:raptor_world, :literal, :datatype, :language], :raptor_term
    attach_function :raptor_new_term_from_blank, [:raptor_world, :blank], :raptor_term

    # @see http://librdf.org/raptor/api/raptor2-section-parser.html
    callback :raptor_statement_handler, [:pointer, :raptor_statement], :void
    typedef :pointer, :raptor_parser
    typedef :string, :mime_type
    typedef :string, :buffer
    attach_function :raptor_new_parser, [:raptor_world, :string], :raptor_parser
    attach_function :raptor_world_guess_parser_name, [:raptor_world, :raptor_uri, :mime_type, :buffer, :size_t, :string], :string
    #attach_function :raptor_set_error_handler, [:raptor_parser, :pointer, :raptor_message_handler], :void
    #attach_function :raptor_set_warning_handler, [:raptor_parser, :pointer, :raptor_message_handler], :void
    attach_function :raptor_parser_set_statement_handler, [:raptor_parser, :pointer, :raptor_statement_handler], :void
    attach_function :raptor_parser_parse_file, [:raptor_parser, :raptor_uri, :raptor_uri], :int
    attach_function :raptor_parser_parse_file_stream, [:raptor_parser, :pointer, :string, :raptor_uri], :int
    attach_function :raptor_parser_parse_uri, [:raptor_parser, :raptor_uri, :raptor_uri], :int
    attach_function :raptor_parser_parse_start, [:raptor_parser, :raptor_uri], :int
    attach_function :raptor_parser_parse_chunk, [:raptor_parser, :string, :size_t, :int], :int
    #attach_function :raptor_get_mime_type, [:raptor_parser], :string
    #attach_function :raptor_set_parser_strict, [:raptor_parser, :int], :void
    #attach_function :raptor_get_need_base_uri, [:raptor_parser], :int
    attach_function :raptor_parser_parse_abort, [], :void
    attach_function :raptor_free_parser, [:raptor_parser], :void

    # @see http://librdf.org/raptor/api/raptor2-section-iostream.html
    typedef :pointer, :raptor_iostream
    attach_function :raptor_new_iostream_from_handler, [:raptor_world, :pointer, :pointer], :raptor_iostream
    attach_function :raptor_new_iostream_to_filename, [:raptor_world, :string], :raptor_iostream
    attach_function :raptor_new_iostream_to_sink, [:raptor_world], :raptor_iostream
    attach_function :raptor_free_iostream, [:raptor_iostream], :void
    callback        :raptor_iostream_init_func, [:pointer], :int
    callback        :raptor_iostream_finish_func, [:pointer], :void
    callback        :raptor_iostream_write_byte_func, [:pointer, :int], :int
    callback        :raptor_iostream_write_bytes_func, [:pointer, :pointer, :size_t, :size_t], :int
    callback        :raptor_iostream_write_end_func, [:pointer], :void
    callback        :raptor_iostream_read_bytes_func, [:pointer, :pointer, :size_t, :size_t], :int
    callback        :raptor_iostream_read_eof_func, [:pointer], :int

    # @see http://librdf.org/raptor/api-1.4/raptor-section-xml-namespace.html
    typedef :pointer, :raptor_namespace

    # @see http://librdf.org/raptor/api/raptor2-section-serializer.html
    typedef :pointer, :raptor_serializer
    attach_function :raptor_new_serializer, [:raptor_world, :string], :raptor_serializer
    attach_function :raptor_free_serializer, [:raptor_serializer], :void
    attach_function :raptor_serializer_start_to_iostream, [:raptor_serializer, :raptor_uri, :raptor_iostream], :int
    attach_function :raptor_serializer_start_to_filename, [:raptor_serializer, :string], :int
    attach_function :raptor_serializer_serialize_statement, [:raptor_serializer, :raptor_statement], :int
    attach_function :raptor_serializer_serialize_end, [:raptor_serializer], :int
    #attach_function :raptor_serializer_set_error_handler, [:raptor_serializer, :pointer, :raptor_message_handler], :void
    #attach_function :raptor_serializer_set_warning_handler, [:raptor_serializer, :pointer, :raptor_message_handler], :void

    # Initialize the world.
    # We do this exactly once and never release because we can't delegate
    # any memory management to the Ruby GC.
    # Internally `raptor_init`/`raptor_finish` work with reference counts.
    @world = raptor_new_world_internal(raptor_version_decimal)
    def self.world
      @world
    end

    ##
    # Allocates memory for the string `str` inside `libraptor`, copying the
    # string into the newly-allocated buffer.
    #
    # The buffer should later be deallocated using `raptor_free_string`.
    #
    # @return [FFI::Pointer]
    def raptor_new_string(str)
      ptr = v2.raptor_alloc_memory(str.bytesize + 1)
      ptr.put_string(0, str)
      ptr
    end
    module_function :raptor_new_string

    alias_method :raptor_free_string, :raptor_free_memory
    module_function :raptor_free_string

  end # v2
end # RDF::Raptor::FFI
