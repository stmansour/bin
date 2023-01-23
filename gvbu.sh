#!/bin/bash
SCRIPT_FULL_PATH="$(readlink -f "$0")"
SCRIPT_PATH="$(dirname "${SCRIPT_FULL_PATH}")"

declare songdir=(
    "Cute Little Lesbians"
    "Living Life"
    "Wall of Love"
)

declare orgdir=(
    "/Volumes/data1/Video Production"
    "/Volumes/data3/Video Production"
    "/Volumes/data3/Video Production"
)

DESTHOME="/Volumes/Plato/Video Production"

usage() {
    cat <<ZZEOF
GRAY video backup script.
Usage:   ./gvbu.sh [OPTIONS]

This is the backup script for GRAY videos.  It gets the date of the last backup
then checks to see if any file in the source directory has been created or modified
since that date.  If so, it makes a backup.  It saves a total of 3 backup versions:
the current backup, the previous backup, and the previous previous backup.

OPTIONS:
-c           Check-Only mode -- this just runs the check to see what directories
             need to be backed up.

Examples:
Command to start ${PROGNAME}:
	bash$  ./gvbu.sh

Command to check what directorys need backup:
	bash$  activate.sh Stop

Command to see if ${PROGNAME} is ready for commands... the response
will be "OK" if it is ready, or something else if there are problems:

    bash$  activate.sh ready
    OK
ZZEOF
}

do_backup() {
    if [ -d "${tmp2}" ]; then
        rm -rf "${tmp2}" || { echo "unable to delete \"${tmp2}\""; ERRORS=$((ERRORS++)); }
    fi
    if [ -d "${tmp1}" ]; then
        mv "${tmp1}" "${tmp2}" || { echo "unable to move \"${tmp1}\" to \"${tmp2}\""; ERRORS=$((ERRORS++)); }
    fi
    if [ -d "${i}" ]; then
        mv "${i}" "${tmp1}" || { echo "unable to move \"${i}\" to \"${tmp1}\""; ERRORS=$((ERRORS++)); }
    fi

    if [ "${CHECKONLY}" != "1" ]; then
        echo "copying..."
        cp -r "${SRCDIR}" . || { echo "unable to copy \"${SRCDIR}\""; ERRORS=$((ERRORS++)); }
    fi
}

cd "${DESTHOME}" || { echo "ERROR: backup directory not found!"; exit 1; }

ERRORS=0
COPIED=0
CHECKONLY=0

while getopts ":c" o; do
    case "${o}" in
       c)
            CHECKONLY=1
            echo "CHECKONLY enabled"
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))


for j in $(seq 0 $(( ${#songdir[@]} -1 )))
do
    i="${songdir[j]}"
    tmp1="${i}1"
    tmp2="${i}2"
    tsrc="${orgdir[j]}"
    SRCDIR="${tsrc}/${i}"
    DESTDIR="${DESTHOME}/${i}"

    # echo "i = ${i}"
    # echo "tmp1 = ${tmp1}"
    # echo "tmp2 = ${tmp2}"
    echo " SRCDIR = ${SRCDIR}"    # this is ORIGINDIR
    echo "DESTDIR = ${DESTDIR}"

    STAT=$("${SCRIPT_PATH}"/needsbkup.sh "${SRCDIR}" "${DESTDIR}")
    case ${STAT} in
    "YES")
        echo "Backing up ${SRCDIR}"
        do_backup
        COPIED=$((COPIED++))
        ;;
    "NO")
        echo "No changes found in ${SRCDIR}"
        ;;
    *)
        echo "Problem with ${SRCDIR}:  ${STAT}"
        ERRORS=$((ERRORS++))
        ;;
    esac
    echo
done

du -sh [A-Za-z]*
echo "Completed"
echo "Directories copied: ${COPIED}"
echo "Errors: ${ERRORS}"
