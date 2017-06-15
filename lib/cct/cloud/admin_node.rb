module Cct
  class AdminNode < Node
    NAME = "crowbar"

    def self.create
      admin_node = new
      crowbar = CrowbarApi.new(admin_node.config)
      admin_node.crowbar_proxy = Node::CrowbarProxy.new(api: crowbar)
      admin_node
    end

    attr_reader :api, :log, :config

    def initialize options={}
      @name = NAME
      @admin = true
      @log = BaseLogger.new(NAME.upcase)
      @config = Cct.config["admin_node"]
      set_node_attributes(options)
      super()
    end

    private

    def set_node_attributes options
      options.empty? ? super(config) : super(config.merge(options))
    end
  end
end
