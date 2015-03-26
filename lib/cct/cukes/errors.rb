module Cct
  class SshConnectionTimeoutError < StandardError
    def initialize timeout: 5, target: 'unknown', host: nil
      super("SSH connection to '#{target}' at #{host} timed out after #{timeout} seconds")
    end
  end

  class ValidationError < StandardError
    def initialize klass, messages=[]
      message = "for #{klass} "
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

  class CrowbarApiError < StandardError; end
  class HttpConnectionFailed < StandardError; end
end
