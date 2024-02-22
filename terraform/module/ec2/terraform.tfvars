aws_region                    = "us-east-1"
ec2_instance_ami              = "ami-0c7217cdde317cfec"
ec2_instance_type             = "t2.micro"
sg_name                       = "test"
instance_name                 = "test"
vpc_id                        = "vpc-057661e092e536f51"
subnet_id                     = "subnet-0efba499e740dd3a1"
root_volume_size              = 10
instance_count                = 1
enable_termination_protection = false
ec2_instance_key_name         = "terraform-aws"
allowed_ports = [
  22,
  80,
  8080
]
tags = {
  "id"             = "1983"
  "owner"          = "s5wesley"
  "teams"          = "DEL"
  "environment"    = "dev"
  "project"        = "del"
  "create_by"      = "Terraform"
  "cloud_provider" = "aws"
}