module Cct
  module Cukes
    class TestCloud
      attr_reader :admin_node, :crowbar, :nodes

      def initialize
        @admin_node = AdminNode.new
        @crowbar = CrowbarApi.new(admin_node.config)
        @nodes = Nodes.new(crowbar)
      end
    end
  end
end

