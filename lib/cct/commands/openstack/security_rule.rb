module Cct
  module Commands
    module Openstack
      class SecurityRule < Command
        self.command = "rule"

        def list group_name, *options
          super(
            options << {args: group_name}.merge(
              columns(Struct.new(:id, :protocol, :ip_range, :port_range))
            )
          )
        end

        def create group_name, options={}
          super do |params|
            params.add :optional, src_ip:   "--src-ip"
            params.add :optional, dst_port: "--dst-port"
            params.add :optional, proto:    "--proto"
          end
        end

      end
    end
  end
end
