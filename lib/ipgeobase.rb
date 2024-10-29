# frozen_string_literal: true
require 'net/http'
require 'uri'

require_relative "ipgeobase/version"

module Ipgeobase
  class Error < StandardError; end
  def self.lookup(address)

  end
end

pp Ipgeobase::lookup ''
