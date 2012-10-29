module HP
  module Cloud
    class CLI < Thor

      desc "volumes:attach <volume> <server> <device>", "Attach a volume to a server (specified by device name)."
      long_desc <<-DESC
  Attach a volume to a server on the specified device name.

Examples:
  hpcloud volumes:attach myVolume myServer /dev/sdf                         # Attach volume `myVolume` to server `myServer` on device `/dev/sdf`:
  hpcloud volumes:attach my-volume myServer /dev/sdg -z az-2.region-a.geo-1 # Attach volume `my-volume` to server `myServer` on device `/dev/sdf` for availability zone `az-2.region-a.geo-1`:

      DESC
      CLI.add_common_options
      define_method "volumes:attach" do |vol_name, server_name, device|
        cli_command(options) {
          server = Servers.new.get(server_name)
          if server.is_valid?
            volume = Volumes.new.get(vol_name)
            if volume.is_valid?
              if volume.fog.ready?
                volume.attach(server, device)
                display "Attached volume '#{volume.name}' to '#{server.name}' on '#{device}'."
              else
                error "Error attaching volume already in use '#{volume.name}'", :conflicted
              end
            else
              error volume.error_string, volume.error_code
            end
          else
            error server.error_string, server.error_code
          end
        }
      end
    end
  end
end
