require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << 'test'
end

desc "Run tests"
task :default => :test

task :console do
  NewRelic.agent_instance.shutdown rescue nil
  require 'irb'
  require 'irb/completion'
  ARGV.clear
  IRB.start
end

task :c => :console

