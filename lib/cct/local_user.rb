module Cct
  class LocalUser
    extend Forwardable

    def_delegators :@info, :uid, :gid

    attr_reader :login, :name, :homedir

    def initialize
      @login = Etc.getlogin
      @info = Etc.getpwnam(login)
      @name = detect_name
      @homedir = @info.dir
    end

    def root?
      uid.zero?
    end

    private

    def detect_name
      name = @info.gecos.split(',').first
      name.to_s.empty? ? login : name
    end
  end
end
