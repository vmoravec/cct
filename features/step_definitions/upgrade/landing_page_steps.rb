Given(/^I click the "([^"]*)" link to trigger the upgrade process$/) do |link|
  #FIXME link is currently not implemented, see bsc#1016923
  visit('/upgrade')
end

Given(/^the upgrade process is successfuly initialized$/) do
  find(".navbar-header", text: "Upgrade 6-7")
end

When(/^I click the "([^"]*)" button to trigger preliminary checks$/) do |button_text|
  check_button = find_button(button_text)
  check_button.click
  expect(check_button.disabled?).to be(true)
  wait_for "Prechecks to finish", max: "60 seconds", sleep: "5 seconds" do
    break if !check_button.disabled?
  end
end

Then(/^all checks show successful results$/) do
  checklist = find("crowbar-checklist")
  failed_prechecks = checklist.find("ul").all("li").find_all do |item|
    !item[:class].match("text-success")
  end
  if !failed_prechecks.empty?
    raise "Prechecks failed:\n#{failed_prechecks.map {|p| p.text}.join("\n")}\n"
  end
end

Then(/^I get the "([^"]*)" button enabled$/) do |button_text|
  upgrade_button = find_button(button_text)
  expect(upgrade_button.disabled?).to be false
end


