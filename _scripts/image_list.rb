#!/usr/bin/env ruby

require 'yaml'

module ImageList
  def self.image_map
    if !@image_map
      @image_map = YAML.load_file('_data/image_map.yml')
      if @image_map == nil || @image_map == '' then @image_map = {} end
    end
    @image_map
  end

  def self.save_image_map
    file = File.open('_data/image_map.yml', 'w')
    file.puts @image_map.to_yaml
    file.close
  end

  def self.update_image_map(files)
    files.each { |filepath| update_image_map_for_file(filepath) }
    save_image_map
  end

  def self.update_image_map_for_file(filepath)
    result = `pandoc -t json #{filepath} | _scripts/image_list_filter.rb | sed -n 's/^- //p'`
    images = result.split("\n")
    image_map[filepath] = images
  end

  def self.update_changed
    # TODO: this doesn't truly update those files that have changed,
    # only those that have never been indexed.
    files_to_update = Dir.glob("_posts/*") - image_map.keys
    update_image_map(files_to_update)
  end
end

# If running from the command line, assume you want to update the arguments you've sent.
if __FILE__ == $0
  ImageList::update_image_map(ARGV)
end

