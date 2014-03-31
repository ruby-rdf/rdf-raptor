source "http://rubygems.org"

gemspec :name => ""

gem 'rdf', :github => 'ruby-rdf/rdf', :branch => "develop"
gem 'rdf-spec', :github => 'ruby-rdf/rdf-spec', :branch => "develop"

group :development do
  gem 'simplecov', :platforms => [:mri_19, :jruby]
end

group :debug do
  gem 'debugger', :platform => [:mri_19]
  gem 'ruby-debug', :platform => [:mri_18]
end

platforms :rbx do
  gem 'rubysl', '~> 2.0'
  gem 'rubinius', '~> 2.0'
end
