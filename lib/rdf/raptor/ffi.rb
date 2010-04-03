require 'ffi'

module RDF::Raptor
  ##
  # A foreign-function interface (FFI) to `libraptor`.
  #
  # @see http://librdf.org/raptor/api/
  # @see http://librdf.org/raptor/libraptor.html
  module FFI
    module Base
      def define_pointer(name)
        self.class.send(:define_method, name) { :pointer }
      end
    end

    ##
    # A foreign-function interface (FFI) to `libraptor` 1.4.x.
    #
    # @see http://librdf.org/raptor/libraptor.html
    module V1_4
      ##
      # @param  [Hash{Symbol => Object}] options
      # @option (options) [Boolean] :init (true)
      # @yield  [world]
      # @yieldparam [FFI::Pointer] world
      # @return [void]
      def self.with_world(options = {}, &block)
        options = {:init => true}.merge(options)
        begin
          raptor_init if options[:init]
          raptor_world_open(world = raptor_new_world)
          block.call(world)
        ensure
          raptor_free_world(world) if world
          raptor_finish if options[:init]
        end
      end

      ##
      # @param  [Hash{Symbol => Object}] options
      # @option (options) [String, #to_s] :name (:rdfxml)
      # @yield  [parser]
      # @yieldparam [FFI::Pointer] parser
      # @return [void]
      def self.with_parser(options = {}, &block)
        begin
          parser = raptor_new_parser((options[:name] || :rdfxml).to_s)
          block.call(parser)
        ensure
          raptor_free_parser(parser) if parser
        end
      end

      extend Base
      extend ::FFI::Library
      ffi_lib 'libraptor'

      # @see http://librdf.org/raptor/api/raptor-section-triples.html
      class Statement < ::FFI::Struct
        layout :subject, :pointer,
               :subject_type, :int,
               :predicate, :pointer,
               :predicate_type, :int,
               :object, :pointer,
               :object_type, :int,
               :object_literal_datatype, :pointer,
               :object_literal_language, :string

        ##
        # @return [String]
        def subject_as_string
          V1_4.raptor_statement_part_as_string(self[:subject], self[:subject_type], nil, nil)
        end

        ##
        # @return [String]
        def predicate_as_string
          V1_4.raptor_statement_part_as_string(self[:predicate], self[:predicate_type], nil, nil)
        end

        ##
        # @return [String]
        def object_as_string
          V1_4.raptor_statement_part_as_string(self[:object], self[:object_type], self[:object_literal_datatype], self[:object_literal_language])
        end
      end

      # @see http://librdf.org/raptor/api/tutorial-initialising-finishing.html
      attach_function :raptor_init, [], :void
      attach_function :raptor_finish, [], :void

      # @see http://librdf.org/raptor/api/raptor-section-world.html
      define_pointer  :raptor_world
      attach_function :raptor_new_world, [], raptor_world
      attach_function :raptor_world_open, [raptor_world], :int
      attach_function :raptor_free_world, [raptor_world], :void

      # @see http://librdf.org/raptor/api/raptor-section-uri.html
      define_pointer  :raptor_uri
      attach_function :raptor_new_uri, [:string], raptor_uri
      attach_function :raptor_uri_as_string, [raptor_uri], :string
      attach_function :raptor_uri_to_string, [raptor_uri], :string
      attach_function :raptor_uri_print, [raptor_uri, :pointer], :void
      attach_function :raptor_free_uri, [raptor_uri], :void

      # @see http://librdf.org/raptor/api/raptor-section-triples.html
      define_pointer  :raptor_statement
      attach_function :raptor_statement_compare, [raptor_statement, raptor_statement], :int
      attach_function :raptor_print_statement, [raptor_statement, :pointer], :void
      attach_function :raptor_print_statement_as_ntriples, [:pointer, :pointer], :void
      attach_function :raptor_statement_part_as_string, [:pointer, :int, raptor_uri, :string], :string

      # @see http://librdf.org/raptor/api/raptor-section-parser.html
      callback :raptor_statement_handler, [:pointer, raptor_statement], :void
      define_pointer  :raptor_parser
      attach_function :raptor_new_parser, [:string], raptor_parser
      attach_function :raptor_set_statement_handler, [raptor_parser, :pointer, :raptor_statement_handler], :void
      attach_function :raptor_parse_file, [raptor_parser, raptor_uri, raptor_uri], :int
      attach_function :raptor_parse_file_stream, [raptor_parser, :pointer, :string, raptor_uri], :int
      attach_function :raptor_parse_uri, [raptor_parser, raptor_uri, raptor_uri], :int
      attach_function :raptor_start_parse, [raptor_parser, :string], :int
      attach_function :raptor_parse_chunk, [raptor_parser, :string, :int, :int], :int # FIXME: size_t
      attach_function :raptor_get_mime_type, [raptor_parser], :string
      attach_function :raptor_set_parser_strict, [raptor_parser, :int], :void
      attach_function :raptor_get_need_base_uri, [raptor_parser], :int
      attach_function :raptor_parser_get_world, [raptor_parser], raptor_world
      attach_function :raptor_free_parser, [raptor_parser], :void
    end
  end
end
