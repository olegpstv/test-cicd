data "aws_ssm_parameter" "al2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

resource "aws_instance" "app" {
  ami                    = data.aws_ssm_parameter.al2023.value
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.app.id]
  iam_instance_profile   = aws_iam_instance_profile.instance.name

  user_data_replace_on_change = true
  user_data = templatefile("${path.module}/user_data.sh", {
    region       = var.region
    registry_url = split("/", var.ecr_repository_url)[0]
    ecr_url      = var.ecr_repository_url
    image_tag    = var.image_tag
  })

  tags = { Name = "${var.prefix}-app" }
}
