Given(/^the barclamp proposal is using rabbitmq as messaging backend$/) do
    json_response = JSON.parse(admin_node.exec!("crowbar rabbitmq show default").output)
    expect(json_response["attributes"]["rabbitmq"]).not_to be_empty
end

When(/^the node with rabbitmq-server role has been detected successfully$/) do
    @node = nodes.find(barclamp: "rabbitmq", element: "rabbitmq-server").first
    node_name = @node.attributes()[:name]
    expect(node_name).not_to be_empty
end

Then(/^I can check the status of rabbitmq-server using command line$/) do
    rabbitmq_status = @node.exec!("rabbitmqctl status").output.lines[1..-1] 
    rabbitmq_pid = 0
    rabbitmq_status.each do |line|
        line = line[0..-2]
        scan_list = line.scan(/\{([^\}]*)\}/)[0][0].split(',')
        if scan_list[0] == "pid"
            rabbitmq_pid = scan_list[1].to_i
            break
        end
    end
    expect(rabbitmq_pid).not_to equal(0)
end

And(/^I can add a new user and view the user in the users list$/) do
    @username = "rabbit"
    @password = "crowbar"
    @node.exec!("rabbitmqctl add_user #{@username} #{@password}")
    user_list = @node.exec!("rabbitmqctl list_users").output.lines[1..-1]

    new_user_created = false
    user_list.each do |user|
        new_user_info = user[0..-2].split(/\t/)
        if new_user_info[0] == @username
            new_user_created = true
            break
        end
    end
    expect(new_user_created).to equal(true)
end

And(/^I can change the user's role to an adminstrator$/) do
    @node.exec!("rabbitmqctl set_user_tags #{@username} administrator")
    user_list = @node.exec!("rabbitmqctl list_users").output.lines[1..-1]
    new_user_info = []
    user_list.each do |user|
        new_user_info = user[0..-2].split(/\t/)
        if new_user_info[0] == @username 
            break
        end
    end

    @new_user = new_user_info[0]
    new_user_role = new_user_info[1].delete("[]")

    expect(new_user_role).not_to be_empty
    expect(new_user_role).to eq("administrator")
end

And(/^I can delete the user and verify the users list$/) do
    @node.exec!("rabbitmqctl delete_user #{@username}")
    user_list = @node.exec!("rabbitmqctl list_users").output.lines[1..-1]
    new_user_exist = false
    user_list.each do |user|
        new_user_info = user[0..-2].split(/\t/)
        if new_user_info[0] == @username
            new_user_exist = true
            break
        end
    end
    expect(new_user_exist).to equal(false)
end

