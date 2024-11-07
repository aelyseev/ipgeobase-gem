# frozen_string_literal: true

require "test_helper"
require "webmock"

class TestIpgeobase < Minitest::Test
  def setup
    stub_request(:get, Ipgeobase.build_url("0.0.0.0").to_s)
      .to_return(status: 200, body: RESERVED_RANGE_RESPONSE, headers: {})
    stub_request(:get, Ipgeobase.build_url("62.149.128.40").to_s)
      .to_return(status: 200, body: PUBLIC_IP_RESPONSE, headers: {})
  end

  def test_that_it_has_a_version_number
    refute_nil ::Ipgeobase::VERSION
  end

  def test_return_error_for_reserved_addresses
    assert_raises(Ipgeobase::Error) do
      Ipgeobase.lookup "0.0.0.0"
    end
  end

  def test_return_proper_resut_valid_ip
    meta = Ipgeobase.lookup "62.149.128.40"
    assert_kind_of String, meta.city
    assert_kind_of String, meta.country
    assert_kind_of String, meta.countryCode
    assert_kind_of Float, meta.lat
    assert_kind_of Float, meta.lon
  end
end
