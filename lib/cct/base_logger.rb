module Cct
  class BaseLogger
    extend Forwardable

    def_delegators :@base, :level, :level=, :progname, :progname=, :debug?, :info?,
                           :error?, :fatal?

    attr_reader :name, :base

    def initialize name, verbose=false, path=nil
      @name = name
      if path
        @base = Logger.new(path, File::WRONLY | File::APPEND | File::CREAT)
        base.progname = name
        base.formatter = LogFormatters::SIMPLE
      else
        @base = Cct.logger
      end
      base.level = Cct.verbose? ? Logger::DEBUG : Logger::INFO
    end

    def info message
      original_logger(:info, message)
    end

    def warn message
      original_logger(:warn, message)
    end

    def error message
      original_logger(:error, message)
    end

    def fatal message
      original_logger(:fatal, message)
    end

    def debug message
      original_logger(:debug, message)
    end

    def add severity, message=nil, progname=nil, &block
      progname = "#{name}: " << progname.to_s
      base.add(severity, message, progname, &block)
    end

    private

    def original_logger severity, message, &block
      base.send(severity, name) { message }
    end
  end

  module LogFormatters
    COLOR = Proc.new do |severity, datetime, progname, message|
      time_format = "%Y-%m-%d-%H:%M:%S"
      colorized_message = case severity[0]
                            when 'E', 'F' then message.to_s.red
                            when 'W'      then message.to_s.yellow
                            else message.to_s.grey
                          end
      "#{severity[0]}, [#{datetime.strftime(time_format)} ##{$$}] #{severity } -- #{progname}: #{colorized_message.strip}\n"
    end

    SIMPLE = Proc.new do |severity, datetime, progname, message|
      time_format = "%Y-%m-%d-%H:%M:%S"
      "#{severity[0]}, [#{datetime.strftime(time_format)} ##{$$}] #{severity } -- #{progname}: #{message.strip}\n"
    end
  end
end
