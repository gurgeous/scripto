require "bundler/gem_tasks"
require "rake/testtask"
require "rdoc/task"
require "rubocop/rake_task"

# rake test
Rake::TestTask.new(:test) { _1.libs << "test" }
task default: :test
