module Cct
  class SshConnectionTimeoutError < StandardError
    def initialize timeout: 5, node: 'unknown'
      super("SSH connection to node '#{node.name}' timed out after #{timeout} seconds")
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
