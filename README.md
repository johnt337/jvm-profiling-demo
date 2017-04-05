## Background

The purpose of this demo is to provide a turn key solution to a question I was recently asked "How do I profile a remote JVM in a container?".
As such it aims to simulate a multi-tier, multi-system Java application deployment.

One of the twists that was added to the original question "How would it be done via bastion host?".
A bastion host (or jump box) that serves as an ingress point to an otherwise isolated environment.

So in order to faciliate answering these questions, this demo has the following underlying infrastructure:

### Infrastructure Architecture
![png](https://github.com/johnt337/jvm-profiling-demo/blob/master/jvm-profiling-infra.png?raw=true)

### Container Architecture
![png](https://github.com/johnt337/jvm-profiling-demo/blob/master/jvm-profiling-demo-container-components.png?raw=true)

## Getting Started
[![asciicast](https://asciinema.org/a/1qv0pv1cqphgoj5hy20sgfcds.png)](https://asciinema.org/a/1qv0pv1cqphgoj5hy20sgfcds?autoplay=1&speed=5&loop=1)

## Profiling

![png](https://github.com/johnt337/jvm-profiling-demo/blob/master/profiling.png?raw=true)

## Cleaning Up
[![asciicast](https://asciinema.org/a/69l82jctjoe5gkfklg2vxum4i.png)](https://asciinema.org/a/69l82jctjoe5gkfklg2vxum4i?autoplay=1&speed=5&loop=1)


## How-to

### Start the app

```bash
$ export FQDN="<your_hostname_and_domain>"
$ export ACCESS_KEY="<your_sysdig_token>"
$ export AWS_DEFAULT_R53_ZONE="<your_domain_zone>"
$ export AWS_DEFAULT_R53_ZONE_ID="<your_domain_zone_id>"
$ export AWS_DEFAULT_SUBNET_ID="<your_subnet_id>"
$ export AWS_DEFAULT_VPC_ID="<your_vpc_id>"

# build & deploy new instance with sample app
$ make tls-certs
$ make ssh-keys
$ make build-images
$ make push-images
$ make infra-all

# or...
$ make
```

### Tear down the app

```bash
$ make clean
```

### Connect to the bastion host

```bash
$ alias weak-ssh='ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'
$ weak-ssh -i services/demo-bastion/conf/demo.pem ubuntu@${FQDN} -p 20022
```

### Change the ubuntu password

```bash
$ vim docker-compose.yml
# edit the UBUNTU_PASSWORD args variable

$ make build-image/demo-bastion
```

### Change the root password

```bash
$ vim docker-compose.yml
# edit the ROOT_PASSWORD args variable

$ make build-image/demo-bastion
```

### Generate your own ssh-keys

```bash
$ make clean-keys && make ssh-keys
$ make build-image/bastion
```

### Replace demo ssh-keys

```bash
$ make clean-certs && make tls-certs
$ make build-image/bastion
```

### Connecting to the APP

```bash
$ weak-ssh -ti ./services/containers/demo-bastion/conf/demo.pem core@${FQDN} docker exec -it demo-server /bin/sh
```
### Connecting to the DB

```bash
$ weak-ssh -ti ./services/containers/demo-bastion/conf/demo.pem core@${FQDN} docker exec -it demo-db mysql -h localhost -u demo --password=demo demo
```

### Forwarding the JMX connection from the demo-server to the demo-bastion
``` bash
$ ssh -v -L localhost:9090:demo-server.demo_backend:9090 -N -i ./services/containers/demo-bastion/conf/demo.pem ubuntu@${FQDN} -p 20022 &
```

### Configure the JVM (note you should secure your config (using TLS, username, and password) in a production scenario
```bash
- CATALINA_OPTS=-Dcom.sun.management.jmxremote=true -Dcom.sun.management.jmxremote.port=9090 -Dcom.sun.management.jmxremote.rmi.port=9090 -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.local.only=false -Djava.awt.headless=true -XX:+UseConcMarkSweepGC -XX:+CMSClassUnloadingEnabled -Djava.net.preferIPv4Stack=true -Djava.net.preferIPv4Addresses=true -Duser.timezone=UTC  -Djava.rmi.server.hostname=localhost -XX:-UsePerfData
```


## Presentation available [here](https://docs.google.com/presentation/d/1PkN1-FZV-VxFKsqPdm4BRmAkijS0HqI2QAlMJVCxPKs/edit?usp=sharing)

## TODO
- Update README.md
- Create sample db jsp

## KNOWN ISSUES
- SYSDIG Agent does not work on OSX (if you want to run this locally, comment out the sysdig agent part from the `docker-compose.yml`

