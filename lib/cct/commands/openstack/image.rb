module Cct
  module Commands
    module Openstack
      class Image < Command
        self.command = ["image"]

        def create name, options={}
          super do |params|
            # mandatory params
            params.add container_format: "--container-format"
            params.add disk_format:      "--disk-format"

            # optional params
            params.add :optional, copy_from: "--copy-from"
            params.add :optional, location: "--location"
            params.add :optional, visibility: "--visibility"

            # properties: will be transformed into --property hypervisor_type=kvm
            params.add :property, hypervisor_type: "hypervisor_type"
            params.add :property, vm_mode: "vm_mode"

            # fallback to all properties defined at once
            params.add :properties, param_type: :properties
          end
        end

      end
    end
  end
end
