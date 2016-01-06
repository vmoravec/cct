module Cct
  module Commands
    module Openstack
      class Server < Command
        self.command = "server"

        def list *options
          cols = columns(
            Struct.new(:id, :name, :status, :networks)
          )
          super(options << cols)
        end

        def create name, options={}
          super do |params|
            params.add :optional, wait:     "--wait", param_type: :switch
            params.add :optional, image:    "--image"
            params.add :optional, volume:   "--volume"
            params.add :optional, flavor:   "--flavor"
            params.add :optional, key_name: "--key-name"
            params.add :optional, min:      "--min"
            params.add :optional, max:      "--max"
            params.add :optional, property: "--property"
            params.add :optional, availability_zone: "--availability-zone"
            params.add :optional, security_group: "--security-group"
          end
        end

        def delete name, options={}
          super do |params|
            params.add :optional, wait: "--wait", param_type: :switch
          end
        end

      end
    end
  end
end
