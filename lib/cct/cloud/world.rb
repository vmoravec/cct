require "cct/cloud/crowbar_api"
require "cct/cloud/node"
require "cct/cloud/admin_node"
require "cct/cloud/control_node"
require "cct/cloud/nodes"

module Cct
  module Cloud
    class World
      include Commands::Local

      attr_reader :admin_node, :control_node, :crowbar, :nodes, :log

      def initialize logger=nil
        @admin_node = AdminNode.new
        @crowbar = CrowbarApi.new(admin_node.config)
        admin_node.crowbar_proxy = Node::CrowbarProxy.new(api: crowbar)
        @control_node = ControlNode.new(crowbar: crowbar, gateway: admin_node.attributes)
        @nodes = Nodes.new(crowbar)
        nodes << control_node << admin_node
        @command =
          if Cct.config.fetch("proxy")
            RemoteCommand.new(Cct.config["proxy"].merge(proxy: false))
          else
            LocalCommand.new
          end
        @log = logger if logger
      end

      def exec! command_name, *params
        @command.exec!(command_name, params)
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
