provider "aws" {
  access_key = "AKIAZMXKYZWJWCKVE4W7"
  secret_key = "FCImuSx2nAQfBXTS6FAzDhJ6h2gWj+Tcn/NUvqos"
  region     = "us-east-1"
}

resource "aws_security_group" "example_asg" {
  name        = "example-sg"
  description = "Example security group"
  vpc_id      = aws_vpc.example.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
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
  name_prefix          = "example-lc-"
  image_id             = "ami-053b0d53c279acc90"
  instance_type        = "t2.micro"
  security_groups      = [aws_security_group.example_asg.id]
  key_name             = "local_ec2"
  user_data            = "#cloud-config\n\npackages:\n  - httpd\n  - php\n\nruncmd:\n  - service httpd start\n"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "example" {
  name                      = "example-asg"
  min_size                  = 1
  max_size                  = 3
  desired_capacity          = 2
  launch_configuration      = aws_launch_configuration.example.name
  vpc_zone_identifier       = [aws_subnet.public.id]
  health_check_type         = "EC2"
  health_check_grace_period = 300

}

resource "aws_autoscaling_policy" "example_cpu_scaling" {
  name                   = "example-cpu-scaling-policy"
  autoscaling_group_name = aws_autoscaling_group.example.name
  policy_type            = "TargetTrackingScaling"
  estimated_instance_warmup = 300

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 50
  }
}
