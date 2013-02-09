#! /usr/bin/env gem build
# encoding: utf-8

lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

Gem::Specification.new do |gem|
  gem.name                  = 'ruby-error-logger'
  gem.version               = '0.0.4'
  gem.date                  = '2013-02-09'
  gem.summary               = "Generic file based error logger/processor"
  gem.description           = gem.summary
  gem.authors               = ["Paul Karadimas"]
  gem.email                 = 'paulkar@gmail.com'
  gem.files                 = ["lib/ruby-error-logger.rb"]
  gem.homepage              = 'https://github.com/pkar/ruby-error-logger'
  gem.require_paths         = ["lib"]

  gem.add_dependency "msgpack"
  gem.add_dependency "eventmachine"
  gem.add_dependency "eventmachine-tail"
end
