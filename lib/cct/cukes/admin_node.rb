module Cct
  class AdminNode < Node
    NAME = "crowbar"

    attr_reader :api, :log

    def initialize options={}
      @name = NAME
      @admin = true
      @log = BaseLogger.new(NAME.upcase)
      set_node_attributes(options)
      super
    end

    def config
      Cct.config['admin_node']
    end

    private

    def set_node_attributes options
      options.empty? ? super(config) : super
    end
  end
end
