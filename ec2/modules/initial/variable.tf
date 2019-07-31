# common
variable "vpc" {}
variable "region" {}
variable "env" {}
# alb settings
variable "certificate_arn" {}
variable "lb_name" {
  default = ""
}
variable "internal_option" {}
variable "lb_type" {}
variable "web_alb_sg" {
  type = "list"
}
variable "web_alb_subnet" {
  type = "list"
}
variable "service_name" {}
# alb target group settings
variable "web_alb_tg_port" {}
variable "web_alb_tg_protocol" {}
variable "alb_tg_deregistration_delay" {
  default = "300"
}
variable "alb_tg_health_check_path" {}
