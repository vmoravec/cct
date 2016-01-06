module Cct
  module Commands
    module Openstack
      class SecurityGroup < Command
        self.command = "security group"
        self.subcommand = Openstack::SecurityRule

        def list *options
          super(
            options << columns(Struct.new(:id, :name, :description))
          )
        end

        def create name, options={}
          super do |params|
            params.add :optional, description: "--description"
          end
        end

        def set name, options={}
          super do |params|
            params.add :optional, name: "--name"
            params.add :optional, description: "--description"
          end
        end

      end
    end
  end
end
