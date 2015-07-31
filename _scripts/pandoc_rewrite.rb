#!/usr/bin/env ruby

require 'yaml'

module PandocFilter

  def self.get_frontmatter(filename)
    frontmatter = YAML.load_file(filename)
    data = nil
    IO.popen('pandoc -t markdown -s', 'r+') {|f| # don't forget 'r+'
      f.puts(frontmatter.to_yaml) # you can also use #write
      # Pandoc needs this to know it's frontmatter
      f.puts('---')
      f.close_write
      data = f.read # get the data from the pipe
    }
    data = YAML.load(data)
    ['author-bio', 'prologue'].each do |key|
      if data.has_key?(key)
        frontmatter[key] = data[key]
      end
    end
    return frontmatter
  end

  def self.pandoc_rewrite(filename, filter = nil)

    tmpfilename = "#{filename}.tmp"

    # First load the YAML frontmatter
    frontmatter = get_frontmatter(filename)

    `pandoc -t markdown #{("--filter \"#{filter}\"") if filter} -o "#{tmpfilename}" "#{filename}"`

    `rm "#{filename}"`

    file = File.open(filename, 'w')
    file.print frontmatter.to_yaml
    file.puts "---\n\n"
    file.close

    `cat "#{tmpfilename}" >> "#{filename}"`

    `rm "#{tmpfilename}"`

    `_scripts/replace_hr.sh "#{filename}"`
  end
end

if __FILE__ == $0
  filenames = ARGV

  filenames.each do |filename|
    puts filename
    PandocFilter::pandoc_rewrite(filename)
  end
end
