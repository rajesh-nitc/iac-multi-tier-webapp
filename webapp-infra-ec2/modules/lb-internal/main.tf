# instance iam profile

resource "aws_iam_instance_profile" "test_profile" {
  name = "test_profile_internal"
  role = "${aws_iam_role.ec2_iam_role.name}"
}

resource "aws_iam_role" "ec2_iam_role" {
  name               = "ec2_iam_role_internal"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "ec2.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ec2-read-only-policy-attachment" {
  role       = "${aws_iam_role.ec2_iam_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# autoscaling group ~ mig

resource "aws_security_group" "instance" {
  name   = "instance_internal"
  vpc_id = "${var.vpc_id}"

  ingress {
    from_port   = 3000 //nodejs server port
    to_port     = 3000 //nodejs server port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_launch_configuration" "example" {
  name_prefix     = "launch-config-"
  image_id        = "ami-0c55b159cbfafe1f0"
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.instance.id]

  iam_instance_profile = aws_iam_instance_profile.test_profile.name
  key_name             = "mykeypair2"

  user_data = templatefile("${path.module}/templates/startup-script.tmpl", {
    region            = "${var.region}",
    repo_name         = "${var.repo_server}",
    database_host     = "${var.database_host}",
    database_name     = "${var.database_name}",
    database_user     = "${var.database_user}",
    database_password = "${var.database_password}"
  })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "example" {
  name                 = "test1"
  launch_configuration = aws_launch_configuration.example.name
  vpc_zone_identifier  = ["${var.subnet1}", "${var.subnet2}"] // list of subnets

  target_group_arns = [aws_lb_target_group.asg.arn]
  health_check_type = "ELB"

  min_size = 1
  max_size = 2

  tag {
    key                 = "Name"
    value               = "internal-asg-group"
    propagate_at_launch = true
  }
}

# ALB

resource "aws_security_group" "alb" {
  name   = "alb-internal"
  vpc_id = "${var.vpc_id}"

  ingress {
    from_port   = 80 //alb port
    to_port     = 80 //alb port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "example" {
  name               = "alb-internal"
  internal           = true
  load_balancer_type = "application"
  subnets            = ["${var.subnet1}", "${var.subnet2}"]
  security_groups    = [aws_security_group.alb.id]

  # depends_on = ["aws_internet_gateway.main"]
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.example.arn
  port              = 80
  protocol          = "HTTP"
  # ssl_policy        = "ELBSecurityPolicy-2016-08"
  # certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"

  # By default, return a simple 404 page
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code  = 404
    }
  }
}

resource "aws_lb_target_group" "asg" {
  name     = "lb-target-group-internal"
  port     = 3000 // nodejs server port
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener_rule" "asg" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 100

  condition {
    field  = "path-pattern"
    values = ["*"]
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.asg.arn
  }
}

