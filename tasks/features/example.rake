namespace :feature do
  feature_name "Example of a test"

  namespace :example do
    desc "First feature task"
    feature_task :first, tags: :@first

    feature_task :all
  end

  desc "Verification of 'Example of a test' feature"
  task :example => "example:all"
end
