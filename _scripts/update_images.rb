#!/usr/bin/env ruby

require 'yaml'

profiles = YAML.load_file('_data/image-profiles.yml')

Dir.new('_images/original').each do |fname|
  infilepath = File.join('_images','original',fname)
  profiles.each do |profile|
    outfilepath = File.join('_images', profile['name'], fname)
    if !File.exists?(outfilepath)
      puts "convert #{profile['options']} \"#{infilepath}\" \"#{outfilepath}\""
      `convert #{profile['options']} "#{infilepath}" "#{outfilepath}"`
    end
  end
end
