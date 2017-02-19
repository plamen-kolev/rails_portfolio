#!/bin/bash

echo "Adding puppet"
# sudo apt-get update
/usr/bin/yum install puppet  -y
mkdir -p /etc/puppet/modules
puppet module install puppetlabs-mysql 
puppet module install puppetlabs-vcsrepo
