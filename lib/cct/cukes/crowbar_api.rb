module Cct
  class CrowbarApi
    HEADERS = {
      "Content-Type" => "application/json"
    }

    extend Forwardable

    def_delegators :@connection, :head, :get

    attr_reader :connection

    def initialize options={}
      validate(options)
      faraday_options = { url: "#{options['url']}:#{options['port']}", headers: HEADERS }
      @connection = Faraday.new(faraday_options) do |f|
        f.request(:digest, options['user'], options['password'])
        f.adapter ::Faraday.default_adapter
      end
    rescue Faraday::ConnectionFailed => e
      raise CrowbarApiError, e.message
    end

    private

    #TODO
    def validate options;  end
  end
end
