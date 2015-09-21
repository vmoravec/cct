namespace :features do
  desc "Run basic tests for cloud"
  task :base do
    invoke_task "feature:admin"
    invoke_task "feature:controller"
    invoke_task "features:barclamps"
    invoke_task "test:func:all"
    invoke_task "feature:users"
    invoke_task "feature:images"
  end

  desc "Run barclamp tests"
  task :barclamps do
    invoke_task "feature:barclamp:database"
  end
end
