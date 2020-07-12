#!/bin/sh

[ ! -d /html ] && >&2 echo "error - no /html directory found... exiting" && exit 1
[ ! -d /repositories ] && >&2 echo "error - no /repositories directory found... exiting" && exit 1

cd html/

STAGIT="stagit"
STAGIT_INDEX="stagit-index"
NORMAL_PWD="$PWD""/../repositories/"

# stagit
for folder in $(find ../repositories/ -name "*.git" -exec sh -c 'echo {} | sed "s,.*repositories/,,g" | sed "s,\.git$,,g"' \; | sort | uniq) ; do
  echo -n "building $folder ... "
  mkdir -p "$folder"
  cd "$folder"
  $STAGIT "$NORMAL_PWD""/""$folder"".git"
  cd - >/dev/null
  echo "done"
done

echo
echo

# stagit-index
for folder in $(find ../repositories/ -name "*.git" -exec sh -c 'echo {} | sed "s,.*repositories/,,g" | sed "s,[^/]*\.git$,,g"' \; | sort | uniq) ; do
  echo -n "building index for $folder ... "
  cd "$folder"
  $STAGIT_INDEX "$NORMAL_PWD""$folder"*.git > index.html
  cd - >/dev/null
  echo "done"
done

echo
echo

for folder in $(find . -iname "index.html" -exec sh -c 'echo "{}" | sed "s,[^/]*/index.html,,g"' \; | sort | uniq); do
  echo -n "indexing $folder ... "
  echo '<html><head></head><body><h1>Stagit - Projects</h1><hr><ul>' > "$folder/index.html"

  for subfolder in $(find "$folder" -iname "index.html" -exec sh -c 'echo "{}"' \; | sort | uniq | grep -v '^'"$folder"'index.html$'); do
    subfolder_name=$(echo "$subfolder" | sed 's,^\./,,g' | sed 's,/index.html,,g')
    echo '<li><a href="'"$subfolder"'">'"$subfolder_name"'</a></li>' >> "$folder/index.html"
  done 

  echo '</ul></body></html>' >> "$folder/index.html"
  echo "done"
done

echo
echo

echo -n "set permissions ..."
chmod a+rwx -R *
echo "done"
