require "logger"
require "net/ssh"
require "ostruct"
require "timeout"
require "faraday"
require "faraday/digestauth"
require "faraday_middleware"

require "cct/cukes/errors"
require "cct/cukes/crowbar_api"
require "cct/cukes/local_command"
require "cct/cukes/remote_command"
require "cct/cukes/commands/local"
require "cct/cukes/commands/remote"
require "cct/cukes/node"
require "cct/cukes/admin_node"
require "cct/cukes/nodes"
require "cct/cukes/test_cloud"

module Cct
  module Cukes
    class World
      extend Forwardable

      def_delegators :@cloud, :admin_node, :crowbar, :nodes

      include Commands::Local

      def initialize
        @cloud = TestCloud.new
        @local_command = LocalCommand.new
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
