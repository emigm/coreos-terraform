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
    - name: docker.service
      drop-ins:
        - name: 50-insecure-registry.conf
          content: |
            [Service]
            Environment=DOCKER_OPTS='--insecure-registry="${subnet_cidr}"'
    - name: docker_registry.service
      command: start
      content: |
        [Unit]
        Description=Docker Registry

        # Requirements
        Requires=docker.service

        # Dependency ordering
        After=docker.service

        [Service]
        # Get CoreOS environment varialbes
        EnvironmentFile=/etc/environment

        ExecStartPre=-/usr/bin/docker kill docker_registry
        ExecStartPre=-/usr/bin/docker rm docker_registry
        ExecStartPre=/usr/bin/docker pull registry:2

        ExecStart=/usr/bin/docker run \
            --name docker_registry \
            -p 5000:5000 \
            registry:2

        [Install]
        WantedBy=multi-user.target
  update:
    group: stable
    reboot-strategy: best-effort
