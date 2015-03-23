module Cct
  module Dsl
    def local_user
      Cct.user
    end

    def config
      Cct.config
    end

    def log
      Cct.logger
    end

    def include_config filename
      Cct.config.merge!(filename.to_s)
    end

    def invoke_task task_name
      Rake::Task[task_name].invoke
    end

    def feature_name name=nil
      name ? @feature_name = name : @feature_name
    end

    def feature_task name, options={}
      fail "Feature name not defined" unless feature_name

      rake_desc = Rake.application.last_description
      tags = resolve_tags(options[:tags])

      Cucumber::Rake::Task.new(name, rake_desc) do |task|
        task.cucumber_opts = ["--name '#{feature_name}'"]
        task.cucumber_opts << "--tags #{tags}" unless tags.empty?
        task.cucumber_opts << "--require #{Cct.root.join("features")}"
        task.cucumber_opts << "--verbose" if Cct.verbose?
        yield(task) if block_given?
      end
    end

    def before task, prerequisite=nil, *args, &block
      if prerequisite.nil?
        letters = [*'a'..'z']
        prerequisite = "before-task:#{task}:" << letters.shuffle.take(10).join
      end

      prerequisite = Rake::Task.define_task(prerequisite, *args, &block)
      Rake::Task[task].enhance([prerequisite])
    end

    def after task, post_task=nil, *args, &block
      if post_task.nil?
        letters = [*'a'..'z']
        post_task = letters.shuffle.take(10).join
      end

      Rake::Task.define_task(post_task, *args, &block)

      post_task = Rake::Task[post_task]
      Rake::Task[task].enhance do
        post_task.invoke
      end
    end

    private

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

self.extend(Cct::Dsl)
