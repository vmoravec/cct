module Cct
  class CommandProxy
    attr_reader :command

    def initialize type, options={}
      @command =
        case type
        when :local
          LocalCommand.new
        when :remote
          RemoteCommand.new(options)
        end
    end

    def exec! command_name, *options
      command.exec!(command_name, *options)
    end
  end
end
