#!/bin/bash

##
# This will update the `ubuntu.pkr.hcl` file with the generated ISO image checksum.
# REF: https://help.ubuntu.com/community/VerifyIsoHowto
##

# Aborts the script when a command fails or a unset variable is used,
# and prints the executed commands
set -eux

iso_url=$(perl -n -e '/"(.+\.iso)"/ && print $1' ubuntu.pkr.hcl)
iso_checksum_url="$(dirname $iso_url)/SHA256SUMS"
iso_filename="$(basename $iso_url)"
curl -O --silent --show-error $iso_checksum_url
curl -O --silent --show-error $iso_checksum_url.gpg
gpg --keyid-format long --keyserver hkp://keyserver.ubuntu.com --recv-keys \
    0x46181433FBB75451 \
    0xD94AA3F0EFE21092 \
    0x3B4FE6ACC0B21F32 \
    0x871920D1991BC93C
gpg --verify SHA256SUMS.gpg SHA256SUMS
iso_checksum=$(grep $iso_filename SHA256SUMS | awk '{print $1}')
sed -i -E "s,\"sha.+?:[a-f0-9]*\",\"sha256:$iso_checksum\",g" ubuntu.pkr.hcl
rm SHA256SUMS*

echo "iso_checksum updated successfully"
