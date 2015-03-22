require "cct"
require "cct/cukes/world"

Cct.setup(Dir.pwd)

World do
  Cct::Cukes::World.new
end
