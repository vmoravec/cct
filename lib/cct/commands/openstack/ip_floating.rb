module Cct
  module Commands
    module Openstack
      class IpFloating < Command
        self.command = "ip floating"

        def list *options
          super(
            options << columns(Struct.new(:id, :pool, :ip, :fixed_ip, :instance_id))
          )
        end

        def add address, server, options={}
          super(options.merge(args: [address, server])) do |params|
            params.add :optional, name: "--name"
            params.add :optional, description: "--description"
          end
        end

        def remove address, server
          custom(:remove, address, server)
        end

      end
    end
  end
end
