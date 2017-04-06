Given(/^I am on the page for admin repo checks for upgrade workflow$/) do
  visit('/upgrade')
  # We need to wait a bit to get the final page with correct url
  sleep 5
  if page.current_url.match(/backup$/)
    verify_upgrade_admin_backup_page
  end
  wait_for "Show admin repos page", max: "60 seconds", sleep: "5 seconds" do
    puts "Current url: #{page.current_url}"
    break if page.current_url.match(/administration-repositories-checks$/)
  end
end

Given(/^the "([^"]*)" button is available and enabled$/) do |check_button_text|
  @check_button = find_button(check_button_text)
end

Given(/^the "([^"]*)" button is available and disabled$/) do |button_text|
  find_button(button_text, disabled: true)
end

When(/^I click the "([^"]*)" button to verify new cloud repos on admin node$/) do |text|
  @check_button.click
end

Then(/^I get successful results for all repos$/) do
  checklist = find("crowbar-checklist")
  items = checklist.find("ul").all("li")

  wait_for "Show 'Next' button", max: "60 seconds", sleep: "3 seconds" do
    next_btn_enabled = all("button", text: "Next").find {|b| !b[:disabled]}
    # The check button remains disabled after all checks have succeeded.
    # But we need to test its status dynamically together with Next button status
    # which gets enabled after all checks were successful
    break if (@check_button.disabled?  && next_btn_enabled) ||
             (!@check_button.disabled? && !next_btn_enabled)
  end

  failed_checks = items.find_all do |item|
    !item[:class].match("text-success")
  end

  if !failed_checks.empty?
    raise "Repo checks failed:\n#{failed_checks.map {|p| p.text}.join("\n")}\n"
  end
end
