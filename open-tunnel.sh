#!/bin/bash

echo -n 'waiting for application to become available'
while [ $(curl -kf https://${FQDN}/hello.jsp > /dev/null 2>&1; echo $?) -ne 0 ];
do
        sleep 5;
        echo -n ".";
done
echo "done"

echo -n 'testing if bastion has started listening'
while [ $(nc -w 1 -z ${FQDN} 20022 > /dev/null 2>&1; echo $?) -ne 0 ]; 
do
        sleep 5;
        echo -n ".";
done
echo "done"

echo "creating tunnel, point your visual vm at localhost:9090";
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
        -L 127.0.0.1:9090:demo-server.demo_backend:9090 -N -i ./services/containers/demo-bastion/conf/demo.pem ubuntu@${FQDN} -p 20022 &
sleep 2
jobs -l
