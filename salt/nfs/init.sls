{% set nfs_ip = salt['grains.get']('nfs_ip') %}

include:
  - nfs.cfg

nfs-server-alias:
  host.present:
    - ip: {{ nfs_ip }}
    - names:
      - nfs
      - nfs.{{ pillar['dns_domain'] }}

rpcbind-running:
  service.running:
    - name: rpcbind

nfs-running:
  service.running:
    - name: nfs 
    - require:
      - sls: nfs.cfg
      - mount: {{ pillar['nfs_mount_dir'] }}

label-nfs-disk:
  module.run:
   - name: partition.mklabel
   - device: {{ pillar['nfs_partition_device'] }}
   - label_type: {{ pillar['nfs_partition_label_type'] }}
   - unless: fdisk -l {{ pillar['nfs_partition_device'] }} | grep {{ pillar['nfs_partition_label_type'] }}

create-nfs-partition:
  module.run:
   - name: partition.mkpart
   - device: {{ pillar['nfs_partition_device'] }}
   - part_type: primary
   - start: 0%
   - end: 100%
   - require:
     - module: label-nfs-disk
   - unless: fdisk -l {{ pillar['nfs_partition_device'] }} | grep {{ pillar['nfs_fs_partition_name'] }}

nfs-device:
  blockdev.formatted:
    - name: {{ pillar['nfs_fs_partition_name'] }}
    - fs_type: {{ pillar['nfs_fs_type'] }}
    - unless: blkid | grep {{ pillar['nfs_partition_device'] }} | grep {{ pillar['nfs_fs_type'] }}
    - require:
      - module: create-nfs-partition

mount-nfs-partition:
  mount.mounted:
    - name: {{ pillar['nfs_mount_dir'] }}
    - device: {{ pillar['nfs_fs_partition_name'] }}
    - fstype: {{ pillar['nfs_fs_type'] }}
    - mkmnt: True
    - opts:
      - defaults
    - require:
      - blockdev: {{ pillar['nfs_fs_partition_name'] }}
    - unless: mount | grep {{ pillar['nfs_fs_partition_name'] }}
     
