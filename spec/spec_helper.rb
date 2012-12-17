require 'bundler/setup'

begin
  require 'simplecov'
  SimpleCov.start
rescue LoadError
  # SimpleCov only works in Ruby 1.9+
end

require 'rdf/raptor'
require 'rdf/spec'
require 'rdf/spec/matchers'

RSpec.configure do |config|
  config.include(RDF::Spec::Matchers)
  config.exclusion_filter = {:ruby => lambda { |version|
    RUBY_VERSION.to_s !~ /^#{version}/
  }}
  
  unless ENV['RDF_RAPTOR_ENGINE'] == 'cli'
    config.filter_run_excluding :cli => true
  end
end
