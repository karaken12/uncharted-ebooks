#!/usr/bin/env ruby

require_relative './pandoc_rewrite'

filenames = ARGV

filenames.each do |filename|
  puts filename
  PandocFilter::pandoc_rewrite(filename, '_scripts/cache_images.rb')
end

