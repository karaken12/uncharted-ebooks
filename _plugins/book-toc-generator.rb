module Uncharted
  class BookToc < Jekyll::Page
    def initialize(site, base, dir, data)
      @site = site
      @base = base
      @dir = dir
      @name = 'toc.ncx'

      self.process(@name)
      self.read_yaml(File.join(base, '_layouts'), 'toc.ncx')


      self.data['book'] = data
    end
  end

  class BookContentOpf < Jekyll::Page
    def initialize(site, base, dir, data)
      @site = site
      @base = base
      @dir = dir
      @name = 'content.opf'

      self.process(@name)
      self.read_yaml(File.join(base, '_layouts'), 'content.opf')

      self.data['book'] = data
    end
  end

  class StaticContent < Jekyll::Page
    def initialize(site, base, dir, file_name)
      @site = site
      @base = base
      @dir = dir
      @name = file_name
      self.process(@name)
      self.read_yaml(File.join(base, '_static'), file_name)
    end
  end

  class Generator < Jekyll::Generator
    def generate(site)
      site.categories.each do |name, posts|
        book_dir = File.join('books',name)
        data = site.data['books'][name]
        chapters = posts.sort{|x,y| x.date <=> y.date}.map do |post|
          { 'id'    => post.slug,
            'title' => post.title,
            'src'   => post.url.sub(/^\/books\/origins\/OEBPS\//,'')
          }
        end
        authors = posts.map{|post| post.data['author']}.sort
        authors.unshift("The Magic Creative Team")
        data['chapters'] = chapters
        data['authors'] = authors.uniq
        # TODO: add the Title page onto the front of the chapter list
        site.pages << StaticContent.new(site, site.source, book_dir, 'mimetype')
        site.pages << StaticContent.new(site, site.source, File.join(book_dir, 'META-INF'), 'container.xml')
        site.pages << BookToc.new(site, site.source, File.join(book_dir, 'OEBPS'), data)
        site.pages << BookContentOpf.new(site, site.source, File.join(book_dir, 'OEBPS'), data)
      end
    end
  end
end
