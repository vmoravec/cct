namespace :feature do
  feature_name "Upgrade cloud via browser UI"


  namespace :ui do
    namespace :upgrade do
      desc "Landing page"
      feature_task :landing, tags: :@landing

      desc "Admin node backup"
      feature_task :"admin:backup", tags: :@admin_backup

      feature_task :all
    end

    desc "Run all upgrade steps"
    task :upgrade => "upgrade:all"
  end
end
