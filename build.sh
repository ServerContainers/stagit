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

echo -n "set permissions ..."
chmod a+rwx -R *
echo "done"
