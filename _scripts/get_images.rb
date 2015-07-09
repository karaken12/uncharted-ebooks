#!/usr/bin/env ruby

require 'yaml'

#file = File.open('urls.tmp','w')
image_data = YAML.load_file('_data/images.yml')
if image_data == nil then image_data = {} end

image_data.each do |url, filename|
  filepath = File.join("_images", filename)
  `wget -O "#{filepath}" #{url}`
end
