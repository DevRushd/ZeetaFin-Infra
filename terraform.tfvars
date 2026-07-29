aws_region    = "eu-west-1"
vpc_cidr      = "10.0.0.0/16"
name_prefix   = "gridsynk"
my_ip         = "YOUR_IP/32"
instance_type = "t3.small"
key_pair      = "YOUR_KEYPAIR_NAME"
asg_min_size = 1
asg_max_size = 4
asg_desired_capacity = 2

