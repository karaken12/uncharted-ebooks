#!/usr/bin/env ruby

require 'yaml'
require_relative 'add'

# For each markdown page, get the URL
# Then run the other script

def get_url(filename)
  return YAML.load_file(filename)['original-url']
end

def rerun(filename)
  puts "Rerunning on #{filename}"
  url = get_url(filename)
  if url == nil
    puts "File #{filename} does not have a URL!"
  else
    get_story(url)
  end
end

# ---

if (ARGV[0])
  start_time = Time.now
  if ARGV[0] == "all" then
    Dir.foreach("_posts") do |fname|
      if fname == '.' || fname == '..' then next end
      rerun("_posts/" + fname)
    end
  else
    ARGV.each do |fname|
      rerun(fname)
    end
  end
  end_time = Time.now
  puts " = Time spent: #{end_time - start_time}s"
end

