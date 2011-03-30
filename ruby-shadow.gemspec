# -*- encoding: utf-8 -*-

Gem::Specification.new do |spec|
  spec.authors               = ['Adam Palmblad', 'Eric Hankins', 'Ian Marlier', 'Jeff Blaine', 'Takaaki Tateishi']
  spec.description           = 'This module provides access to shadow passwords on Linux and Solaris'
  spec.email                 = ['adam.palmblad@teampages.com']
  spec.extensions            = ['extconf.rb']
  spec.files                 = ['HISTORY', 'MANIFEST', 'README', 'README.euc', 'shadow.c']
  spec.homepage              = 'https://github.com/apalmblad/ruby-shadow'
	spec.name                  = 'ruby-shadow'
	spec.required_ruby_version = '>= 1.8'
	spec.summary               = '*nix Shadow Password Module'
	spec.version               = '2.1.2'
end
