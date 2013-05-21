require 'warden-client'
require 'tempfile'

module RubyMelee
  class WardenClient

    def self.launch_container
      client = Warden::Client.new
      return client.create
    end

    def self.run(container, content)
      # create temp file
      file = Tempfile.new('melee.rb')
      file.write content
      file.close

      client = Warden::Client.new
      client.run :script => "/.rbenv/versions/1.9.3-p327/bin/ruby #{file.path} 2>&1", :handle => container
    end

    def self.destroy(container)
      client = Warden::Client.new
      client.destroy :handle => container
      true
    end

  end
end