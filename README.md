# mount_new_disk
System Storage Manager (SSM) provides a command line interface to manage storage in various technologies. We will show a kind of use case that how to manage a brand new disk and mount it on the certain point.
# Background

We consider such a situation that we already have had a machine running with Linux OS, and now we finding out the space of `/opt` is almost running out in some reasons. We decide add a new disk for this node ( if you are using virtual machine  you just add a new disk without any other operations, but you have to take consideration of raid in physical machine case ) endeavor to migrate data to this new space and keep the mount point ( `/opt` ) stays the same for long. 

# Script

Here we give a comparatively complete steps in this script demo though the command is pretty simple. You still have to notice that there are several special conditions are limited in our case: 1) Available yum source; 2) The device name of disk new added is `/dev/sdb` and the mount point is `/opt`; 3) The logic volume name is `lv_opt`, the volume group name is `datavg`, those are specified in command `ssm create -n lv_opt --fstype xfs -p datavg /dev/sdb /opt`
