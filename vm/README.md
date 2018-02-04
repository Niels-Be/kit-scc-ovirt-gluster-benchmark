## Setup Notes

1. on one of the hosts run `../host/createStorageVolumes.sh`
2. create storage domains in ovirt ui for all gluster volumes. (start with `rhv_data` as master)
3. upload os iso to `rhv_iso`
4. create a vm with system disk on `rhv_data`
5. complete installation of the vm os
6. install tools: `yum install vim git curl wget fio jq epel-release bash-completion ovirt-guest-agent-common`
6. create and attach all `test_*` disks to the vm (remember the order)
7. adapt and run `setupDisk.sh` inside the vm
8. adapt and run `run.sh` inside the vm

