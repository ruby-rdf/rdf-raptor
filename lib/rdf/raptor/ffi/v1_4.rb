module RDF::Raptor::FFI
  ##
  # A foreign-function interface (FFI) to `libraptor` 1.4.x.
  #
  # @see http://librdf.org/raptor/libraptor.html
  module V1_4
    autoload :IOStreamHandler, 'rdf/raptor/ffi/v1_4/iostream_handler'
    autoload :Parser,          'rdf/raptor/ffi/v1_4/parser'
    autoload :Serializer,      'rdf/raptor/ffi/v1_4/serializer'
    autoload :Statement,       'rdf/raptor/ffi/v1_4/statement'

    extend ::FFI::Library
    ffi_lib RDF::Raptor::LIBRAPTOR

    # TODO: Ideally this would be an enum, but the JRuby FFI (as of
    # version 1.4.0) has problems with enums as part of structs:
    #   `Unknown field type: #<FFI::Enum> (ArgumentError)`
    RAPTOR_IDENTIFIER_TYPE_RESOURCE  = 1
    RAPTOR_IDENTIFIER_TYPE_ANONYMOUS = 2
    RAPTOR_IDENTIFIER_TYPE_LITERAL   = 5

    # @see http://librdf.org/raptor/api-1.4/tutorial-initialising-finishing.html
    attach_function :raptor_init, [], :void
    attach_function :raptor_finish, [], :void

    # @see http://librdf.org/raptor/api-1.4/raptor-section-locator.html
    typedef :pointer, :raptor_locator
    attach_function :raptor_locator_line, [:raptor_locator], :int
    attach_function :raptor_locator_column, [:raptor_locator], :int
    attach_function :raptor_locator_byte, [:raptor_locator], :int

    # @see http://librdf.org/raptor/api-1.4/raptor-section-general.html
    attach_variable :raptor_version_major, :int
    attach_variable :raptor_version_minor, :int
    attach_variable :raptor_version_release, :int
    attach_variable :raptor_version_decimal, :int
    callback        :raptor_message_handler, [:pointer, :raptor_locator, :string], :void

    # @see http://librdf.org/raptor/api-1.4/raptor-section-uri.html
    typedef :pointer, :raptor_uri
    attach_function :raptor_new_uri, [:string], :raptor_uri
    attach_function :raptor_uri_as_string, [:raptor_uri], :string
    attach_function :raptor_uri_to_string, [:raptor_uri], :string
    attach_function :raptor_uri_print, [:raptor_uri, :pointer], :void
    attach_function :raptor_free_uri, [:raptor_uri], :void

    # @see http://librdf.org/raptor/api-1.4/raptor-section-triples.html
    typedef :int,     :raptor_identifier_type
    typedef :pointer, :raptor_identifier
    typedef :pointer, :raptor_statement
    attach_function :raptor_statement_compare, [:raptor_statement, :raptor_statement], :int
    attach_function :raptor_print_statement, [:raptor_statement, :pointer], :void
    attach_function :raptor_print_statement_as_ntriples, [:pointer, :pointer], :void
    attach_function :raptor_statement_part_as_string, [:pointer, :raptor_identifier_type, :raptor_uri, :pointer], :string

    # @see http://librdf.org/raptor/api-1.4/raptor-section-parser.html
    callback :raptor_statement_handler, [:pointer, :raptor_statement], :void
    typedef :pointer, :raptor_parser
    attach_function :raptor_new_parser, [:string], :raptor_parser
    attach_function :raptor_set_error_handler, [:raptor_parser, :pointer, :raptor_message_handler], :void
    attach_function :raptor_set_warning_handler, [:raptor_parser, :pointer, :raptor_message_handler], :void
    attach_function :raptor_set_statement_handler, [:raptor_parser, :pointer, :raptor_statement_handler], :void
    attach_function :raptor_parse_file, [:raptor_parser, :raptor_uri, :raptor_uri], :int
    attach_function :raptor_parse_file_stream, [:raptor_parser, :pointer, :string, :raptor_uri], :int
    attach_function :raptor_parse_uri, [:raptor_parser, :raptor_uri, :raptor_uri], :int
    attach_function :raptor_start_parse, [:raptor_parser, :string], :int
    attach_function :raptor_parse_chunk, [:raptor_parser, :string, :size_t, :int], :int
    attach_function :raptor_get_mime_type, [:raptor_parser], :string
    attach_function :raptor_set_parser_strict, [:raptor_parser, :int], :void
    attach_function :raptor_get_need_base_uri, [:raptor_parser], :int
    attach_function :raptor_free_parser, [:raptor_parser], :void

    # @see http://librdf.org/raptor/api-1.4/raptor-section-iostream.html
    typedef :pointer, :raptor_iostream
    attach_function :raptor_new_iostream_from_handler2, [:pointer, :pointer], :raptor_iostream
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

    # @see http://librdf.org/raptor/api-1.4/raptor-section-serializer.html
    typedef :pointer, :raptor_serializer
    attach_function :raptor_new_serializer, [:string], :raptor_serializer
    attach_function :raptor_free_serializer, [:raptor_serializer], :void
    attach_function :raptor_serialize_start_to_iostream, [:raptor_serializer, :raptor_uri, :raptor_iostream], :int
    attach_function :raptor_serialize_start_to_filename, [:raptor_serializer, :string], :int
    attach_function :raptor_serialize_statement, [:raptor_serializer, :raptor_statement], :int
    attach_function :raptor_serialize_end, [:raptor_serializer], :int
    attach_function :raptor_serializer_set_error_handler, [:raptor_serializer, :pointer, :raptor_message_handler], :void
    attach_function :raptor_serializer_set_warning_handler, [:raptor_serializer, :pointer, :raptor_message_handler], :void

    # Initialize the world.
    # We do this exactly once and never release because we can't delegate
    # any memory management to the Ruby GC.
    # Internally `raptor_init`/`raptor_finish` work with reference counts.
    raptor_init
  end # V1_4
end # RDF::Raptor::FFI
