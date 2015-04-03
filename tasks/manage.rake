namespace :add do
  desc "Add new feature; mandatory params: name='New Feature' and task=task_name"
  task :feature do
    feature_name = ENV['name']
    task_name = ENV['task']

    new_feature = FeatureFactory.new(feature_name, task_name)

    abort "Missing feature name: name='New Feature Name'" unless feature_name
    abort "Missing task name: task=task_name" unless task_name

    puts "Creating new cucumber feature file in #{"features/#{task_name}.feature".green}"
    puts "Creating new rake task file in #{"tasks/features/#{task_name || feature_name}.rake".green}"

    new_feature.create_files

    puts "Done."
  end
end

class FeatureFactory
  TASK_TEMPLATE    = "tasks/templates/feature_task.rake.erb"
  TASK_DESTINATION = "tasks/features/"
  FEATURE_TEMPLATE = "tasks/templates/feature_file.feature.erb"
  FEATURE_DESTINATION = "features/"

  attr_reader :feature_name, :task_name

  def initialize feature, task
    @feature_name = feature
    @task_name = task
  end

  def create_files
    create_feature_task
    create_feature_file
  end

  def create_feature_task
    new_task_path = TASK_DESTINATION + task_name + ".rake"
    abort "Task already exists" if File.exist?(new_task_path)

    template = ERB.new(File.read(TASK_TEMPLATE)).result(binding)
    File.write(new_task_path, template)
  end

  def create_feature_file
    new_feature_path = FEATURE_DESTINATION + task_name + ".feature"
    abort "Feature already exists" if File.exist?(new_feature_path)

    template = ERB.new(File.read(FEATURE_TEMPLATE)).result(binding)
    File.write(new_feature_path, template)
  end
end

