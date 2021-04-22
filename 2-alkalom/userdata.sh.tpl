#!/bin/bash

AUTHORIZED_GITLAB_USERS=(${authorized_gitlab_users})

echo "HWSW - Adding software"
apt-get update && apt-get install -y jq wget curl docker.io awscli
echo "HWSW - Software added"

echo "HWSW - Adding authorized keys"
for glu in "$${AUTHORIZED_GITLAB_USERS[@]}"; do
  curl -s "https://gitlab.com/api/v4/users/$glu/keys" | jq -r '.[].key' >> /home/ubuntu/.ssh/authorized_keys
  echo "HWSW - Added keys of $glu to authorized_keys"
done
echo "HWSW - Authorized keys added"

echo "HWSW - Starting docker"
systemctl start docker && systemctl enable docker
usermod -aG docker ubuntu
docker run -d -p 5678:5678 hashicorp/http-echo -text="hello hwsw"
echo "HWSW - Docker started"
