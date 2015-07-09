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
      book_dir = 'books/origins'
      data = {
        'uid' => 'b1bda1ee-2567-11e5-b345-feff819cdc9f',
        'title' => 'Uncharted Realms: Magic Origins',
        'authors' => [ "The Magic Creative Team", "Jenna Helland", "Doug Beyer", "James Wyatt", "Kelly Digges", "Ari Levitch" ],
        'rights' => "Copyright Wizards of the Coast, all rights reserved.",
        'publisher' => "Wizards of the Coast",
        'chapters' => [
          { 'id'    => 'magic-origins-new-era',
            'title' => 'Magic Origins: A New Era',
            'src'   => "2015-06-03-magic-origins-new-era.xhtml" },
          { 'id'    => "chandras-origin-fire-logic",
            'title' => "Chandra's Origin: Fire Logic",
            'src'   => "2015-06-10-chandras-origin-fire-logic.xhtml" },
          { 'id'    => "lilians-origin-fourth-pact",
            'title' => "Liliana's Origin: The Fourth Pact",
            'src'   => "2015-06-17-lilianas-origin-fourth-pact.xhtml" },
          { 'id'    => "jaces-origin-absent-minds",
            'title' => "Jace's Origin: Absent Minds",
            'src'   => "2015-06-24-jaces-origin-absent-minds.xhtml" },
          { 'id'    => "gideons-origin-kytheon-iora-akros",
            'title' => "Gideon's Origin: Kytheon Iora of Akros",
            'src'   => "2015-07-01-gideons-origin-kytheon-iora-akros.xhtml" }
        ]
      }
      # TODO: add the Title page onto the front of the chapter list
      site.pages << StaticContent.new(site, site.source, book_dir, 'mimetype')
      site.pages << StaticContent.new(site, site.source, book_dir + '/META-INF', 'container.xml')
      site.pages << BookToc.new(site, site.source, book_dir + '/OEBPS', data)
      site.pages << BookContentOpf.new(site, site.source, book_dir + '/OEBPS', data)
    end
  end
end
