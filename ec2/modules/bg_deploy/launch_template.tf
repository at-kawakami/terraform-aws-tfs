### EC2 LaunchTemplate
resource "aws_launch_template" "web_launch_template" {
  name = "${var.env}-${var.service_name}-${var.color}-launch-template"

  credit_specification {
    cpu_credits = "standard"
  }

  disable_api_termination = "false"

  iam_instance_profile {
    name = "${var.iam_instance_profile}"
  }

  image_id                             = "${var.ami}"
  instance_initiated_shutdown_behavior = "terminate"

  instance_market_options {
    market_type = "spot"
  }

  instance_type = "${var.instance_type}"
  key_name      = "${var.key_name}"

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = ["${var.ec2_security_groups}"]
    delete_on_termination       = true
  }

  tag_specifications {
    resource_type = "instance"

    tags {
      Name        = "${var.env}-${var.service_name}-${var.color}"
      ServiceType = "${var.tag_service_type}"
    }
  }
}
