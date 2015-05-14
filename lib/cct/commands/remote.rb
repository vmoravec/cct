module Cct
  module Commands
    module Remote
      def read_file path
        result = exec!("cat", path)
        result.output
      end

      def rpm_q package_name
        exec!("rpm", "-q #{package_name}")
      end

      def remote_file_exists url
        exec!("curl --output /dev/null --silent --head --fail #{url}")
      end

    end
  end
end
