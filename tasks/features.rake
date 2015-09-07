namespace :features do
  desc "Run basic tests for cloud"
  task :base do
    invoke_task "feature:admin"
    invoke_task "feature:controller"
    invoke_task "feature:users"
    invoke_task "feature:images"
    invoke_task "test:all_clients"
  end
end
