module Cct
  module Commands
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
        remote = RemoteCommand.new(node.attributes)
        remote.test_ssh!
      end
    end
  end
end
