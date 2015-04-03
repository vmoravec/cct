module Cct
  module Commands
    module Remote
      def read_file path
        result = exec!("cat", path)
        result.output
      end

      def rpm_installed? package_name
        exec!("rpm", "-q #{package_name}").success?
      end
    end
  end
end
