namespace :feature do
  feature_name "Admin node"

  namespace :admin do
    desc "Test NTP Server availability"
    feature_task :ntp, tags: :@ntp

    desc "Check operating system support"
    feature_task :os, tags: :@os

    desc "Detect required services"
    feature_task :services, tags: :@services

    desc "Test crowbar API"
    feature_task :api, tags: :@api

    desc "Smoke tests for admin feature"
    feature_task :smoke, tags: :@smoke

    feature_task :all
  end

  desc "Top-down verification of admin node"
  task :admin => "admin:all"
end

