#!/usr/bin/env ruby
# encoding: utf-8

require 'bundler/setup'
require 'ruby-error-logger'
require "benchmark"

c = PEL::CONFIG
c[:debug] = true
c[:logfile] = 'err.log'
c[:write_queue_size] = 2
c[:read_queue_size] = 4
c[:rotate_time] = 10
c[:rotate_size] = c[:rotate_size] / 1000
c[:size_checker_time] = 1.0
c[:throttle_send] = 0.0
c[:throttle_parse] = 0.0


puts "Writer without locking or threads"
writer = File.open(c[:logfile], 'a')
writer.sync = true
time = Benchmark.measure do
  1000000.times do |i|
    writer.write "#{PEL.encode_string("{\"x\":#{i}}")}\n" 
  end
end
writer.close
`rm err.log`
puts time


puts "Writer with locking and threads"
writer = PEL::Writer.new
time = Benchmark.measure do
  1000000.times do |i|
    writer.log "{\"x\":#{i}}"
  end
  writer.close
end
`rm err.log`
puts time

