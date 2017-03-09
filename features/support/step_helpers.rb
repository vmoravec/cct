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

  def verify_upgrade_admin_backup_page
    step 'button for "Download Backup of Administration Server" is available and enabled'
    step 'the "Next" button is disabled'
    step 'I click the backup button'
    step 'I get the backup archive created'
    step 'the "Next" button gets enabled'
    step 'I click the "Next" button to move to next upgrade action'
  end

  def verify_upgrade_admin_repos_page
    step 'I am on the page for admin repo checks for upgrade workflow'
    step 'the "Check" button is available and enabled'
    step 'the "Next" button is available and disabled'
    step 'I click the "Check" button to verify new cloud repos on admin node'
    step 'I get successful results for all repos'
    step 'I click the "Next" button to move to next upgrade action'
  end

  def verify_nodes_repo_check_page
    step 'I am on the page for checking nodes repos'
    step 'the "Check" button is available and enabled'
    step 'the "Next" button is available and disabled'
    step 'I click the "Check" button to verify new cloud repos on for all nodes'
    step 'I get successful results for all repos'
    step 'I click the "Next" button to move to next upgrade action'
  end
end
