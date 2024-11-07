# frozen_string_literal: true
require "net/http"
require "uri"
require "addressable/uri"
require 'happymapper'

require_relative "ipgeobase/version"

module Ipgeobase
  API_BASE = "http://ip-api.com/"

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
    if uri.respond_to?(:path)
      uri.path = "xml/#{address}"
    else
      raise Error, "Can't build URL"
    end
    URI.parse(uri.normalize)
  end

  def self.lookup(address)
    response = Net::HTTP.get_response(build_url(address))

    xml_body = if response.is_a?(Net::HTTPSuccess)
                 response.body
               else
                 raise Error, "Error: #{response.code} - #{response.message}"
               end
    begin
      ip_meta = HappyMapper::parse(xml_body)
    rescue StandardError => e
      raise Error, "Error while parsing xml response: #{e.class} - #{e.message}"
    end

    if ip_meta.status == "fail"
      raise Error, ["Status: #{ip_meta.status}", "message: #{ip_meta.message}", "address: #{ip_meta.query}"].join(" ")
    end

    LookupResult.new(
      city: ip_meta.city,
      country: ip_meta.country,
      countryCode: ip_meta.country_code,
      lat: ip_meta.lat.to_f,
      lon: ip_meta.lon.to_f
    )
  end
end
