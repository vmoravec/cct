module Cct
  class AdminNode < Node
    attr_reader :config, :location

    def initialize options={}
      super
      @config = Cct.config["admin_node"]
      discover_node_location
      @admin = true
    end

    def exec command_name, options={}
      command =
        case location
        when :local  then Command.new(command_name, options)
        when :remote then Net::SSH.start(config['ip'], config['user'], config['password'])
        end
    end

    def validate!
      true
    end

    def remote?
      location == :remote
    end

    def local?
      !remote
    end

    private

    def discover_node_location
      if config["remote"]
        @location = :remote

      else
        @location = :local
        # I'm on admin node, run all commands locally
      end
    end
  end
end
