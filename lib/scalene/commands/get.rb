module HP
  module Scalene
    class CLI < Thor

      map %w(fetch) => 'get'

      desc 'get <resource>', 'fetch an object to local file system'
      long_desc "Use the 'get' command to copy the specified object (file) from a bucket to the current directory on your local file system.
                The file will retain its name.  This is a convenience command.
                For example, the command 'scalene get :my_bucket/my_file.txt' is equivilant to calling
                'scalene copy :my_bucket/my_file.txt ./my_file.txt'.
                \n\nExample(s): 'scalene get :my_bucket/my_file.txt'
                \n\nNote: 'get' currently supports fetching of files, but not entire buckets.
                    It does not yet support wildcards."
      def get(resource)
        bucket, path = Bucket.parse_resource(resource)
        type = Resource.detect_type(resource)

        if :object == type
          copy(resource, "./#{path}")
        elsif :bucket == type
          error "You can get files, but not buckets."
        else
          error "The object path '#{resource}' wasn't recognized.  Usage: '#{selfname} get :bucket_name/object_name'.", :incorrect_usage
        end
      end

    end
  end
end

