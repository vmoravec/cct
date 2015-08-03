When(/^I disable the user$/) do
  @user_name = config["features"]["users"]["user_name"]
  control_node.openstack.user.set(@user_name, :disable => true)
end


When(/^I delete this user$/) do
  @user_name = config["features"]["users"]["user_name"]
  control_node.openstack.user.delete(@user_name)
end


Then(/^Nova does not accept this user$/) do
  expect { step "Nova accepts this user" }.to raise_error
end


Then(/^Nova accepts this user$/) do
  @user_name = config["features"]["users"]["user_name"]
  @user_pass = config["features"]["users"]["user_pass"]
  control_node.openstack.network.list("--os-username=#{@user_name}", "--os-password=#{@user_pass}")
end
