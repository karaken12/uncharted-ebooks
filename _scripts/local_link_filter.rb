#!/usr/bin/env ruby

require 'yaml'
require 'pandoc-filter'
require 'uri'

link_data = YAML.load_file('_data/local_links.yml')
if link_data == nil || link_data == '' then link_data = {} end

PandocFilter.filter do |type, value|
  if type == 'Link'
    url = value[1][0].downcase
    # Only care about remote URLs
    if !url.start_with?('http') then next end

    fragment = URI.parse(url).fragment
    if fragment
      url = url.gsub(/##{fragment}$/,'')
    end
    local_path = nil
    if !link_data.has_key?(url)
      next
    end

    local_path = link_data[url]
    if fragment
      local_path = "#{local_path}##{fragment}"
    end

    new = value[1]
    new[0] = local_path
    PandocElement.Link(value[0], new)
  end
end
