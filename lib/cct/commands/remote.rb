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

      # Ping with 5 seconds timeout and 5 attempts
      def ping! node
        node.load!  # Force loading the node to get the IP
        command = "ping -q -c 5 -w 5 #{node.ip}"
        result = exec!(command)
        if result.exit_code.nonzero?
          raise PingError.new(command, result.output)
        end
        result
      end
    end
  end
end
