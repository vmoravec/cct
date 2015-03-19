namespace :test do
  feature_name "Admin node"

  namespace :admin do

    desc "Smoke test for admin node"
    feature_task :smoke, tags: :@smoke

    desc "NTP Server availability"
    feature_task :ntp, tags: :@ntp

    desc "Support for the operating system"
    feature_task :system, tags: :@system

    desc "Admin node HTTP API"
    feature_task :api, tags: :@api

    desc "Admin node UI"
    feature_task :ui, tags: :@ui

    feature_task :all
  end

  desc "Top-down verification of admin node"
  task :admin => "admin:all"
end
