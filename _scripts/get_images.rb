#!/usr/bin/env ruby

require 'yaml'

#file = File.open('urls.tmp','w')
image_data = YAML.load_file('_data/images.yml')
if image_data == nil || image_data == '' then image_data = {} end

image_data.each do |url, filename|
  filepath = File.join("_images", "original", filename)
  if !File.exists?(filepath)
    puts "wget -O \"#{filepath}\" \"#{url}\""
    `wget -O "#{filepath}" "#{url}"`
  end
end
