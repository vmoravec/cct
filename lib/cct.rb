require "forwardable"
require "etc"
require "logger"
require "pathname"

require "cct/version"
require "cct/base_logger"
require "cct/core_ext"
require "cct/local_user"
require "cct/config"
require "cct/dsl"

module Cct
  LOG_TAG = "CCT"
  LOG_FILENAME = "cct.log"

  class << self
    attr_reader :root, :user, :logger, :config

    def setup root_dir, verbose=false
      @verbose = verbose
      @root = Pathname.new(root_dir.to_s)
      @config = Config.new
      @user = LocalUser.new
      @logger = BaseLogger.new(LOG_TAG, verbose?, root.join("log", LOG_FILENAME)).base
    end

    def verbose?
      @verbose
    end
  end
end
