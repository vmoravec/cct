require "cct/commands/openstack"

module Cct
  class ControlNode < Node
    LOG_TAG = "CONTROL_NODE"
    CONTROL_NODE_ROUTE = "/crowbar/nova/1.0/default"
    ENV_FILE = "/root/.openrc"

    include Commands::Openstack

    attr_reader :gateway, :crowbar, :log
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
      set_command_options
      @command = RemoteCommand.new(command_options.merge(skip_validation: [:ip]))
    end

    def exec! command_name, *params
      self.load!
      params << update_environment(params)
      command.exec!(command_name, params.compact)
    end

    # Expected are params in form of a hash
    # Typical there will be two kinds of keys:
    # * source => will refer to list of files you want to source
    # * other keys => they will be grouped into the hash with key 'environment'
    # @param Hash
    def update_environment params
      options = params.last.is_a?(Hash) ? params.pop : {}
      source = update_source(options.delete(:source))
      environment = options
      {environment: environment.merge(source: source)}
    end

    def update_source source
      new_source =
        case source
        when String
          [ source ]
        when nil
          []
        when Array
          source
        else
          raise "Source type #{source.class} not allowed"
        end
      new_source << ENV_FILE
    end

    def get_hash_from_envfile
      in_hash = {}
      f = read_file(ENV_FILE)
      f.each_line do |line|
        next unless line.start_with?("export")
        line.sub!("export", "").chomp!
        key, value = line.split("=", 2)
        key.strip!
        value.strip!
        in_hash[key] = value.tr_s!("'*'", "")
      end
      return in_hash
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
      controller_fqdn = nil
      %w(nova-controller nova-multi-controller).each do |controller_role|
        if response.body["deployment"]["nova"]["elements"].has_key? controller_role
          controller_fqdn =
            response.body["deployment"]["nova"]["elements"][controller_role].first
          break
        end
      end
      raise "Failed to get FQDN for controller node" unless controller_fqdn

      # For getting the controller fqdn in clustered environment
      if controller_fqdn.start_with? "cluster:"
        cluster_name = controller_fqdn.split(":")[1]
        response = crowbar.get("/crowbar/pacemaker/1.0/#{cluster_name}")
        controller_fqdn =
          response.body["deployment"]["pacemaker"]["elements"]["pacemaker-cluster-member"].first
        raise "Failed to get FQDN for controller node" unless controller_fqdn
      end

      @fqdn = controller_fqdn
      @name = fqdn.split(".").first
      @description = response["description"]
      data = crowbar.nodes[name]
      @alias = data["alias"]
      @state = data["state"]
      @status = data["status"]
      data = crowbar.node(name)
      @data = data
      @ip = data["crowbar"]["network"]["admin"]["address"]
      command.options.ip = ip
      @hostname = data["hostname"]
      @domain = data["domain"]

      # call the super class validation method
      validate_attributes

      @loaded = true
    end

    private

    def set_command_options
      options = {port: port, user: user}
      options.merge!(timeout: config["timeout"]) if config["timeout"]
      options.merge!(password: password) unless password.to_s.empty?
      options.merge!(gateway: gateway) if gateway
      options.merge!(logger: log)
      @command_options = options
    end
  end
end
