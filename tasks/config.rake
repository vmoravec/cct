desc "Show configuration"
task :config do
  require "awesome_print"

  ap Cct.config.content
end
