#!/bin/bash
# This script returns YES if any file in ORGDIR was created or modified
# after the create date of DESTDIR
#----------------------------------------------------------------------

# Function to check a file or directory
check_file_or_directory() {
    local file="$1"
    #--------------------------------------------------------------------
    # the expansion of "$file/*" will contain an asterisk at the end if
    # $file is an empty directory.  We skip empty directories
    #--------------------------------------------------------------------
    # if [[ "${file}" != "*"* ]]; then
    if [ "${file: -1}" != "*" ]; then
        # Check if the file/directory's modification date is greater than the creation date of "xyz"
        if [[ $(stat -f %B "$file") -gt ${DEST_CREATION_DATE} ]]; then
            echo "YES"
            exit 0
        fi
        # If the file is a directory and is not empty, recursively check its contents
        # if [[ -d "$file" ]] && find "$file" -mindepth 1 -print -quit | grep -q .; then
        if [[ -d "$file" ]];  then
            for f in "$file"/*; do
                check_file_or_directory "$f"
            done
        fi
    fi
}


# Check if exactly two arguments have been provided:  origindir and destdir
if [ $# -ne 2 ]; then
  echo "Error: Please provide exactly two arguments:  ORIGINDIR and DESTDIR"
  exit 1
fi

ORIGDIR=$1
DESTDIR=$2

# Check if ORIGDIR is a directory
if [ ! -d "${ORIGDIR}" ]; then
  echo "Error: ${ORIGDIR} is not a directory"
  exit 1
fi

# Store the creation date of destination directory
DEST_CREATION_DATE=$(stat -f %B "${DESTDIR}")

for file in "${ORIGDIR}"/*; do
    check_file_or_directory "${file}"
done

echo "NO"
