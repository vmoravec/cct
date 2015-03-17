lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cct/version'

Gem::Specification.new do |spec|
  spec.name          = "cct"
  spec.version       = Cct::VERSION
  spec.authors       = ["Vladimir Moravec"]
  spec.email         = ["vmoravec@suse.com"]
  spec.summary       = %q{Cucumber testsuites for SUSE Openstack Cloud}
  spec.homepage      = ""
  spec.license       = "GNU GPL2"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "cucumber", "~> 2.0.0.rc.4"
  spec.add_dependency "rake", "~> 10.0"
  spec.add_dependency "bundler", "~> 1.6"
end
