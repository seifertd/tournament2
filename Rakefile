# encoding: utf-8
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://guides.rubygems.org/specification-reference/ for more options
  gem.name = "tournament2"
  gem.homepage = "http://github.com/seifertd/tournament2"
  gem.license = "MIT"
  gem.summary = %Q{Library for running bracket-based tournament pools, such as the NCAA basketball tournament.}
  gem.description = %Q{Version 2 with general improvements.}
  gem.email = "doug@dseifert.net"
  gem.authors = ["Douglas A. Seifert"]
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  require "./spec/spec_helper"
  spec.pattern = FileList['spec/**/*.rb']
end

task :default => :spec

desc "Code coverage detail"
task :simplecov do
  ENV['COVERAGE'] = "true"
  Rake::Task['spec'].execute
end

task :benchmark do
  $:.unshift "./lib"
  $:.unshift "."
  puts "Scoring Benchmark:"
  require "benchmarks/scoring_bm"
end

require 'yard'
YARD::Rake::YardocTask.new
