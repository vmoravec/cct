namespace :git do
  desc "Ignore some file with `git update-index`; mandatory parameter file=FILE"
  task :ignore do
    file = ENV["file"]
    abort "Missing file" unless file

    system "git update-index --assume-unchanged #{file}"
  end

  desc "Revert ignored file; mandatory parameter file=FILE"
  task :unignore do
    file = ENV["file"]
    abort "Missing file" unless file

    system "git update-index --no-assume-unchanged #{file}"
  end
end
