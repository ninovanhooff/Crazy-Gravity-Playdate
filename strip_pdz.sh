#!/bin/sh

invokeDir=$(pwd)
sourceDir="$1"
pdxPath="$2"
pdxDir="$invokeDir/$pdxPath"

cd "$sourceDir" || exit

grep -r '^import' . | while read -r line ; do
  # echo "hello $line"
  matchFilePath=$(echo "$line" | sed -r 's/(.*)\:.*$/\1/')
  matchDirPath=$(echo "$matchFilePath" | sed -r 's/(.*)\/.*.lua$/\1/')
  pdzName=$(echo "$line" | sed -r 's/.*import \"(.*)\"$/\1/')
  pdzName=$(echo "$pdzName" | sed -r 's/(.*).lua$/\1/') || "$pdzName" # strip .lua if found
  # echo "pdzName $pdzName"
  pdzPath="$invokeDir/$pdxPath/$matchDirPath/$pdzName.pdz"
  if [ -f "$pdzPath" ] ; then # file may not exist when it was deleted in the same run. imports for the same file may be found in multiple source files
      echo "DELETE $pdzPath"
      rm "$pdzPath"
  fi
done

unitTestsPath="$pdxDir/lua/unittests.pdz"
if [ -f "$unitTestsPath" ] ; then
    echo "DELETE $unitTestsPath"
    rm "$unitTestsPath"
fi

# Remove empty directories
find "$pdxDir" -type d -empty -delete
