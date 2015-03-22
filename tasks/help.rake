namespace :help do
  task :all do
    system "rake -T"
  end

  desc "Show admin node test commands"
  task :admin do
    system "rake -T feature:admin"
  end
end

desc "Show commands"
task :help => "help:all"
