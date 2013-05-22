require 'tempfile'

module RubyMelee
  class FakeWardenClient

    def self.launch_container
      return 'fake-container-handle'
    end

    def self.run(container, content)
      # create temp file
      file = Tempfile.new('melee.rb')
      file.write content
      file.close

      # run it
      output = `ruby #{file.path} 2>&1`

      # kill the temp file
      file.unlink

      [output, container]
    end

    def self.destroy(container)
      false
    end


  end
end