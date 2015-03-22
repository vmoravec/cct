require "cct/cukes/test_cloud"
require "cct/cukes/admin_node"
require "cct/cukes/nodes"

module Cct
  module Cukes
    class World
      attr_reader :admin_node, :config, :cloud

      def initialize
        @config = Cct.config
        @admin_node = AdminNode.new
        @cloud = TestCloud.new(admin_node)
      end
    end
  end
end
