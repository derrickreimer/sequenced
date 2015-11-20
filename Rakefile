#!/usr/bin/env rake
begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end
begin
  require 'rdoc/task'
rescue LoadError
  require 'rdoc/rdoc'
  require 'rake/rdoctask'
  RDoc::Task = Rake::RDocTask
end

RDoc::Task.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Sequenced'
  rdoc.options << '--line-numbers'
  rdoc.rdoc_files.include('README.rdoc')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

Bundler::GemHelper.install_tasks

require 'rake/testtask'

Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = false
end

task :default => :test

namespace :db do
  task :create do
    # File.expand_path is executed directory of generated Rails app
    rakefile = File.expand_path('Rakefile', 'test/dummy/')
    command = "rake -f '%s' db:create" % rakefile
    sh(command)
  end

  task :drop do
    # File.expand_path is executed directory of generated Rails app
    rakefile = File.expand_path('Rakefile', 'test/dummy/')
    command = "rake -f '%s' db:drop" % rakefile
    sh(command)
  end

  namespace :test do
    task :prepare do
      # File.expand_path is executed directory of generated Rails app
      rakefile = File.expand_path('Rakefile', 'test/dummy/')
      command = "rake -f '%s' db:test:prepare" % rakefile
      sh(command)
    end
  end
end
