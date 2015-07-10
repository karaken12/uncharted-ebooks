#!/usr/bin/env ruby

require 'yaml'

filenames = ARGV

filenames.each do |filename|
  puts filename
  tmpfilename = "#{filename}.tmp"
  # First load the YAML frontmatter
  frontmatter = YAML.load_file(filename)

  `pandoc -t markdown --filter _scripts/cache_images.rb -o "#{tmpfilename}" "#{filename}"`
#  puts "pandoc -t markdown --filter _scripts/cache_images.rb -o \"#{filename}.tmp\" \"#{filename}\""

  `rm "#{filename}"`

  file = File.open(filename, 'w')
  file.print frontmatter.to_yaml
  file.puts "---\n\n"
  file.close

  `cat "#{tmpfilename}" >> "#{filename}"`

  `rm "#{tmpfilename}"`
end

