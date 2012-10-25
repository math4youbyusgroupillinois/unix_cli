require 'hpcloud/accounts'

module HP
  module Cloud
    class CLI < Thor
    
      desc 'account:use <account_to_use>', "Overwrite the default account with specified account."
      long_desc <<-DESC
  Use the specified account as default.  This command overwrites the default account.
  
Examples:
  hpcloud account:use useast
      DESC
      define_method "account:use" do |name|
        cli_command(options) {
          HP::Cloud::Accounts.new().read(name)
          config = Config.new(true)
          config.set(:default_account, name)
          config.write()
          display("Account '#{name}' is now the default")
        }
      end
    end
  end
end
