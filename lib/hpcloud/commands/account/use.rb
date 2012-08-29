require 'hpcloud/accounts'

module HP
  module Cloud
    class CLI < Thor
    
      desc 'account:use', "Overwrite default account with specified account"
      long_desc <<-DESC
  Use the specified account as default.  This command will overwrite the default account.
  
Examples:
  hpcloud account:use useast
      DESC
      define_method "account:use" do |name|
        cli_command(options) {
          accounts = HP::Cloud::Accounts.new()
          accounts.copy(name, 'default')
          display("Account '#{name}' copied to 'default'")
        }
      end
    end
  end
end
