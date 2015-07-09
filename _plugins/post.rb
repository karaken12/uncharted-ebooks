
# Patch Jekyll::Post to allow 'xhtml' as an extension

module Jekyll
  class Post
    # Obtain destination path.
    #
    # dest - The String path to the destination dir.
    #
    # Returns destination file path String.
    def destination(dest)
      # The url needs to be unescaped in order to preserve the correct filename
      path = site.in_dest_dir(dest, URL.unescape_path(url))
      path
    end
  end
end
