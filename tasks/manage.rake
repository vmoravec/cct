namespace :add do
  desc "Add new feature: creates new cucumber feature file and new rake task"
  task :feature do
    feature_name = ENV['name']
    task_name = ENV['task']
    abort "Missing feature name: name=NEWFEATURE" unless feature_name
    abort "Missing task name: task=NEWTASK" unless task_name

    puts "Creating new cucumber feature file in #{"features/#{task_name}.feature".green}"
    puts "Creating new rake task file in tasks/features/#{task_name || feature_name}.rake"

  end
end

