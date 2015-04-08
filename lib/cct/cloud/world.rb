require "cct/cloud/crowbar_api"
require "cct/cloud/node"
require "cct/cloud/admin_node"
require "cct/cloud/nodes"

module Cct
  module Cloud
    class World
      include Commands::Local

      attr_reader :admin_node, :crowbar, :nodes

      def initialize
        @admin_node = AdminNode.new
        @crowbar = CrowbarApi.new(admin_node.config)
        admin_node.crowbar_proxy = Node::CrowbarProxy.new(api: crowbar)
        @nodes = Nodes.new(crowbar)
        nodes << admin_node
        @local_command = LocalCommand.new
      end

      def control_node
        nodes.control_node
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
