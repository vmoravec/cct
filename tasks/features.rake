namespace :features do
  task :all do
    invoke_task "feature:admin"
    invoke_task "feature:controller"
    invoke_task "feature:glance"
  end
end

desc "Run all features"
task :features => "features:all"
