namespace :features do
  desc "Run basic tests for cloud"
  task :base do
    invoke_task "feature:admin"
    invoke_task "feature:controller"
    invoke_task "test:func:all"
    invoke_task "feature:users"
    invoke_task "feature:images"
    invoke_task "feature:barclamps"
  end

  desc "Run barclamp tests"
  task :barclamps do
    invoke_task "feature:barclamp:database"
    invoke_task "feature:barclamp:rabbitmq"
  end
end
