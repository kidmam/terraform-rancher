variable "name" {}

variable "subnet_ids" {}

variable "security_groups" {}

variable "vpc_id" {}

variable "ssl_certificate_arn" {}

resource "aws_alb" "rancher_management" {
  name            = "${var.name}-alb"
  internal        = false
  security_groups = ["${split(",", var.security_groups)}"]
  subnets         = ["${split(",", var.subnet_ids)}"]
}

resource "aws_alb_target_group" "rancher_management" {
  name     = "${var.name}-target-group"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"
}

resource "aws_alb_listener" "rancher_ha" {
  load_balancer_arn = "${aws_alb.rancher_management.arn}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2015-05"
  certificate_arn   = "${var.ssl_certificate_arn}"

  default_action {
    target_group_arn = "${aws_alb_target_group.rancher_management.arn}"
    type             = "forward"
  }
}

output "management_id" {
  value = "${aws_alb.rancher_management.id}"
}

output "target_group_arn" {
  value = "${aws_alb_target_group.rancher_management.arn}"
}