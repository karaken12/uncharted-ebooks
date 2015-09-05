#!/usr/bin/env ruby

require 'yaml'

module PandocFilter

  def self.get_frontmatter(filename, filter = nil)
    frontmatter = YAML.load_file(filename)

    ['author-bio', 'prologue'].each do |key|
      if frontmatter.has_key?(key)
        frontmatter[key] = pandoc_process(frontmatter[key], filter)
      end
    end

    return frontmatter
  end

  def self.pandoc_rewrite(filename, filter = nil)

    tmpfilename = "#{filename}.tmp"

    # First load the YAML frontmatter
    frontmatter = get_frontmatter(filename, filter)

    `pandoc --atx-headers -t markdown-grid_tables-simple_tables+pipe_tables+multiline_tables #{("--filter \"#{filter}\"") if filter} -o "#{tmpfilename}" "#{filename}"`

    `rm "#{filename}"`

    file = File.open(filename, 'w')
    file.print frontmatter.to_yaml
    file.puts "---\n\n"
    file.close

    `cat "#{tmpfilename}" >> "#{filename}"`

    `rm "#{tmpfilename}"`

    `_scripts/replace_hr.sh "#{filename}"`
  end

  def self.pandoc_process(data, filter = nil)
    cmd = "pandoc --atx-headers -t markdown-grid_tables-simple_tables+pipe_tables+multiline_tables #{("--filter \"#{filter}\"") if filter}"
    IO.popen(cmd, 'r+') do |f|
      f.puts(data)
      f.close_write
      f.read # get the data from the pipe
    end
  end

end

if __FILE__ == $0
  filenames = ARGV

  filenames.each do |filename|
    puts filename
    PandocFilter::pandoc_rewrite(filename)
  end
end
