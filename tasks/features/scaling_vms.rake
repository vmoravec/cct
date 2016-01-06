namespace :feature do
  feature_name "Scaling VMs"

  namespace :scale do
    desc "Scale with cirros VMs"
    feature_task :cirros, tags: :@cirros
  end
end

