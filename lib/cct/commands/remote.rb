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
    end
  end
end
