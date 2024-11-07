# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "ipgeobase"

require "minitest/autorun"
require 'webmock/minitest'

RESERVED_RANGE_RESPONSE = File.read(File.join(__dir__, "fixtures", "reserved-range.xml"))
PUBLIC_IP_RESPONSE = File.read(File.join(__dir__, "fixtures", "public-ip.xml"))
