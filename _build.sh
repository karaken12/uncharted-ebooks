
jekyll build \
&& _scripts/build_epub.sh origins \
&& epubcheck _site/books/origins.epub
