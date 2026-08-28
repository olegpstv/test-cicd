set -euxo

dnf install -y docker
systemctl enable --now docker

aws ecr get-login-password --region ${region} | docker login --username AWS --password-stdin ${registry_url}

docker run -d --restart=always -p 8000:8000 --name app ${ecr_url}:${image_tag}