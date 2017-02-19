#!/bin/bash

echo "Adding puppet"
# sudo apt-get update
/usr/bin/apt-get install puppet  -y
puppet module install puppetlabs-mysql 
puppet module install puppetlabs-vcsrepo
