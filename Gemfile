source "https://rubygems.org"

gemspec

gem 'rdf',            github: 'ruby-rdf/rdf',            branch: "develop"
gem 'rdf-spec',       github: 'ruby-rdf/rdf-spec',       branch: "develop"
gem "rdf-isomorphic", github: "ruby-rdf/rdf-isomorphic", branch: "develop"

group :test do
  gem 'simplecov', '~> 0.21',  platforms: :mri
  gem 'simplecov-lcov', '~> 0.8',  platforms: :mri
end

group :debug do
  gem 'pry'
  gem 'pry-byebug', platforms: :mri
end
