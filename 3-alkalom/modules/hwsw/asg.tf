data "aws_ami" "ubuntu" {
  most_recent = true
  owners = [
    "099720109477"]

  filter {
    name = "name"

    values = [
      "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"
    ]
  }
}

resource "aws_security_group" "api-asg" {
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port = 5678
    protocol = "tcp"
    to_port = 5678
    security_groups = [
      aws_security_group.lb.id]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  tags = {
    Name = join("-", [
      local.derived_name,
      "api-sg"])
  }
}

resource "aws_iam_instance_profile" "api-asg" {
  name_prefix = "api-asg"
  role = aws_iam_role.api-asg.name
}

resource "aws_iam_role" "api-asg" {
  name = "api-instance-profile"
  assume_role_policy = data.aws_iam_policy_document.api_assume_role_policy.json
}

data "aws_iam_policy_document" "api_assume_role_policy" {
  statement {
    actions = [
      "sts:AssumeRole"]
    principals {
      identifiers = [
        "ec2.amazonaws.com"]
      type = "Service"
    }
    effect = "Allow"
  }
}

module "asg" {
  source = "terraform-aws-modules/autoscaling/aws"
  version = "4.1.0"

  name = local.derived_name

  image_id = data.aws_ami.ubuntu.id
  instance_type = var.ec2_instance_type

  security_groups = [
    aws_security_group.api-asg.id]
  target_group_arns = [
    module.lb.target_group_arns.0]

  root_block_device = [
    {
      volume_size = "30"
      volume_type = "gp2"
    },
  ]

  vpc_zone_identifier = module.vpc.public_subnets
  health_check_type = "EC2"
  min_size = 1
  max_size = 1
  desired_capacity = 1
  wait_for_capacity_timeout = 0
  iam_instance_profile_name = aws_iam_instance_profile.api-asg.name

  use_lc = true
  create_lc = true

  user_data = templatefile("${path.module}/userdata.sh.tpl", {
    authorized_gitlab_users = "matelang"
  })
}
