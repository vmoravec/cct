module Cct
  class Node
    extend Forwardable

    def_delegators :@command, :exec!, :connected?, :connect!

    attr_reader :admin, :name, :ip, :user, :password, :timeout

    private :admin

    def initialize options={}
      set_node_attributes(options) unless options.empty?
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
      @ip = options['ip'] || options[:ip]
      @name ||= (options['name'] || options[:name])
      @user = options['user'] || options[:user]
      @password = options['password'] || options[:password]
      @timeout = options['timeout'] || options[:timeout]
    end

    def extract_attributes
      { ip: ip,
        user: user,
        target: name,
        name: name,
        password: password,
        timeout: timeout
      }
    end

    def validate_attributes node=self
      errors = []
      errors.push("IP can't be blank")   unless ip
      errors.push("user can't be blank") unless user
      errors.push("name can't be blank") unless name
      errors.unshift("Invalid attributes for node '#{name}'") unless errors.empty?
      raise ValidationError.new(self, errors) unless errors.empty?
    end
  end
end


