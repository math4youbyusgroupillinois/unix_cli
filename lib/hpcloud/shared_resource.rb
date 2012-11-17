module HP
  module Cloud
    class SharedResource < RemoteResource
      def parse()
        @container = nil
        @path = nil
        if @fname.empty?
          return
        end
        #
        # Extract container given the expected input in the form:
        # https://domain_and_port/version/tenant_id/container/object/name/with/slashes.txt
        # where the container for that shared object is:
        # https://domain_and_port/version/tenant_id/container
        # and the path for the object is:
        # object/name/with/slashes.txt
        @container = @fname.match(/http[s]*:\/\/[^\/]*\/[^\/]*\/[^\/]*\/[^\/]*/).to_s
        @path = @fname.gsub(@container, '')
        @path = @path.gsub(/^\/*/, '')
      end

      def get_container
        begin
          return false if is_valid? == nil
          return true unless @directory.nil?

          @directory = @storage.shared_directories.get(@container)
          if @directory.nil?
            @error_string = "Cannot find container '#{@container}'."
            @error_code = :not_found
            return false
          end
        rescue Excon::Errors::Forbidden => e
          resp = ErrorResponse.new(e)
          @error_string  = resp.error_string
          @error_code = :permission_denied
          return false
        rescue Fog::HP::Errors::Forbidden => error
          @error_string  = "Permission denied trying to access '#{@fname}'."
          @error_code = :permission_denied
          return false
        rescue Exception => error
          @error_string = "Error reading '#{@fname}': " + error.to_s
          @error_code = :general_error
          return false
        end
        return true
      end

      def get_size()
        begin
          return 0 unless get_container
          file = @directory.files.get(@path)
          return 0 if file.nil?
          return file.content_length
        rescue Exception => e
        end
        return 0
      end

      #
      # Add the capability to iterate through all the matching files
      # for copy.  Use different regular expressions for a directory
      # where we want to recursively copy things vs a regular file
      #
      def foreach(&block)
        return false if get_container == false
        return if @directory.nil?
        case @ftype
        when :shared_directory
          regex = "^" + path + ".*"
        else
          regex = "^" + path + '$'
        end
        @directory.files.each { |x|
          name = x.key.to_s
          if ! name.match(regex).nil?
            yield ResourceFactory.create(@storage, container + '/' + name)
          end
        }
      end

      def read
        begin
          @storage.get_shared_object(@fname) { |chunk|
            yield chunk
          }
        rescue Fog::Storage::HP::NotFound => e
          @error_string = "The specified object does not exist."
          @error_code = :not_found
          result = false
        end
      end

      def copy_file(from)
        result = true
        if from.isLocal()
          return false unless from.open
          options = { 'Content-Type' => from.get_mime_type() }
          @storage.put_shared_object(@container, @destination, {}, options) {
            from.read().to_s
          }
          result = false unless from.close()
        else
          begin
            @storage.put_shared_object(@container, @destination, nil, {'X-Copy-From' => "/#{from.container}/#{from.path}" })
          rescue Fog::Storage::HP::NotFound => e
            @error_string = "The specified object does not exist."
            @error_code = :not_found
            result = false
          end
        end
        return result
      end

      def remove(force)
        if @path.empty?
          @error_string = "Removal of shared containers is not supported."
          @error_code = :not_supported
          return false
        end
        super(force)
      end
    end
  end
end