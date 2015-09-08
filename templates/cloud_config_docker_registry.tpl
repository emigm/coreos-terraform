#cloud-config

coreos:
  units:
    - name: docker.service
      command: start
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
            --net host \
            registry:2

        ExecStop=/usr/bin/docker stop docker_registry

        Restart=always
        RestartSec=10
        TimeoutStartSec=0

        [Install]
        WantedBy=multi-user.target
  update:
    group: stable
    reboot-strategy: best-effort
