#!/bin/sh

invokeDir=$(pwd)
sourceDir="$1"
pdxPath="$2"
pdxDir="$invokeDir/$pdxPath"

function removeIfExists() {
    if [ -f "$1" ] ; then
        echo "DELETE $1"
        rm "$1"
    fi
}

cd "$sourceDir" || exit

grep -r '^import' . | while read -r line ; do
  # echo "hello $line"
  matchFilePath=$(echo "$line" | sed -r 's/(.*)\:.*$/\1/')
  matchDirPath=$(echo "$matchFilePath" | sed -r 's/(.*)\/.*.lua$/\1/')
  pdzName=$(echo "$line" | sed -r 's/.*import \"(.*)\"$/\1/')
  pdzName=$(echo "$pdzName" | sed -r 's/(.*).lua$/\1/') || "$pdzName" # strip .lua if found
  # echo "pdzName $pdzName"
  pdzPath="$invokeDir/$pdxPath/$matchDirPath/$pdzName.pdz"
  # file may not exist when it was deleted in the same run. imports for the same file may be found in multiple source files
  removeIfExists "$pdzPath"
done

unitTestsPath="$pdxDir/lua/unittests.pdz"
removeIfExists "$unitTestsPath"

# temp level files created by GravityExpressLevelEditor
removeIfExists "$pdxDir/levels/temp.bin"
removeIfExists "$pdxDir/levels/temp.pdz"

# Remove empty directories
find "$pdxDir" -type d -empty -delete
