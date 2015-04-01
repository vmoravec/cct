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
  class LocalCommandFailed < StandardError; end
end
