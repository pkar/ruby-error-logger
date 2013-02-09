#!/usr/bin/env ruby
# encoding: utf-8

require 'bundler/setup'
require 'ruby-error-logger'

c = PEL::CONFIG
c[:debug] = true
c[:logfile] = 'err.log'
c[:write_queue_size] = 2
c[:read_queue_size] = 4
c[:rotate_time] = 10
c[:rotate_size] = c[:rotate_size] / 10
c[:size_checker_time] = 1.0
c[:throttle_send] = 0.0
c[:throttle_parse] = 0.0

pid = Process.fork do
  rotator = PEL::Rotator.new
  rotator.run
end

writer = PEL::Writer.new
100000.times do |i|
  writer.log "{\"x\":#{i}}"
end
writer.close


Process.wait(pid)

