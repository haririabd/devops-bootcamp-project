#!/bin/bash

# NAT gateway / route table may not be ready the instant this instance boots,
# so apt-get can fail with "Network is unreachable". Poll until outbound
# connectivity is up (capped at 5 minutes) before installing anything.
for i in $(seq 1 30); do
  if curl -s --max-time 5 -o /dev/null http://ap-southeast-1.ec2.archive.ubuntu.com; then
    break
  fi
  echo "Waiting for network... ($i/30)"
  sleep 10
done

apt-get update -y
apt-get install -y ansible

mkdir -p /home/ubuntu/ansible
cat > /home/ubuntu/ansible/requirements.yaml << 'ANSIBLE_REQS'
${requirements_yaml}
ANSIBLE_REQS

chown -R ubuntu:ubuntu /home/ubuntu/ansible
sudo -u ubuntu ansible-galaxy install -r /home/ubuntu/ansible/requirements.yaml
