resource "aws_lb" "logstash" {
  name               = "${var.logstash_cluster}-logstash-lb"
  security_groups    = ["${aws_security_group.logstash_elb_security_group.id}"]
  subnets            = ["${var.public_subnets}"]
  internal           = false
  load_balancer_type = "application"
  idle_timeout       = 400
  tags               = "${merge(var.global_tags,map("Name","${var.logstash_cluster}-logstash-lb"))}"
}

resource "aws_lb_listener" "logstash" {
  load_balancer_arn = "${aws_lb.logstash.arn}"
  port              = "5044"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_lb_target_group.logstash.arn}"
    type             = "forward"
  }
}

resource "aws_lb_target_group" "logstash" {
  name     = "logstash-${var.logstash_cluster}-lb-tg"
  port     = 5044
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"
}

resource "aws_autoscaling_attachment" "logstash" {
  autoscaling_group_name = "${aws_autoscaling_group.client_nodes.id}"
  alb_target_group_arn   = "${aws_lb_target_group.logstash.arn}"
}
