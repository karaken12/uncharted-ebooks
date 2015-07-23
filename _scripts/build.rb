#!/usr/bin/env ruby

require_relative('image_list')

def build_site
  # First things first...
  # Update the image map for those files that need it.
  ImageList::update_changed
  # Now actually build the data.
  if system('jekyll build') == false
    puts "Failed to build site; aborting."
  else
    Dir.glob('_site/books/*').each do |path|
      book_name = File.basename(path)
      puts "===\nBuilding book #{book_name}"
      build_book(book_name)
    end
  end
end

def build_book(book_name)
  if make_epub(book_name)
    check_epub(book_name)
  else
    puts "Failed to build book #{book_name}"
  end
end

def make_epub(book_name)
  Dir.chdir("_site/books/#{book_name}") do
    file_name = "../#{book_name}.epub"
    if File.exist?(file_name)
      File.delete(file_name)
    end
    `zip -qX0 "#{file_name}" mimetype`
    `zip -qX9Dr "#{file_name}" META-INF OEBPS`
  end
end

def check_epub(book_name)
  return system("epubcheck _site/books/#{book_name}.epub")
end

build_site
