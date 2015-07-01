#!/usr/bin/env ruby

require_relative 'MagicArticleScraper'

def get_story(url)
  if URI(url).host == "magic.wizards.com"
    return MagicArticleScraper.get_story(url)
  #elsif URI(url).host == "archive.wizards.com"
  #  return OldMagicArticleScraper.get_story(url)
  else
    puts "Unknown host!"
    return
  end
end

def get_loop()
  while(true)
    puts "==="
    # Ask for URL
    print "Enter story URL: "
    url = STDIN.gets.chomp
    if url == '' then return end
    get_story(url)
  end
end

if __FILE__==$0
  # Bit nasty, but should do the job
  if (ARGV[0])
    if ARGV[0] == '-'
      get_loop()
    else
      get_story(ARGV[0])
    end
  end
end
