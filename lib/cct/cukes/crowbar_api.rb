module Cct
  class CrowbarApi
    LOG_TAG = "CROWBAR"

    ROUTES = {
      nodes:     "/nodes.json",
      barclamps: "/crowbar.json",
      dashboard: "/dashboard.json"
    }

    # Dynamicaly define instance methods for crowbar API from
    # the list above for convenience
    ROUTES.each_pair do |route, fragment|
      define_method(route) { get(fragment).body }
    end

    extend Forwardable

    def_delegators :@connection, :head, :get

    attr_reader :connection, :log

    def initialize options={}
      @log = BaseLogger.new(LOG_TAG)
      config = options["remote"]["api"]
      config[:url] = config["ssl"] ? "https://" : "http://"
      config[:url] << options["remote"]["ip"] << ":#{config["port"]}"

      @connection = Faraday.new(url: config[:url] ) do |builder|
        builder.request(:digest, config['user'], config['password'])
        builder.request :json
        builder.request :url_encoded
        builder.response :crowbar_logger, log
        builder.response :json, :content_type => /\bjson$/
        builder.adapter ::Faraday.default_adapter
      end
    rescue Faraday::ConnectionFailed => e
      raise CrowbarApiError, e.message
    end

    def route name
      ROUTES[name]
    end

    def routes
      ROUTES
    end

    def test!
      if !head.success?
        log.error "HEAD request at #{connection.build_url} failed"
        raise CrowbarApiError, "Crowbar API head request to #{connection.build_url} failed"
      end
      true
    rescue Faraday::ConnectionFailed => e
      log.error(e.message)
      raise CrowbarApiError, e.message
    end
  end

  # Idea stolen from https://github.com/envylabs/faraday-detailed_logger
  # The goal is to have detailed log about sent and received data
  # If verbose all headers with response body will be logged; this might
  # be a huge amount of data as crowbar API returns a lot of details for nodes
  class CrowbarMiddleware < Faraday::Response::Middleware
    attr_reader :logger

    def initialize app, logger
      super(app)
      @logger = logger
    end

    def call env
      logger.info("#{env[:method].upcase} #{env[:url]}")
      logger.debug(curl_output(env[:request_headers], env[:body]).inspect)
      super
    end

    def on_complete env
      logger.info("HTTP #{env[:response_headers]["status"]}")
      logger.debug(curl_output(env[:response_headers], env[:body]).inspect)
    end

    private

    def curl_output headers, body
      string = headers.collect { |k,v| "#{k}: #{v}" }.join("\n")
      string + "\n\n#{body}"
    end
  end

  Faraday::Response.register_middleware(
    :crowbar_logger => CrowbarMiddleware
  )
end
