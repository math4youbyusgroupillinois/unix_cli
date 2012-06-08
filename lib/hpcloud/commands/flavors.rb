module HP
  module Cloud
    class CLI < Thor

      map 'flavors:list' => 'flavors'

      desc "flavors", "list of available flavors"
      long_desc <<-DESC
  List the flavors in your compute account. Optionally, an availability zone can be passed.

Examples:
  hpcloud flavors                         # List flavors
  hpcloud flavors -z az-2.region-a.geo-1  # List flavors for an availability zone

Aliases: flavors:list
      DESC
      method_option :availability_zone,
                    :type => :string, :aliases => '-z',
                    :desc => 'Set the availability zone.'
      def flavors
        begin
          # Need specific flavors for HP
          flavors = connection(:compute, options).flavors
          if flavors.empty?
            display "You currently have no flavors."
          else
            # :rxtx_cap, :rxtx_quota, :swap, :vcpus are not attributes on model
            flavors.table([:id, :name, :ram, :disk])
          end
        rescue Fog::HP::Errors::ServiceError, Fog::Compute::HP::Error => error
          display_error_message(error, :general_error)
        rescue Excon::Errors::Unauthorized, Excon::Errors::Forbidden => error
          display_error_message(error, :permission_denied)
        end
      end

    end
  end
end