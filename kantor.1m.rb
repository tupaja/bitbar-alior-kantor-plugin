#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'open-uri'
require 'json'

url = 'https://kantor.aliorbank.pl/forex/json/current'

charset = nil
json = open(url) do |f|
  charset = f.charset
  f.read
end

doc = JSON.parse(json)

currency = doc["currencies"].find do |currency|
  currency["currency1"] == "PLN" && currency["currency2"] == "USD"
end

puts currency["buy"]
