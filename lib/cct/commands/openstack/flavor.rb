module Cct
  module Commands
    module Openstack
      class Flavor < Command
        self.command = "flavor"

        def list *options
          super(options << columns(
            Struct.new(:id, :name, :ram, :disk, :ephemeral, :vcpus, :is_public)
          ))
        end

      end
    end
  end
end
