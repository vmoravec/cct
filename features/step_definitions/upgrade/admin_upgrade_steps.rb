Given(/^I am on the page for upgrade admin server$/) do
  visit('/upgrade')
  sleep 5
  if page.current_url.match(/administration-repositories-checks$/)
    verify_upgrade_admin_repos_page
  end
  wait_for "Show upgrade admin page", max: "10 seconds", sleep: "1 seconds" do
    puts "Current url: #{page.current_url}"
    break if page.current_url.match(/upgrade-administration-server$/)
  end
end
