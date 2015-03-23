module Cct
  class RemoteCommand
    TIMEOUT = 10
    DEFAULT_OPTIONS = {
      logger: Cct.logger,
      number_of_password_prompts: 0
    }

    attr_reader :session, :timeout, :options, :node

    def initialize options={}
      @node = options[:node]
      @timeout = node.timeout || Cct.config['ssh']['timeout'] || TIMEOUT
      @options = construct_ssh_options(options)
      validate_options!
    end

    def exec! command, *params
      connect!
      session.exec!("#{command} #{params.join(" ")}")
    end

    def connect!
      return true if connected?

      @session = Net::SSH.start(*options)
      true
    rescue Timeout::Error
      raise SshConnectionTimeoutError.new(node: node, timeout: timeout)
    end

    def connected?
      !!session
    end

    private

    def construct_ssh_options opts
      options = []
      options << ( node.ip   || opts['ip']   || opts['hostname'] )
      options << ( node.user || opts['user'] || opts['login'] )
      options << DEFAULT_OPTIONS
      options.last.merge!(timeout: timeout)
      options.last.merge!(password: node.password || opts['password']) if opts['password'] || node.password
      options
    end

    def validate_options!
      errors = []
      errors.push("missing IP or hostname") if options.first.to_s.empty?
      errors.push("missing user name") if options[1].to_s.empty?
      errors.unshift("Insufficient options for node '#{node.name}'") unless errors.empty?
      raise ValidationError.new(self, errors) unless errors.empty?
    end
  end
end
