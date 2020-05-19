output "vpc_id" {
  value = aws_vpc.secops_jupiter_env.id 

}
output "vpn_subnet_id" {
  value = aws_subnet.vpn-subnet.id
}

output "web_subnet_id" {
  value = aws_subnet.web-subnet.id
}

output "mgmt_subnet_id" {
  value = aws_subnet.mgmt-subnet.id
}


output "vpc_cidr" {
  value = aws_vpc.secops_jupiter_env.cidr_block 
}


output "s3_bucket_filebuck_id" {
  value = aws_s3_bucket.filebucket.id
}

output "aws_eip_vpn_id" {
  value = aws_eip.vpn-server_ip.id
}
output "aws_eip_vpn_public-ip" {
  value = aws_eip.vpn-server_ip.public_ip
}