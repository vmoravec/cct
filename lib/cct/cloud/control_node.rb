module Cct
  class ControlNode < Node
    LOG_TAG = "CONTROL_NODE"
    CONTROL_NODE_ROUTE = "/crowbar/nova/1.0/default"
    ENV_FILE = "/root/.openrc"

    attr_reader :gateway, :crowbar
    attr_reader :name, :fqdn, :state, :status, :description
    attr_reader :config, :command, :command_options

    def initialize options
      @loaded = false
      @controller = true
      @config = Cct.config["control_node"]
      @log = BaseLogger.new(LOG_TAG)
      @user = config["ssh"]["user"]
      @password = config["ssh"]["password"]
      @port = config["ssh"]["port"]
      @environment = {}
      @crowbar = options[:crowbar]
      @gateway = options[:gateway]
      @command = RemoteCommand.new(gateway: options[:gateway])
    end

    def exec! command_name, *params
      self.load!
      set_command_target
      command.exec!(command_name, params)
    end

    def test_ssh!
      exec!("echo 'Test ssh!'")
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
      @domain = data["domain"]

      # call the super class validation method
      validate_attributes

      @loaded = true
    end

    private

    def set_command_target
      return if command.target

      command.target = self
      set_command_options
    end

    def set_command_options
      return if command_options

      options = {port: port}
      options.merge!(timeout: command.options.extended.timeout)
      options.merge!(password: password) unless password.to_s.empty?
      @command_options = options
    end
  end
end
