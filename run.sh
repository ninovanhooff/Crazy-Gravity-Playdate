sourceDir=Source
pdxName=gravityExpress.pdx
pdc "$sourceDir" "$pdxName" || exit
./strip_pdz.sh "$sourceDir" "$pdxName"
open gravityexpress.pdx
