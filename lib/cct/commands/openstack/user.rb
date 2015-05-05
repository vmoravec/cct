module Cct
  module Commands
    module Openstack
      class User
        include NodeContext

        self.command = "user"

        def list
          user_row = Struct.new(:id, :name)
          result = exec!("list", "--format csv").output
          csv_parse(result).map do |row|
            user_row.new(*row)
          end
        end

        def show id_or_name
          result = exec!("show", id_or_name, "--format shell").output
          OpenStruct.new(shell_parse(result))
        end

        def create name, options={}
          OpenStruct.new(
            shell_parse(
              exec!(
                "create",
                name,
                "--format=shell",
                optional("--password", :password, options),
                optional("--email",    :email,    options),
                optional("--project",  :project,  options),
                optional("--enable",   :enable,   options, type: :switch),
                optional("--disable",  :disable,  options, type: :switch),
              ).output
            )
          )
        end

        def delete id_or_name
          exec!("delete", id_or_name)
        end
      end
    end
  end
end
