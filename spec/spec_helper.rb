require 'bundler/setup'

begin
  require 'pry'
  require 'pry-byebug'
rescue LoadError
end

begin
  require 'simplecov'
  require 'simplecov-lcov'

  SimpleCov::Formatter::LcovFormatter.config do |config|
    #Coveralls is coverage by default/lcov. Send info results
    config.report_with_single_file = true
    config.single_report_path = 'coverage/lcov.info'
  end

  SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new([
    SimpleCov::Formatter::HTMLFormatter,
    SimpleCov::Formatter::LcovFormatter
  ])
  SimpleCov.start do
    add_filter "/spec/"
  end
rescue LoadError => e
  STDERR.puts "Coverage Skipped: #{e.message}"
end

require 'rdf/raptor'
require 'rdf/spec'
require 'rdf/spec/matchers'

RSpec.configure do |config|
  config.include(RDF::Spec::Matchers)
  config.exclusion_filter = {ruby: lambda { |version|
    RUBY_VERSION.to_s !~ /^#{version}/
  }}
  
  unless ENV['RDF_RAPTOR_ENGINE'] == 'cli'
    config.filter_run_excluding cli: true
  end
end
