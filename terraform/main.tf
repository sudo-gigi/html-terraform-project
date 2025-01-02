# Terraform configuration file for AWS infrastructure

# Specify the provider
provider "aws" {
  region = "us-east-1"
}

# Resource to create a security group that allows SSH (port 22) and HTTP (port 80) access
#resource "aws_security_group" "web_server_sg" {
#  name        = "web-server-sg"
#  description = "Allow SSH and HTTP access"

#  ingress {
#    from_port   = 22
#    to_port     = 22
#    protocol    = "tcp"
#    cidr_blocks = ["0.0.0.0/0"] # Allows SSH from anywhere
#  }

#  ingress {
#    from_port   = 80
#    to_port     = 80
#    protocol    = "tcp"
#    cidr_blocks = ["0.0.0.0/0"] # Allows HTTP from anywhere
#  }

#  egress {
#    from_port   = 0
#    to_port     = 0
#    protocol    = "-1"
#    cidr_blocks = ["0.0.0.0/0"] # Allows all outbound traffic
#  }
#}
# resource "aws_dynamodb_table" "terraform_lock" {
 # name         = "terraform-gg"
 # hash_key     = "LockID"
 # billing_mode = "PAY_PER_REQUEST"
  # attribute {
  #   name = "LockID"
  #   type = "S"
#   }
# }

# Resource to create an EC2 instance
resource "aws_instance" "web_server" {
  ami           = "ami-0885b1f6bd170450c" # Ubuntu Server 22.04 LTS (Free Tier Eligible)
  instance_type = "t2.micro"

  # Attach the security group to the EC2 instance
  security_groups = [aws_security_group.web_server_sg.name]

  # Attach the HTML directory as user data
  user_data = <<-EOF
              #!/bin/bash
              sudo apt update && sudo apt upgrade -y
              sudo apt install nginx -y

              echo "Deploying the landing page"
              cat <<-HTML > /var/www/html/index.html
              <!DOCTYPE html>
              <html lang="en">
              <head>
                  <meta charset="UTF-8">
                  <meta name="viewport" content="width=device-width, initial-scale=1.0">
                  <title>Glory Eziani</title>
                  <style>
                      body {
                          font-family: Arial, sans-serif;
                          text-align: center;
                          padding: 50px;
                          background: linear-gradient(to right, #d291bc, #957dad);
                          color: #ffffff;
                      }
                      h1 {
                          font-size: 2.5rem;
                      }
                      p {
                          font-size: 1.2rem;
                      }
                      <!--
                      .witty-text {
                          margin-top: 30px;
                          font-style: italic;
                          font-weight: bold;
                          color: #ffffff;
                          text-shadow: 1px 1px 2px #000000;
                      }
                      <!--
                  </style>
              </head>
              <body>
                  <h1>Hi, I'm Glory Eziani 👩‍💻</h1>
                  <p>Welcome to my landing page powered by Terraform, AWS CodePipeline, and EC2 🚀</p>
                  <p>I'm passionate about Cloud Computing and DevOps 🌥️.</p>
                  <!-- <p class="witty-text">Detect any changes? Yup, you guessed right! 🚨</p> -->
              </body>
              </html>
              HTML
              sudo systemctl start nginx
              sudo systemctl enable nginx
              sudo chown www-data:www-data /var/www/html/index.html
              sudo chmod 644 /var/www/html/index.html

              EOF

  # Tags for better identification
  tags = {
    Name = "web-server"
  }
}

# Elastic IP for the EC2 instance
resource "aws_eip" "web_server_eip" {
  instance = aws_instance.web_server.id


  tags = {
    Name = "web-server-eip"
  }
}

# Output the Elastic IP so you can access it later
output "elastic_ip" {
  value = aws_eip.web_server_eip.public_ip
}
