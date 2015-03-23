module Cct
  class Node
    attr_reader :config, :command_proxy, :admin

    private :command_proxy, :admin

    def initialize options={}
      @admin = false unless admin
      @config = options[:config] unless config
      @command_proxy = CommandProxy.new(:remote) unless command_proxy
    end

    def exec! command_name, *options
      command_proxy.exec!(command_name, options)
    end

    def admin?
      @admin
    end

    # Change by implementing your own version in subclass
    def remote?
      true
    end

    # Change by implementing your own version in subclass
    def local?
      false
    end
  end
end


