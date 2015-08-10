#!/usr/bin/env ruby

require 'yaml'
require 'pandoc-filter'
require 'uri'

PandocFilter.filter do |type, value|
  if type == 'Link'
    url = value[1][0]
    puts "- #{url}"
  end
end
