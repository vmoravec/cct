Given(/^the test user does not exist$/) do
  user_name = config["features"]["users"]["user_name"]
  if control_node.openstack.user.list.map(&:name).include?(user_name)
    control_node.openstack.user.delete(user_name)
  end
end


Given(/^I create the test user$/) do
  @user_name = config["features"]["users"]["user_name"]
  @user_pass = config["features"]["users"]["user_pass"]
  @project_name = config["features"]["users"]["project_name"]

  users = control_node.openstack.user.list
  user_names = users.map(&:name)
  unless user_names.include?(@user_name)
    control_node.openstack.user.create(
      @user_name,
      :email    => "tux@suse.com",
      :password => @user_pass,
      :project  => @project_name
    )
    control_node.openstack.role.add(
      "Member",
      :project  => @project_name,
      :user     => @user_name
    )
    users = control_node.openstack.user.list
  end
  user_names = users.map(&:name)
  expect(user_names).to include(@user_name)
end


Given(/^I enable the user$/) do
  @user_name = config["features"]["users"]["user_name"]
  control_node.openstack.user.set(@user_name, :enable => true)
end


Given(/^project 'openstack' exists$/) do
  @project_name = config["features"]["users"]["project_name"]
  projects = control_node.openstack.project.list
  project_names = projects.map(&:name)
  expect(project_names).to include(@project_name)
end
