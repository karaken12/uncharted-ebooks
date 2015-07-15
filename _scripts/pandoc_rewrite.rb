#!/usr/bin/env ruby

require 'yaml'

module PandocFilter

  def self.pandoc_rewrite(filename, filter = nil)

    tmpfilename = "#{filename}.tmp"
    # First load the YAML frontmatter
    frontmatter = YAML.load_file(filename)

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
