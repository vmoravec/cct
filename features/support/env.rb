require "cct"
require "cct/cucumber/world"

Cct.setup(Dir.pwd)

World do
  Cct::Cucumber::World.new
end
