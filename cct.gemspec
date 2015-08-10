lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cct/version'

Gem::Specification.new do |spec|
  spec.name = "cct"
  spec.version = Cct::VERSION
  spec.authors = ["Vladimir Moravec"]
  spec.email = ["vmoravec@suse.com"]
  spec.summary = %q{Cucumber testsuites for SUSE Openstack Cloud}
  spec.description = %q{Use for testing your instance of SUSE Cloud}
  spec.homepage = ""
  spec.license = "GNU GPL2"

  spec.files = `git ls-files -z`.split("\x0")
  spec.executables = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files = spec.files.grep(%r{^(spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "cucumber", "~> 2.0.0.rc.5"
  spec.add_dependency "rake", "~> 10.0"
  spec.add_dependency "bundler", "~> 1.6"
  spec.add_dependency "rspec", "~> 3.2.0"
  spec.add_dependency "net-ssh", "~> 2.9.2"
  spec.add_dependency "net-ssh-gateway", "~> 1.2.0"
  spec.add_dependency "awesome_print", "~> 1.6.1"
  spec.add_dependency "faraday", "~> 0.9.1"
  spec.add_dependency "faraday-digestauth", "~> 0.2.1"
  spec.add_dependency "faraday_middleware", "~> 0.9.2"
end
