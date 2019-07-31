### data
data "aws_vpc" "selected" {
  tags {
    Name = "${var.vpc}"
  }
}

data "aws_subnet_ids" "selected" {
  vpc_id = "${data.aws_vpc.selected.id}"

}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

### Provider
provider "aws" {
  profile = "terraform_user"
  region  = "${var.region}"
}

### ALB ##################
resource "aws_lb" "web-alb" {
  name                       = "${var.env}-${var.service_name}-alb"
  internal                   = "${var.internal_option}"
  load_balancer_type         = "${var.lb_type}"
  security_groups            = ["${var.web_alb_sg}"]
  subnets                    = ["${var.web_alb_subnet}"]
  enable_deletion_protection = false

  tags = {
    Environment = "${var.env}"
  }
}

### ALB Target group ##################
resource "aws_lb_target_group" "web_alb_tg" {
  name     = "${var.env}-${var.service_name}-tg"
  port     = "${var.web_alb_tg_port}"
  protocol = "${var.web_alb_tg_protocol}"
  vpc_id   = "${data.aws_vpc.selected.id}"
  health_check {
    path     = "${var.alb_tg_health_check_path}"
  }
  deregistration_delay = "${var.alb_tg_deregistration_delay}"
}

### ALB Listener
resource "aws_lb_listener" "alb_listner" {
  load_balancer_arn = "${aws_lb.web-alb.arn}"
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "${var.certificate_arn}"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.web_alb_tg.arn}"
  }

  depends_on = ["aws_lb.web-alb"]
}

output "foo" {
  value = "${data.aws_vpc.selected.id}"
}
