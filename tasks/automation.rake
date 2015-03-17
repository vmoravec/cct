namespace :automation do
  def automation_repo check_existence=true
    repo_path = config['vendor_dir'] + '/automation'

    if check_existence
      abort "Automation repo does not exist in #{repo_path}" unless Dir.exist?(repo_path)
    end

    repo_path
  end

  def checkout_target
    ENV['branch'] || config['automation']['git']['branch'] || 'master'
  end

  desc "Remove the old repo and clone it again"
  task :reload do
    rm_rf(automation_repo(false))
    invoke_task("automation:clone")
  end

  desc "Fetch the remote"
  task :fetch do
    puts "Fetching from url '#{config['automation']['git']['url']}'"
    chdir(automation_repo) do
      system "git fetch origin"
    end
  end

  desc "Create a clone of automation repository"
  task :clone do
    puts "Cloning from url '#{config['automation']['git']['url']}'"
    chdir(config['vendor_dir']) do
      system "git clone git@#{config['automation']['git']['url']}"
    end
  end

  desc "Update the automation code from upstream repo"
  task :pull do
    chdir(automation_repo) do
      system "git pull origin #{checkout_target}"
    end
  end

  desc "Checkout the prefered branch"
  task :checkout do
    chdir(automation_repo) do
      system "git checkout #{checkout_target}"
    end
  end

  desc "Show git log"
  task :log do
    chdir(automation_repo) do
      system "git log"
    end
  end

end

