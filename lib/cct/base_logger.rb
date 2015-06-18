require 'logger'

module Cct
  class BaseLogger
    def self.main
      Cct
    end

    extend Forwardable

    def_delegators :@base, :level, :level=, :progname, :progname=, :debug?, :info?,
                           :error?, :fatal?, :warn?

    attr_reader :name, :base, :path

    def initialize name, verbose: false, path: nil, stdout: false, level: Logger::INFO
      @name = name
      if path
        @path = path
        @base = Logger.new(path, File::WRONLY | File::APPEND | File::CREAT)
        base.progname = name
        base.formatter = LogFormatters::SIMPLE
      elsif stdout
        @base = Logger.new(STDOUT)
        base.progname = name
        base.formatter = LogFormatters::SIMPLE
      else
        @base = self.class.main.logger
      end
      base.level = verbose ? Logger::DEBUG : level
    end

    def info message
      original_logger(Logger::INFO, message)
    end

    def warn message
      original_logger(Logger::WARN, message)
    end

    def error message
      original_logger(Logger::ERROR, message)
    end

    def fatal message
      original_logger(Logger::FATAL, message)
    end

    def debug message
      original_logger(Logger::DEBUG, message)
    end

    def always message
      original_level = base.level
      base.level = Logger::INFO
      info(message)
      base.level = original_level
    end

    def add severity, message=nil, progname=nil, &block
      progname = "#{name}: " << progname.to_s
      base.add(severity, message, progname, &block)
    end

    private

    def original_logger severity, message
      base.add(severity, nil, name) { message }
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
