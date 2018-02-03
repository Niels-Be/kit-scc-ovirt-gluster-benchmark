## Setup Notes

1. on one of the hosts run `../host/createStorageVolumes.sh`
2. create storage domains in ovirt ui for all gluster volumes. (start with `rhv_data` as master)
3. upload iso to `rhv_iso`
4. create a vm with system disk on `rhv_data`
5. complete installation of the vm os
6. attach all `test_*` disks to the vm (remember the order)
7. adapt and run `setupDisk.sh` inside the vm
8. adapt and run `run.sh` inside the vm

