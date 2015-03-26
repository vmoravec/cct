module Cct
  class Node
    module Commands
      # Ping with 5 seconds timeout and a single attempt
      def ping!
        command = "ping -q -c 1 -W 5 #{ip}"
        result  = `#{command}`
        if $?.exitstatus.nonzero?
          raise PingError.new(command, result)
        end
      end
    end

    include Commands

    extend Forwardable

    def_delegators :@command, :exec!, :connected?, :connect!, :test_ssh!

    attr_reader :admin, :name, :ip, :user, :password, :port

    private :admin

    def initialize options={}
      set_node_attributes(options)
      @admin ||= false
      @command ||= RemoteCommand.new(extract_attributes)
      validate_attributes
    end

    def admin?
      @admin
    end

    def remote?
      true
    end

    def local?
      false
    end

    private

    def set_node_attributes options
      return if options.empty?

      @ip = options['ip'] || options[:ip]
      @name ||= (options['name'] || options[:name])
      set_ssh_attributes(options['ssh'] || options[:ssh])
    end

    def extract_attributes
      { ip: ip,
        user: user,
        target: name,
        name: name,
        password: password,
      }
    end

    def set_ssh_attributes options={}
      return if options.empty?

      @user = options['user'] || options[:user]
      @password = options['password'] || options[:password]
      @port = options['port'] || options[:port]
    end

    def validate_attributes
      errors = []
      errors.push("IP can't be blank")   unless ip
      errors.push("user can't be blank") unless user
      errors.push("name can't be blank") unless name
      errors.unshift("Invalid attributes for node '#{name}'") unless errors.empty?
      raise ValidationError.new(self, errors) unless errors.empty?
    end
  end
end


