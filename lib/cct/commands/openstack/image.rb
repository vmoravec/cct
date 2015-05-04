module Cct
  module Commands
    module Openstack
      class Image
        include NodeContext

        self.command = "image"

        def list
          image_row = Struct.new(:id, :name)
          result = exec!("list", "--format csv").output
          csv_parse(result).map do |row|
            image_row.new(*row)
          end
        end

        def show id_or_name
          result = exec!("show", id_or_name, "--format shell").output
          OpenStruct.new(shell_parse(result))
        end

        def create name, options
          OpenStruct.new(
            shell_parse(
              exec!(
                "create",
                name,
                "--format=shell",
                "#{options[:properties]}",
                "--container-format=#{options[:container_format]}",
                "--disk-format=#{options[:disk_format]}",
                "--copy-from=#{options[:copy_from]}",
                "#{'--public' if options[:public]}",
                "#{'--private' if options[:private]}"
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
