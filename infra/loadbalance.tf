
# Create network load balancer
resource "aws_lb" "my_lb" {
  name               = "my-load-balancer"
  internal           = false
  load_balancer_type = "network"

  subnet_mapping {
    subnet_id = aws_subnet.public_subnet.id
  }
}

# Create listener for network load balancer
resource "aws_lb_listener" "my_lb_listener" {
  load_balancer_arn = aws_lb.my_lb.arn
  port              = 80
  protocol          = "TCP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.my_lb_target_group.arn
  }
}

# Create target group for network load balancer
resource "aws_lb_target_group" "my_lb_target_group" {
  name_prefix       = "target"
  port              = 80
  protocol          = "TCP"
  vpc_id            = aws_vpc.my_vpc.id
}

# Register EC2 instance with target group
resource "aws_lb_target_group_attachment" "my_lb_target_group_attachment" {
  target_group_arn = aws_lb_target_group.my_lb_target_group.arn
  target_id        = aws_instance.my_ec2_instance.id
}
