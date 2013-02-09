#!/usr/bin/env ruby
# encoding: utf-8

require 'bundler/setup'
require 'rubygems'
require 'logger'
require 'base64'
require 'msgpack'

require 'rotator'
require 'writer'
require 'watcher'
require 'parser'

module PEL

  CONFIG = {
    :log               => Logger.new(STDOUT), # app log
    :logfile           => 'err.log', # path to file to be processed
    :write_queue_size  => 3, # schedule jobs to this many threads
    :read_queue_size   => 4, # schedule jobs to this many threads
    :rotate_time       => 30, # seconds to rotate log if no workers
    :rotate_size       => 1048576, # bytes 1mb
    :size_checker_time => 3, #interval to check file size for rotations
    :throttle_send     => 0.1, # seconds to sleep between requests sent
    :throttle_parse    => 0.0, # seconds to sleep between reading from file
    :debug             => false # send actual data to proxy
    }

  # @params [Integer] upto number of elements in array
  # @return [Array]
  def exp_backoff(upto)
    result = []
    # ^ stores wait periods
    (1..upto).each do |iter|
      result << (1.0/2.0*(2.0**iter - 1.0)).ceil
      # using ceil to round off
    end
    return result
  end

  # Set flock on file path and execute block
  def lock(path)
    File.open(path) do |file|
      file.flock(File::LOCK_EX)
      yield
      file.flock(File::LOCK_UN)
    end
  end

  # @params [String] json
  # @return [String] Base64 encoded message packed json.
  def encode_string(json)
    "#{Base64.strict_encode64(json.to_msgpack)}" rescue ""
  end

  # @params [String] enc base 64 encoded and message packed
  # @return [String] Object
  def decode_string(enc)
    "#{MessagePack.unpack(Base64.strict_decode64(enc.strip))}" rescue nil
  end 

  module_function :lock, :exp_backoff, :encode_string, :decode_string

end

