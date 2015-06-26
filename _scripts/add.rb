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
  contents_element = page.at('article #content-detail-page-of-an-article')
  contents = PandocRuby.convert(contents_element.to_html, :from=>:html, :to=>:markdown)

  return headers.to_yaml + "---\n\n" + contents.chomp('')
end

def get_headers(page)
  url = page.canonical_uri.to_s
  title = page.at('#main-content h1').text
  author = page.at('article .article-header .author p').text.sub(/^By /i,'')
  author_pic = page.at('article .article-header .author img').attributes['src'].to_s
  bio_element = page.at('article .article-header #author-biography')
  author_bio = PandocRuby.convert(bio_element.to_html, :from=>:html, :to=>:markdown)
  prologue = get_prologue(page.at('article #content-detail-page-of-an-article'))
  
  headers = {}
  headers['layout'] = 'chapter'
  headers['title'] = title
  headers['author'] = author
  if author_pic
    headers['author-pic'] = author_pic
  end
  if author_bio
    headers['author-bio'] = author_bio
  end
  if prologue
    headers['prologue'] = prologue
  end
  headers['url'] = url
  return headers
end

def get_prologue(article)
  elements = []
  stuff = article.at('p')
  while (stuff.name == 'p')
    if stuff.children.length > 0
      if stuff.first_element_child.name != 'i'
        return nil
      else
        stuff.first_element_child.replace(stuff.first_element_child.inner_html)
      end
    end
    elements.push(stuff)
    stuff = stuff.next_element
  end
  html = ''
  elements.each do |element|
    html += element.to_html
    element.unlink
  end
  stuff.unlink

  return PandocRuby.convert(html, :from=>:html, :to=>:markdown).chomp('')
end

# Bit nasty, but should do the job
if (ARGV[0])
  #testing(ARGV[0])
  get_story(ARGV[0])
end

