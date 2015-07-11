#!/usr/bin/env ruby

require 'yaml'

files = ARGV

image_map = YAML.load_file('_data/image_map.yml')
if image_map == nil || image_map == '' then image_map = {} end

files.each do |filepath|
  result = `pandoc -t json #{filepath} | _scripts/image_list_filter.rb | sed -n 's/^- //p'`
  images = result.split("\n")
  image_map[filepath] = images
end

file = File.open('_data/image_map.yml', 'w')
file.puts image_map.to_yaml
file.close

