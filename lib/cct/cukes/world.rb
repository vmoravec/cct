require "logger"
require "net/ssh"
require "ostruct"
require "timeout"
require "faraday"
require "faraday/digestauth"

require "cct/cukes/logger"
require "cct/cukes/errors"
require "cct/cukes/http_command"
require "cct/cukes/local_command"
require "cct/cukes/remote_command"
require "cct/cukes/node"
require "cct/cukes/admin_node"
require "cct/cukes/test_cloud"

module Cct
  module Cukes
    class World
      attr_reader :cloud

      def initialize
        @cloud = TestCloud.new
      end

      def admin_node
        cloud.admin_node
      end

      def config
        Cct.config
      end

      def exec!
        raise NotImplementedError
      end
    end
  end
end
