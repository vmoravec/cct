module Cct
  class Nodes
    extend Forwardable

    def_delegators :@nodes, :map, :first, :each, :last, :find, :[], :size, :<<

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

    def load! force=false
      return load_nodes! if force
      return nodes if loaded?

      load_nodes!
    end

    def inspect
      nodes.inspect
    end

    def exept node
      nodes.select {|n| n.name != node.name}
    end

    private

    def load_nodes!
      crowbar.nodes.each_pair do |name, attrs|
        details = crowbar.node(name)
        if name == AdminNode::NAME
          load_admin(name, attrs, details)
          next
        end
        next if load_known_config(name, attrs, details)
        load_default_config(name, attrs, details)
      end
      @loaded = true
      nodes
    end

    def load_admin name, attrs, node_details
      admin_node = nodes.find {|n| n.name == AdminNode::NAME}
      if admin_node
        return admin_node.reload! unless admin_node.loaded?
        return admin_node if admin_node.loaded?
      end
      nodes << AdminNode.new(
        crowbar: {
          api: crowbar,
          base: attrs,
          extended: node_details
        }
      )
    end

    def load_known_config name, attrs, node_details
      known_config = find_in_config(name)
      if known_config
        nodes << Node.new(
          known_config.merge(
            ip: node_details["ipaddress"],
            crowbar: {
              api: crowbar,
              base: attrs,
              extended: node_details
            }
          )
        )
      end
    end

    def load_default_config name, attrs, node_details
      node_config = default_node_config
      nodes << Node.new(
        node_config.merge(
          ip: node_details["ipaddress"],
          name: name,
          crowbar: {
           api: crowbar,
           base: attrs,
           extended: node_details
          }
        )
      )
    end

    def find_in_config name
      config.find {|node| node["name"] == name }
    end

    def default_node_config
      conf = config.find {|node| node["name"].nil? }
      if conf.nil? || !conf.is_a?(Hash)
        raise ConfigurationError, "Default configuration for nodes not found"
      elsif conf["ssh"].nil? || !conf["ssh"].is_a?(Hash)
        raise ConfigurationError, "Node configuration for ssh not found"
      end
      conf
    end
  end
end
