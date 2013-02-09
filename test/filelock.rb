#!/usr/bin/env ruby
# encoding: utf-8

require 'bundler/setup'
require 'ruby-error-logger'

c = PEL::CONFIG
c[:debug] = true
c[:logfile] = 'err.log'
c[:write_queue_size] = 4
c[:read_queue_size] = 4
c[:rotate_time] = 10
c[:rotate_size] = c[:rotate_size] / 1000
c[:size_checker_time] = 1.0
c[:throttle_send] = 0.41
c[:throttle_parse] = 1.41


pid = Process.fork do
  PEL.lock('err.log') do
    puts 'locked'
    sleep 10
    puts 'unlocked file'
  end
end

sleep 3

writer = PEL::Writer.new
10.times do |i|
  PEL.lock('err.log') do
    puts i
    writer.log "{\"x\":#{i}}"
  end
end
writer.close


Process.wait(pid)

