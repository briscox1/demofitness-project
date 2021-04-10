# Create ALB Listner - HTTPS

resource "aws_lb_listener" "dfsc_https" {
  load_balancer_arn = aws_lb.dfsc_alb.arn
  port = 443
  protocol = "HTTP"
  #ssl_policy        = "ELBSecurityPolicy-TLS-1-0-2015-04"
  #certificate_arn   = "arn:aws:acm:eu-west-1:233561773867:certificate/a96ed4f4-11bf-4148-8047-b71a0bb7ec8c"
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.dfsc-front-end-tg.arn
  }
}

# Create ALB Listner Backend Rule - HTTPS

resource "aws_lb_listener_rule" "dfsc_admin_https" {
  listener_arn = aws_lb_listener.dfsc_https.arn
  priority     = 100
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.dfsc-back-end-tg.arn
  }
    condition {
    path_pattern {
      values = ["/admin*"]
    }
  }
}