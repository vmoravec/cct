module Cct
  class LocalCommand
    attr_reader :log

    def initialize
      @log = BaseLogger.new("LOCAL")
    end

    def exec! command_name, *args
      command = "#{command_name} #{args.join(" ")}".strip
      log.info("Running command `#{command}`")
      result = ""
      IO.popen(command, :err=>[:child, :out]) do |lines|
        lines.each do |line|
          result << line
          next unless log.debug?

          log_command_output(line)
        end
      end

      if $?.success?
        log.info("Command `#{command}` succeeded")
        log.debug("Command result:\n#{result}")
        return result
      else
        log.error("Command `#{command}` failed with exit status #{$?.exitstatus}")
      end
    rescue Errno::ENOENT => e
      message = "Command `#{command_name}` not found"
      log.error(message)
      raise LocalCommandFailed, message
    rescue => e
      log.error(e.message)
      raise LocalCommandFailed, e.message
    end

    def log_command_output line
      case line
      when /warn|cannot/i
        log.warn(line.chomp)
      when /error/i
        log.error(line.chomp)
      else
        log.debug(line.chomp)
      end
    end
  end
end
