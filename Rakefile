require "bundler/gem_tasks"
require "rake/testtask"
require "rdoc/task"

Rake::TestTask.new(:test) do |test|
  test.libs << "test"
end
task default: :test

RDoc::Task.new do |rdoc|
  rdoc.rdoc_dir = "rdoc"
  rdoc.title = "scripto #{Scripto::VERSION}"
  rdoc.main = "README.md"
  rdoc.rdoc_files.include("lib/**/*.rb")
  rdoc.rdoc_files.include("README.md")
end