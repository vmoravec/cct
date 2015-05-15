module Cct
  module Commands
    module Openstack
      class Role < Command
        self.command = "role"

        def add name, options={}
          super do |params|
            params.add :optional, domain:  "--domain"
            params.add :optional, project: "--project"
            params.add :optional, user:    "--user"
            params.add :optional, group:   "--group"
          end
        end

      end
    end
  end
end
