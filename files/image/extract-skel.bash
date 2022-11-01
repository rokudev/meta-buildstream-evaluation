#!/usr/bin/env bash
set -eu
scrdir=$(dirname $(readlink -f $0))

image_name_replace
extract_name_replace

path_extract=${scrdir}/${extract_name}
path_image=${scrdir}/${image_name}

mkdir ${path_extract} || (echo "Error: '${path_extract}' already exists!" && exit 6)

tar -C ${path_extract} -x -f ${path_image}

echo "Extracted to: ${path_extract}"
