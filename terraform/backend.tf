terraform {
  backend "s3" {
    bucket         = "terraform-bucket-gg"
    key            = "terraform.tfstate"
    region         = "us-east-1"  
    encrypt        = true
    dynamodb_table = "terraform-gg"
    acl            = "private"
  }
}