#cloud-config

coreos:
  etcd2:
    discovery: ${etcd_cluster_discovery_url}
    advertise-client-urls: http://${etcd_advertised_ip_address}_ipv4:2379
    initial-advertise-peer-urls: http://${etcd_advertised_ip_address}_ipv4:2380
    listen-client-urls: http://0.0.0.0:2379,http://0.0.0.0:4001
    listen-peer-urls: http://${etcd_advertised_ip_address}_ipv4:2380
  fleet:
    metadata: |-
      role=${fleet_unit_role}
  units:
    - name: etcd2.service
      command: start
    - name: fleet.service
      command: start
    - name: flanneld.service
      drop-ins:
        - name: 50-network-config.conf
          content: |
            [Unit]
            Requires=etcd2.service
            [Service]
            Environment="FLANNEL_VER=0.5.0"
            ExecStartPre=/usr/bin/etcdctl set /coreos.com/network/config '{ "Network": "10.20.0.0/16", "Backend": {"Type": "aws-vpc"} }'
      command: start
  update:
    group: stable
    reboot-strategy: best-effort
write_files:
  - path: /home/core/.dockercfg
    owner: core:core
    permissions: 0644
    content: |
      {
        "quay.io": {
          "auth": "${quayio_secret_key}",
          "email": "${quayio_email}"
        }
      }
