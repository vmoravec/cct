namespace :feature do
  feature_name "OpenStack Image management"

  namespace :images do
    desc "Create and delete KVM image"
    feature_task :kvm, tags: :@kvm

    desc "Create and delete XEN HVM image"
    feature_task :xen_hvm, tags: :@xen_hvm

    desc "Create and delete XEN PV image"
    feature_task :xen_pv, tags: :@xen_pv

    feature_task :all
 end

  desc "Complete verification of 'OpenStack Image management' feature"
  task :images => "images:all"
end
