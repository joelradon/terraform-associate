variable "region" {
  default     = "us-east-1"
  description = "AWS Region"
}

variable "vpc_cidr" {
  default     = "10.0.0.0/16"
  description = "VPC CIDR Block"
}

variable "vpn_subnet_cidr" {
  default     = "10.0.1.0/24"
  description = "VPN Subnet 1 CIDR"
}

variable "web_subnet_cidr" {
  default     = "10.0.2.0/24"
  description = "Web Subnet 2 CIDR"
}


variable "vpn_az" {
  description = "VPN Subnet Availability Zone"
}

variable "mgmt_subnet_cidr" {
  default     = "10.0.6.0/24"
  description = "MGMT Subnet 3 CIDR"
}


variable "mgmt_az" {
  description = "VPN Subnet Availability Zone"
}

variable "web_az" {
  description = "VPN Subnet Availability Zone"
}

variable "my_ip" {
  description = "NY IP"
}
variable "remote_state_key" {}




variable "project_name" {}


variable "remote_state_bucket" {}

variable "remote_state_region" {}


variable "arn" {}
variable "trailprefix" {}
