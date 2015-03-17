module Cct
  class LocalUser
    extend Forwardable

    def_delegators :@info, :uid, :gid

    attr_reader :login, :name, :homedir

    def initialize
      @login = Etc.getlogin
      @info = Etc.getpwnam(login)
      @name = @info.gecos.split(',').first
      @homedir = @info.dir
    end

    def root?
      uid.zero?
    end
  end
end
