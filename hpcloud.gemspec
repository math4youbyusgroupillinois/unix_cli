# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'hpcloud/version'

Gem::Specification.new do |s|

  s.name      = 'hpcloud'
  s.version   = HP::Cloud::VERSION
  s.date      = '2014-06-23'

  s.summary       = 'HP Cloud CLI'
  s.description   = 'Useful command-line tools for managing your HP Cloud services'

  s.authors   = ["Matt Sanders", "Rupak Ganguly", "Terry Howe"]
  s.email     = %w{rupak.ganguly@hp.com}
  s.homepage  = 'https://docs.hpcloud.com/cli/unix'
  # s.licenses = [""]

  s.executables         = ["hpcloud"]
  s.required_ruby_version = '>= 1.8.5'
  s.required_rubygems_version = '>= 1.2.0'

  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.5.0}

  s.files = Dir.glob("{bin,lib,completion}/**/**/*") + %w(LICENSE README.rdoc CHANGELOG)
  s.extra_rdoc_files = [
    "LICENSE",
    "README.rdoc"
  ]

  # Dependencies, this syntax requires RubyGems > 1.2.0
  s.add_runtime_dependency 'thor', '~>0.16.0'
  s.add_runtime_dependency 'fog', '~>1.19'
  s.add_runtime_dependency 'ruby-progressbar', '~>1.0.1'
  s.add_development_dependency 'rspec', '~>2.14.0'
  s.add_runtime_dependency 'json', '~>1.7.5'

end
