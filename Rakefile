require "bundler/gem_tasks"
require "rake/testtask"
require "rdoc/task"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/**/*_test.rb"]
end

Rake::TestTask.new(:examples) do |t|
  t.libs << "examples"
  #t.libs << "lib" # uncomment for local development without the gem installed.
  t.test_files = FileList["examples/test/*_test.rb"]
end

Rake::RDocTask.new do |rdoc|
  files = ['README.md', 'LICENSE.txt', 'lib/']
  rdoc.rdoc_files.add(files)
  rdoc.main = "README.md" # page to start on
end

task :default => :test
