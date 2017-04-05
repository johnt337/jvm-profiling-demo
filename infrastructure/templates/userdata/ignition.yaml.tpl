---
ignition:
storage:
  disks:
  - device: "${var_volume_path}"
    wipe_table: true
    partitions:
    - label: varlibdocker
      number: 1
      start: 0
      size: 0
  - device: "${data_volume_path}"
    wipe_table: true
    partitions:
    - label: data
      number: 1
      start: 0
      size: 0
  filesystems:
  - mount:
      device: "${var_volume_path}1"
      format: ext4
      create:
        force: true
        options:
        - "-L"
        - VARLIBDOCKER
  - mount:
      device: "${data_volume_path}1"
      format: ext4
      create:
        force: true
        options:
        - "-L"
        - DATA
  files:
  - filesystem: root
    path: "/etc/hostname"
    contents:
      inline: ${format("%s-%s-%s", site_name, role, environment)}
    mode: 420
  - filesystem: root
    path: "/etc/envvars"
    contents:
      inline: |
        iam_instance_profile=${iam_instance_profile}
        aws_account_id=${aws_account_id}
        version=${version}
        region=${region}
        environment=${environment}
        customer=${customer}
        consortium=${consortium}
        dns_domain=${dns_domain}
        role=${role}
        node_name=${format("%s-%s-%s", site_name, role, environment)}
        aws_tag_version=${aws_tag_version}
    mode: 420
  - filesystem: root
    path: "/etc/iam_auth"
    contents:
      remote:
        url: https://gist.githubusercontent.com/johnt337/2b89f62c5c530c112484ccc50f3510f8/raw/a29b4f337728ee009fe80c18d48f8514834e48ad/iam_auth
        verification:
          hash:
            function: sha512
            sum: d8abd0f363d22e41f7875c72938afdcde6fcb384781247174d55a2b6a781c02d03d3bd80a5d4b013b9431945cb0b1a70861ecf9a9e0ae10ee982f6d51da3ca38
    mode: 360
    user:
      id: 0
    group:
      id: 500
  - filesystem: root
    path: "/etc/ec2_tag"
    contents:
      remote: 
        url: https://gist.githubusercontent.com/johnt337/1fc2aa3d253f4ac020ecba8cb332bb99/raw/1d5f26288df38f3d25c3be4851df1085a5152b2c/ec2_tag
        verification:
          hash: 
            function: sha512
            sum: 66a727c0b948326d7503608c8e935352ad5c1b6f6c955c9949435f7093a4bf332b9cb731ecab57f7d33e154af30cb3f4ec86fe9c949ec3ba8adff9b20a08993a
    mode: 448
systemd:
  units:
  - name: pull-ec2-tag.service
    enable: true
    contents: |
      [Service]
      Type=oneshot
      ExecStart=/usr/bin/docker pull aidevops/ec2_tag:${aws_tag_version}

      [Install]
      WantedBy=multi-user.target
  - name: pull-confd.service
    enable: true
    contents: |
      [Service]
      Type=oneshot
      ExecStart=/usr/bin/docker pull johnt337/confd

      [Install]
      WantedBy=multi-user.target
  - name: pull-compose-files.service
    enable: true
    contents: |
      [Service]
      Type=oneshot
      ExecStart=/bin/sh -c "source /etc/iam_auth; /usr/bin/docker run --rm -e AWS_ACCESS_KEY_ID=$$AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY=$$AWS_SECRET_ACCESS_KEY -e AWS_SESSION_TOKEN=$$AWS_SESSION_TOKEN -v /data/demo:/data/demo floccus/s3:${s3_util_version} get -b ${configuration_bucket} -s /data/demo -v"

      [Install]
      WantedBy=multi-user.target
  - name: demo.service
    enable: true
    contents: |
      [Unit]
      After=pull-compose-files.service
      Requires=pull-compose-files.service

      [Service]
      Type=oneshot
      ExecStartPre=-/usr/bin/docker run --rm -i -e ACCESS_KEY=${access_key} -e FQDN=${fqdn} -e REGISTRY=${registry} -v /data/demo:/data/demo --workdir=/data/demo -v /var/run/docker.sock:/var/run/docker.sock aidevops/docker-compose docker-compose pull
      ExecStart=/usr/bin/docker run --rm -i -e ACCESS_KEY=${access_key} -e FQDN=${fqdn} -e REGISTRY=${registry} -v /data/demo:/data/demo --workdir=/data/demo -v /var/run/docker.sock:/var/run/docker.sock aidevops/docker-compose docker-compose up
      ExecStop=/usr/bin/docker run --rm -i -e ACCESS_KEY=${access_key} -e FQDN=${fqdn} -e REGISTRY=${registry} -v /data/demo:/data/demo --workdir=/data/demo -v /var/run/docker.sock:/var/run/docker.sock aidevops/docker-compose docker-compose down

      [Install]
      WantedBy=multi-user.target
  - name: ec2_tag.service
    enable: true
    contents: |
      [Unit]
      After=pull-ec2-tag.service
      Requires=pull-ec2-tag.service

      [Service]
      Type=oneshot
      ExecStart=/etc/ec2_tag

      [Install]
      WantedBy=multi-user.target
  - name: var-lib-docker.mount
    enable: true
    contents: |
      [Mount]
      What=${var_volume_path}1
      Where=/var/lib/docker
      Type=ext4

      [Install]
      WantedBy=local-fs.target
  - name: data.mount
    enable: true
    contents: |
      [Mount]
      What=${data_volume_path}1
      Where=/data
      Type=ext4

      [Install]
      WantedBy=local-fs.target
passwd:
  users:
  - name: demo
    password_hash: '\$${password}'
    ssh_authorized_keys:
    - '\$${ssh_key}'
    create:
      uid: 501
      gecos: Demo User
      home_dir: "/home/demo"
      no_create_home: false
      primary_group: core
      groups:
      - wheel
      - docker
      - demo
      no_user_group: false
      no_log_init: false
      shell: "/bin/bash"
  groups:
  - name: demo
    gid: 1000
