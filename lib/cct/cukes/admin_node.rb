module Cct
  class AdminNode < Node
    NAME = "admin"

    extend Forwardable

    def_delegators :@api, :head, :get

    attr_reader :api

    def initialize options={}
      @name = NAME
      @admin = true
      set_node_attributes(options)
      @api = Cct::CrowbarApi.new(
        config["remote"]["api"].merge("url"=>"http://#{ip}")
      ).connection
      super
    end

    def test_api!
      response = api.head
      if !response.success?
        puts response.body
        raise CrowbarApiError, "Crowbar API head request to #{ip} failed"
      end
      true
    end

    def config
      Cct.config['admin_node']
    end

    private

    def set_node_attributes options
      options.empty? ? super(config["remote"]) : super
    end
  end
end
