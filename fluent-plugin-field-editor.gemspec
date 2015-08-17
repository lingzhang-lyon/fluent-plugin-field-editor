# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |gem|
  gem.name          = "fluent-plugin-field-editor"
  gem.version       = "0.1.0"
  gem.date          = '2015-08-17'
  gem.authors       = ["Ling Zhang"]
  gem.email         = ["zhangling.ice@gmail.com"]
  gem.summary       = %q{Fluentd output plugin for edit selected field according specified criteria }
  gem.description   = %q{FLuentd output plugin for edit selected field according specified criteria}
  gem.homepage      = 'https://github.com/lingzhang-lyon/fluent-plugin-field-editor'
  gem.license       = 'MIT'

  gem.files         = `git ls-files`.split($\)
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.require_paths = ["lib"]

  gem.add_runtime_dependency 'fluentd', '~> 0.10', '>= 0.10.9'

end
