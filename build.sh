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

  CHECK_FILE="log.html"

  GIT_DATE_ISO=$(git --git-dir="$NORMAL_PWD""/""$folder"".git/.git" log -n1 --date=iso | grep 'Date:' | tr ' ' '\n' | grep '^[0-9][0-9]' | tr '\n' ' ')
  GIT_DATE_SECONDS=$(date -d "$GIT_DATE_ISO" +%s)

  LOG_DATE_ISO=$(stat "$CHECK_FILE" | grep Modify | sed 's/\..*$//g' | sed 's/^[^0-9]*//g')
  LOG_DATE_SECONDS=$(date -d "$LOG_DATE_ISO" +%s)

  if [ ! -f "$CHECK_FILE" ] || [ $GIT_DATE_SECONDS -gt $LOG_DATE_SECONDS ]; then
    $STAGIT "$NORMAL_PWD""/""$folder"".git"
  else
    echo "  skipped stagit (git: $GIT_DATE_ISO, last generation: $LOG_DATE_ISO)"
  fi
  
  cd - >/dev/null
  echo "done"
done

echo
echo

# stagit-index
for folder in $(find ../repositories/ -name "*.git" -exec sh -c 'echo {} | sed "s,.*repositories/,,g" | grep -v '/.git' | sed "s,[^/]*\.git$,,g"' \; | sort | uniq) ; do
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
