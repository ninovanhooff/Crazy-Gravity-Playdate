sourceDir=Source

# Get Game name from pdxinfo and remove whitespace. pdutil cannot run files with whitespace in them
pdxName="$(cat Source/pdxinfo | grep name | cut -d "=" -f 2- | sed '/^$/d;s/[[:blank:]]//g').pdx"

pdc -q "$sourceDir" "$pdxName" || exit
./strip_pdz.sh "$sourceDir" "$pdxName"
open $pdxName
