#!/usr/bin/env ruby

require 'yaml'

module LinkList
#  def self.link_map
#    if !@link_map
#      @link_map = YAML.load_file('_data/link_map.yml')
#      if @link_map == nil || @link_map == '' then @link_map = {} end
#    end
#    @link_map
#  end
#
#  def self.save_link_map
#    file = File.open('_data/link_map.yml', 'w')
#    file.puts @link_map.to_yaml
#    file.close
#  end

  def self.update_link_map(files)
    files.each { |filepath| update_link_map_for_file(filepath) }
#    save_image_map
  end

  def self.update_link_map_for_file(filepath)
    result = `pandoc -t json #{filepath} | _scripts/link_list_filter.rb | sed -n 's/^- //p'`
    urls = result.split("\n")
    puts urls
    #image_map[filepath] = images
  end

end

# If running from the command line, assume you want to update the arguments you've sent.
if __FILE__ == $0
  LinkList::update_link_map(ARGV)
end

