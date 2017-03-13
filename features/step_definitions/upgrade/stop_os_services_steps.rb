Given(/^I am on the page for stopping the Openstack services$/) do
  visit('/upgrade')
  sleep 5
  if page.current_url.match(/nodes-repositories-checks$/)
    verify_nodes_repo_check_page
  end
  wait_for "Show openstack services page", max: "10 seconds", sleep: "1 seconds" do
    puts "Current url: #{page.current_url}"
    break if page.current_url.match(/openstack-services$/)
  end
end

When(/^I click the "([^"]*)" button to perform the action on the backend$/) do |button_text|
  find_button(button_text).click
  wait_for "'#{button_text}' button to get disabled", max: "30 seconds", sleep: "2 seconds" do
    button_disabled = find_all("button", text: button_text).find {|b| b[:disabled]}
    break if button_disabled
  end
end

Then(/^I wait max "([^"]*)" until the openstack services are stopped$/) do |time|
  wait_for "'Next' button to get enabled", max: time, sleep: "10 seconds" do
    next_btn_enabled = find_all("button", text: "Next").find {|b| !b[:disabled]}
    break if next_btn_enabled
  end
end
