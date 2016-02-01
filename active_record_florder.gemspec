# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'active_record_florder/version'

Gem::Specification.new do |spec|
  spec.name          = "active_record_florder"
  spec.version       = ActiveRecordFlorder::VERSION
  spec.authors       = ["Marek Fajkus"]
  spec.email         = ["marek.faj@gmail.com"]

  spec.summary       = "Floating point ActiveRecord Models ordering for rich client apps"
  spec.description   = "Floating point ActiveRecord Models ordering for rich client apps heavily inspirated by Trello's ordering alorithm. ActiveRecordFlorder let client decide model's position in collection, normalize given value and resolve conflicts to keep your data clean. It's highly optimalized and generate as small SQL queries. The whole philosophy is to load and update as little records as possible so in 99% it runs just one SELECT and one UPDATE. In edge cases sanitization of all records happens and bring records back to the Garden of Eden state. It's implemented with both Rails and non-Rails apps in mind and highly configurable."
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
