require 'erb'
require 'yaml'

module Cct
  class Config
    DIR = 'config'
    EXT = '.yml'
    DEFAULT_FILE = 'default.yml'

    attr_reader :content

    attr_reader :files

    def initialize
      @files = []
      @content = load_default_config
      autoload_config_files
    end

    def [](config_value)
      return content[config_value] if content[config_value]

      abort "Your current config does not include root element '#{config_value}'"
    end

    def merge! filename
      filename << EXT unless filename.match(/.#{EXT}$/)
      config_file = Cct.root.join(DIR, filename)
      files << config_file
      @content = content.deep_merge!(load_content(config_file))
    end

    private

    def load_content file
      ::YAML.load(ERB.new(File.read(file)).result) || {}
    rescue Errno::ENOENT
      abort "Configuration file '#{file}' not found"
    end

    def autoload_config_files
      return unless content['autoload_config_files']

      content['autoload_config_files'].each do |config_file|
        next if config_file.to_s.match(/\A#{DEFAULT_FILE}$/)
        next if !File.exist?(Cct.root.join(DIR, config_file + EXT))

        merge!(config_file)
      end
    end

    def load_default_config
      default_config = Cct.root.join(DIR, DEFAULT_FILE)
      files << default_config
      load_content(default_config.to_s)
    end
  end
end

