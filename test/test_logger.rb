#!/usr/bin/env ruby
# encoding: utf-8
#--
#
# State Based Session Management
# Copyright (C) 2004 Hannes Wyss
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#
# ywesee - intellectual capital connected, Winterthurerstrasse 52, CH-8006 Zürich, Switzerland
# hwyss@ywesee.com
#
# TestSession -- sbsm -- 22.10.2002 -- hwyss@ywesee.com 
#++

require 'minitest/autorun'
require 'fileutils'
require 'sbsm/logger'
begin
  require 'pry'
rescue LoadError
end
class TestLogger < Minitest::Test
  def setup
    @saved_loger = SBSM.logger.clone
    @default_name = Time.now.strftime("/tmp/sbsm_#{SBSM::VERSION}.log.%Y%m%d")
    FileUtils.rm_f(@default_name)
    # we reload the logger class as it initializes the logger to a default value
    load 'sbsm/logger.rb'
    assert(File.exist?(@default_name))
  end
  def teardown
    SBSM.logger= @saved_loger
  end

  def test_default_levels
    saved_length = File.size(@default_name)
    SBSM.debug("debug #{__LINE__}")
    assert_equal(saved_length, File.size(@default_name))
    SBSM.info("info #{__LINE__}")
    assert_equal(saved_length, File.size(@default_name))

    SBSM.logger.level = :info
    SBSM.info("info #{__LINE__}")
    assert(saved_length < File.size(@default_name))
    saved_length = File.size(@default_name)
    SBSM.debug("debug #{__LINE__}")
    saved_length = File.size(@default_name)

    SBSM.logger.level = :debug
    SBSM.info("info #{__LINE__}")
    assert(saved_length < File.size(@default_name))
    saved_length = File.size(@default_name)
    SBSM.debug("debug #{__LINE__}")
    assert(saved_length < File.size(@default_name))

    saved_length = File.size(@default_name)
    SBSM.logger.level = :warn
    SBSM.info("info #{__LINE__}")
    SBSM.debug("debug #{__LINE__}")
    assert_equal(saved_length, File.size(@default_name))
  end

  def test_change_logger
    new_name = '/tmp/sbsm_test_log'
    FileUtils.rm_f(new_name)
    assert_equal(false, File.exist?(new_name))
    SBSM.logger= Logger.new(new_name)
    assert_equal(true, File.exist?(new_name))
    saved_length = File.size(new_name)

    default_saved_length = File.size(@default_name)
    SBSM.debug("debug #{__LINE__}")
    SBSM.info("info #{__LINE__}")
    assert_equal(default_saved_length, File.size(@default_name))
    assert_equal(true, File.exist?(new_name))

    SBSM.logger.level = :info
    SBSM.info("info #{__LINE__}")
    assert(saved_length < File.size(new_name))
    saved_length = File.size(new_name)
    SBSM.debug("debug #{__LINE__}")
    saved_length = File.size(new_name)

    SBSM.logger.level = :debug
    SBSM.info("info #{__LINE__}")
    assert(saved_length < File.size(new_name))
    saved_length = File.size(new_name)
    SBSM.debug("debug #{__LINE__}")
    assert(saved_length < File.size(new_name))

    saved_length = File.size(new_name)
    SBSM.logger.level = :warn
    SBSM.info("info #{__LINE__}")
    SBSM.debug("debug #{__LINE__}")
    assert_equal(saved_length, File.size(new_name))
    assert_equal(default_saved_length, File.size(@default_name))
  end

  def test_nil_logger
    default_saved_length = File.size(@default_name)
    SBSM.logger= nil
    assert_equal(default_saved_length, File.size(@default_name))
    SBSM.debug("debug #{__LINE__}")
    SBSM.info("info #{__LINE__}")
    assert_equal(default_saved_length, File.size(@default_name))
  end

end