module Cct
  class Nodes
    CROWBAR_NODE = "crowbar"

    attr_reader :nodes
    private :nodes

    attr_reader :crowbar, :config

    def initialize crowbar_api
      @crowbar = crowbar_api
      @loaded = false
      @nodes = Array.new
      @config = Cct.config["nodes"]
    end

    def loaded?
      @loaded
    end

    def load!
      return if loaded?

      load_nodes!
    end

    def inspect
      nodes.inspect
    end

    private

    def load_nodes!
      crowbar.nodes.each_pair do |name, attrs|
        node_details = crowbar.node(name)
        known_config = find_in_config(name)
        if known_config
          nodes << Node.new(known_config.merge(ip: node_details["ipaddress"]))
          next
        end

        node_config = default_node_config
        nodes << Node.new(node_config.merge(ip: node_details["ipaddress"], name: name))
      end
      @loaded = true
    end

    def find_in_config name
      known = config.find {|node| node["name"] == name }
      return known["ssh"] if known
    end

    def default_node_config
      conf = config.find {|node| node["name"].nil? }
      if conf.nil? || !config.is_a?(Hash)
        raise ConfigurationError, "Default configuration for nodes not found"
      elsif conf["ssh"].nil? || !conf["ssh"].is_a?(Hash)
        raise ConfigurationError, "Node configuration for ssh not found"
      end
      conf["ssh"]
    end
  end
end
