resource "aws_eip" "vpn-server_ip" {
  vpc      = true

  tags = {
    Name = "${var.project_name } vpn-ip"
  }

}


#resource "aws_eip" "http-server_ip" {
 # instance = aws_instance.http-server.id
 # vpc      = true
 # tags     = {Name = "sec-lab_http-server_ip"}
#}

