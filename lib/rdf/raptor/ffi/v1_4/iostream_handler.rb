module RDF::Raptor::FFI::V1_4
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

    ##
    # @return [IO]
    attr_accessor :rubyio

    ##
    def initialize(*args)
      super
      # Keep a Ruby land reference to our procs so they don't get
      # snatched by GC.
      @procs = {}

      self[:version] = 2

      # @procs[:init] = self[:init] = Proc.new do |context|
      #   $stderr.puts("#{self.class}: init")
      # end
      # @procs[:finish] = self[:finish] = Proc.new do |context|
      #   $stderr.puts("#{self.class}: finish")
      # end
      @procs[:write_byte] = self[:write_byte] = Proc.new do |context, byte|
        begin
          @rubyio.putc(byte)
        rescue
          return 1
        end
        0
      end
      @procs[:write_bytes] = self[:write_bytes] = Proc.new do |context, data, size, nmemb|
        begin
          @rubyio.write(data.read_string(size * nmemb))
        rescue
          return 1
        end
        0
      end
      # @procs[:write_end] = self[:write_end] = Proc.new do |context|
      #   $stderr.puts("#{self.class}: write_end")
      # end
      # @procs[:read_bytes] = self[:read_bytes] = Proc.new do |context, data, size, nmemb|
      #   $stderr.puts("#{self.class}: read_bytes")
      # end
      # @procs[:read_eof] = self[:read_eof] = Proc.new do |context|
      #   $stderr.puts("#{self.class}: read_eof")
      # end
    end
  end # IOStreamHandler
end # RDF::Raptor::FFI::V1_4
