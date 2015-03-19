module Cct
  module Cucumber
    class World
      attr_reader :admin_node

      def initialize
        @admin_node = AdminNode.new
      end
    end
  end
end
