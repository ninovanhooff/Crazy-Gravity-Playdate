until ls /dev/cu.usbmodemPD*
do
  echo "Playdate not found. Is it connected to USB and unlocked?"
  sleep 1
done

PDUTIL_DEVICE="$(ls /dev/cu.usbmodemPD* | head -n 1)"
echo "device $PDUTIL_DEVICE"


# Get Game name from pdxinfo and remove whitespace. pdutil cannot run files with whitespace in them
PRODUCT="$(cat Source/pdxinfo | grep name | cut -d "=" -f 2- | sed '/^$/d;s/[[:blank:]]//g').pdx"

echo "Compiling C projects and libs"
make device

echo "PDUTIL_DEVICE ${PDUTIL_DEVICE}"
echo "PRODUCT ${PRODUCT}"
pdc Source "${PRODUCT}"
pdutil "${PDUTIL_DEVICE}" datadisk

echo "Waiting for Data Disk to be mounted ... "
until [ -d /Volumes/PLAYDATE/GAMES ]
do
     sleep 1
done
echo "Game Dir mounted"

# Only copy files with changed file sizes. To copy all files, remove "--size-only"
rsync -zarv --size-only --prune-empty-dirs "${PRODUCT}" "/Volumes/PLAYDATE/Games/"
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
