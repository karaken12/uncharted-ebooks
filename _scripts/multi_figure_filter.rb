#!/usr/bin/env ruby

require 'yaml'
require 'pandoc-filter'
require 'uri'

next_image = nil
PandocFilter.filter do |type, value, format, meta|
  if type == 'Div' && value[0][1].include?('figure')
    if value[1].length == 1
      inner_div = value[1][0]
      if inner_div['t'] == 'Div' && inner_div['c'][0][1].include?('figure')
        PandocElement.Div(value[0],inner_div['c'][1])
      end
    end
  end
end
