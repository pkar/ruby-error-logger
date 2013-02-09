#!/usr/bin/env ruby
# encoding: utf-8

require 'pool'

module PEL

  class Writer

    # Override config to set new file
    # Files rotate every PEL::CONFIG[:rotate_size] bytes
    # PEL::CONFIG[:logfile] = 'err.log'
    def initialize
      @writer = File.open(CONFIG[:logfile], 'a')
      @writer.sync = true
      @pool = Pool.new(CONFIG[:write_queue_size])
    end

    # Close class method Logger instance
    def close
      if !(defined?(@writer)).nil?
        @pool.shutdown
        @writer.close
      end
    end

    def write(msg)
      log msg
    end

    # @params [String] Message to be written to log.
    def log(msg)
      @pool.schedule do
        PEL.lock("#{CONFIG[:logfile]}") do
          @writer.write "#{PEL.encode_string(msg)}\n"
        end
      end
      return true
    end
  end

end
