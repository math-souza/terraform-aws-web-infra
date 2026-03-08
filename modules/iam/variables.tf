variable "role_name" {
	type = string
	default = "ec2-s3-access-role"
}

variable "policy_name" {
	type = string
	default = "ec2-s3-policy"
}

variable "instance_profile_name" {
	type = string
	default = "ec2-s3-profile"
}
