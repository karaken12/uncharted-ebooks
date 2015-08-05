#!/usr/bin/env ruby

require 'yaml'

link_data = YAML.load_file('_data/local_links.yml')
if link_data == nil || link_data == '' then link_data = {} end

Dir.glob("_posts/*").each do |filepath|
  original_url = YAML.load_file(filepath)['original-url']
  if original_url
    link_data[original_url.downcase] = "#{File.basename(filepath, '.*')}.xhtml"
  end
end

file = File.open('_data/local_links.yml', 'w')
file.puts link_data.to_yaml
file.close

