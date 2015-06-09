module Cct
  class CucumberTask
    DEFAULT_FORMAT = "pretty"

    attr_reader :name
    attr_reader :desc
    attr_reader :feature
    attr_reader :tags
    attr_reader :formats
    attr_reader :scope

    def initialize name, desc, options={}
      @name = name
      @desc = desc
      @feature = options[:feature]
      @scope = options[:scope]
      fail "Feature name not defined" unless feature

      @tags = resolve_tags(options[:tags])
      @formats = provide_formats
      @task = create_new_task
    end

    private

    def create_new_task
      Cucumber::Rake::Task.new(name, desc) do |task|
        task.cucumber_opts = ["--name '#{feature}'"]
        task.cucumber_opts << "--tags #{tags}" unless tags.empty?
        task.cucumber_opts << "--require #{Cct.root.join("features")}"
        task.cucumber_opts << "--verbose" if Cct.verbose?
        task.cucumber_opts << emit_formats
        yield(task) if block_given?
      end
    end

    def provide_formats
      config = Cct.config.fetch("cucumber")
      formats = []
      if config && config.is_a?(Hash) && config["formats"]
        formats.concat(config["formats"])
      end
      formats << DEFAULT_FORMAT if formats.empty?
      formats
    end

    def emit_formats
      result = ""
      line   = " --format %name %output "
      formats.each do |format|
        case format
        when String
          result << " --format #{format} "
        when Hash
          format.each_pair do |name, out|
            extension =
              case name
              when "pretty" then ".feature"
              when "json"   then ".json"
              end
            result << " --format #{name} #{"--out #{out}/#{scope}#{extension}"}"
          end
        else
          fail "Cucumber log format must be a string or a hash"
        end
      end
      result
    end

    def resolve_tags tags
      env_tags  = ENV['tags'].to_s
      rake_tags = case tags
                  when String, Symbol
                    tags.to_s
                  when Array
                    tags.join(",")
                  when nil
                    ""
                  else
                    fail "Tags must be an array or string"
                  end
      rake_tags + (env_tags.empty? ? "" : (rake_tags.empty? ? "#{env_tags}" : ",#{env_tags}"))
    end

  end
end
