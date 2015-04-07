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
    attr_reader :root, :user, :logger, :config, :hostname

    def setup root: __dir__, logger: nil, verbose: false
      @verbose = verbose
      @root = Pathname.new(root_dir.to_s)
      @config = Config.new
      @user = LocalUser.new
      @hostname = `hostname -f &2>1`.strip rescue "(uknown)"
      @logger = logger || BaseLogger.new(LOG_TAG, verbose: verbose?, path: root.join("log", LOG_FILENAME)).base
    end

    def verbose?
      @verbose
    end
  end
end
