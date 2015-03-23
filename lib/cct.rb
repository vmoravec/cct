require "forwardable"
require "etc"

require "cct/version"
require "cct/core_ext"
require "cct/local_user"
require "cct/config"
require "cct/dsl"

module Cct
  class << self
    attr_reader :root, :user, :logger, :config


    def setup root_dir, verbose=false
      @verbose = verbose
      @root = Pathname.new(root_dir.to_s)
      @user = LocalUser.new
      @logger = Logger.new(STDOUT)
      logger.level = verbose? ? Logger::DEBUG : Logger::INFO
      @config = Config.new
    end

    def verbose?
      @verbose
    end
  end
end
