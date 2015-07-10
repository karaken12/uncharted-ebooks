#!/usr/bin/env ruby

Dir.new('_images/original').each do |fname|
  infilepath = File.join('_images','original',fname)
  outfilepath = File.join('_images','grayscale',fname)
  if !File.exists?(outfilepath)
    puts "convert -set colorspace RGB -colorspace gray \"#{infilepath}\" \"#{outfilepath}\""
    `convert -set colorspace RGB -colorspace gray "#{infilepath}" "#{outfilepath}"`
  end
end
