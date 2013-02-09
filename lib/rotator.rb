#!/usr/bin/env ruby
# encoding: utf-8

require 'fileutils'
require 'pool'
require 'eventmachine'
require 'eventmachine-tail'

module PEL
  class Rotator

    def rotate_file(path)
      PEL.lock("#{path}") do
        new_path = "#{path}.#{Time.now.to_i}"
        CONFIG[:log].info "Rotating path: #{new_path}"
        FileUtils.cp path, new_path
        File.truncate("#{path}", 0)
        CONFIG[:log].info "Emptied: #{path}"
      end
    end

    def run
      EM.run do
        CONFIG[:log].info "Starting event machine...logging to #{CONFIG[:logfile]}*"
        @EM = EM.spawn {EM.stop}

        @pool = Pool.new(CONFIG[:read_queue_size])
        @watcher = Watcher.new("#{CONFIG[:logfile]}*", @pool)

        # Size checker
        EM.add_periodic_timer(CONFIG[:size_checker_time]) {
          size = File.size?(CONFIG[:logfile])
          if size != nil
            if size > CONFIG[:rotate_size]
              rotate_file "#{CONFIG[:logfile]}"
            end
          end
        }

        # Time checker
        # TODO get disk space available and remove oldest log rotation
        EM.add_periodic_timer(CONFIG[:rotate_time]) {
          size = File.size?(CONFIG[:logfile])
          if ((size and (size > 0)) and Dir["#{CONFIG[:logfile]}*"].size == 1)
            rotate_file("#{CONFIG[:logfile]}")
          end
        }

        EventMachine.add_shutdown_hook { 
          CONFIG[:log].info "Shutting down"
          @pool.shutdown
          CONFIG[:log].info "Closed pool"
          @watcher.shutdown
          CONFIG[:log].info "Closed file watcher"
        }
      end
    end

    def stop
      @EM.notify
    end
    
  end
end
