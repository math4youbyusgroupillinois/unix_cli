require "bundler/setup" # Comment out for delivery
require 'fog'

require 'hpcloud/version'
require 'hpcloud/accounts'
require 'hpcloud/addresses'
require 'hpcloud/address_helper'
require 'hpcloud/volumes'
require 'hpcloud/volume_helper'
require 'hpcloud/volume_attachment'
require 'hpcloud/volume_attachments'
require 'hpcloud/snapshots'
require 'hpcloud/snapshot_helper'
require 'hpcloud/config'
require 'hpcloud/images'
require 'hpcloud/image_helper'
require 'hpcloud/keypairs'
require 'hpcloud/keypair_helper'
require 'hpcloud/metadata'
require 'hpcloud/progress'
require 'hpcloud/resource'
require 'hpcloud/servers'
require 'hpcloud/server_helper'
require 'hpcloud/error_response'
require 'hpcloud/container'

require 'hpcloud/cli'

require 'hpcloud/commands/info'
require 'hpcloud/commands/account'
require 'hpcloud/commands/volumes'
require 'hpcloud/commands/config'
require 'hpcloud/commands/containers'
require 'hpcloud/commands/list'
require 'hpcloud/commands/copy'
require 'hpcloud/commands/move'
require 'hpcloud/commands/remove'
require 'hpcloud/commands/acl'
require 'hpcloud/commands/location'
require 'hpcloud/commands/get'

require 'hpcloud/commands/servers'
require 'hpcloud/commands/flavors'
require 'hpcloud/commands/images'
require 'hpcloud/commands/keypairs'
require 'hpcloud/commands/addresses'
require 'hpcloud/commands/securitygroups'
require 'hpcloud/commands/snapshots'

require 'hpcloud/commands/cdn_containers'
