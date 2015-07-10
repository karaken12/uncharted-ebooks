#!/usr/bin/env ruby

require 'yaml'
require 'pandoc-filter'

#file = File.open('urls.tmp','w')
image_data = YAML.load_file('_data/images.yml')
if image_data == nil then image_data = {} end

PandocFilter.filter do |type, value|
  if type == 'Image'
    url = value[1][0]
    # Only care about remote URLs
    if !url.start_with?('http') then next end

#    file.puts url
#    url = "/images/#{url}"
    id = nil
    if image_data.has_key?(url)
      id = image_data[url]
    else
      while (id == nil || image_data.has_value?(id))
        id = ('a'..'z').to_a.shuffle[0,8].join
      end
      id = "#{id}#{File.extname(url)}"
      image_data[url] = id
    end

    new = value[1]
    new[0] = File.join("images", id)
    PandocElement.Image(value[0], new)
  end
end

file = File.open('_data/images.yml', 'w')
file.puts image_data.to_yaml
file.close
