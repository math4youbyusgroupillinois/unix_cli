module HP
  module Cloud
    class CLI < Thor

      desc "volumes:add <name> [size]", "Add a volume."
      long_desc <<-DESC
  Add a new volume to your compute account with the specified name and size.  Optionally, you can specify a description, metadata or availability zone.  If you do not specify a size, it is taken from the specified snapshot or image.  If no image or snapshot is specified, the size defaults to 1 gigabyte.

Examples:
  hpcloud volumes:add my_volume 10               # Create a new volume named 'my_volume' of size 10:
  hpcloud volumes:add my_volume 10 -d 'test vol' # Create a new volume named 'my_volume' of size 10 with a description:
  hpcloud volumes:add my_volume -s 'snappy'      # Create a new volume named 'my_volume' based on the snapshot 'snappy':
  hpcloud volumes:add my_volume -i 20103         # Create a new bootable volume named 'my_volume' based on the image '20103':
  hpcloud volumes:add my_volume 1 -z az-2.region-a.geo-1 # Creates volume `my_volume` in availability zone `az-2.region-a.geo-1`:
      DESC
      method_option :description,
                    :type => :string, :aliases => '-d',
                    :desc => 'Description of the volume.'
      method_option :metadata,
                    :type => :string, :aliases => '-m',
                    :desc => 'Set the meta data.'
      method_option :snapshot,
                    :type => :string, :aliases => '-s',
                    :desc => 'Create volume from the specified snapshot.'
      method_option :image,
                    :type => :string, :aliases => '-i',
                    :desc => 'Create volume from the specified image.'
      CLI.add_common_options
      define_method "volumes:add" do |name, *volume_size|
        cli_command(options) {
          if Volumes.new.get(name).is_valid? == true
            error "Volume with the name '#{name}' already exists", :general_error
          end
          vol = HP::Cloud::VolumeHelper.new(Connection.instance)
          vol.name = name
          vol.size = volume_size.first
          unless options[:snapshot].nil?
            snapshot = HP::Cloud::Snapshots.new.get(options[:snapshot])
            if snapshot.is_valid?
              vol.snapshot_id = snapshot.id.to_s
              vol.size = snapshot.size.to_s if vol.size.nil?
            else
              error snapshot.error_string, snapshot.error_code
            end
          end
          unless options[:image].nil?
            image = HP::Cloud::Images.new.get(options[:image])
            if image.is_valid?
              vol.imageref = image.id.to_s
            else
              error image.error_string, image.error_code
            end
          end
          vol.size = 1 if vol.size.nil?
          vol.description = options[:description]
          vol.meta.set_metadata(options[:metadata])
          if vol.save == true
            display "Created volume '#{name}' with id '#{vol.id}'."
          else
            error(vol.error_string, vol.error_code)
          end
        }
      end
    end
  end
end
