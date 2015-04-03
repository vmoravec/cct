module Cct
  class LocalCommand
    Result = Struct.new(:success?, :output, :exit_code, :host)

    attr_reader :log

    def initialize
      @log = BaseLogger.new("LOCAL")
    end

    def exec! command_name, *args
      command = "#{command_name} #{args.join(" ")}".strip
      log.info("Running command `#{command}`")
      result = Result.new(false, "", 1000, Cct.hostname)

      IO.popen(command, :err=>[:child, :out]) do |lines|
        lines.each do |line|
          result.output << line
          next unless log.debug?

          log_command_output(line)
        end
      end

      result[:success?] = $?.success?
      result.exit_code = $?.exitstatus
      if !result.success?
        log.error(
          "#{result.host}: Command `#{command}` " +
          "failed with '#{result.output.strip}' " +
          "and status #{result.exit_code} "
        )
        raise LocalCommandFailed.new(result)
      end

      return result

    rescue Errno::ENOENT => e
      result.output << "Command `#{command_name}` not found"
      log.error("#{result.host}: #{result.output}")
      raise LocalCommandFailed.new(result)
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
