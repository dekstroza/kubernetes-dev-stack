{% set nfs_ip = salt['grains.get']('nfs_ip') %}

include:
  - nfs.cfg
  - nfs.partitioning

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
      - sls: nfs.partitioning
      - mount: {{ pillar['nfs_mount_dir'] }}

