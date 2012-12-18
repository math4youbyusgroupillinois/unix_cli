require 'hpcloud/resource_factory'

module HP
  module Cloud
    class CLI < Thor
    
      map %w(ls containers containers:list) => 'list'
      map 'ls' => 'list'
    
      desc 'list [container ...]', "List containers or container contents."
      long_desc <<-DESC
  List containers or the contents of the specified containers. Optionally, an availability zone can be passed.

Examples:
  hpcloud list :tainer/1.txt :tainer/2.txt      # List the two objects `1.txt` and `2.txt` in the container `tainer`:
  hpcloud list :tainer                          # List all the objects in container `tainer`:
  hpcloud list                                  # List all containers:
  hpcloud list :my_container -z region-a.geo-1  # List all the objects in container `my_container` for availability zone `region-a.geo-1`:

Aliases: ls
      DESC
      CLI.add_common_options
      def list(*sources)
        cli_command(options) {
          sources = [""] if sources.empty?
          multi = sources.length > 1
          sources.each { |name|
            begin
              from = ResourceFactory.create(Connection.instance.storage, name)
              if from.valid_source()
                found = false
                from.foreach { |file|
                  if from.is_container?
                    if multi
                      display file.fname
                    else
                      display file.path
                    end
                  else
                    if file.is_container?
                      display file.container
                    else
                      display file.fname
                    end
                  end
                  found = true
                }
                unless found
                  if from.is_object_store?
                    error_message "Cannot find any containers, use `#{selfname} containers:add <name>` to create one.", :not_found
                  elsif from.isDirectory() == false
                    error_message "Cannot find resource named '#{name}'.", :not_found
                  end
                end
              else
                error_message from.error_string, from.error_code
              end
            rescue Exception => e
              error_message "Exception reading '#{name}': " + e.to_s, :general_error
            end
          }
        }
      end
    end
  end
end
