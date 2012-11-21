require 'hpcloud/connection.rb'
require 'mime/types'
require 'ruby-progressbar'

module HP
  module Cloud
    class Resource
      attr_reader :fname, :ftype, :container, :path
      attr_reader :public_url, :cdn_public_url, :cdn_public_ssl_url, :public
      attr_reader :destination, :error_string, :error_code
      attr_reader :readers, :writers
    
      def initialize(storage, fname)
        @error_string = nil
        @error_code = nil
        @storage = storage
        @fname = fname
        @ftype = ResourceFactory.detect_type(@fname)
        @disable_pbar = false
        @mime_type = nil
        parse()
      end

      def self.container_name_for_service(container_string)
        unless container_string.index('/').nil?
          raise Exception.new("Valid container names do not contain the '/' character: #{container_string}")
        end
        unless container_string.length < 257
          raise Exception.new("Valid container names must be less than 256 characters long")
        end
        if container_string[0,1] == ':'
          container_string[1..-1]
        else
          container_string
        end
      end
    
      # is container_name a valid virtualhost name?
      def self.valid_virtualhost?(container_name)
        if (1..63).include?(container_name.length)
          if container_name =~ /^[a-z0-9-]*$/
            if container_name[0,1] != '-' and container_name[-1,1] != '-'
              return true 
            end
          end
        end
        false
      end

      def is_valid?
        return @error_string.nil?
      end

      def set_error(from)
        return unless is_valid?
        @error_string = from.error_string
        @error_code = from.error_code
      end

      def not_implemented(value)
        @error_string = "Not implemented: #{value}"
        @error_code = :general_error
        return false
      end

      def isLocal()
        return ResourceFactory::is_local?(@ftype)
      end

      def isRemote()
        return ResourceFactory::is_remote?(@ftype)
      end

      def is_object_store?
        return @ftype == :object_store
      end

      def is_container?
        return @ftype == :container
      end

      def is_shared?
        return @ftype == :shared_resource || @ftype == :shared_directory
      end

      def isDirectory()
        return @ftype == :directory ||
               @ftype == :container_directory ||
               @ftype == :shared_directory ||
               @ftype == :container ||
               @ftype == :object_store
      end

      def isFile()
        return @ftype == :file
      end

      def isObject()
        return @ftype == :object
      end

      def parse()
        @container = nil
        @path = nil
        if @fname.empty?
          return
        end
        if @fname[0,1] == ':'
          @container, *rest = @fname.split('/')
          @container = @container[1..-1] if @container[0,1] == ':'
          @path = rest.empty? ? '' : rest.join('/')
        else
          rest = @fname.split('/')
          @path = rest.empty? ? '' : rest.join('/')
        end
      end

      def to_hash
        hash = {}
        instance_variables.each {|var| hash[var.to_s.delete("@")] = instance_variable_get(var) }
        hash
      end

      def set_mime_type(value)
        @mime_type = value.tr("'", "") unless value.nil?
      end

      def get_mime_type()
        return @mime_type unless @mime_type.nil?
        filename = ::File.basename(@fname)
        unless (mime_types = ::MIME::Types.of(filename)).empty?
          return mime_types.first.content_type
        end
        return 'application/octet-stream'
      end

      def valid_source()
        return true
      end

      def isMulti()
        return true if isDirectory()
        found = false 
        foreach { |x|
          if (found == true)
            return true
          end
          found = true
        }
        return false
      end

      def valid_destination(source)
        return true
      end

      def set_destination(from)
        return true
      end

      def read_header()
        @error_string = "Not supported on local object '#{@fname}'."
        @error_code = :not_supported
        return false
      end

      def open(output=false, siz=0)
        return not_implemented("open")
      end

      def read()
        not_implemented("read")
        return nil
      end

      def write(data)
        return not_implemented("write")
      end

      def close()
        return not_implemented("close")
      end

      def copy_file(from)
        return not_implemented("copy_file")
      end

      def copy(from)
          if copy_all(from)
            return true
          end
          set_error(from)
          if is_valid?
            @error_string = 'Unknown error copying'
            @error_code = :unknown
          end
          return false
      end

      def copy_all(from)
        if ! from.valid_source() then return false end
        if ! valid_destination(from) then return false end

        copiedfile = false
        original = File.dirname(from.path)
        from.foreach { |file|
          if (original != '.')
            filename = file.path.sub(original, '').sub(/^\//, '')
          else
            filename = file.path
          end
          return false unless set_destination(filename)
          return false unless copy_file(file)
          copiedfile = true
        }

        if (copiedfile == false)
          @error_string = "No files found matching source '#{from.path}'"
          @error_code = :not_found
          return false
        end
        return true
      end

      def foreach(&block)
        return
      end

      def get_destination()
        return @destination.to_s
      end

      def remove(force)
        @error_string = "Removal of local objects is not supported: #{@fname}"
        @error_code = :incorrect_usage
        return false
      end

      def tempurl(period = 172800)
        @error_string = "Temporary URLs of local objects is not supported: #{@fname}"
        @error_code = :incorrect_usage
        return nil
      end

      def grant(acl)
        @error_string = "ACLs of local objects are not supported: #{@fname}"
        @error_code = :incorrect_usage
        return false
      end

      def revoke(acl)
        @error_string = "ACLs of local objects are not supported: #{@fname}"
        @error_code = :incorrect_usage
        return false
      end
    end
  end
end
