terraform {
  backend "s3" {
    bucket  = "production-terraform-tfstate"
    region  = "ap-northeast-1"
    profile = "terraform_user"
    key     = "production-alb-web.tfstate"
    encrypt = true
  }
}

module "production-web-initial" {
  # common
  env              = "production"
  service_name     = "web"
  vpc              = "hogeo-no-VPC"
  certificate_arn  = "arn:aws:acm:ap-northeast-1:xxxxxxxxxxxx:certificate/xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  # alb settings
  region          = "ap-northeast-1"
  source          = "../../../../modules/initial"
  lb_name         = "production-web-alb"
  internal_option = "false"
  lb_type         = "application"
  web_alb_sg      = ["sg-xxxxxxxxxxxxxxxxx"]
  # alb target group settings
  web_alb_tg_port             = 80
  web_alb_tg_protocol         = "HTTP"
  alb_tg_health_check_path    = "/health_check"
  alb_tg_deregistration_delay = "30"

  #VpcId取れるなら、ここも自動で取れるはず
  web_alb_subnet = ["subnet-xxxxxxxxxxxxxxxxx", "subnet-yyyyyyyyyyyyyyyyy"]
}
