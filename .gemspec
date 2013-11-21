#!/usr/bin/env ruby -rubygems
# -*- encoding: utf-8 -*-

Gem::Specification.new do |gem|
  gem.version            = File.read('VERSION').chomp
  gem.date               = File.mtime('VERSION').strftime('%Y-%m-%d')

  gem.name               = 'rdf-raptor'
  gem.homepage           = 'http://ruby-rdf.github.com/rdf-raptor'
  gem.license            = 'Public Domain' if gem.respond_to?(:license=)
  gem.summary            = 'Raptor RDF Parser plugin for RDF.rb.'
  gem.description        = 'RDF.rb plugin for parsing/serializing NTriples, RDF/XML, Turtle and RDFa data using the Raptor RDF Parser library.'
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

  gem.required_ruby_version      = '>= 1.9.2'
  gem.requirements               = ['libraptor (>= 2.0)']
  gem.add_runtime_dependency     'ffi',      '>= 1.9.3'
  gem.add_runtime_dependency     'rdf',      '>= 1.1.0'
  gem.add_development_dependency 'yard' ,    '>= 0.8.6'
  gem.add_development_dependency 'rspec',    '>= 2.14.0'
  gem.add_development_dependency 'rdf-spec', '>= 1.1.0'
  gem.add_development_dependency 'rake'

  # Rubinius has it's own dependencies
  if RUBY_ENGINE == "rbx" && RUBY_VERSION >= "2.1.0"
    gem.add_runtime_dependency     "rubysl-bigdecimal"
    gem.add_runtime_dependency     "rubysl-digest"
    gem.add_runtime_dependency     "rubysl-enumerator"
    gem.add_development_dependency "rubysl-open-uri"
    gem.add_development_dependency "rubysl-prettyprint"
  end

  gem.post_install_message       = nil
end
