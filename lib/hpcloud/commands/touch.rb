module HPCloud
  class CLI < Thor
    
    desc 'touch <resource>', "create an empty object"
    def touch(resource)
      puts "touch an object"
    end
    
  end
end