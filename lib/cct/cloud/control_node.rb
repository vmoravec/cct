module Cct
  class ControlNode < Node
    LOG_TAG = "CONTROL_NODE"
    CONTROL_NODE_ROUTE = "/crowbar/nova/1.0/default"
    ENV_FILE = "/root/.openrc"

    attr_reader :gateway
    attr_reader :name, :fqdn, :state, :status, :description
    attr_reader :config, :command

    def initialize options
      @loaded = false
      @controller = true
      @config = Cct.config["control_node"]
      @log = BaseLogger.new(LOG_TAG)
      @user = config["user"]
      @password = config["password"]
      @port = config["port"]
      @environment = {}
      @crowbar = options[:crowbar]
      @gateway = options[:gateway]
      @command = Net::SSH::Gateway.new(
        gateway.attributes["ip"],
        gateway.attributes["user"],
        password: gateway["password"],
        port: gateway["port"]
      )
    end

    def exec! com
      self.load!
      options = {port: port}
      options.merge!(password: password) unless password.to_s.empty?
      command.ssh(ip, user, options) do |ssh|
        puts ssh.exec!(com)
      end
    end

    def loaded?
      @loaded
    end

    def load! force: false
      return if loaded? && !force

      response = crowbar.get(CONTROL_NODE_ROUTE)
      if !response.success?
        fail CrowbarApiError,
          "Failed at #{response.env[:url]} while requesting controller node details"
      end

      # FIXME: In case there are several controller nodes, take the first one
      #        This strategy is not perfect but it's enough sofar
      #        as it's the typical setup
      controller_fqdn =
        response.body["deployment"]["nova"]["elements"]["nova-multi-controller"].first
      raise "Failed to get FQDN for controller node" unless controller_fqdn

      @fqdn = controller_fqdn
      @name = fqdn.split(".").first
      @description = response["description"]
      data = crowbar.nodes[name]
      @alias = data["alias"]
      @state = data["state"]
      @status = data["status"]
      data = crowbar.node(name)
      @data = data
      @ip = data["ipaddress"]
      @hostname = data["hostname"]
      @doamin = data["domain"]
      validate_attributes
      @loaded = true
    end
  end
end
