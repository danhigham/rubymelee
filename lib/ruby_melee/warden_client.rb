require 'tempfile'
require 'warden/client'

module RubyMelee
  class WardenClient

    def self.launch_container
      client = open_client
      handle = client.create.handle
      client.disconnect

      handle
    end

    def self.run(container, content)

      # create temp file
      file = Tempfile.new('melee.rb')
      file.write content
      file.close

      client = open_client
      container = ensure_container client, container

      client.copy_in :handle => container, :src_path => file.path, :dst_path => file.path
      response = client.run :script => "/.rbenv/versions/1.9.3-p327/bin/ruby #{file.path} 2>&1", :handle => container
      client.disconnect

      file.unlink

      [response.stdout, container]
    end

    def self.destroy(container)
      client = open_client
      client.destroy :handle => container
      client.disconnect
      true
    end

    :private 

    def self.ensure_container(client, container)
      container_list = client.list.handles
      return client.create.handle if container_list.nil?
      return container_list.include?(container) ? container : client.create.handle
    end

    def self.open_client
      client = Warden::Client.new '/tmp/warden.sock'
      client.connect
      client
    end
  end
end