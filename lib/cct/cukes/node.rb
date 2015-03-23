module Cct
  class Node
    extend Forwardable

    def_delegators :@command, :exec!, :connected?, :connect!

    attr_reader :admin, :name, :ip, :user, :password, :timeout

    private :admin

    def initialize options={}
      extract_options(options)
      fail "Missing node name" unless name

      @admin = false
      yield if block_given?
      @command ||= RemoteCommand.new(node: self)
    end

    def admin?
      @admin
    end

    # Change by implementing your own version in subclass
    def remote?
      true
    end

    # Change by implementing your own version in subclass
    def local?
      false
    end

    private

    def extract_options options
      @ip = options['ip'] || options[:ip]
      @name ||= (options['name'] || options[:name])
      @user = options['user'] || options[:user]
      @password = options['password'] || options[:password]
      @timeout = options['timeout'] || options[:timeout]
    end
  end
end


