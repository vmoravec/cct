module Cct
  class HttpCommand
    HEADERS = {
      "Content-Type" => "application/json"
    }

    attr_reader :connection

    def initialize options={}
      validate(options)
      faraday_options = { url: "#{options['url']}:#{options['port']}", headers: HEADERS }
      @connection = Faraday.new(faraday_options) do |f|
        f.request(:digest, options['user'], options['password'])
        f.adapter ::Faraday.default_adapter
      end
    rescue Faraday::ConnectionFailed => e
      raise HttpConnectionFailed, e.message
    end

    private

    def validate options
    end
  end
end
