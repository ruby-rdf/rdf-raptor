#!/usr/bin/env ruby -rubygems
# -*- encoding: utf-8 -*-

Gem::Specification.new do |gem|
  gem.version            = File.read('VERSION').chomp
  gem.date               = File.mtime('VERSION').strftime('%Y-%m-%d')

  gem.name               = 'rdf-raptor'
  gem.homepage           = 'http://rdf.rubyforge.org/raptor/'
  gem.license            = 'Public Domain' if gem.respond_to?(:license=)
  gem.summary            = 'Raptor RDF Parser plugin for RDF.rb.'
  gem.description        = 'RDF.rb plugin for parsing/serializing RDF/XML, Turtle and RDFa data using the Raptor RDF Parser library.'
  gem.rubyforge_project  = 'rdf'

  gem.authors            = ['Arto Bendiken', 'John Fieber']
  gem.email              = 'public-rdf-ruby@w3.org'

  gem.platform           = Gem::Platform::RUBY
  gem.files              = %w(AUTHORS CREDITS README UNLICENSE VERSION etc/doap.ttl) + Dir.glob('lib/**/*.rb')
  gem.bindir             = %q(bin)
  gem.executables        = %w()
  gem.default_executable = gem.executables.first
  gem.require_paths      = %w(lib)
  gem.extensions         = %w()
  gem.test_files         = %w()
  gem.has_rdoc           = false

  gem.required_ruby_version      = '>= 1.8.1'
  gem.requirements               = ['libraptor (>= 1.4.16)']
  gem.add_runtime_dependency     'ffi',      '>= 1.0'
  gem.add_runtime_dependency     'rdf',      '= 0.3.0.pre'
  gem.add_development_dependency 'yard' ,    '>= 0.6.0'
  gem.add_development_dependency 'rspec',    '>= 1.3.0'
  gem.add_development_dependency 'rdf-spec', '= 0.3.0.pre'
  gem.post_install_message       = nil
end
