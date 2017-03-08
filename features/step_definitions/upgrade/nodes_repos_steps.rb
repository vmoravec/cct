Given(/^I am on the page for checking nodes repos$/) do
  visit('/upgrade')
  sleep 5
  if page.current_url.match(/database-configuration$/)
    find_button("Next").click
  end
  wait_for "Show nodes' repo page", max: "10 seconds", sleep: "1 seconds" do
    puts "Current url: #{page.current_url}"
    break if page.current_url.match(/nodes-repositories-checks$/)
  end
end

When(/^I click the "([^"]*)" button to verify new cloud repos on for all nodes$/) do |btn_text|
  check_button = find_button(btn_text)
  check_button.click
  expect(check_button.disabled?).to be(true)
end
