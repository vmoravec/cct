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
      @config = Cct.config.fetch("nodes", {})
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
      load!
      nodes.select {|n| n.name != node.name}
    end

    # @param name [String] Hostname of a node
    # @param fqdn [String] Fully qualified domain name
    # @param barclamp [String] Name of a barclamp assigned to a node
    # @param element [String] Element name in the crowbar proposal json tree
    # @note Parameter :barclamp requires element to be specified
    # @return [Array] One or multiple node instances
    def find name: nil, fqdn: nil, barclamp: nil, element: nil
      load!
      return nodes.select {|n| n.name == name } if name
      return nodes.select {|n| n.fqdn == fqdn } if fqdn

      if barclamp
        raise "Missing element for barclamp proposal" unless element

        proposal = JSON.parse(
          admin_node.exec!("crowbar #{barclamp} show default").output
        )

        nodes_detected = []

        clustered = proposal["deployment"][barclamp]["elements"][element].first.start_with?("cluster:")

        if clustered
          nodes_detected.push(
            proposal["deployment"][barclamp]["elements_expanded"][element]
          )
        else
          nodes_detected.push(
            proposal["deployment"][barclamp]["elements"][element]
          )
        end

        nodes_detected.flatten.compact.map do |node_fqdn|
          nodes.find {|n| n.fqdn == node_fqdn }
        end.compact
      end
    end

    def admin_node
      @admin_node ||= nodes.find {|node| node.name == AdminNode::NAME }
    end

    def clear
      nodes.clear
      @loaded = false
    end

    private

    def load_nodes!
      clear
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
