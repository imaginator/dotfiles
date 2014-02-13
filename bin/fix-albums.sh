#!/bin/sh
# Fix the photo albums
set -x
find ~simon/public_html/albums -type f -name .DS_Store    -ls -exec rm {} \;
find ~simon/public_html/albums -type f -name ._dscn\*     -ls -exec rm {} \;
find ~simon/public_html/albums -type f -name \*Thumbs\*   -ls -exec rm {} \;
find ~simon/public_html/albums -type f -name ._\*         -ls -exec rm {} \;
find ~simon/public_html/albums -type f                        -exec chmod 644 {} \;
find ~simon/public_html/albums -type d                        -exec chmod 755 {} \;
