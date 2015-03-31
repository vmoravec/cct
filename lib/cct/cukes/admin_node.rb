module Cct
  class AdminNode < Node
    NAME = "admin"

    attr_reader :api, :log

    def initialize options={}
      @name = NAME
      @admin = true
      @log = BaseLogger.new(NAME.upcase)
      set_node_attributes(options)
      @api = create_api
      super
    end

    def test_api!
      log.info "Sending request HEAD #{api.build_url}"
      if !api.head.success?
        log.error "HEAD request at #{api.build_url} failed"
        raise CrowbarApiError, "Crowbar API head request to #{ip} failed"
      end
      true
    rescue Faraday::ConnectionFailed => e
      log.error(e.message)
      raise CrowbarApiError, e.message
    end

    def config
      Cct.config['admin_node']
    end

    private

    def create_api
      api_config = config["remote"]["api"]
      api_url = api_config["ssl"] ? "https://" : "http://"
      api_url << ip
      Cct::CrowbarApi.new(api_config.merge("url"=> api_url)).connection
    end

    def set_node_attributes options
      options.empty? ? super(config["remote"]) : super
    end
  end
end
