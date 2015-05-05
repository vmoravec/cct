module Cct
  module Commands
    module Openstack
      class User < Command
        self.command = "user"

        def create name, options={}
          super do |params|
            params.add :optional, password: "--password"
            params.add :optional, email:    "--email"
            params.add :optional, project:  "--project"
            params.add :optional, enable:   "--enable",  param_type: :switch
            params.add :optional, disable:  "--disable", param_type: :switch
          end
        end

      end
    end
  end
end
