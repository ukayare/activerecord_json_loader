# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'activerecord_json_loader/version'

Gem::Specification.new do |spec|
  spec.name          = "activerecord_json_loader"
  spec.version       = ActiverecordJsonLoader::VERSION
  spec.authors       = ["ukayare"]
  spec.email         = ["ukayare@gmail.com"]

  spec.summary       = %q{Json data load to ActiveRecord schema mapping object extension}
  spec.description   = %q{ActiverecordJsonLoader is enable to load json file for ActiveRecord's model. For example, when you must use and import master data(ex. game character, enemy, and item stc), it will help you. }
  spec.homepage      = "https://github.com/ukayare/activerecord_json_loader"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
end
