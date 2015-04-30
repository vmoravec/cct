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
      end
    end
  end
end
