module HP
  module Scalene
    class CLI < Thor

      map %w(rm delete destroy del) => 'remove'

      desc 'remove <object/container>', 'remove an object or container'
      long_desc <<-DESC
  Remove an object. If the specified target is a container, behavior is
  identical to calling `containers:remove`.
        
Examples:
  scalene remove :my_container/my_file.txt   # Delete object 'my_file.txt'
  scalene remove :my_container               # Delete container 'my_container'
        
Aliases: rm, delete, destroy, del
      DESC
      method_option :force, :default => false, :type => :boolean, :aliases => '-f',
                    :desc => 'Do not confirm removal, remove non-empty containers.'

      def remove(resource)
        container, path = Container.parse_resource(resource)
        type = Resource.detect_type(resource)

        begin
          directory = connection.directories.get(container)
        rescue Excon::Errors::Forbidden => error
          error "Access Denied.", :permission_denied
        end
        if not directory
          error "You don't have a container named '#{container}'", :not_found
        end

        if type == :object
          begin
            file = directory.files.get(path)
          rescue Excon::Errors::Forbidden => error
            display_error_message(error)
          end
          if file
            file.destroy
            display "Removed object '#{resource}'."
          else
            error "You don't have a object named '#{path}'.", :not_found
          end

        elsif type == :container
          if options.force? or yes?("Are you sure you want to remove the container '#{resource}'?")
            send('containers:remove', container)
          end

        else
          error "Could not find resource '#{resource}'. Correct syntax is :containername/objectname.",
                :incorrect_usage
        end
      end

    end
  end
end

