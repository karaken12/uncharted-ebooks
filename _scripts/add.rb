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

def testing(url)
  mechanize = Mechanize.new
  page = mechanize.get(url)
  filename = get_filename(page)
  puts "Filename: #{filename}"
  puts get_headers(page).to_yaml
  contents = get_contents(page)
end

def get_story(url)
  mechanize = Mechanize.new
  page = mechanize.get(url)
  filename = '_posts/' + get_filename(page)
  contents = get_file_contents(page)
  file = File.open(filename, 'w')
  file.puts contents
  file.close
end

def get_filename(page)
  title = page.canonical_uri.path.split('/').last
  matches = /^(.*)-(\d\d\d\d-\d\d-\d\d)/.match(title)
  return matches[2] + '-' + matches[1] + '.markdown'
end

def get_file_contents(page)
  headers = get_headers(page)
  contents = get_contents(page)
  return headers.to_yaml + "---\n\n" + contents.chomp('')
end

def get_contents(page)
  contents_element = page.at('article #content-detail-page-of-an-article')
  # Remove traling stuff if it exists
  remove_trailers(contents_element)
  return PandocRuby.convert(contents_element.to_html, :from=>:html, :to=>:markdown)
end

def remove_trailers(contents)
  keep_going = true
  while(keep_going)
    keep_going = false
    last = contents.last_element_child
    if last.name == 'p'
      if last.children.length == 0
        # An empty paragraph; unlink and continue
        last.unlink
        keep_going = true
      else
        if last.content == "Find more official Magic fiction on the Uncharted Realms page."
          last.unlink
          keep_going = true
        end
      end
    elsif last.name == 'hr'
      last.unlink
      keep_going = true
    end
  end
end

def get_headers(page)
  url = page.canonical_uri.to_s
  title = page.at('#main-content h1').text.chomp('')
  author = page.at('article .article-header .author p').text.sub(/^By /i,'').chomp('')
  author_pic = page.at('article .article-header .author img').attributes['src'].to_s.chomp('')
  bio_element = page.at('article .article-header #author-biography')
  author_bio = PandocRuby.convert(bio_element.to_html, :from=>:html, :to=>:markdown).chomp('')
  prologue = get_prologue(page.at('article #content-detail-page-of-an-article'))
  
  headers = {}
  headers['layout'] = 'chapter'
  headers['title'] = title
  headers['author'] = author
  if author_pic != ''
    headers['author-pic'] = author_pic
  end
  if author_bio != ''
    headers['author-bio'] = author_bio + "\n"
  end
  if prologue != nil && prologue != ''
    headers['prologue'] = prologue + "\n"
  end
  headers['url'] = url
  return headers
end

def get_prologue(article)
  elements = []
  committed = []
  stuff = article.at('p')
  while true
    if stuff.name == 'p'
      if stuff.children.length > 0
        child = stuff.first_element_child
        if child == nil || (child.name != 'i' && child.name != 'em')
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

def de_italic(element)
  if element.name != 'p' || element.children.length == 0 || element.first_element_child == nil
    return element
  end
  child = element.first_element_child
  if child.name != 'i' && child.name != 'em'
    return element
  else
    child.replace(child.inner_html)
    return element
  end
end

if __FILE__==$0
  # Bit nasty, but should do the job
  if (ARGV[0])
    #testing(ARGV[0])
    get_story(ARGV[0])
  end
end
