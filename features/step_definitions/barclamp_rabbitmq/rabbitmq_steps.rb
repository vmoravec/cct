Given(/^the barclamp proposal is using rabbitmq as messaging backend$/) do
  json_response = JSON.parse(admin_node.exec!("crowbar rabbitmq show default").output)
  expect(json_response["attributes"]["rabbitmq"]).not_to be_empty
end

And(/^the node with rabbitmq-server role has been detected successfully$/) do
  @nodes = nodes.find(barclamp: "rabbitmq", element: "rabbitmq-server")
  expect(@nodes).not_to be_empty
end

Then(/^I can check the status of rabbitmq-server using command line$/) do
  status_results = @nodes.map do |node|
    node.exec!("rabbitmqctl status", capture_error: true)
  end
  expect(status_results).to succeed_at_least_once
end

When(/^I add a new user and view the user in the users list$/) do
  @username = "cucumber_rabbit"
  @password = "cucumber_crowbar"
  results = @nodes.map do |node|
    list_users = node.exec!("rabbitmqctl list_users", capture_error: true)
    if list_users.success? && list_users.output.match(@username)
      node.exec!("rabbitmqctl delete_user #{@username}")
      node.exec!("rabbitmqctl add_user #{@username} #{@password}")
    end
    list_users
  end
  expect(results).to succeed_at_least_once
end

And(/^I change the user's role to an administrator$/) do
  results = @nodes.map do |node|
    result = node.exec!(
      "rabbitmqctl set_user_tags #{@username} administrator", capture_error: true
    )
    if result.success?
      user_list = node.exec!("rabbitmqctl list_users")
      expect(user_list.output.gsub("\t", " ")).to match(/#{@username}\s\[administrator\]/)
    end
    result
  end
  expect(results).to succeed_at_least_once
end
