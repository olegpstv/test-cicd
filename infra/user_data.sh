#!/bin/bash
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
set -x

dnf install -y docker
systemctl enable --now docker

for i in {1..30}; do
  docker info >/dev/null 2>&1 && break
  echo "waiting for docker ($i)"
  sleep 2
done

aws ecr get-login-password --region ${region} \
  | docker login --username AWS --password-stdin ${registry_url}

docker run -d --restart=always -p 8000:8000 \
  --name app ${ecr_url}:${image_tag}

docker ps -a