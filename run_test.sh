#!/bin/bash
cd /sys/class/mmc_host/mmc*/mmc*\:*
echo "man:$(cat manfid) oem:$(cat oemid) name:$(cat name) hwrev:$(cat hwrev) fwrev:$(cat fwrev) date:$(cat date) cid:$(cat cid) csd:$(cat csd)"

DEVICE=$1
echo "============== Device: ${DEVICE} ===== "

echo "============== Partition table ===== "
sudo fdisk -l ${DEVICE}

echo "============== Examining first partition ===== "
if [ ${DEVICE} = "/dev/mmcblk0" ]; then
    PART="${DEVICE}p1";
else
    PART="${DEVICE}1";
fi
sudo fsck.vfat -n -v ${PART}



echo "============== Linear read speed (dd, 4M block) ============"
for i in `seq 1 5`; do
    echo "==== $i ===="
    sudo echo 3 > /proc/sys/vm/drop_caches
    sudo dd if=${DEVICE} bs=4M count=10 of=/dev/null 2>&1
done


echo "============== Linear read speed (dd, 4M block, skip 10) ============"
for i in `seq 1 5`; do
    echo "==== $i ===="
    sudo echo 3 > /proc/sys/vm/drop_caches
    sudo dd if=${DEVICE} bs=4M count=10 skip=10 of=/dev/null 2>&1
done

echo "============== Linear read speed (dd, 64kb block, skip 1024) ============"
for i in `seq 1 5`; do
    echo "==== $i ===="
    sudo echo 3 > /proc/sys/vm/drop_caches
    sudo dd if=${DEVICE} bs=64K count=512 skip=1024 of=/dev/null 2>&1
done


echo "============== Linear write speed (dd, 4M block) ============"
for i in `seq 1 5`; do
    echo "==== $i ===="
    sudo dd if=/dev/zero of=${DEVICE} bs=4M count=10 2>&1 conv=fdatasync
done

echo "============== Linear write speed (dd, 4M block, seek 10) ============"
for i in `seq 1 5`; do
    echo "==== $i ===="
    sudo dd if=/dev/zero of=${DEVICE} bs=4M seek=10 count=10 2>&1 conv=fdatasync
done

echo "============== Linear write speed (dd, 64kb block, seek 1024) ============"
for i in `seq 1 5`; do
    echo "==== $i ===="
    sudo dd if=/dev/zero of=${DEVICE} bs=64K seek=1024 count=512 2>&1 conv=fdatasync
done

echo "============== Linear read speed (hdparm) ============"
for i in `seq 1 5`; do
    echo "==== $i ===="
    sudo hdparm -t ${DEVICE}
done


echo "============== Align test ============"
for i in `seq 1 3`; do
    echo "======= Align test: $i ======="
    sudo flashbench -a ${DEVICE} -b 1024 -c 50
done

echo "============== Find FAT ============"
for i in `seq 1 3`; do
    echo "======= find FAT: $i ======="
    sudo flashbench -f --fat-nr=8 ${DEVICE} -b 1024 -c 50
done



echo "============== Linear access ============"
for i in `seq 1 7`; do
    echo "======= AU=$i, linear access ======="
    sudo flashbench  --open-au --open-au-nr=$i ${DEVICE} -b 4096;
done

echo "============== Random access============"
for i in `seq 1 7`; do
    echo "======= AU=$i, random access ======="
    sudo flashbench --random --open-au --open-au-nr=$i ${DEVICE} -b 4096;
done



#bonnie++ -n 5:102400:2:100 -r 256M -s 1024M -d /media/boger/test/
