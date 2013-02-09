#!/usr/bin/env ruby
# encoding: utf-8

require 'pool'

module PEL
  class Watcher < EM::FileGlobWatch

    # @params [String] pathglob
    # @params [Pool] pool workers
    # @params [Integer] interval seconds to check for new files
    def initialize(pathglob, pool, interval=5)
      @pool = pool
      super(pathglob, interval)
    end

    # @params [String] path
    def file_deleted(path)
      #puts "file_deleted: #{path}"
    end

    # When a new file is found(happens on startup as well)
    # Fork a ruby process and process the file until it is
    # empty. Only process worker files.
    #
    # @params [String] path
    def file_found(path)
      if (path != CONFIG[:logfile]) and !(path.include? '.tmp')
        @pool.schedule do
          Parser.new path
          #pid = Process.fork do
          #  Parser.new path
          #end
          #Process.detach(pid)
          CONFIG[:log].info "Parsed: #{path} "
        end
      end
    end

    def shutdown
      stop
      @pool.shutdown
    end

  end
end

