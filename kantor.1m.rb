#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'open-uri'
require 'json'
require 'date'

url = 'https://kantor.aliorbank.pl/forex/json/current'
web_url = 'https://kantor.aliorbank.pl/forex'.freeze
file_path = "#{Dir.home}/.bitbar-alior-kantor-plugin-store.txt".freeze

charset = nil
json = open(url) do |f|
  charset = f.charset
  f.read
end

doc = JSON.parse(json)

currency_usd = doc["currencies"].find do |currency|
  currency["currency1"] == "PLN" && currency["currency2"] == "USD"
end

currency_euro = doc["currencies"].find do |currency|
  currency["currency1"] == "PLN" && currency["currency2"] == "EUR"
end

def color(direction)
  if direction == 1
    "green"
  elsif direction == -1
    "red"
  end
end

def load_min_max(path)
  unless File.exist?(path)
    save_min_max(path,0,10,Date.today.day)
  end
  line = File.open(path).read
  @max, @min, @day = line.split(':').map { |l| Float(l).round(4) }
  @max, @min = [0,10] if @day != Date.today.day
end

def save_min_max(path, max, min, day)
  File.open(path, 'w') { |file| file.write("#{max}:#{min}:#{day}") }
end

load_min_max(file_path)
current_value = Float(currency_euro["buy"].gsub(',', '.')).round(4)

if current_value.nil?
  current_value = '---'
else
  @max = current_value if current_value > @max
  @min = current_value if current_value < @min
  save_min_max(file_path, @max, @min, Date.today.day)
end

content = <<HEREDOC
$#{currency_usd['buy']} €#{currency_euro['buy']} | color=#{color(currency_euro["direction"])}
---
alior | href=#{web_url}
max: €#{@max}
min: €#{@min}

HEREDOC

puts content
