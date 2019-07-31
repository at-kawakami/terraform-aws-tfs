### Provider
provider "aws" {
  profile = "terraform_user"
  region  = "${var.region}"
}

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

### AutoScalingGroup EC2 Web
resource "aws_autoscaling_group" "web_asg" {
  name                      = "${var.env}-${var.service_name}-${var.color}-asg"
  max_size                  = "${var.web_asg_max_size}"
  min_size                  = "${var.web_asg_min_size}"
  health_check_grace_period = "${var.web_asg_health_check_grace_period}"
  health_check_type         = "${var.web_asg_health_check_type}"
  desired_capacity          = "${var.web_asg_desired_capacity}"
  force_delete              = "${var.web_asg_force_delete}"
  placement_group           = "${var.web_asg_placement_group}"
  default_cooldown          = "${var.web_asg_default_cooldown}"
  protect_from_scale_in     = "${var.protect_from_scale_in}"

  launch_template {
    id      = "${aws_launch_template.web_launch_template.id}"
    version = "$$Latest"
  }

  vpc_zone_identifier = ["${var.web_asg_vpc_zone_identifier}"]

  tag {
    key                 = "RunningStatus"
    value               = "${var.running_status}"
    propagate_at_launch = false
  }
}

resource "aws_autoscaling_lifecycle_hook" "launching" {
  name                    = "launch_${var.env}_${var.service_name}_lifecycle_hook"
  autoscaling_group_name  = "${aws_autoscaling_group.web_asg.name}"
  default_result          = "CONTINUE"
  heartbeat_timeout       = 7200
  lifecycle_transition    = "autoscaling:EC2_INSTANCE_LAUNCHING"
  notification_target_arn = "${var.notification_target_arn}"
  role_arn                = "${var.role_arn}"
}

resource "aws_autoscaling_lifecycle_hook" "terminate" {
  name                    = "terminate_${var.env}_${var.service_name}_lifecycle_hook"
  autoscaling_group_name  = "${aws_autoscaling_group.web_asg.name}"
  default_result          = "CONTINUE"
  heartbeat_timeout       = 7200
  lifecycle_transition    = "autoscaling:EC2_INSTANCE_TERMINATING"
  notification_target_arn = "${var.notification_target_arn}"
  role_arn                = "${var.role_arn}"
}

### AutoScalingPolicy
resource "aws_autoscaling_policy" "reduce_web_autoscaling_policy" {
  name                      = "reduce_instance"
  autoscaling_group_name    = "${aws_autoscaling_group.web_asg.name}"
  adjustment_type           = "ChangeInCapacity"
  scaling_adjustment        = "-1"
  cooldown                  = "${var.cooldown}"
  estimated_instance_warmup = "0"
  policy_type               = "SimpleScaling"
}

resource "aws_autoscaling_policy" "increase_web_autoscaling_policy" {
  name                      = "increace_instance"
  autoscaling_group_name    = "${aws_autoscaling_group.web_asg.name}"
  adjustment_type           = "ChangeInCapacity"
  scaling_adjustment        = "1"
  cooldown                  = "${var.cooldown}"
  estimated_instance_warmup = "0"
  policy_type               = "SimpleScaling"
}

### CloudWatch metric alarm for AutoScaling
resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "${var.env}-${var.service_name}-${var.color}-Ec2-ASG-CPUHigh"
  alarm_description   = "AutoScaling alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "${var.cpu_high_threshold}"

  dimensions {
    AutoScalingGroupName = "${aws_autoscaling_group.web_asg.name}"
  }

  actions_enabled = true
  alarm_actions   = ["${aws_autoscaling_policy.increase_web_autoscaling_policy.arn}"]
}

resource "aws_cloudwatch_metric_alarm" "cpu_low" {
  alarm_name          = "${var.env}-${var.service_name}-${var.color}-Ec2-ASG-CPULow"
  alarm_description   = "AutoScaling alarm"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "${var.cpu_low_threshold}"

  dimensions {
    AutoScalingGroupName = "${aws_autoscaling_group.web_asg.name}"
  }

  actions_enabled = true
  alarm_actions   = ["${aws_autoscaling_policy.reduce_web_autoscaling_policy.arn}"]
}
