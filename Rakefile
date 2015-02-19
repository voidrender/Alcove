require 'bundler/gem_tasks'
require 'rake/testtask'

task :ci => [:test, :build]

Rake::TestTask.new do |test|
  test.pattern = "test/test_*.rb"
end
