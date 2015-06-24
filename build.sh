jekyll build
# See https://puppetlabs.com/blog/automated-ebook-generation-convert-markdown-epub-mobi-pandoc-kindlegen for more info
mkdir -p _site/files
pandoc -o _site/files/ebook.epub _site/2015/06/10/chandras-origin-fire-logic.html _site/2015/06/17/lilianas-origin-fourth-pact.html
