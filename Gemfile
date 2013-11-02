source "http://rubygems.org"

gemspec :name => ""

gem 'rdf', :git => 'http://github.com/ruby-rdf/rdf', :branch => "develop"
gem 'rdf-spec', :git => 'http://github.com/ruby-rdf/rdf-spec', :branch => "develop"

group :development do
  gem 'simplecov', :platforms => [:mri_19, :jruby]
end

group :debug do
  gem 'debugger', :platform => [:mri_19]
  gem 'ruby-debug', :platform => [:mri_18]
end

gem 'ffi', '~> 1.3.1', :platforms => [:rbx]