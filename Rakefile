#!/usr/bin/env ruby
# frozen_string_literal: true
$LOAD_PATH.unshift(File.expand_path(File.join(File.dirname(__FILE__), 'lib')))
require 'rubygems'

namespace :gem do
  desc "Build the rdf-spec-#{File.read('VERSION').chomp}.gem file"
  task :build  do
    sh "gem build rdf-spec.gemspec && mv rdf-spec-#{File.read('VERSION').chomp}.gem pkg/"
  end

  desc "Release the rdf-spec-#{File.read('VERSION').chomp}.gem file"
  task :release do
    sh "gem push pkg/rdf-spec-#{File.read('VERSION').chomp}.gem"
  end
end

require 'rdf/raptor'
require 'bundler/gem_helper'
Bundler::GemHelper.install_tasks name: 'rdf-raptor'

desc 'Run memory leak test with valgrind'
task :memtest do
  puts system 'valgrind --log-file=valgrind.log --trace-children=yes --leak-check=full ruby memtest.rb; grep -C 20 raptor_ valgrind.log'
end

require 'rspec/core/rake_task'
desc 'Default: run specs.'
task default: :spec

desc 'Run specs'
RSpec::Core::RakeTask.new do |t|
  t.pattern = './spec/**/*_spec.rb' # don't need this, it's default.
  # Put spec opts in a file named .rspec in root
end
