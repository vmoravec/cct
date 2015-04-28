namespace :feature do
  feature_name "OpenStack Identity"

  namespace :users do
    desc "Enabled user is allowed to operate"
    feature_task :enable_user, tags: :@enable_user

    desc "Disabled user is denied to operate"
    feature_task :disable_user, tags: :@disable_user

    desc "Reenabled user is allowed to operate"
    feature_task :reenable_user, tags: :@reenable_user

    desc "Deleted user is denied to operate"
    feature_task :delete_user, tags: :@delete_user

    feature_task :all
  end

  desc "Complete verification of 'OpenStack Identity' feature"
  task :users => "users:all"
end
