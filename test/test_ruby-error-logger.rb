# encoding: utf-8

require 'test/unit'
require 'ruby-error-logger'
require 'pry'


class PELTest < Test::Unit::TestCase

  def setup
    PEL::CONFIG[:logfile] = 'test.log'
  end

  def teardown
    `rm err.log* 2>&1`
    `rm test.log* 2>&1`
  end

  def test_encode_string
    assert PEL.encode_string("xxx") != "Fo3h4eA==", "Encoding incorrect"
  end

  def test_decode_string
    assert PEL.decode_string("") == nil, 'Decoding incorrect'
  end

  def test_encode_decode_string
    writer = PEL::Writer.new
    writer.log "{\"x\":1}"
    writer.close
    encoded = `head -n 1 test.log`
    assert PEL::decode_string(encoded) == "{\"x\":1}", 'Decoding incorrect'
  end

  def test_create_logfile

    PEL::CONFIG[:logfile] = 'pel.log'
    PEL::Writer.new.log "{}"
    assert File.exists?("pel.log") == true, "No file created pel.log"
    `rm pel.log`

    PEL::CONFIG[:logfile] = 'pel.log'
    PEL::Writer.new.log "{}"
    assert File.exists?("pel.log") == true, "No file created pel.log"
    `rm pel.log`
  end

  def test_rotator

    read_thread = Thread.new do
      @rotator = PEL::Rotator.new
      @rotator.run
      Thread.exit
    end

    write_thread = Thread.new do
      writer = PEL::Writer.new
      writer.log "{\"x\":1}"
      writer.close

      assert File.exists?("test.log") == true

      sleep 10

      #assert File.size?("test.log") == nil

      @rotator.stop
      Thread.kill(read_thread)
      Thread.exit
    end

    write_thread.join
    read_thread.join

  end

  def test_rotator_rotate

    PEL::CONFIG[:logfile] = 'test.log'
    writer = PEL::Writer.new
    writer.log "{\"x\":1}"
    writer.close

    rotator = PEL::Rotator.new
    rotator.rotate_file('test.log')
    assert File.size?("test.log") == nil
    assert Dir["test.log*"].size > 1

  end

end
