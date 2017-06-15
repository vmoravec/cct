namespace :feature do
  feature_name "Monasca - cloud monitoring"

  namespace :monasca do
    desc "First feature task"
    feature_task :first, tags: :@first

    feature_task :all
  end

  desc "Verification of 'Monasca - cloud monitoring' feature"
  task :monasca => "monasca:all"
end
