module StepHelpers
  def validate_admin!
    step "the admin node responds to a ping"
    step "I can establish SSH connection"
    step "I can reach the crowbar API"
  end
end
