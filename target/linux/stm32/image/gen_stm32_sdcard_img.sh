#!/bin/sh
# Copyright (C) 2024 Bootlin

set -ex
[ $# -eq 8 ] || {
    echo "SYNTAX: $0 <file> <fsbl> <fip> <bootfs image> <rootfs image> <env size> <bootfs size> <rootfs size>"
    exit 1
}

OUTPUT="${1}"
FSBL="${2}"
FIP="${3}"
BOOTFS="${4}"
ROOTFS="${5}"
ENVSIZE="$((${6} / 1024))"
BOOTFSSIZE="${7}"
ROOTFSSIZE="${8}"

set $(ptgen -o "${OUTPUT}" -g -a 5 -l 2048 -G ${GUID} -N fsbl1 -p 2M -N fsbl2 -p 2M -N fip -p 2M -N u-boot-env -p "${ENVSIZE}" -N boot -p${BOOTFSSIZE}M -N rootfs -p ${ROOTFSSIZE}M)
FSBL1OFFSET="$((${1} / 512))"
FSBL1SIZE="$((${2} / 512))"
FSBL2OFFSET="$((${3} / 512))"
FSBL2SIZE="$((${4} / 512))"
FIPOFFSET="$((${5} / 512))"
FIPSIZE="$((${6} / 512))"
ENVOFFSET="$((${7} / 512))"
ENVSIZE="$((${8} / 512))"
BOOTFSOFFSET="$((${9} / 512))"
BOOTFSSIZE="$((${10} / 512))"
ROOTFSOFFSET="$((${11} / 512))"
ROOTFSSIZE="$((${12} / 512))"

dd bs=512 if="${FSBL}" of="${OUTPUT}" seek="${FSBL1OFFSET}" conv=notrunc
dd bs=512 if="${FSBL}" of="${OUTPUT}" seek="${FSBL2OFFSET}" conv=notrunc
dd bs=512 if="${FIP}"  of="${OUTPUT}" seek="${FIPOFFSET}" conv=notrunc
dd bs=512 if=/dev/zero of="${OUTPUT}" seek="${ENVOFFSET}" count="${ENVSIZE}" conv=notrunc
dd bs=512 if="${BOOTFS}" of="${OUTPUT}" seek="${BOOTFSOFFSET}" conv=notrunc
dd bs=512 if="${ROOTFS}" of="${OUTPUT}" seek="${ROOTFSOFFSET}" conv=notrunc
