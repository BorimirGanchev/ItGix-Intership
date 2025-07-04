terraform {
    backend "s3" {
        bucket = "bori-itgx-intership-remote-state"
        key    = "terraform.tfstate"
        region = "eu-central-1"
        encrypt = true
    }
}

# Fetch subnets in the given VPC
data "aws_subnets" "example" {
    filter {
        name   = "vpc-id"
        values = ["vpc-03787e796e0dcde99"]
    }
}

# Security Group for EC2 and ALB
resource "aws_security_group" "web_sg" {
    name        = "web_sg"
    description = "Allow HTTP traffic"
    vpc_id      = "vpc-03787e796e0dcde99"

    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

# Web Server 1
resource "aws_instance" "webserver1" {
    ami                    = "ami-0b65d57be27e8f4e7"
    instance_type          = "t2.micro"
    subnet_id              = data.aws_subnets.example.ids[0]
    key_name               = "bori-itgix"
    vpc_security_group_ids = [aws_security_group.web_sg.id]

    user_data = <<-EOF
        #!/bin/bash
        sudo yum update -y
        sudo yum install httpd -y
        sudo systemctl start httpd
        sudo systemctl enable httpd
        echo "web 1" | sudo tee /var/www/html/index.html
    EOF
}

# Web Server 2
resource "aws_instance" "webserver2" {
    ami                    = "ami-0b65d57be27e8f4e7"
    instance_type          = "t2.micro"
    subnet_id              = data.aws_subnets.example.ids[1]
    key_name               = "bori-itgix"
    vpc_security_group_ids = [aws_security_group.web_sg.id]

    user_data = <<-EOF
        #!/bin/bash
        sudo yum update -y
        sudo yum install httpd -y
        sudo systemctl start httpd
        sudo systemctl enable httpd
        echo "web 2" | sudo tee /var/www/html/index.html
    EOF
}

# Load Balancer
resource "aws_lb" "lb1" {
    name               = "lb1"
    internal           = false
    load_balancer_type = "application"
    subnets            = data.aws_subnets.example.ids
    security_groups    = [aws_security_group.web_sg.id]
}

# Target Group
resource "aws_lb_target_group" "tg1" {
    name     = "tg1"
    port     = 80
    protocol = "HTTP"
    vpc_id   = "vpc-03787e796e0dcde99"

    health_check {
        path = "/"
    }
}

# Listener
resource "aws_lb_listener" "tg1" {
    load_balancer_arn = aws_lb.lb1.arn
    port              = 80
    protocol          = "HTTP"

    default_action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.tg1.arn
    }
}

# Attach EC2 instances to target group
resource "aws_lb_target_group_attachment" "tgw1" {
    target_group_arn = aws_lb_target_group.tg1.arn
    target_id        = aws_instance.webserver1.id
    port             = 80
}

resource "aws_lb_target_group_attachment" "tgw2" {
    target_group_arn = aws_lb_target_group.tg1.arn
    target_id        = aws_instance.webserver2.id
    port             = 80
}
