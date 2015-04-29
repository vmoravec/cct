module Cct
  class RemoteCommand
    DEFAULT_TYPE = :direct
    TIMEOUT = 5
    EXTENDED_OPTIONS = OpenStruct.new(
      number_of_password_prompts: 0,
      port: 22
    )

    Result = Struct.new(:success?, :output, :exit_code, :host)

    attr_reader :session, :options, :log, :gateway
    attr_accessor :target

    def initialize opts
      @gateway = opts[:gateway]
      @log = BaseLogger.new("SSH")
      @options = OpenStruct.new
      construct_options(opts)
      validate = (opts[:validate].nil? ? true : opts[:validate])
      validate_options
    end

    def exec! command, params=[]
      connect!
      environment = set_environment(params)
      full_command = "#{command} #{params.join(" ")}".strip
      result = Result.new(false, "", 1000, options.ip)
      open_session_channel do |channel|
        channel.exec("#{environment}#{full_command}") do |p, d|
          channel.on_close do
            log.info("Running command `#{full_command}` on remote host #{options.ip}")
          end
          channel.on_data {|p,data| result.output << data }
          channel.on_extended_data {|_,_,data| result.output << data }
          channel.on_request("exit-status") {|p,data| result.exit_code = data.read_long}
        end
      end
      session.loop
      result[:success?] = result.exit_code.zero?
      if !result.success?
        log.error(result.output)
        raise RemoteCommandFailed.new(full_command, result)
      end
      result
    end

    def connect!
      return true if connected?

        @session =
          if gateway
            create_gateway_session
          else
            Net::SSH.start(options.ip, options.user, options.extended.to_h)
          end
      true
    end

    def connected?
      session && !session.closed? ? true : false
    end

    def test_ssh!
      handle_errors do
        test_plain_ssh
      end
    end

    private

    def open_session_channel &block
      if gateway
        session.ssh(target.ip, target.user, target.command_options) &block
      else
        session.open_channel(&block)
      end
    end

    def create_gateway_session
      Net::SSH::Gateway.new(
        gateway.attributes["ip"],
        gateway.attributes["user"],
        password: gateway.attributes["password"],
        port: gateway.attributes["port"],
        timeout: detect_timeout
      )
    end

    def handle_errors
      attempts = 0
      yield
    rescue Timeout::Error, Errno::ETIMEDOUT, Errno::ECONNREFUSED => e
      raise SshConnectionError.new(
        ip: options.ip,
        message: e.message
      )
    rescue Net::SSH::HostKeyMismatch => e
      attempts += 1
      log.error("Mismatch of host keys, #{attempts}. attempt, fixing and going to retry now..")
      e.remember_host!
      retry unless attempts > 1
      log.error("Mismatch of host keys, #{attempts}. attempt, failing..")
      raise
    end

    def test_plain_ssh
      Net::SSH::Transport::Session.new(
        options.ip,
        timeout: options.extended.timeout,
        port: options.extended.port,
        logger: log
      )
    end

    def set_environment params
      options = params.pop if params.last.is_a?(Hash)
      return "" if options.nil? || options[:environment].nil?

      source_files = options[:environment].delete(:source) || []
      export_env = options[:environment].map {|env| "#{env[0]}=#{env[1]} " }.join.strip
      export_env.prepend("export ") unless export_env.empty?
      source_env = source_files.map {|f| "source #{f}; "}.join
      source_env + export_env
    end

    def construct_options opts
      options.ip = opts['ip'] || opts[:ip]
      options.user = opts['user'] || opts[:user]
      options.environment = opts['env'] || opts['environment'] || opts [:env] || {}
      options.extended = EXTENDED_OPTIONS
      options.extended.logger = log
      options.extended.port = opts['port'] || opts[:port] if opts['port'] || opts[:port]
      options.extended.password = opts['password'] || opts[:password]
      options.extended.timeout = detect_timeout(opts)
    end

    def detect_timeout opts={}
      timeout = TIMEOUT
      timeout = Cct.config['timeout']['ssh'] ? Cct.config['timeout']['ssh'] : timeout
      timeout = opts['timeout'] || opts[:timeout] || timeout
      timeout.to_i
    end

    def validate_options
      errors = []
      errors.push("missing ip") unless options.ip
      errors.push("missing user") unless options.user
      errors.unshift("Invalid options: ") unless errors.empty?
      raise ValidationError.new(self, errors) unless errors.empty?
    end
  end
end
