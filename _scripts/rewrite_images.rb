#!/usr/bin/env ruby

filenames = ARGV

filenames.each do |filename|
  puts filename
  #`pandoc -t markdown --filter _scripts/cache_images.rb -o "#{filename}" "#{filename}"`
  puts "pandoc -t markdown --filter _scripts/cache_images.rb -o \"#{filename}\" \"#{filename}\""
end

