#!/usr/bin/env ruby

require 'yaml'
require 'pandoc-filter'
require 'uri'

next_image = nil
PandocFilter.filter do |type, value, format, meta|
#if type == 'Div'
#puts "Div: #{value}"
#end
  if next_image != nil
    # Create an array of the image element and this element.
    image_para = PandocElement.Para([next_image,PandocElement.Str('')])
    this_element = {'t'=>type, 'c'=>value}
    elmnt = nil
    if type == 'Para'
      # If this element is actually a paragraph, then wrap both in a Div
      elmnt = PandocElement.Div(['',['figure'],[]], [image_para, this_element])
    else
      # Otherwise, just wrap the figure in a Div.
      elmnt = [PandocElement.Div(['',['figure'],[]], [image_para]), this_element]
    end
    next_image = nil
    elmnt
  else
    if type == 'Para'
#puts "Para: #{value}"
      def onechild(array, type)
        return array.length == 1 && array[0]['t'] == type
      end
      # If only contains one child, and that child is an image,
      # OR it only contains one child and that child is a link, which only contains one child and that child is an image
      if onechild(value, 'Image') then
        #PandocElement.Para([])
#        puts value[0]
#        puts PandocElement.Image(value[0]['c'][0],value[0]['c'][1])
        #PandocElement.Image(value[0]['c'][0], value[0]['c'][1])
#        PandocElement.Div(['',['figure'],[]],[PandocElement.Image(value[0]['c'][0], value[0]['c'][1])])
        #PandocElement.Div(['',['figurexxx'],[]],[PandocElement.Para([value[0],value[0]])])
        #PandocElement.Para([value[0], PandocElement.Str('')])
        # For some reason, it seems to prepend "fig:" on to the title text.
        next_image = value[0]
#puts "n: #{next_image}"
#puts "n: #{next_image['c']}"
#puts "n: #{next_image['c'][1]}"
#puts "n: #{next_image['c'][1][1]}"
        next_image['c'][1][1] = next_image['c'][1][1][4..-1]
        PandocElement.Null
      elsif onechild(value, 'Link') && onechild(value[0]['c'][0], 'Image') then
        next_image = value[0]
        # For some reason. this doesn't seem to happen!
        #next_image['c'][0][0]['c'][1][1] = next_image['c'][0][0]['c'][1][1][4..-1]
        elmnt = PandocElement.Div(['',['figure'],[]], [PandocElement.Para([next_image,PandocElement.Str('')])])
        next_image = nil
        elmnt
      end
    end
  end
#  if type == 'Image'
#    url = value[1][0]
#    # Only care about remote URLs
#    if !url.start_with?('http')
#      if url.start_with?('/')
#        # Prepend the original URL data...
##        url = URI.join(meta['original-url']['c'][0]['c'], url).to_s
#      else
#        # Don't know how to handle it, so just go onto the next one
#        next
#      end
 #   end
#
#    id = nil
#    if image_data.has_key?(url)
#      id = image_data[url]
#    else
#      while (id == nil || image_data.has_value?(id))
#        id = ('a'..'z').to_a.shuffle[0,8].join
#      end
#      ext = File.extname(URI.parse(url).path)
#      if ext == '.ashx' then ext = '.jpeg' end
#      id = "#{id}#{ext}"
#      image_data[url] = id
#    end
#
#    new = value[1]
#    new[0] = File.join("images", id)
#    PandocElement.Image(value[0], new)
#  end
end
