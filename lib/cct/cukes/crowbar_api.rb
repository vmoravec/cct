module Cct
  class CrowbarApi
    LOG_TAG = "CROWBAR"
    ROUTES = {
      nodes: "/nodes.json"
    }

    extend Forwardable

    def_delegators :@connection, :head, :get

    attr_reader :connection, :log

    def initialize options={}
      @log = BaseLogger.new(LOG_TAG)
      config = options["remote"]["api"]
      config[:url] = config["ssl"] ? "https://" : "http://"
      config[:url] << options["remote"]["ip"] << ":#{config["port"]}"

      @connection = Faraday.new(url: config[:url] ) do |c|
        c.request(:digest, config['user'], config['password'])
        c.request :json

        c.response :json, :content_type => /\bjson$/

        c.adapter ::Faraday.default_adapter
      end
    rescue Faraday::ConnectionFailed => e
      raise CrowbarApiError, e.message
    end

    def create_api
      Cct::CrowbarApi.new(api_config.merge("url"=> api_url)).connection
    end


    def route name
      ROUTES[name]
    end

    #TODO currently this returns a big hash (json -> Hash)
    #What do we want to do here with this data?
    def nodes
      get(route(:nodes)).body
    end

    def test!
      log.info "Sending request HEAD #{connection.build_url}"
      if !head.success?
        log.error "HEAD request at #{connection.build_url} failed"
        raise CrowbarApiError, "Crowbar API head request to #{connection.build_url} failed"
      end
      true
    rescue Faraday::ConnectionFailed => e
      log.error(e.message)
      raise CrowbarApiError, e.message
    end


    private

    #TODO
    def extract options
      api_config = options["remote"]["api"]
      api_url = api_config["ssl"] ? "https://" : "http://"
      api_url << ip
    end
  end
end
