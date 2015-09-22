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

  class BookIndex < Jekyll::Page
    def initialize(site, base, dir, data)
      @site = site
      @base = base
      @dir = dir
      @name = 'index.html'

      self.process(@name)
      self.read_yaml(File.join(base, '_layouts'), 'index.html')

      self.data['book'] = data
    end
  end

  class BookContents < Jekyll::Page
    def initialize(site, base, dir, data)
      @site = site
      @base = base
      @dir = dir
      @name = 'contents.xhtml'

      self.process(@name)
      self.read_yaml(File.join(base, '_layouts'), 'contents.xhtml')

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

  class StaticContent < Jekyll::StaticFile
    # Initialize a new StaticFile.
    #
    # site - The Site.
    # base - The String path to the <source>.
    # dir  - The String path between <source> and the file.
    # name - The String filename of the file.
    def initialize(site, base, dir, name)
      @site = site
      @base = base
      @dir  = dir
      @name = name
    end

    # Returns source file path.
    def path
      File.join(@base, '_static', @name)
    end

    # Returns the source file path relative to the site source
    def relative_path
      @relative_path ||= File.join('_static', @name)
    end
  end

  class MovedPage < Jekyll::Page
    # Initialize a new Page.
    #
    # site - The Site object.
    # base - The String path to the source.
    # dir  - The String path between the source and the file.
    # name - The String filename of the file.
    def initialize(site, base, dir, name, output_url)
      super(site, base, dir, name)
      @output_url = output_url
    end

    def url
      @output_url
    end

  end

  class LinkedContent < Jekyll::StaticFile
    def initialize(site, base, dir, target, link_name)
      @site = site
      @base = base
      @dir = dir
      @name = link_name

      @target = target
    end

    # Returns source file path.
    def path
      File.join(@base, @target)
    end

    # Returns the source file path relative to the site source
    def relative_path
      @relative_path ||= File.join(@dir, @target)
    end

    # Write the static file to the destination directory (if modified).
    #
    # dest - The String path to the destination dir.
    #
    # Returns false if the file was not modified since last time (no-op).
    def write(dest)
      dest_path = destination(dest)

      return false if File.exist?(dest_path) and !modified?
      @@mtimes[path] = mtime

      FileUtils.mkdir_p(File.dirname(dest_path))
      FileUtils.rm(dest_path) if File.exist?(dest_path)
      FileUtils.ln(path, dest_path)

      true
    end

  end


  class Generator < Jekyll::Generator
    def generate(site)
      def get_format(ext)
        if ext == ".png" then return "image/png" end
        if ext == ".jpg" then return "image/jpeg" end
        false
      end
      image_data = YAML.load_file('_data/image_map.yml')
      site.posts.each do |post|
        post.data['images'] = image_data["_posts/#{post.name}"]
      end

      site.categories.each do |name, posts|
        data = site.data['books'][name]
        if !data
          puts "Could not generate book #{name}: no data!"
          next
        end
        data['name'] = name
        data['posts'] = posts.reverse
        book_dir = File.join('books',name)
        images = []

        site.static_files << StaticContent.new(site, site.source, book_dir, 'mimetype')
        site.static_files << StaticContent.new(site, site.source, File.join(book_dir, 'META-INF'), 'container.xml')
        site.static_files << StaticContent.new(site, site.source, File.join(book_dir, 'OEBPS', 'styles'), 'page-template.xpgt')

        # Get all the images used by the stories in this book.
        posts.each.map{|post| post.data['images']}.compact.flatten.uniq.each do |image|
          images.push( {
            'href'   => image,
            'format' => get_format(File.extname(image))
          })
          filename = image.gsub(/^images\//,'')
          link_name = File.join(book_dir, 'OEBPS', 'images', filename)
          target = File.join('_images', 'grayscale', filename)
          site.static_files << LinkedContent.new(site, site.source, File.join(book_dir, 'OEBPS', 'images'), target, filename)
        end
        images = images.uniq
        images.each_with_index{|image,index| image['id'] = "img#{index}"}

        chapters = posts.sort{|x,y| x.date <=> y.date}.map do |post|
          { 'id'    => post.slug,
            'title' => post.title,
            'src'   => post.url.sub(/^\/books\/#{name}\/OEBPS\//,'')
          }
        end
        authors = posts.map{|post| post.data['author']}.sort
        authors.unshift("The Magic Creative Team")
        data['chapters'] = chapters
        data['authors'] = authors.uniq
        data['images'] = images
        # TODO: add the Title page onto the front of the chapter list
        site.pages << BookToc.new(site, site.source, File.join(book_dir, 'OEBPS'), data)
        site.pages << BookIndex.new(site, site.source, book_dir, data)
        site.pages << BookContents.new(site, site.source, File.join(book_dir, 'OEBPS'), data)
        site.pages << BookContentOpf.new(site, site.source, File.join(book_dir, 'OEBPS'), data)
        site.pages << MovedPage.new(site, site.source, '/css', 'main.scss', File.join(book_dir, 'OEBPS', 'styles', 'main.css'))
      end
    end
  end
end
