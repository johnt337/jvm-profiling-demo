# Registry, default DNS name, and sysdig access token 
REGISTRY     ?= quay.io/johnt337
FQDN         ?= my.demo.com
ACCESS_KEY ?= 1234-1234-1234-1234
export REGISTRY FQDN ACCESS_KEY

# cli overrides
args         ?= 


all: tls-certs ssh-keys build-images push-images infra-all open-tunnel

clean: clean-infra clean-infra-templates clean-images clean-certs clean-keys

include services/Makefile infrastructure/Makefile

tls-certs:
	@if [ ! -f ${PWD}/services/containers/demo-lb/certs/demo.crt -o ! -f ${PWD}/services/containers/demo-lb/certs/demo.key ]; then \
	  echo "generating tls certs for ${FQDN}..."; \
	  openssl req -new -x509 -sha256 -newkey rsa:2048 -nodes -days 3650 -out ${PWD}/services/containers/demo-lb/certs/demo.crt -keyout ${PWD}/services/containers/demo-lb/certs/demo.key -subj "/C=US/ST=New York/L=New York/O=Acme Inc./CN=${FQDN}"; \
  fi
	@echo "!!!!!!!!!!! TLS CERTS !!!!!!!!!!!"

ssh-keys:
	@if [ ! -f ${PWD}/services/containers/demo-bastion/conf/demo.pem -o ! -f ${PWD}/services/containers/demo-bastion/conf/demo.pem.pub ]; then \
	  echo "generating ssh keys..."; \
	  ssh-keygen -f ${PWD}/services/containers/demo-bastion/conf/demo.pem -P "" -C "demo@${FQDN}"; \
		awk '{q=p;p=$$0}NR>1{print q}END{ORS = ""; print p}' ${PWD}/services/containers/demo-bastion/conf/demo.pem > ${PWD}/services/containers/demo-bastion/conf/demo.pem.tmp; \
		mv -f ${PWD}/services/containers/demo-bastion/conf/demo.pem.tmp ${PWD}/services/containers/demo-bastion/conf/demo.pem; \
		awk '{q=p;p=$$0}NR>1{print q}END{ORS = ""; print p}' ${PWD}/services/containers/demo-bastion/conf/demo.pem.pub > ${PWD}/services/containers/demo-bastion/conf/demo.pem.pub.tmp; \
		mv -f ${PWD}/services/containers/demo-bastion/conf/demo.pem.pub.tmp ${PWD}/services/containers/demo-bastion/conf/demo.pem.pub; \
  fi
	@echo "!!!!!!!!!!! SSH KEYS !!!!!!!!!!!"

clean-certs: ${PWD}/services/containers/demo-lb/certs/demo.crt ${PWD}/services/containers/demo-lb/certs/demo.key
	@rm -f ${PWD}/services/containers/demo-lb/certs/demo.{crt,key}
	@echo "!!!!!!!!!!! CERTS CLEANED !!!!!!!!!!!"

clean-keys: ${PWD}/services/containers/demo-bastion/conf/demo.pem*
	@rm -f ${PWD}/services/containers/demo-bastion/conf/demo.pem*
	@echo "!!!!!!!!!!! SSH KEYS CLEANED !!!!!!!!!!!"

open-tunnel: ${PWD}/open-tunnel.sh
	@$^

.PHONY: clean open-tunnel
