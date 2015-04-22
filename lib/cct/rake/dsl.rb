module Rake
  module DSL
    def cct
      Cct
    end

    def invoke_task task_name
      Rake::Task[task_name].invoke
    end

    def feature_namespace name=nil, &block
      if name
        @feature_namespace = name
        namespace name, &block
      else
        @feature_namespace
      end
    end

    def feature_name name=nil
      name ? @feature_name = name : @feature_name
    end

    def feature_task name, options={}
      rake_desc = Rake.application.last_description
      Cct::CucumberTask.new(name, rake_desc, options.merge(feature: feature_name))
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
  end
end
