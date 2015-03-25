require "forwardable"
require "etc"
require "logger"
require "pathname"

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
      @config = Config.new
      @user = LocalUser.new
      @logger = Logger.new(STDOUT)
      logger.level = verbose? ? Logger::DEBUG : Logger::INFO
      logger.progname = "cct"
    end

    def verbose?
      @verbose
    end
  end
end
