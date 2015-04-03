module Cct
  module Cukes
    class TestCloud
      attr_reader :admin_node, :crowbar, :nodes

      def initialize
        @admin_node = AdminNode.new
        @crowbar = CrowbarApi.new(admin_node.config)
        admin_node.crowbar_proxy = Node::CrowbarProxy.new(api: crowbar)
        @nodes = Nodes.new(crowbar)
        nodes << admin_node
      end
    end
  end
end

