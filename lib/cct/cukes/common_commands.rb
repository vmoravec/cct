module Cct
  module CommonCommands
    module Local
      # Ping with 5 seconds timeout and a single attempt
      def ping! node
        command = ["ping", "-q -c 1 -W 5 #{node.ip}"]
        result = exec!(*command)
        if result.exit_code.nonzero?
          raise PingError.new(command, result.output)
        end
        result
      end

      def ssh_handshake! node
        remote = RemoteCommand.new(node.extract_attributes)
        remote.test_ssh!
      end
    end

    module Remote
      def read_file path
        exec!("cat", path)
      end

      def rpm? package_name
        exec!("rpm", "-q #{package_name}")
      end
    end
  end
end
