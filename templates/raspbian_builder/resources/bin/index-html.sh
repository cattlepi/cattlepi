#!/bin/sh
echo '<p><b>File listing</b></p>'
echo '<ul>'
sed 's/^.*/<li><a href="&">&<\/a><br\/><\/li>/'
echo '</ul>'
