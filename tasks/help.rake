namespace :help do
  task :all do
    system "rake -T"
  end
end

desc "Show commands"
task :help => "help:all"
task :h    => "help:all"
