#!/bin/sh

invokeDir=$(pwd)
sourceDir="./Source"
pdxPath="./gravityexpress.pdx"

cd "$sourceDir" || exit

grep -r '^import' . | while read -r line ; do
  echo "hello $line"
  matchFilePath=$(echo "$line" | sed -r 's/(.*)\:.*$/\1/')
  matchDirPath=$(echo "$matchFilePath" | sed -r 's/(.*)\/.*.lua$/\1/')
  pdzName=$(echo "$line" | sed -r 's/.*import \"(.*)\"$/\1/')
  pdzPath="$invokeDir/$pdxPath/$matchDirPath/$pdzName.pdz"
  echo "DELETE $pdzPath"
  rm "$pdzPath"
done
