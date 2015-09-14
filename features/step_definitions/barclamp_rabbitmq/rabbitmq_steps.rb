Given(/^the barclamp proposal is using rabbitmq as messaging backend$/) do
  json_response = JSON.parse(admin_node.exec!("crowbar rabbitmq show default").output)
  expect(json_response["attributes"]["rabbitmq"]).not_to be_empty
end

When(/^the node with rabbitmq-server role has been detected successfully$/) do
  @node_list = nodes.find(barclamp: "rabbitmq", element: "rabbitmq-server")
  expect(@node_list).not_to be_empty
end

Then(/^I can check the status of rabbitmq-server using command line$/) do
  rabbitmq_status = @nodes.map do |node|
    node.exec!("rabbitmqctl status", capture_error: true)
  end
  expect(rabbitmq_status).to succeed_at_least_once
end

And(/^I can add a new user and view the user in the users list$/) do
  @username = "cucumber_rabbit"
  @password = "cucumber_crowbar"
  results = @nodes.map do |node|
    user_list = node.exec!("rabbitmqctl list_users", capture_error: true)
    if user_list.success?
      if user_list.output.match(@username)
        node.exec!("rabbitmqctl delete_user #{@username}")
      end
      node.exec!("rabbitmqctl add_user #{@username} #{@password}")
    end
    user_list
  end
  expect(results).to succeed_at_least_once
end

And(/^I can change the user's role to an adminstrator$/) do
  results = @nodes.map do |node|
    user_list = node.exec!("rabbitmqctl list_users", capture_error: true)
    if user_list.success? && user_list.output.match(@username)
      result = node.exec!("rabbitmqctl set_user_tags #{@username} administrator")
      if result.success?
        list_users = node.exec!("rabbitmqctl list_users")
        expect(list_users.output.gsub("\t", " ")).to match(/#{@username}\s\[administrator\]/)
      end
      result
    end
    user_list
  end
  expect(results).to succeed_at_least_once
end

