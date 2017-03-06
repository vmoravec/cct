Given(/^I am on the page for creating postgresql database$/) do
  visit('/upgrade')
  sleep 5
  if page.current_url.match(/upgrade-administration-server$/)
    find_button("Next").click
  end
  wait_for "Show postgresql database page", max: "10 seconds", sleep: "1 seconds" do
    puts "Current url: #{page.current_url}"
    break if page.current_url.match(/database-configuration$/)
  end
end

When(/^I insert "([^"]*)" as the "([^"]*)"$/) do |value, field_name|
  fill_in(field_name, with: value)
end

Then(/^I click the "([^"]*)" button to set up the db backend$/) do |btn_text|
  find_button(btn_text).click
end

Then(/^I wait max "([^"]*)" until the database is created$/) do |time|
  wait_for "Waiting for 'Next' button to get enabled", max: time, sleep: "10 seconds" do
    break unless all("button", text: "Next").empty?
  end
end
