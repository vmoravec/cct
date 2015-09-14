namespace :test do
  namespace :func do
    feature_name "Openstack Clients Functional Tests"

    desc "Nova client functional tests"
    feature_task :novaclient, tags: :@novaclient

    desc "Functional tests for all client libraries"
    feature_task :all
  end
end

