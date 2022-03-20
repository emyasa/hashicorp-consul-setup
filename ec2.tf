data "template_file" "server_user_data" {
  template = file("${path.module}/scripts/server.sh")
}

data "template_file" "client_api_user_data" {
  template = file("${path.module}/scripts/client-api.sh")
  vars = {
    project_tag       = "Project"
    project_tag_value = "${var.main_project_tag}"
  }
}

data "template_file" "client_web_user_data" {
  template = file("${path.module}/scripts/client-web.sh")
  vars = {
    project_tag       = "Project"
    project_tag_value = "${var.main_project_tag}"
  }
}

resource "aws_instance" "consul_server" {
  ami                    = var.ami_id
  instance_type          = "t2.nano"
  key_name               = var.ec2_key_pair_name
  vpc_security_group_ids = [aws_security_group.consul_server.id]
  subnet_id              = aws_subnet.private[0].id

  tags = merge(
    { "Name" = "${var.main_project_tag}-server" },
    { "Project" = var.main_project_tag }
  )

  user_data = data.template_file.server_user_data.rendered
}

resource "aws_instance" "consul_client" {
  ami                    = var.ami_id
  instance_type          = "t2.nano"
  key_name               = var.ec2_key_pair_name
  vpc_security_group_ids = [aws_security_group.consul_client.id]
  subnet_id              = aws_subnet.private[1].id
  iam_instance_profile   = aws_iam_instance_profile.consul_instance_profile.name

  tags = merge(
    { "Name" = "${var.main_project_tag}-client" },
    { "Project" = var.main_project_tag }
  )

  user_data = data.template_file.client_api_user_data.rendered
}

resource "aws_instance" "bastion" {
  ami                         = var.ami_id
  instance_type               = "t2.nano"
  key_name                    = var.ec2_key_pair_name
  vpc_security_group_ids      = [aws_security_group.bastion.id, aws_security_group.consul_client.id]
  subnet_id                   = aws_subnet.public[0].id
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.consul_instance_profile.name

  tags = merge(
    { "Name" = "${var.main_project_tag}-bastion" },
    { "Project" = var.main_project_tag }
  )

  user_data = data.template_file.client_web_user_data.rendered
}