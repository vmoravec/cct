Given(/^I click the "([^"]*)" button on the landing page$/) do |button_text|
  visit('/upgrade')
  # We need to wait a bit to get the final page with correct url
  sleep 10
  if page.current_url.match(/landing$/)
    verify_upgrade_landing_page
    upgrade_button = find_button(button_text)
    upgrade_button.click
  end

  wait_for "Starting upgrade workflow", max: "80 seconds", sleep: "10 seconds" do
    puts "Current url: #{page.current_url}"
    break if page.current_url.match(/backup$/)
  end
end

Given(/^button for "([^"]*)" is available and enabled$/) do |button_text|
  @backup_button = find_button(button_text)
  expect(@backup_button.disabled?).to be(false)
end

Given(/^the "([^"]*)" button is disabled$/) do |button_text|
  button = find_button(button_text, disabled: true)
end

When(/^I click the backup button$/) do
  @backup_button.click
  wait_for "Waiting for 'Next' button to get enabled", max: "60 seconds", sleep: "3 second" do
    next_btn_enabled = find_all("button", text: "Next").find {|b| !b[:disabled]}
    break if next_btn_enabled
  end
end

Then(/^I get the backup archive created$/) do
  # Due to being not able to really test the download of the tar.gz archive
  # let's check for the label existence right below the button
  expect(page.has_content?(
      "Backup can be found under \"/var/lib/crowbar/backup/upgrade-backup"
  )).to be(true)
end

Then(/^the "([^"]*)" button gets enabled$/) do |button_text|
  button = find_button(button_text, disabled: false)
end

Then(/^I click the "([^"]*)" button to move to next upgrade action$/) do |button_text|
  find_button(button_text).click
end
