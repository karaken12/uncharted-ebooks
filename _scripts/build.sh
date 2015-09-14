
_scripts/build.rb 2>&1 | tee _log/log
cp _log/log _log/log.tmp
_scripts/link_list.rb _posts/* > _log/urls
sed 's/\(.*\)/\L\1/;/^http:\/\/gatherer.wizards.com/d;s/\#.*$//;' _log/urls | sort -u > _log/urls.tmp
