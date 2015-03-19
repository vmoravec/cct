namespace :test do
  feature_name "Admin node"

  namespace :admin do
    desc "Test NTP Server availability"
    feature_task :ntp, tags: :@ntp

    desc "Check system support"
    feature_task :system, tags: :@system

    desc "Detect required services"
    feature_task :services, tags: :@services

    desc "Admin node HTTP API"
    feature_task :api, tags: :@api

    desc "Admin node UI"
    feature_task :ui, tags: :@ui

    feature_task :all
  end

  desc "Top-down verification of admin node"
  task :admin => "admin:all"
end
