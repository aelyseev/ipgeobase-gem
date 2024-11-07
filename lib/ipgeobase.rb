# frozen_string_literal: true

# rubocop:disable Naming/MethodParameterName
# rubocop:disable Naming/VariableName
# rubocop:disable Naming/MethodName

require "net/http"
require "uri"
require "addressable/uri"
require "happymapper"

require_relative "ipgeobase/version"

# The Ipgeobase module provides methods to work with IP geolocation.
# It includes functionality to retrieve geolocation
# information based on a given IP address.
module Ipgeobase
  API_BASE = "http://ip-api.com/"

  # The LookupResult class represents the result of an IP address geolocation lookup.
  # It includes attributes such as:
  # - city: The name of the city.
  # - country: The name of the country.
  # - countryCode: The code of the country (e.g., "IT" for Italy).
  # - lat: The geographical latitude.
  # - lon: The geographical longitude.
  class LookupResult
    attr_reader :city, :country, :countryCode, :lat, :lon

    def initialize(city:, country:, countryCode:, lat:, lon:)
      @city = city
      @country = country
      @countryCode = countryCode
      @lat = lat
      @lon = lon
    end
  end

  class Error < StandardError; end

  def self.build_url(address)
    uri = Addressable::URI.parse(Ipgeobase::API_BASE)
    raise Error, "Can't build URL" unless uri.respond_to?(:path)

    uri.path = "xml/#{address}"

    URI.parse(uri.normalize)
  end

  def self.make_request(uri)
    response = Net::HTTP.get_response(uri)

    raise Error, "Error: #{response.code} - #{response.message}" unless response.is_a?(Net::HTTPSuccess)

    response.body
  end

  def self.parse_xml(xml)
    begin
      meta = HappyMapper.parse(xml)
    rescue StandardError => e
      raise Error, "Error while parsing xml response: #{e.class} - #{e.message}"
    end

    if meta.status == "fail"
      raise Error, ["Status: #{meta.status}", "message: #{meta.message}", "address: #{meta.query}"].join(" ")
    end

    meta
  end

  private_class_method :make_request, :parse_xml

  def self.lookup(address)
    xml_body = make_request(build_url(address))
    ip_meta = parse_xml(xml_body)

    LookupResult.new(
      city: ip_meta.city,
      country: ip_meta.country,
      countryCode: ip_meta.country_code,
      lat: ip_meta.lat.to_f,
      lon: ip_meta.lon.to_f
    )
  end
end

# rubocop:enable Naming/MethodParameterName
# rubocop:enable Naming/VariableName
# rubocop:enable Naming/MethodName
