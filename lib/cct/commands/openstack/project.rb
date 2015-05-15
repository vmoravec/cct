module Cct
  module Commands
    module Openstack
      class Project < Command
        self.command = "project"

        def create name, options={}
          super do |params|
            params.add :optional, domain:      "--domain"
            params.add :optional, description: "--description"
            params.add :optional, enable:      "--enable",  param_type: :switch
            params.add :optional, disable:     "--disable", param_type: :switch
            params.add :optional, property:    "--property"
          end
        end

      end
    end
  end
end
