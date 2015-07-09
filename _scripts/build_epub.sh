#!/bin/sh

#zip -X0 "_site/books/${1}.epub" "_site/books/$1/mimetype"
#zip -X9Dr "_site/books/${1}.epub" "_site/books/$1/META-INF" "_site/books/$1/OEBPS"
#echo "zip -X0 \"_site/books/${1}.epub\" \"_site/books/$1/mimetype\""
#echo "zip -X9Dr \"_site/books/${1}.epub\" \"_site/books/$1/META-INF\" \"_site/books/$1/OEBPS\""
#echo "cd \"_site/books/$1\""
#echo "zip -X0 \"../${1}.epub\" mimetype"
#echo "zip -X9Dr \"../${1}.epub\" META-INF OEBPS"
cd "_site/books/$1"
rm "../${1}.epub"
zip -X0 "../${1}.epub" mimetype
zip -X9Dr "../${1}.epub" META-INF OEBPS
