require 'erb'
require 'yaml'

module Cct
  class Config
    DIR = 'config'
    EXT = '.yml'
    DEFAULT_FILE = 'default.yml'
    DEVELOPMENT_FILE = 'development.yml'
    FEATURES_DIR = "features"

    attr_reader :content

    attr_reader :files

    attr_reader :dir

    def initialize
      @dir = Cct.root.join(DIR)
      @files = []
      @content = load_default_config
      load_features_config
      load_devel_config
      load_env_config
    end

    def [](config_value)
      return content[config_value] if content[config_value]

      raise "Your current config does not include root element '#{config_value}'"
    end

    def fetch value, default
      content[value] || default
    end

    def merge! filename
      filename << EXT unless filename.to_s.match(/.#{EXT}$/)
      config_file = filename.is_a?(String) ? dir.join(filename) : filename.expand_path.to_s
      files << config_file
      @content = content.deep_merge!(load_content(config_file))
    end

    private

    def load_env_config
      env_config = ENV["cct_config"]
      return if env_config.to_s.empty?

      env_config = YAML.load(env_config)
      content.deep_merge!(env_config)
    end

    def load_features_config
      config_dir = dir.join(FEATURES_DIR)
      return unless Dir.exist?(config_dir)
      return if config_dir.children.empty?

      config_dir.children.each do |file|
        merge!(file)
      end
    end

    def load_devel_config
      devel_config = dir.join(DEVELOPMENT_FILE)
      return unless File.exist?(devel_config)

      merge!(devel_config)
      autoload_config_files
    end

    def load_content file
      ::YAML.load(ERB.new(File.read(file)).result) || {}
    rescue Errno::ENOENT
      abort "Configuration file '#{file}' not found"
    end

    def autoload_config_files
      return unless content['autoload_config_files']

      content['autoload_config_files'].each do |config_file|
        config_file << EXT unless config_file.to_s.match(/.#{EXT}$/)
        next if config_file.to_s.match(/\A#{DEFAULT_FILE}$/)

        if !File.exist?(dir.join(config_file))
          abort "Configuration file #{config_file} does not exist".red
        end

        merge!(config_file)
      end
    end

    def load_default_config
      default_config = dir.join(DEFAULT_FILE)
      files << default_config
      load_content(default_config.to_s)
    end
  end
end

