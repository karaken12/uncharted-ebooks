
#--
# Copyright (C) 2015 Tom Potts
# Footnote code modifed from kramdown code.
# This file is licensed under the MIT.
#
# Kramdown:
# Copyright (C) 2009-2015 Thomas Leitner <t_leitner@gmx.at>
#++
#


module Kramdown
  class Converter::Xhtml < Converter::Html
      def convert_footnote(el, indent)
        repeat = ''
        if (footnote = @footnotes_by_name[el.options[:name]])
          number = footnote[2]
          repeat = ":#{footnote[3] += 1}"
        else
          number = @footnote_counter
          @footnote_counter += 1
          @footnotes << [el.options[:name], el.value, number, 0]
          @footnotes_by_name[el.options[:name]] = @footnotes.last
        end
        "<sup id=\"fnref-#{el.options[:name]}#{repeat}\"><a href=\"#fn-#{el.options[:name]}\" class=\"footnote\">#{number}</a></sup>"
      end

      FOOTNOTE_BACKLINK_FMT = "%s<a href=\"#fnref-%s\" class=\"reversefootnote\">%s</a>"

      # Return a HTML ordered list with the footnote content for the used footnotes.
      def footnote_content
        ol = Element.new(:ol)
        ol.attr['start'] = @footnote_start if @footnote_start != 1
        i = 0
        while i < @footnotes.length
          name, data, _, repeat = *@footnotes[i]
          li = Element.new(:li, nil, {'id' => "fn-#{name}"})
          li.children = Marshal.load(Marshal.dump(data.children))

          if li.children.last.type == :p
            para = li.children.last
            insert_space = true
          else
            li.children << (para = Element.new(:p))
            insert_space = false
          end

          para.children << Element.new(:raw, FOOTNOTE_BACKLINK_FMT % [insert_space ? ' ' : '', name, "&#8617;"])
          (1..repeat).each do |index|
            para.children << Element.new(:raw, FOOTNOTE_BACKLINK_FMT % [" ", "#{name}-#{index}", "&#8617;<sup>#{index+1}</sup>"])
          end

          ol.children << Element.new(:raw, convert(li, 4))
          i += 1
        end
        (ol.children.empty? ? '' : format_as_indented_block_html('div', {:class => "footnotes"}, convert(ol, 2), 0))
      end
  end
end
