module Cct
  module Commands
    module Openstack
      class Network < Command
        self.command = "network"

        def list *options
          super(*(options << {row: Struct.new(:id, :name, :subnets)}))
        end
      end
    end
  end
end
