module Cct
  module Commands
    module Openstack
      class Keypair < Command
        self.command = "keypair"

        def list *options
          super(
            options << columns(Struct.new(:name, :fingerprint))
          )
        end

        def public_key key_name
          exec!("show", key_name, "--public-key").output
        end

        def create name, options={}
          super(name, options.merge(dont_format_output: true)) do |params|
            params.add :optional, public_key: "--public-key"
          end
        end
      end
    end
  end
end
