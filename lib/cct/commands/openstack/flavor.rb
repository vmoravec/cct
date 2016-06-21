module Cct
  module Commands
    module Openstack
      class Flavor < Command
        self.command = "flavor"

        def list *options
          super(options << columns(
            id: "ID",
            name: "Name",
            ram: "RAM",
            disk: "Disk",
            is_public: "Is Public"
          ))
        end

      end
    end
  end
end
