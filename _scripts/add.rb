
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

def testing()
  mechanize = Mechanize.new
  page = mechanize.get('http://magic.wizards.com/en/articles/archive/ajanis-vengeance-2014-07-23')
  filename = get_filename(page)
  puts "Filename: #{filename}"
  puts get_file_contents(page)
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

  return headers.to_yaml + "---\n\n" + contents
end

def get_headers(page)
  url = page.canonical_uri.to_s
  title = page.at('#main-content h1').text
  author = page.at('article .article-header .author p').text.sub(/^By /i,'')
  author_pic = page.at('article .article-header .author img').attributes['src'].to_s
  bio_element = page.at('article .article-header #author-biography')
  author_bio = PandocRuby.convert(bio_element.to_html, :from=>:html, :to=>:markdown)
  #prologue = 
  
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
  headers['url'] = url
  #if prologue
  #  headers['prologue'] = prologue
  #end
  return headers
end




testing()
get_story('http://magic.wizards.com/en/articles/archive/uncharted-realms/jaces-origin-absent-minds-2015-06-24')
