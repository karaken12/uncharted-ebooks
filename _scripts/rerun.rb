#!/usr/bin/env ruby

require 'yaml'
require_relative 'add'

# For each markdown page, get the URL
# Then run the other script

def get_url(filename)
  return YAML.load_file(filename)['url']
end

def rerun(filename)
  url = get_url(filename)
  get_story(url)
end

# ---

if (ARGV[0])
  if ARGV[0] == "all" then
    puts "Not implemented!"
  else
    rerun(ARGV[0])
  end
end

