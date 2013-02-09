#!/usr/bin/env ruby
# encoding: utf-8

require 'thread'

class Pool
  def initialize(size)
    @size = size
    @jobs = Queue.new
    
    @pool = Array.new(@size) do |i|
      Thread.new do
        Thread.current[:id] = i

        catch(:exit) do
          loop do
            # Non-blocking pop
            job, args = @jobs.pop(true) rescue nil
            if job
              job.call(*args)
            else
              sleep 0.01
            end
          end
        end
      end
    end
  end
  
  def schedule(*args, &block)
    @jobs << [block, args]
  end
  
  def shutdown
    @size.times do
      schedule { throw :exit }
    end
    
    @pool.map(&:join)
  end
end
