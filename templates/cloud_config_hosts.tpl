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
      command: start
      drop-ins:
        - name: 50-network-config.conf
          content: |
            [Unit]
            Requires=etcd2.service
            [Service]
            Environment="FLANNEL_VER=0.5.0"
            ExecStartPre=/usr/bin/etcdctl set /coreos.com/network/config '{ "Network": "10.20.0.0/16", "Backend": {"Type": "aws-vpc"} }'
    - name: docker.service
      command: start
      drop-ins:
        - name: 50-custom-opts.conf
          content: |
            [Unit]
            # Requirements
            Requires=flanneld.service

            # Dependency ordering
            After=flanneld.service

            [Service]
            Environment=DOCKER_OPTS='--dns="$private_ipv4"'
    - name: skydns.service
      command: start
      content: |
        [Unit]
        Description=SkyDNS
    
        # Requirements
        Requires=etcd2.service
        Requires=docker.service
    
        # Dependency ordering
        After=etcd2.service
        After=docker.service

        [Service]
        # Get CoreOS environment varialbes
        EnvironmentFile=/etc/environment

        ExecStartPre=-/usr/bin/docker kill skydns
        ExecStartPre=-/usr/bin/docker rm skydns
        ExecStartPre=/usr/bin/docker pull skynetservices/skydns:latest

        ExecStart=/usr/bin/docker run \
          -e SKYDNS_ADDR=$private_ipv4:53 \
          -e SKYDNS_DOMAIN=skydns.local \
          -e SKYDNS_NAMESERVERS=8.8.8.8:53,8.8.4.4:53 \
          --name skydns \
          --net host \
          skynetservices/skydns:latest

        Restart=always
        RestartSec=10
        TimeoutStartSec=0

        [Install]
        WantedBy=multi-user.target
  update:
    group: stable
    reboot-strategy: best-effort
