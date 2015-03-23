module Cct
  class AdminNode < Node
    attr_reader :location
    private :location

    def initialize options={}
      @admin = true
      @location = config["remote"] ? :remote : :local
      command_options = remote? ? config["remote"] : {}
      @command_proxy = CommandProxy.new(location, command_options)
    end

    def remote?
      location == :remote
    end

    def local?
      location == :local
    end

    def config
      Cct.config['admin_node']
    end
  end
end
