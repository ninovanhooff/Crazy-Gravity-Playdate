# Get Game name from pdxinfo and remove whitespace. pdutil cannot run files with whitespace in them
PRODUCT="$(cat Source/pdxinfo | grep name | cut -d "=" -f 2- | sed '/^$/d;s/[[:blank:]]//g').pdx"
echo "PRODUCT ${PRODUCT}"

# Put device in data disk mode
until ls /dev/cu.usbmodemPD*
do
  echo "Playdate not found. Is it connected to USB and unlocked?"
  sleep 1
done
PDUTIL_DEVICE="$(ls /dev/cu.usbmodemPD* | head -n 1)"
echo "device $PDUTIL_DEVICE"
pdutil "${PDUTIL_DEVICE}" datadisk

echo "Compiling C projects and libs"
make device
pdc Source "${PRODUCT}"

echo "Waiting for Data Disk to be mounted ... "
until [ -d /Volumes/PLAYDATE/GAMES ]
do
     sleep 1
done
echo "Game Dir mounted"
#echo "Input anything to continue"
#trap 'tput setaf 1;tput bold;echo $BASH_COMMAND;read;tput init' DEBUG

# Only copy files with changed file sizes. To copy all files, remove "--size-only"
rsync -zarvi --size-only --prune-empty-dirs "${PRODUCT}" "/Volumes/PLAYDATE/Games/"
MOUNT_DEVICE="$(diskutil list | grep PLAYDATE | grep -oE '[^ ]+$')"
diskutil unmount "${MOUNT_DEVICE}"
diskutil eject PLAYDATE

echo "Waiting for USB Device to be mounted ... "
until ls "${PDUTIL_DEVICE}"
do
     sleep 1
done
echo "Usb Device Connected"

# run
echo "Running ${PRODUCT}"
pdutil "${PDUTIL_DEVICE}" run "/Games/${PRODUCT}"
