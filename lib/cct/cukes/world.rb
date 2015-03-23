require "logger"
require "net/ssh"

require "cct/cukes/logger"
require "cct/cukes/errors"
require "cct/cukes/remote_command"
require "cct/cukes/local_command"
require "cct/cukes/command_proxy"
require "cct/cukes/node"
require "cct/cukes/admin_node"
require "cct/cukes/nodes"
require "cct/cukes/test_cloud"

module Cct
  module Cukes
    class World
      attr_reader :admin_node, :cloud

      def initialize options={}
        @admin_node = AdminNode.new(options)
        @cloud = TestCloud.new(admin_node, options)
      end

      def config
        Cct.config
      end
    end
  end
end
