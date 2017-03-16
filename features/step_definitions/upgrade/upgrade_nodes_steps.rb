Given(/^I am on the page for upgrade of the cloud nodes$/) do
  visit('/upgrade')
  sleep 5
  if page.current_url.match(/openstack-backup$/)
    find_button("Next").click
  end
  wait_for "Show upgrade nodes page", max: "10 seconds", sleep: "1 seconds" do
    puts "Current url: #{page.current_url}"
    break if page.current_url.match(/upgrade-nodes$/)
  end
end

When(/^I click the "([^"]*)" button to upgrade the cloud nodes$/) do |button_text|
  find_button(button_text).click
  wait_for "'#{button_text}' button to get disabled", max: "30 seconds", sleep: "2 seconds" do
    button_disabled = find_all("button", text: button_text).find {|b| b[:disabled]}
    break if button_disabled
  end
end

Then(/^I wait "([^"]*)" until the nodes get upgraded$/) do |time|
  wait_for "'Finish' button to get enabled", max: time, sleep: "30 seconds" do
    finish_btn_enabled = find_all("button", text: "Finish").find {|b| !b[:disabled]}
    break if finish_btn_enabled && page.has_content?("Upgrade is completed")
  end
end

Then(/^I click the "([^"]*)" button to finish the upgrade process$/) do |button_text|
  find_button(button_text).click
end

Then(/^I can see the crowbar dashboard$/) do
  wait_for "Showing the crowbar dashboard page", max: "30 seconds", sleep: "3 seconds" do
    break if page.has_content?("Dashboard")
  end
end
