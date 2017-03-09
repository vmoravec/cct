Given(/^I am on the page for Openstack database backup$/) do
  visit('/upgrade')
  sleep 5
  if page.current_url.match(/openstack-services$/)
    find_button("Next").click
  end
  wait_for "Showing openstack db backup page", max: "10 seconds", sleep: "1 seconds" do
    puts "Current url: #{page.current_url}"
    break if page.current_url.match(/openstack-backup$/)
  end
end

When(/^I click the "([^"]*)" button to perform the backup action$/) do |button_text|
  find_button(button_text).click
  wait_for "'#{button_text}' button to get disabled", max: "30 seconds", sleep: "2 seconds" do
    button_disabled = find_all("button", text: button_text).find {|b| b[:disabled]}
    break if button_disabled
  end
end

Then(/^I get the openstack database backup archive created$/) do
  wait_for "Showing openstack dump archive path", max: "30 seconds", sleep: "5 seconds" do
    break if page.has_content?( "Backup can be found under")
  end
  expect(page.has_content?("/var/lib/crowbar/backup/6-to-7-openstack_dump.sql.gz")).to be(true)
  admin_node.exec!("test -e /var/lib/crowbar/backup/6-to-7-openstack_dump.sql.gz")
end
