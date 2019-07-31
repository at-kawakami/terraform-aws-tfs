variable "region" {}
variable "lb_name" {
  default = ""
}
variable "internal_option" {
  default = ""
}
variable "lb_type" {
  default = ""
}

variable "env" {}
variable "ec2_security_groups" {
  type = "list"
}
variable "tag_service_type" {}
variable "ami" {}
variable "instance_type" {}
variable "key_name" {}
variable "service_name" {}
variable "vpc" {}
variable "web_asg_max_size" {}
variable "web_asg_min_size" {}
variable "web_asg_health_check_grace_period" {}
variable "web_asg_health_check_type" {}
variable "web_asg_desired_capacity" {}
variable "web_asg_force_delete" {}
variable "web_asg_placement_group" {}
variable "web_asg_launch_configuration" {}
variable "web_asg_vpc_zone_identifier" {
  type = "list"
}
variable "vpc_service_name" {}
variable "iam_instance_profile" {}
variable "web_asg_service_linked_role_arn" {}
variable "web_asg_default_cooldown" {}
variable "launch_template_name" {
  default = ""
}
variable "color" {}
variable "running_status" {}
variable "notification_target_arn" {}
variable "role_arn" {}
# Auto Scaling policy cloudwatch metric alarm
variable "cpu_high_threshold" {}
variable "cpu_low_threshold" {}
variable "cooldown" {}
variable "protect_from_scale_in" {}
