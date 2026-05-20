#!/bin/bash
#
# Script to generate qcow and qcow2 test files
# Requires Linux with qemu-img

source ./shared_linux.sh

assert_availability_binary qemu-img

VERSION=$( qemu-img -V | head -n 1 | sed 's/^qemu-img version \(\S*\) .*$/\1/' )

SPECIMENS_PATH="specimens/qemu-img-${VERSION}"

if test -d ${SPECIMENS_PATH}
then
	echo "Specimens directory: ${SPECIMENS_PATH} already exists."

	exit ${EXIT_FAILURE}
fi

mkdir -p ${SPECIMENS_PATH}

set -e

# To determine supported options:
# qemu-img create -f qcow -o ?
# qemu-img create -f qcow2 -o ?

echo "Creating: qcow version 1"
qemu-img create -f qcow ${SPECIMENS_PATH}/version1.qcow 4M

echo "Creating: qcow version 1; with 128-bit AES-CBC encryption"
qemu-img create -f qcow --object secret,id=sec0,data=qcow-TEST -o encrypt.format=aes,encrypt.key-secret=sec0 ${SPECIMENS_PATH}/version1_with_aes_encryption.qcow 4M

echo "Creating: qcow version 1; with backing file"
qemu-img create -f qcow -o backing_fmt=qcow,backing_file=version1.qcow ${SPECIMENS_PATH}/version1_with_backing_file.qcow 4M

echo "Creating: qcow version 2"
qemu-img create -f qcow2 -o compat=v2,preallocation=metadata ${SPECIMENS_PATH}/version2.qcow 4M
qemu-img create -f qcow2 -o compat=v2,preallocation=full ${SPECIMENS_PATH}/version2_full.qcow 4M

echo "Creating: qcow version 2; with zlib compression"
qemu-img create -f qcow2 -o compat=v2,preallocation=metadata,compression_type=zlib ${SPECIMENS_PATH}/version2_with_compression_type_zlib.qcow 4M

echo "Creating: qcow version 2; with 128-bit AES-CBC encryption"
qemu-img create -f qcow2 --object secret,id=sec0,data=qcow-TEST -o compat=v2,preallocation=metadata,encrypt.format=aes,encrypt.key-secret=sec0 ${SPECIMENS_PATH}/version2_with_aes_encryption.qcow 4M

echo "Creating: qcow version 2; with LUKS encryption"
qemu-img create -f qcow2 --object secret,id=sec0,data=qcow-TEST -o compat=v2,preallocation=metadata,encrypt.format=luks,encrypt.key-secret=sec0 ${SPECIMENS_PATH}/version2_with_luks_encryption.qcow 4M

echo "Creating: qcow version 2; with backing file"
qemu-img create -f qcow2 -o compat=v2,backing_fmt=qcow2,backing_file=version2.qcow ${SPECIMENS_PATH}/version2_with_backing_file.qcow 4M

echo "Creating: qcow version 2; with snapshot"
qemu-img create -f qcow2 -o compat=v2,preallocation=metadata ${SPECIMENS_PATH}/version2_with_snapshot.qcow 4M
qemu-img snapshot -c snapshot1 ${SPECIMENS_PATH}/version2_with_snapshot.qcow

# TODO: add images with different cluster sizes (must be between 512 and 2M) (cluster_size=) default is 65536
# TODO: add images with different refcount size (refcount_bits=) default is 16

echo "Creating: qcow version 3"
qemu-img create -f qcow2 -o compat=v3,preallocation=metadata ${SPECIMENS_PATH}/version3.qcow 4M

echo "Creating: qcow version 3; with compression"
qemu-img create -f qcow2 -o compat=v3,preallocation=metadata,compression_type=zlib ${SPECIMENS_PATH}/version3_with_compression_type_zlib.qcow 4M

echo "Creating: qcow version 3; with image data file"
qemu-img create -f qcow2 -o compat=v3,preallocation=metadata,data_file_raw=off,data_file=${SPECIMENS_PATH}/data_file.raw ${SPECIMENS_PATH}/version3_with_data_file.qcow 4M

echo "Creating: qcow version 3; with raw data file"
qemu-img create -f qcow2 -o compat=v3,preallocation=metadata,data_file_raw=on,data_file=${SPECIMENS_PATH}/data_file.raw ${SPECIMENS_PATH}/version3_with_raw_data_file.qcow 4M

echo "Creating: qcow version 3; with lazy refcounts"
qemu-img create -f qcow2 -o compat=v3,preallocation=metadata,lazy_refcounts=on ${SPECIMENS_PATH}/version3_with_lazy_refcounts.qcow 4M

# TODO: test with encrypted backing file
# TODO: test with backing file with snapshots
# TODO: test with backing file with backing file
# TODO: test with backing file with different format

exit ${EXIT_SUCCESS}
