module Cct
  class AdminNode < Node
    NAME = "admin"

    attr_reader :location
    private     :location

    attr_reader :api

    def initialize options={}
      @name = options[:name] || config["name"] || NAME
      @admin = true
      @location = detect_location(options)
      set_node_attributes(options)
      @command = remote? ? RemoteCommand.new(extract_attributes) : LocalCommand.new
      @api = detect_api
      super
    end

    def api_test!
      if !api.connection.head.success?
        raise CrowbarApiError, "Crowbar API head request call at #{ip} failed"
      end
      true
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

    def detect_api
      case location
      when :remote
        Cct::HttpCommand.new(config["remote"]["api"].merge("url"=>"http://#{ip}"))
      when :local
        Cct::HttpCommand.new(config["api"])
      end
    end

    def set_node_attributes options
      options.empty? ? super(config["remote"]) : super
    end

    def detect_location options
      location = detect_location_from_options(options)
      return if location

      location = detect_location_from_config
      raise "Location for node '#{name}' not detected" if location.nil?
      location
    end

    def detect_location_from_options options
      return if options.empty?

      return :remote if options["remote"] || options[:remote]
      :local
    end

    def detect_location_from_config
      :remote if config["remote"]
    end
  end
end
