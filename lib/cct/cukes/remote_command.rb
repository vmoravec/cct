module Cct
  class RemoteCommand
    TIMEOUT = 10
    EXTENDED_OPTIONS = OpenStruct.new(
      number_of_password_prompts: 0,
      port: 22
    )

    Result = Struct.new(:success?, :output, :exit_code, :host)

    attr_reader :session, :options, :log

    def initialize opts={}
      @log = BaseLogger.new("SSH")
      @options = OpenStruct.new
      construct_options(opts)
      validate_options
    end

    def exec! command, *params
      connect!
      result = Result.new(false, "", 1000, options.ip)
      session.open_channel do |channel|
        channel.exec("#{command} #{params.join(" ").strip}") do |ch, succ|
          channel.on_data {|_,data| result.output << data }
          channel.on_extended_data {|_,_,data| result.output << data }
          channel.on_request("exit-status") {|_,data| result.exit_code = data.read_long }
        end
      end
      session.loop
      result[:success?] = result.exit_code.zero?
      result
    end

    def connect!
      return true if connected?

      @session = Net::SSH.start(options.ip, options.user, options.extended.to_h)
      true
    rescue Timeout::Error => e
      raise SshConnectionError.new(
        ip: options.ip,
        message: e.message,
        target: options.target,
        timeout: options.extended.timeout
      )
    end

    def connected?
      session && !session.closed? ? true : false
    end

    def test_ssh!
      Net::SSH::Transport::Session.new(
        options.ip,
        timeout: options.extended.timeout,
        port: options.extended.port,
        logger: log
      )
      true
    rescue Timeout::Error, Errno::ETIMEDOUT, Errno::ECONNREFUSED => e
      raise SshConnectionError.new(
        ip: options.ip,
        target: options.target,
        message: e.message)
    end

    private

    def construct_options opts
      options.ip = opts['ip'] || opts[:ip]
      options.user = opts['user'] || opts[:user]
      options.target = opts['target'] || opts[:target]
      options.extended = EXTENDED_OPTIONS
      options.extended.logger = log
      options.extended.port = opts['port'] || opts[:port] if opts['port'] || opts[:port]
      options.extended.password = opts['password'] || opts[:password]
      options.extended.timeout = detect_timeout(opts)
    end

    def detect_timeout opts
      timeout = TIMEOUT
      timeout = Cct.config['timeout']['ssh'] ? Cct.config['timeout']['ssh'] : timeout
      timeout = opts['timeout'] || opts[:timeout] || timeout
      timeout.to_i
    end

    def validate_options
      errors = []
      errors.push("missing ip") unless options.ip
      errors.push("missing user") unless options.user
      errors.push("missing target") unless options.target
      errors.unshift("Invalid options#{" for target '#{options.target}'" if options.target}") unless errors.empty?
      raise ValidationError.new(self, errors) unless errors.empty?
    end
  end
end
