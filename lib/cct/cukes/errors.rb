module Cct
  class SshConnectionTimeoutError < StandardError
    def initialize timeout: 5, target: 'unknown'
      super("SSH connection to '#{target}' timed out after #{timeout} seconds")
    end
  end

  class ValidationError < StandardError
    def initialize klass, messages=[]
      message = "for #{klass} "
      message << messages.join(", ")
      super(message)
    end
  end
end
