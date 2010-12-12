module RDF::Raptor::FFI::V1
  ##
  # @see http://librdf.org/raptor/api-1.4/raptor-section-iostream.html
  class IOStreamHandler < ::FFI::Struct
    include RDF::Raptor::FFI
    layout :version, :int,
           :init, :raptor_iostream_init_func,
           :finish, :raptor_iostream_finish_func,
           :write_byte, :raptor_iostream_write_byte_func,
           :write_bytes, :raptor_iostream_write_bytes_func,
           :write_end, :raptor_iostream_write_end_func,
           :read_bytes, :raptor_iostream_read_bytes_func,
           :read_eof, :raptor_iostream_read_eof_func

    HANDLERS = [:init, :finish, :write_byte, :write_bytes, :read_bytes, :read_eof]

    ##
    # The IO object to operate upon.
    #
    # @return [IO]
    attr_accessor :io

    ##
    # @overload initialize(ptr)
    #   @param  [FFI::Pointer] ptr
    #
    # @overload initialize(io)
    #   @param  [IO, StringIO] io
    #
    def initialize(ptr_or_io = nil)
      ptr = case ptr_or_io
        when FFI::Pointer
          ptr_or_io
        when IO, StringIO
          @io = ptr_or_io
          nil
        when nil then nil
        else
          raise ArgumentError, "invalid argument: #{ptr_or_io.inspect}"
      end
      super(ptr)
      initialize!
    end

    ##
    # @return [void]
    def initialize!
      self[:version] = 2

      #define_handler(:init) do |context|
      #  $stderr.puts("#{self.class}: init")
      #end
      #define_handler(:finish) do |context|
      #  $stderr.puts("#{self.class}: finish")
      #end
      define_handler(:write_byte) do |context, byte|
        begin
          @io.putc(byte)
          0
        rescue => e
          $stderr.puts("#{e} in #{self.class}#write_byte")
          1
        end
      end
      define_handler(:write_bytes) do |context, data, size, nmemb|
        begin
          @io.write(data.read_string(size * nmemb))
          0
        rescue => e
          $stderr.puts("#{e} in #{self.class}#write_bytes")
          1
        end
      end
      #define_handler(:write_end) do |context|
      #  $stderr.puts("#{self.class}: write_end")
      #end
      #define_handler(:read_bytes) do |context, data, size, nmemb|
      #  $stderr.puts("#{self.class}: read_bytes")
      #end
      #define_handler(:read_eof) do |context|
      #  $stderr.puts("#{self.class}: read_eof")
      #end
    end

    ##
    # @param  [Proc] func
    # @return [void]
    def init_handler=(func)
      define_handler(:init, &func)
    end
    alias_method :init=, :init_handler=

    ##
    # @param  [Proc] func
    # @return [void]
    def finish_handler=(func)
      define_handler(:finish, &func)
    end
    alias_method :finish=, :finish_handler=

    ##
    # @param  [Proc] func
    # @return [void]
    def write_byte_handler=(func)
      define_handler(:write_byte, &func)
    end
    alias_method :write_byte=, :write_byte_handler=

    ##
    # @param  [Proc] func
    # @return [void]
    def write_bytes_handler=(func)
      define_handler(:write_bytes, &func)
    end
    alias_method :write_bytes=, :write_bytes_handler=

    ##
    # @param  [Proc] func
    # @return [void]
    def write_end_handler=(func)
      define_handler(:write_end, &func)
    end
    alias_method :write_end=, :write_end_handler=

    ##
    # @param  [Proc] func
    # @return [void]
    def read_bytes_handler=(func)
      define_handler(:read_bytes, &func)
    end
    alias_method :read_bytes=, :read_bytes_handler=

    ##
    # @param  [Proc] func
    # @return [void]
    def read_eof_handler=(func)
      define_handler(:read_eof, &func)
    end
    alias_method :read_eof=, :read_eof_handler=

    ##
    # @param  [Symbol, #to_sym] name
    # @return [void]
    def define_handler(name, &block)
      name = name.to_sym
      raise ArgumentError, "invalid IOStreamHandler function name: #{name}" unless HANDLERS.include?(name)
      @procs ||= {} # prevents premature GC of the procs
      @procs[name] = self[name] = block
    end
  end # IOStreamHandler
end # RDF::Raptor::FFI::V1
