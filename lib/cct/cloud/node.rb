module Cct
  class Node
    include Commands::Remote

    extend Forwardable

    def_delegators :@command, :connected?, :connect!, :test_ssh!
    def_delegators :@crowbar_proxy, :status, :state, :alias, :fqdn, :domain,
                                    :data, :loaded?

    attr_reader :admin, :name, :ip, :user, :password, :port, :environment, :command,
                :keys

    private :admin

    def initialize options={}
      set_node_attributes(options)
      @admin ||= false
      @controller ||= false
      @environment ||= {}
      @command = RemoteCommand.new(attributes)
      @crowbar_proxy = CrowbarProxy.new(options[:crowbar])
      validate_attributes
    end

    def exec! command, *params, capture_error: false, environment: {}
      params << {environment: environment} unless environment.empty?
      @command.exec!(command, params, capture_error: capture_error)
    end

    def crowbar reload: false
      if reload
        @crowbar_proxy.reload!(attributes)
      else
        @crowbar_proxy.load!(attributes)
      end
    end

    def crowbar_proxy= proxy
      @crowbar_proxy = proxy
    end

    def actions
      public_methods.sort - Object.methods
    end

    def admin?
      @admin
    end

    def controller?
      @controller
    end

    def inspect
      "<#{self.class}##{object_id} alias=#{self.alias} name=#{name} ip=#{ip} " +
      "user=#{user} connected?=#{connected?} status=#{status} state=#{state} " +
      "fqdn=#{fqdn} environment=#{environment}>"
    end

    def attributes
      attrs = {
        ip: ip,
        user: user,
        name: name,
        password: password,
        port: port
      }
      attrs.merge!(keys: keys) if keys && !keys.empty?
      attrs
    end

    def load!
      crowbar
      self
    end

    def reload!
      crowbar(reload: true)
      self
    end

    private

    def set_node_attributes options
      return if options.empty?

      @ip = options['ip'] || options[:ip]
      @name ||= (options['name'] || options[:name])
      @environment = options['environment'] || options[:environment]
      set_ssh_attributes(options['ssh'] || options[:ssh])
    end

    def set_ssh_attributes options={}
      return if options.empty?
      @user = options['user'] || options[:user]
      @password = options['password'] || options[:password]
      @port = options['port'] || options[:port]
      @keys = options["keys"] || options[:keys]
    end

    def validate_attributes
      errors = []
      errors.push("IP can't be blank")   unless ip
      errors.push("user can't be blank") unless user
      errors.push("name can't be blank") unless name
      errors.unshift("Invalid attributes for node '#{name}'") unless errors.empty?
      raise ValidationError.new(self, errors) unless errors.empty?
    end

    class CrowbarProxy
      attr_reader :crowbar

      attr_reader :alias, :state, :status, :description, :loaded, :data, :hostname,
                  :fqdn, :domain

      alias_method :loaded?, :loaded

      def initialize options
        @loaded = false
        return if options.nil?

        @crowbar = options[:api]
        set_base_data(options[:base])
        set_extended_data(options[:extended])
      end

      def load! node_attributes
        loaded ? self : reload!(node_attributes)
      end

      def reload! attributes
        set_base_data(crowbar.nodes[attributes[:name]])
        set_extended_data(crowbar.node(attributes[:name]))
        self
      end

      def inspect
        "<#{self.class}##{object_id} hostname=#{hostname} alias=#{self.alias} "        +
        "state=#{state} status=#{status} description=#{description} domain=#{domain} " +
        "fqdn=#{fqdn} data={...#{data.keys.size} pairs...} >"
      end

      private

      def set_base_data data
        return if data.nil? || !data.is_a?(Hash)

        @alias = data["alias"].to_s
        @state = data["state"].to_s
        @status = data["status"].to_s
        @description = data["description"].to_s
      end

      def set_extended_data data
        return if data.nil? || !data.is_a?(Hash)

        @data = data
        @hostname = data["hostname"]
        @fqdn = data["fqdn"]
        @domain = data["domain"]
        @loaded = true
      end
    end
  end
end


