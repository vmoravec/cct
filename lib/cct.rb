require "forwardable"
require "etc"
require 'logger'

require "cct/core_ext"
require "cct/local_user"
require "cct/command"
require "cct/version"
require "cct/logger"
require "cct/config"
require "cct/dsl"
require "cct/admin_node"

module Cct
  class << self
    attr_reader :root, :user, :logger, :config


    def setup root_dir
      @root = Pathname.new(root_dir.to_s)
      @user = LocalUser.new
      @logger = Logger.new(STDOUT)
      @config = Config.new
    end
  end
end
