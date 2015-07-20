#!/usr/bin/env ruby

def build_site
  # First things first...
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
  return system("_scripts/build_epub.sh #{book_name}")
end

def check_epub(book_name)
  return system("epubcheck _site/books/#{book_name}.epub")
end

build_site
