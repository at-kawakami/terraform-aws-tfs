terraform {
  backend "s3" {
    bucket  = "production-terraform-tfstate"
    region  = "ap-northeast-1"
    profile = "terraform_user"
    key     = "production-web-blue-ec2.tfstate"
    encrypt = true
  }
}

module "production-web-blue" {
  # common
  color            = "blue"
  region           = "ap-northeast-1"
  env              = "production"
  service_name     = "web"
  vpc              = "hogeo-no-VPC"
  vpc_service_name = "hogeo-no-VPC Public Subnet"
  source           = "../../../../modules/bg_deploy"

  # ec2 settings web
  ami                  = "ami-xxxxxxxxxxxxxxxxx"
  instance_type        = "c4.large"
  key_name             = "prd-key"
  ec2_security_groups  = ["sg-xxxxxxxxxxxxxxxxx"]
  tag_service_type     = "web"
  iam_instance_profile = "terraform"

  # web_asg
  web_asg_max_size                  = "3"
  web_asg_min_size                  = "3"
  web_asg_health_check_grace_period = "120"
  web_asg_health_check_type         = "EC2"
  web_asg_desired_capacity          = "3"
  web_asg_force_delete              = "true"
  web_asg_placement_group           = ""
  web_asg_launch_configuration      = ""
  web_asg_vpc_zone_identifier       = ["subnet-xxxxxxxxxxxxxxxxx", "subnet-xxxxxxxxxxxxxxxxx"]
  web_asg_service_linked_role_arn   = "arn:aws:iam::xxxxxxxxxxxx:instance-profile/terraform"
  web_asg_default_cooldown          = "600"
  running_status                    = "Standby"
  notification_target_arn           = "arn:aws:sqs:ap-northeast-1:xxxxxxxxxxxx:production-web-autoscaling-queue"
  role_arn                          = "arn:aws:iam::xxxxxxxxxxxx:role/terraform"
  protect_from_scale_in             = "true"

  # cloudwatch_metric_alarm
  cpu_high_threshold                = "75"
  cpu_low_threshold                 = "15"
  cooldown                          = "600"
}
