module Cct
  class SshConnectionError < StandardError
    def initialize options={}
      message = "SSH connection to #{options[:ip]} failed\n#{options[:message]}"
      message << "\nTimeout #{options[:timeout]} seconds" if options[:timeout]
      super(message)
    end
  end

  class ValidationError < StandardError
    def initialize klass, messages=[]
      message = "for #{klass} "
      message << messages.shift
      message << messages.join(", ")
      super(message)
    end
  end

  class PingError < StandardError
    def initialize command, message
      full = "#{command}\n\n"
      full << message.to_s
      super(full)
    end
  end

  class RemoteCommandFailed < StandardError
    def initialize command, result
      super(
        "`#{command}` failed.\nError: #{result.error}Output: #{result.output} " +
        "Host: #{result.host} ( #{result.alias} )"
      )
    end
  end

  class LocalCommandFailed < StandardError
    def initialize result
      super("#{result.output.strip}\nHost: #{result.host}")
    end
  end

  class CrowbarApiError < StandardError; end
  class HttpConnectionFailed < StandardError; end
  class LocalCommandFailed < StandardError; end
  class ConfigurationError < StandardError; end
end
