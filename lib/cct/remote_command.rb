module Cct
  class RemoteCommand
    TIMEOUT = 5
    EXTENDED_OPTIONS = OpenStruct.new(
      number_of_password_prompts: 0,
      port: 22
    )

    Result = Struct.new(:success?, :output, :error, :exit_code, :host)

    attr_reader :session, :options, :log, :gateway, :proxy

    def initialize opts
      @gateway = opts[:gateway]
      @proxy = opts[:proxy] || set_ssh_proxy
      @log = BaseLogger.new("SSH")
      @options = OpenStruct.new
      construct_options(opts)
      validate_options(opts[:skip_validation])
    end

    def exec! command, params=[], capture_error: false
      log.base.level = ::Logger::WARN
      connect!
      host_ip = options.ip
      environment = set_environment(params)
      full_command = "#{command} #{params.join(" ")}".strip
      result = Result.new(false, "", "", 1000, host_ip)
      open_session_channel do |channel|
        channel.exec("#{environment}#{full_command}") do |p, d|
          log.always("Running command `#{full_command}` on remote host #{host_ip}")
          channel.on_data {|p,data| result.output << data }
          channel.on_extended_data {|_,_,data| result.error << data }
          channel.on_request("exit-status") {|p,data| result.exit_code = data.read_long}
        end
      end
      session.loop unless gateway
      result[:success?] = result.exit_code.zero?
      if !result.success? || (result.error.length.nonzero? && !result.exit_code.zero?)
        log.error(result.output)
        raise RemoteCommandFailed.new(full_command, result) unless capture_error
      end
      result
    ensure
      log.base.level = Cct.verbose? ? ::Logger::DEBUG : ::Logger::INFO
    end

    def connect!
      return true if connected?

      handle_errors do
        @session =
          if gateway
            create_gateway_session
          else
            create_regular_session
          end
      end
      true
    end

    def connected?
      if gateway
        session && session.active? ? true : false
      else
        session && !session.closed? ? true : false
      end
    end

    def test_ssh!
      handle_errors do
        test_plain_ssh
      end
    end

    private

    def set_ssh_proxy
      proxy =  Cct.config.fetch("proxy")
      return unless proxy

      command = "ssh #{proxy["user"]}@#{proxy["fqdn"] || proxy["ip"]} nc %h #{proxy["port"] || '%p'}"
      require "net/ssh/proxy/command"
      Net::SSH::Proxy::Command.new(command)
    end

    def open_session_channel &block
      if gateway
        session.ssh(options.ip, options.user, options.extended.to_h) do |session|
          session.open_channel(&block)
        end
      else
        session.open_channel(&block)
      end
    end

    def create_regular_session
      Net::SSH.start(options.ip, options.user, options.extended.to_h)
    end

    def create_gateway_session
      options = {
        password: gateway[:password],
        port: gateway[:port],
        timeout: detect_timeout,
      }
      options.merge!(proxy: proxy) if proxy
      Net::SSH::Gateway.new(
        gateway[:ip],
        gateway[:user],
        options
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
      opts = {
        timeout: options.extended.timeout,
        port: options.extended.port,
        logger: log,
      }
      opts.merge!(proxy: proxy) if proxy
      Net::SSH::Transport::Session.new(options.ip, opts)
    end

    def set_environment params
      options = params.pop if params.last.is_a?(Hash)
      return "" if options.nil? || options[:environment].nil?

      source_files = options[:environment].delete(:source) || []
      export_env = options[:environment].map {|env| "export #{env[0]}=#{env[1]};" }.join.strip
      source_env = source_files.map {|file| "source #{file}; "}.join
      env = source_env + export_env
      log.always("Updating environment with `#{env}`")
      env
    end

    def construct_options opts
      options.ip = opts['ip'] || opts[:ip] || opts["fqdn"] || opts[:fqdn]
      options.user = opts['user'] || opts[:user]
      options.environment = opts['env'] || opts['environment'] || opts [:env] || {}
      options.extended = EXTENDED_OPTIONS.dup
      options.extended.logger = log
      options.extended.port = opts['port'] || opts[:port] if opts['port'] || opts[:port]
      options.extended.password = opts['password'] || opts[:password]
      options.extended.timeout = detect_timeout(opts)
      options.extended.proxy = proxy
      options.extended.keys = opts["keys"] || opts[:keys] if opts[:keys] || opts["keys"]
    end

    def detect_timeout opts={}
      timeout = TIMEOUT
      timeout = Cct.config['timeout']['ssh'] ? Cct.config['timeout']['ssh'] : timeout
      timeout = opts['timeout'] || opts[:timeout] || timeout
      timeout.to_i
    end

    def validate_options *options_to_skip
      options_to_skip.flatten!
      errors = []
      errors.push("missing ip") if !options.ip && !options_to_skip.include?(:ip)
      errors.push("missing user") unless options.user
      errors.unshift("Invalid options: ") unless errors.empty?
      raise ValidationError.new(self, errors) unless errors.empty?
    end
  end
end
