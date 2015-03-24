module Cct
  class RemoteCommand
    TIMEOUT = 10
    EXTENDED_OPTIONS = OpenStruct.new(
      logger: Cct.logger,
      number_of_password_prompts: 0
    )

    attr_reader :session, :options

    def initialize opts={}
      @options = OpenStruct.new
      construct_options(opts)
      validate_options
    end

    def exec! command, *params
      connect!
      session.exec!("#{command} #{params.join(" ")}")
    end

    def connect!
      return true if connected?

      @session = Net::SSH.start(options.ip, options.user, options.extended.to_h)
      true
    rescue Timeout::Error
      raise SshConnectionTimeoutError.new(
        target: options.target, timeout: options.extended.timeout
      )
    end

    def connected?
      session && !session.closed? ? true : false
    end

    private

    def construct_options opts
      options.ip = opts['ip'] || opts[:ip]
      options.user = opts['user'] || opts[:user]
      options.target = opts['target'] || opts[:target]
      options.extended = EXTENDED_OPTIONS
      options.extended.password = opts['password'] || opts[:password]
      options.extended.timeout = detect_timeout(opts)
    end

    def detect_timeout opts
      timeout = TIMEOUT
      timeout = Cct.config['ssh'] ? Cct.config['ssh']['timeout'] : timeout
      timeout = opts['timeout'] || opts[:timeout] || timeout
      timeout
    end

    def validate_options
      errors = []
      errors.push("missing ip") unless options.ip
      errors.push("missing user")      unless options.user
      errors.push("missing target")    unless options.target
      errors.unshift("Invalid options#{" for target '#{options.target}'" if options.target}") unless errors.empty?
      raise ValidationError.new(self, errors) unless errors.empty?
    end
  end
end
