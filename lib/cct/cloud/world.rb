require "cct/cloud/crowbar_api"
require "cct/cloud/node"
require "cct/cloud/admin_node"
require "cct/cloud/nodes"
require "cct/cloud/control_node"

module Cct
  module Cloud
    class World
      include Commands::Local

      attr_reader :admin_node, :control_node, :crowbar, :nodes, :log

      def initialize logger=nil
        @admin_node = AdminNode.new
        @crowbar = CrowbarApi.new(admin_node.config)
        admin_node.crowbar_proxy = Node::CrowbarProxy.new(api: crowbar)
        @nodes = Nodes.new(crowbar)
        nodes << admin_node
        @control_node = ControlNode.new(nodes)
        control_node.crowbar_proxy = Node::CrowbarProxy.new(api: crowbar)
        nodes << control_node
        @local_command = LocalCommand.new
        @log = logger if logger
      end

      def exec! command_name, *params
        @local_command.exec!(command_name, params)
      end

      def config
        Cct.config
      end

      def env param
        ENV[param.to_s]
      end
    end
  end
end
