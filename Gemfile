source "https://rubygems.org"

gemspec

gem 'rdf',            github: 'ruby-rdf/rdf',            branch: "develop"
gem 'rdf-spec',       github: 'ruby-rdf/rdf-spec',       branch: "develop"
gem "rdf-isomorphic", github: "ruby-rdf/rdf-isomorphic", branch: "develop"

group :development do
  gem 'simplecov', platforms: [:mri, :jruby]
end

group :debug do
  gem 'pry'
  gem 'pry-byebug', platforms: :mri
end
