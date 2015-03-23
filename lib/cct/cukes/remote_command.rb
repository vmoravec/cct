module Cct
  class RemoteCommand

    DEFAULT_OPTIONS = {
      logger: Cct.logger,
      number_of_password_prompts: 0
    }

    attr_reader :session

    def initialize options={}
      ssh_options = construct_ssh_options(options)
      @session = Net::SSH.start(*ssh_options)
    end

    def exec! command, params
      session.exec!("#{command} #{params.join(" ")}")
    end

    private

    def construct_ssh_options opts
      options = []
      options << ( opts['ip']   || opts['hostname'] )
      options << ( opts['user'] || opts['login'] )
      options << DEFAULT_OPTIONS
      options.last.merge!(password: opts['password']) if opts['password']
      options
    end
  end
end
