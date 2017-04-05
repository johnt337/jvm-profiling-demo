# ubuntu - based off ubuntu:14.04.4
#
# VERSION               14.04.4

# Taken from https://github.com/tianon/dockerfiles/blob/4d24a12b54b75b3e0904d8a285900d88d3326361/sbin-init/ubuntu/upstart/14.04/Dockerfile

FROM ubuntu:14.04.4
MAINTAINER John Torres <enfermo337@yahoo.com>

ARG ROOT_PASSWORD
ENV ROOT_PASSWORD ${ROOT_PASSWORD:-changeM3S00n}

ARG UBUNTU_PASSWORD
ENV UBUNTU_PASSWORD ${UBUNTU_PASSWORD:-changeM3S00n}

ARG TUNNEL_PORT
ENV TUNNEL_PORT ${TUNNEL_PORT:-29090}

# much of this was gleaned from https://github.com/lxc/lxc/blob/lxc-0.8.0/templates/lxc-ubuntu.in
# and then heavily modified and hacked like crazy

# we're going to want this bad boy installed so we can connect :)
RUN \
    apt-get update && apt-get install -y ssh && \
    apt-get clean -y  && \
    rm -rf /var/lib/{apt,dpkg,cache,log}

ADD conf/init-fake.conf /etc/init/fake-container-events.conf
ADD conf/demo.pem.pub /root/.ssh/demo.pem.pub
ADD conf/sudoers /etc/sudoers

RUN \
    chmod 440 /etc/sudoers && chown root:root /etc/sudoers && \
    cat /root/.ssh/*.pub > /root/.ssh/authorized_keys && \
    chmod 700 /root/.ssh && chmod 600 /root/.ssh/authorized_keys && \
    groupadd -g 500 ubuntu && useradd ubuntu -d /home/ubuntu -s /bin/bash -u 500 -g 500 && \
    mkdir -p /home/ubuntu/.ssh && cp /root/.ssh/authorized_keys /home/ubuntu/.ssh/authorized_keys && \
    chmod 700 /home/ubuntu/.ssh && chown -R ubuntu:ubuntu /home/ubuntu

# undo some leet hax of the base image
RUN rm /usr/sbin/policy-rc.d; \
	mv /sbin/initctl /sbin/initctl.orig; dpkg-divert --rename --remove /sbin/initctl

# generate a nice UTF-8 locale for our use
RUN locale-gen en_US.UTF-8 && update-locale LANG=en_US.UTF-8

# remove some pointless services
RUN /usr/sbin/update-rc.d -f ondemand remove; \
	for f in \
		/etc/init/u*.conf \
		/etc/init/mounted-dev.conf \
		/etc/init/mounted-proc.conf \
		/etc/init/mounted-run.conf \
		/etc/init/mounted-tmp.conf \
		/etc/init/mounted-var.conf \
		/etc/init/hostname.conf \
		/etc/init/networking.conf \
		/etc/init/tty*.conf \
		/etc/init/plymouth*.conf \
		/etc/init/hwclock*.conf \
		/etc/init/module*.conf\
		/etc/init/atd*.conf \
	; do \
		dpkg-divert --local --rename --add "$f"; \
	done; \
	echo '# /lib/init/fstab: cleared out for bare-bones Docker' > /lib/init/fstab

# small fix for SSH in 13.10 (that's harmless everywhere else)
RUN sed -ri 's/^session\s+required\s+pam_loginuid.so$/session optional pam_loginuid.so/' /etc/pam.d/sshd
# disable nologin
RUN sed -ri 's/^account\s+required\s+pam_nologin.so$/#account required pam_nologin.so/' /etc/pam.d/sshd && \
    rm -f /etc/nologin

RUN sed -ri 's/^PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config

# let Upstart know it's in a container
ENV container docker

# set a cheap, simple password for great convenience
RUN echo "root:${ROOT_PASSWORD}" | chpasswd && \
    echo "ubuntu:${UBUNTU_PASSWORD}" | chpasswd

# we can has SSH
EXPOSE 22 ${TUNNEL_PORT}

# pepare for takeoff
CMD ["/sbin/init"]
