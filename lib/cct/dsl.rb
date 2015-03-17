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

    def feature version_with_name
      @feature = version_with_name
    end

    def feature_task name, options={}
      rake_desc = options[:name].dup
      rake_desc << " -- #{options[:tag]}" if options[:tag]

      Cucumber::Rake::Task.new(name, rake_desc) do |task|
        task.cucumber_opts = ["--name '#{options[:name]}'"]
        task.cucumber_opts << "--tags #{options[:tag]}" if options[:tag]
        task.cucumber_opts << "--require #{Spider.root.join("features/#{options[:version]}")}"
        yield(task) if block_given?
      end
    end

    def export hash
      env = hash.map {|key, value| "#{key}=#{value}" }.join(" ")
      log.info "Setting environment variables #{env}"
      env
    end

    def before task, prerequisite=nil, *args, &block
      if prerequisite.nil?
        letters = [*'a'..'z']
        prerequisite = letters.shuffle.take(10).join
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
  end
end

self.extend(Cct::Dsl)
