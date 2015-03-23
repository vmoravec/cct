module Cct
  class AdminNode < Node
    NAME = "admin"

    attr_reader :location
    private :location

    def initialize options={}
      @name = options[:name] || NAME
      super do
        @admin = true
        @location = config["remote"] ? :remote : :local
        @command =
          if remote?
            extract_options(config["remote"])
            RemoteCommand.new(node: self)
          else
            LocalCommand.new(node: self)
          end
      end
    end

    def config
      Cct.config['admin_node']
    end

    def connect!
      return true if local?

      super
    end

    def connected?
      return true if local?

      super
    end

    def remote?
      location == :remote
    end

    def local?
      location == :local
    end
  end
end
