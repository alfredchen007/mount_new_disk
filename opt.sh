#!/bin/sh
#if [ $# -ne 1 ];then
#  action "USAGE: $0 disk-use"
#  exit 1
#fi
. /etc/init.d/functions

current_user=`whoami`
if [[ "$current_user" == "root" ]];then
  action "ensure user is root" /bin/true
else
  action "run script must is root" /bin/false
  exit 1
fi

rpm -qa |grep "system-storage-manager"
if [ $? -eq 0 ];then
  action "system-storage-manager have been install " /bin/true
else

  yum list |grep system-storage-manager > /dev/null
  if [ $? -ne 0 ];then
    action "yum list haven't system-storage-manager" /bin/false
    exit 1
  fi
  echo "start install system-storage-manager..."

  yum -y install system-storage-manager > /dev/null
  rpm -qa |grep "system-storage-manager" > /dev/null
  if [ $? -ne 0 ];then
    action "system-storage-manager install fail " /bin/false
    exit 1
  fi
  action "system-storage-manager install Success" /bin/true
fi

opt_line=`ls -l /opt | wc -l`
echo  "/opt file lines is $opt_line"
mkdir -p /tmp/opt
mv /opt/* /tmp/opt
tmp_line=`ls -l /tmp/opt | wc -l`
echo  "/tmp/opt file lines is $tmp_line"

if [[ "$opt_line" == "$tmp_line" ]];then
  action "/opt filelist mv Success " /bin/true
else
  action "/opt filelist mv fail " /bin/false
  exit 1
fi

fdisk -l |grep /dev/sdb > /dev/null
if [ $? -ne 0 ];then
  action "fdisk /dev/sdb not exist " /bin/false
  exit 1
fi
action "fdisk /dev/sdb  ready OK " /bin/true

#ssm create -s 100%FREE -n lv_opt --fstype xfs -p datavg /dev/sdb /opt > /dev/null
ssm create -n lv_opt --fstype xfs -p datavg /dev/sdb /opt > /dev/null
pvs |grep /dev/sdb
if [ $? -ne 0 ];then
  action "PV create fail " /bin/false
  exit 1
fi
action "PV create Success " /bin/true
vgs |grep datavg
if [ $? -ne 0 ];then
  action "VG create fail " /bin/false
  exit 1
fi
action "VG create Success " /bin/true
lvs |grep lv_opt
if [ $? -ne 0 ];then
  action "LV create fail " /bin/false
  exit 1
fi
action "LV create Success " /bin/true
df -Th |grep "opt" > /dev/null
if [ $? -ne 0 ];then
  action "fdisk /dev/sdb not exist " /bin/false
  exit 1
fi
action "/opt mount Success " /bin/true

echo  "/dev/mapper/datavg-lv_opt /opt                    xfs    defaults        0 0" >> /etc/fstab
action "write mount INFO to /etc/fstab " /bin/true
tail -1 /etc/fstab

echo  "start auto mount check"
umount /opt
echo  "start umount /opt "
df -Th |grep "opt" > /dev/null
if [ $? -eq 0 ];then
  action "/opt umount fail " /bin/false
  exit 1
fi
action "/opt umount Success " /bin/true
echo "Start Auto mount "
mount -a
df -Th |grep "opt" > /dev/null
if [ $? -ne 0 ];then
  action "fdisk /dev/sdb auot mount fail " /bin/false
  exit 1
fi
action "/opt mount Success " /bin/true

echo  "/tmp/opt/ file now move /opt "
mv /tmp/opt/* /opt/.
new_opt_line=`ls -l /opt/. |wc -l`
if [[ "$new_opt_line" == "$opt_line" ]];then
  action "/tmp/opt filelist mv Success " /bin/true
  echo  "current line is : $new_opt_line"
else
  action   "/tmp/opt filelist mv fail " /bin/false
  exit 1
fi

ls -l /opt
echo  "all of operation End "
