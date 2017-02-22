module StepHelpers
  def validate_admin!
    step "the admin node responds to a ping"
    step "I can establish SSH connection"
    step "I can reach the crowbar API"
  end

  def verify_upgrade_landing_page
    step 'I click the "Upgrade" link to trigger the upgrade process'
    step 'the upgrade process is successfuly initialized'
    step 'I click the "Check" button to trigger preliminary checks'
    step 'all checks show successful results'
    step 'I get the "Begin Upgrade" button enabled'
  end
end
