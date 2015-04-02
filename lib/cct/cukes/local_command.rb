module Cct
  class LocalCommand
    Result = Struct.new(:success?, :output, :exit_code)

    attr_reader :log

    def initialize
      @log = BaseLogger.new("LOCAL")
    end

    def exec! command_name, *args
      command = "#{command_name} #{args.join(" ")}".strip
      log.info("Running command `#{command}`")
      result = Result.new(false, "", 1000)

      IO.popen(command, :err=>[:child, :out]) do |lines|
        lines.each do |line|
          result.output << line
          next unless log.debug?

          log_command_output(line)
        end
      end

      log.debug("Command output:\n#{result.output}")
      result[:success?] = $?.success?
      result.exit_code = $?.exitstatus
      log.error("Command `#{command}` failed with exit status #{result.exit_code}")
      return result

    rescue Errno::ENOENT => e
      message = "Command `#{command_name}` not found"
      log.error(message)
      raise LocalCommandFailed, message
    rescue => e
      log.error(e.message)
      raise LocalCommandFailed, e.message
    end

    def log_command_output line
      case line.chomp
      when /warn|cannot/i
        log.warn(line)
      when /error/i
        log.error(line)
      else
        log.debug(line)
      end
    end
  end
end
