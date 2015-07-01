#!/usr/bin/env ruby

require 'yaml'
require 'pandoc-ruby'
require 'mechanize'

# Ask for Uncharted Realms story URL
# From the URL, work out the URL we'll use
# Use the contents of article .content-detail-page-of-an-article as the content
# Use PanDoc to translate from HTML to Markdown
# Prepend the Markdown with header details:
#   layout: chapter
#   title: {text contents of #main-content h1:first-of-type}
#   author: {text contents of article .article-header .author p:first-of-type}
#   author-pic: {src of article .article-header .author img:first-of-type}
#   author-bio: {html contents of article .article-header #author-biography p}
#   prologue: {not always present, and within the content when it exists}

module OldMagicArticleScraper

  def self.get_story(url)
    mechanize = Mechanize.new
    page = mechanize.get(url)
    headers = get_headers(page)
    filename = '_posts/' + get_filename(headers)
    contents = get_file_contents(headers, get_contents(page))
    file = File.open(filename, 'w')
    file.puts contents
    file.close
  end

  def self.testing(url)
    mechanize = Mechanize.new
    page = mechanize.get(url)
    headers = get_headers(page)
    filename = '_posts/' + get_filename(headers)
    puts "URL: #{url}"
    puts "Filename: #{filename}"
    #puts headers
    puts get_file_contents(headers, get_contents(page))
  end

  def self.get_filename(headers)
    slug = headers['title'].downcase.gsub(/[^ a-z0-9]/,'').gsub(' ','-')
    return "#{headers['date']}-#{slug}.markdown"
  end

  def self.get_file_contents(headers, contents)
    return headers.to_yaml + "---\n\n" + contents.chomp('')
  end

  def self.get_contents(page)
    contents_element = page.at('#content .article-content')
    # Remove traling stuff if it exists
    remove_trailers(contents_element)
    # Do a little rewriting to allow Pandoc to read the markup.
    # Change Javascript card links to regular links
    contents_element.search('a.nodec').each do |a_el|
      href = "http://gatherer.wizards.com/Pages/Card/Details.aspx?#{a_el['keyname']}=#{a_el['keyvalue'].gsub('_','+')}"
      #a_el.replace("<a href=\"#{href}\">#{a_el.inner_html}</a>")
      a_el['href'] = href
    end
    # Remove the dropcap
    contents_element.search('img').each do |img_el|
      match = img_el['src'].match(/\/magic\/images\/dropcap_(.)\.jpg/)
      if match
        img_el.replace(match[1])
      end
    end
    # No need for breaks after an hr
    contents_element.search('hr').each do |hr_el|
      next_el = hr_el.next
      while (next_el)
        if next_el.element? && next_el.name == 'br'
          to_remove = next_el
          next_el = next_el.next
          to_remove.unlink
          next
        elsif next_el.text? && next_el.text.strip == ''
          next_el = next_el.next
          next
        else
          break
        end
      end
    end
    #contents_element.search('ul').each do |ul_el|
    #  if ul_el.first_element_child && ul_el.first_element_child.name == 'li'
    #  else
    #    ul_el.name = 'p'
    #  end
    #end
    #contents_element.search('pre').each do |pre_el|
    #  if pre_el.first_element_child && pre_el.first_element_child.name == 'img'
    #    pre_el.replace(pre_el.inner_html)
    #  end
    #end
    return PandocRuby.convert(contents_element.to_html, :from=>:html, :to=>:markdown)
  end

  def self.remove_trailers(contents)
    # Very crude: just drop everything after the last HR
    keep_going = true
    while(keep_going)
      last = contents.last_element_child
      if last.name == 'hr'
        keep_going = false
      end
      last.unlink
    end
  end

  def self.get_headers(page)
    description = page.at('#content .description')
    title = description.at('h4').text.strip

    author = nil
    date = nil
    author_and_date = description.at('h5.byline')
    author_and_date.children.each do |child|
      if child.text?
        if !author
          author = child.text.strip
        elsif !date
          date = Date.parse(child.text)
          break
        end
      end
    end

    author_pic_e = page.at('#content .author-image img')
    if author_pic_e
      author_pic = URI(author_pic_e.attributes['src'])
      # Slightly hacky
      author_pic.scheme = "http"
      author_pic.host = "archive.wizards.com"
      author_pic = author_pic.to_s
    end

    bio_e = page.at('article .article-header #author-biography')
    if bio_e
      author_bio = PandocRuby.convert(bio_e.to_html, :from=>:html, :to=>:markdown).strip
    end

    #prologue = get_prologue(page.at('article #content-detail-page-of-an-article'))
    
    headers = {}
    headers['layout'] = 'chapter'
    headers['title'] = title
    if date && date != ''
      headers['date'] = date
    end
    if author && author != ''
      headers['author'] = author
    end
    if author_pic && author_pic != ''
      headers['author-pic'] = author_pic
    end
    if author_bio && author_bio != ''
      headers['author-bio'] = author_bio + "\n"
    end
    #if prologue && prologue != ''
    #  headers['prologue'] = prologue + "\n"
    #end
    headers['original-url'] = page.uri.to_s
    return headers
  end

  def self.get_prologue(article)
    elements = []
    committed = []
    stuff = article.at('p')
    while true
      if !stuff then break end
      if stuff.name == 'p'
        if stuff.children.length > 0
          child = stuff.children.first
          if !(child.element?) || (child.name != 'i' && child.name != 'em' && child.name != 'img')
            break
          end
        end
      end
      elements.push(stuff)
      if stuff.name == 'hr'
        committed.concat(elements)
        elements = []
      end
      stuff = stuff.next_element
    end

    if committed.length == 0
      return nil
    end

    elements = []
    committed.each do |element|
      elements.push(de_italic(element))
    end

    # Get rid of a trailing hr
    elements.reverse.each do |element|
      if element.name == 'hr' || (element.name == 'p' && element.children.length == 0)
        element.unlink
        elements.pop
      else
        break
      end
    end

    html = ''
    elements.each do |element|
      html += element.to_html
      element.unlink
    end

    return PandocRuby.convert(html, :from=>:html, :to=>:markdown).chomp('')
  end

  def self.de_italic(element)
    if element.children.length == 0 || element.first_element_child == nil
      return element
    end
    element.children.each do |child|
      if child.element?
        if child.name == 'i' || child.name == 'em'
          child.replace(child.inner_html)
        else
          de_italic(child)
        end
      elsif child.text?
        if child.inner_text.strip.length > 0
          # Peversely, we actually want to emphasise this.
          child.replace('<em>'+child.inner_text+'</em>')
        end
      end
    end
    return element
  end

end
