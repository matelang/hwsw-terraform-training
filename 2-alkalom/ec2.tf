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

resource "aws_security_group" "api" {
  vpc_id = aws_vpc.vpc.id
  name = "hwsw-api"

  ingress {
    from_port = 5678
    to_port = 5678
    protocol = "tcp"
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
    protocol = "-1"
    to_port = 0
    cidr_blocks = [
      "0.0.0.0/0"]
  }

}

data "aws_iam_policy_document" "hwsw_api_assume_role_policy" {
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

resource "aws_iam_role" "api" {
  assume_role_policy = data.aws_iam_policy_document.hwsw_api_assume_role_policy.json
  name = "hwsw-api"
}

resource "aws_iam_instance_profile" "api" {
  name = "hwsw-api"
  role = aws_iam_role.api.name
}

resource "aws_security_group" "lb" {
  name_prefix = "hwsw-api-lb"
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port = 80
    protocol = "tcp"
    to_port = 80
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
}

resource "aws_lb" "lb" {
  name = "hwsw-api"
  security_groups = [
    aws_security_group.lb.id]
  subnets = aws_subnet.public.*.id
}

resource "aws_alb_listener" "atlassian" {
  load_balancer_arn = aws_lb.lb.arn
  port = "80"
  protocol = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.api.arn
    type = "forward"
  }
}

resource "aws_alb_target_group" "api" {
  vpc_id = aws_vpc.vpc.id
  port = 5678
  protocol = "HTTP"
  health_check {
    healthy_threshold = 3
    port = "5678"
    protocol = "HTTP"
    unhealthy_threshold = 10
    interval = 30
    timeout = 15
  }
}

resource "aws_autoscaling_group" "asg" {
  name = "hwsw-api"

  max_size = 1
  desired_capacity = 1
  min_size = 1
  vpc_zone_identifier = aws_subnet.public.*.id
  launch_configuration = aws_launch_configuration.asg_lc.id
  target_group_arns = [
    aws_alb_target_group.api.arn]
  health_check_grace_period = 300
  health_check_type = "ELB"
}

resource "aws_launch_configuration" "asg_lc" {
  image_id = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  iam_instance_profile = aws_iam_instance_profile.api.name
  security_groups = [
    aws_security_group.api.id]
  user_data = templatefile("userdata.sh.tpl", {
    authorized_gitlab_users = "matelang"
  })
}
