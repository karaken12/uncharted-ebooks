#!/usr/bin/env ruby

require_relative './pandoc_rewrite'

filenames = ARGV

filenames.each do |filename|
  puts filename
  PandocFilter::pandoc_rewrite(filename, '_scripts/local_link_filter.rb')
end

