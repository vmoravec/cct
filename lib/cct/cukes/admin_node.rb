module Cct
  class AdminNode < Node
    NAME = "admin"

    attr_reader :location
    private     :location

    def initialize options={}
      @name = options[:name] || config["name"] || NAME
      @admin = true

      if !options.empty?
        @location = (options["remote"] || options[:remote]) ? :remote : :local
        @location = :local if options[:local]
        set_node_attributes(options)
      else
        @location = config["remote"] ? :remote : :local
        set_node_attributes(config["remote"]) if remote?
      end

      @command =
        if remote?
          RemoteCommand.new(extract_attributes)
        else
          LocalCommand.new
        end
      super
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

    private

    def validate_attributes
      return if local?

      super
    end
  end
end
