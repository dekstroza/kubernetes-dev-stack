include:
  - docker.config-files


docker-running:
  service.running:
    - name: docker
    - require:
      - sls: docker.config-files
      - service: flanneld
      - mount: /var/lib/docker

label-docker-disk:
  module.run:
   - name: partition.mklabel
   - device: {{ pillar['docker_partition_device'] }}
   - label_type: gpt
   - unless: fdisk -l {{ pillar['docker_partition_device'] }} | grep gpt

create-docker-partition:
  module.run:
   - name: partition.mkpart
   - device: {{ pillar['docker_partition_device'] }}
   - part_type: primary
   - start: 0%
   - end: 100%
   - require:
     - module: label-docker-disk
   - unless: fdisk -l {{ pillar['docker_partition_device'] }} | grep {{ pillar['docker_fs_partition_name'] }}

docker-device: 
  blockdev.formatted:
    - name: {{ pillar['docker_fs_partition_name'] }}
    - fs_type: {{ pillar['docker_fs_type'] }}
    - unless: blkid | grep {{ pillar['docker_partition_device'] }} | grep {{ pillar['docker_fs_type'] }}
    - require:
      - module: create-docker-partition

mount-docker-partition:
  mount.mounted:
    - name: /var/lib/docker
    - device: {{ pillar['docker_fs_partition_name'] }}
    - fstype: {{ pillar['docker_fs_type'] }}
    - mkmnt: True
    - opts:
      - defaults
    - require:
      - blockdev: {{ pillar['docker_fs_partition_name'] }}
    - unless: mount | grep {{ pillar['docker_fs_partition_name'] }}

