#!/usr/bin/env ruby
# encoding: utf-8

require 'fileutils'

module PEL
  class Parser

    def initialize(path)
      CONFIG[:log].info "Processing path: #{path}"
      done_file_path = "#{path}.tmp"
      PEL.lock("#{path}") do
        current_line = 1
        start_line = 0
        if File.exists?(done_file_path)
          start_line = `wc -l #{done_file_path}`.to_i
        end

        done_file = File.open(done_file_path, 'a+')
        done_file.sync = true
        File.open(path).each_line do |line|
          # Skip already processed lines
          if current_line > start_line
            event = PEL.decode_string(line)
            if event
              # On error keep retrying
              if !process_event(event)
                backoff = [1, 1, 1, 1, 1, 2, 2, 2, 3] + PEL.exp_backoff(6)
                s = backoff.shift
                while !process_event(event)
                  sleep s
                  if backoff.size > 1
                    s = backoff.shift
                  end
                end
              end
              done_file.write line
              sleep CONFIG[:throttle_parse]
            end
          end
          current_line += 1
        end
      end

      FileUtils.rm path rescue nil
      FileUtils.rm  done_file_path rescue nil
      CONFIG[:log].info "Removed path: #{path}"
    end

    # Define functionality here...
    #
    # @params [Hash] event json decoded object
    # @return [Boolean] Success or Fail
    def process_event(event)
      CONFIG[:log].info "Sending event: #{event}"
      if CONFIG[:debug]
        return true
      else
        event = JSON.parse event
        # Add work here
        return true
      end
    end
  end
end
