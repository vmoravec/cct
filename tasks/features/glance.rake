namespace :feature do
  feature_name "Glance"

  namespace :glance do
    desc "Create KVM image"
    feature_task :create_kvm_image, tags: :@create_kvm_image

    desc "Create XEN HVM image"
    feature_task :create_xen_hvm_image, tags: :@create_xen_hvm_image

    desc "Create XEN PV image"
    feature_task :create_xen_pv_image, tags: :@create_xen_pv_image

    feature_task :all
 end

  desc "Complete verification of 'Glance' feature"
  task :glance => "glance:all"
end
