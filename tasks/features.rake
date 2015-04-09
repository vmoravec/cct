namespace :features do
  task :all do
    invoke_task "feature:admin"
    invoke_task "feature:controller"
  end
end

desc "Run all features"
task :features => "features:all"
