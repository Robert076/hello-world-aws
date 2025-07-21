provider "aws" {
  region = "eu-central-1" 
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = file("~/.ssh/id_rsa.pub") 
}

resource "aws_security_group" "allow_8080" {
  name        = "allow_8080"
  description = "Allow inbound traffic on port 8080"

  ingress = [
  {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    security_groups  = []
    self             = false
    description      = "Allow SSH"
  },
  {
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    security_groups  = []
    self             = false
    description      = "Allow 8080 from everywhere"
  }
]


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "docker_app" {
  ami                    = "ami-01fef3b730849ff89"
  instance_type          = "t2.medium"
  associate_public_ip_address = true
  key_name               = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.allow_8080.id]

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              amazon-linux-extras install docker -y
              service docker start
              usermod -a -G docker ec2-user
              docker run -d -p 8080:8080 robert076/hello-world-aws:v1
              EOF

  tags = {
    Name = "HelloWorldDocker"
  }
}

output "public_ip" {
  value = aws_instance.docker_app.public_ip
}
