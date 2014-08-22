# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ti82/version'

Gem::Specification.new do |spec|
  spec.name          = "ti82"
  spec.version       = Ti82::VERSION
  spec.authors       = ["Jess Brown"]
  spec.email         = ["jess@brownwebdesign.com"]
  spec.description   = %q{This gem will help you perform financial calculator type functions (pv, fv, pmt, int, etc)}
  spec.summary       = %q{This gem will help you perform financial calculator type functions (pv, fv, pmt, int, etc)}
  spec.homepage      = "http://www.github.com/jess/ti82"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rake"
  spec.add_dependency "finance"
end
