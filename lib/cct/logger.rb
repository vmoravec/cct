module Cct
  class Logger < ::Logger
    FORMATTER_COLOR = Proc.new do |severity, datetime, progname, message|
      time_format = "%Y-%m-%d-%H:%M:%S"
      colorized_message = case severity[0]
                            when 'E', 'F' then message.to_s.red
                            when 'W'      then message.to_s.yellow
                            else message.to_s.grey
                          end
      "#{severity[0]}, [#{datetime.strftime(time_format)} ##{$$}] #{severity } -- #{progname}: #{colorized_message.strip}\n"
    end

    FORMATTER_SIMPLE = Proc.new do |severity, datetime, progname, message|
      time_format = "%Y-%m-%d-%H:%M:%S"
      "#{severity[0]}, [#{datetime.strftime(time_format)} ##{$$}] #{severity } -- #{progname}: #{message.strip}\n"
    end
  end
end
