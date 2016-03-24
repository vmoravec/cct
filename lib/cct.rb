require "forwardable"
require "etc"
require "pathname"
require "net/ssh"
require "net/ssh/gateway"
require "ostruct"
require "timeout"
require "faraday"
require "faraday/digestauth"
require "faraday_middleware"

require "cct/version"
require "cct/errors"
require "cct/base_logger"
require "cct/core_ext"
require "cct/local_user"
require "cct/config"
require "cct/rake/dsl"
require "cct/cucumber_task"
require "cct/commands/local"
require "cct/commands/remote"
require "cct/local_command"
require "cct/remote_command"

module Cct
  LOG_TAG = "CCT"
  LOG_FILENAME = "cct.log"
  LOG_DIR = "log"

  class << self
    attr_reader :root, :user, :logger, :config, :hostname, :log_path

    def setup root_dir, logger: nil, verbose: false, log_path: nil
      @verbose = verbose == true
      @root = Pathname.new(root_dir)
      @config = Config.new
      @user = LocalUser.new
      @hostname = `hostname -f 2>&1`.strip rescue "(uknown)"
      @log_path = log_path || root.join(LOG_DIR, LOG_FILENAME)
      @logger = logger || BaseLogger.new(
        LOG_TAG, verbose: verbose?, path: @log_path
      ).base
      self
    end

    alias_method :log, :logger

    def verbose?
      @verbose
    end

    def update_logger base_logger
      @logger = base_logger.base
    end

    def load_tasks!
      require "cucumber"
      require "cucumber/rake/task"
      Dir.glob(root.to_s + '/tasks/**/*.rake').each { |task| load(task) }
    end

    def running_on_admin_node?
      File.exist?("/etc/crowbar.install.key")
    end
  end
end
