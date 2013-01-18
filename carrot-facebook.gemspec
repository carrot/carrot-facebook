# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'carrot-facebook/version'

Gem::Specification.new do |gem|
  gem.name          = "carrot-facebook"
  gem.version       = Carrot::Facebook::VERSION
  gem.authors       = ["Tom Milewski", "Kyle MacDonald"]
  gem.email         = ["tmilewski@gmail.com", "kyle@carrotcreative.com"]
  gem.description   = %q{Facebook view helpers and signed request handling.}
  gem.summary       = %q{Facebook view helpers and signed request handling.}
  gem.homepage      = "http://carrotcreative.com/"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency "yajl-ruby"
  gem.add_development_dependency "rails"
  gem.add_development_dependency "rspec"
end
