
#default vpc

/*data "aws_vpc" "selected" {
  id = "${var.default_vpc_id}" 
}*/

/*

# Create a VPC to launch our instances into
resource "aws_vpc" "default" {
  cidr_block = "10.0.0.0/16"
}

# Create an internet gateway to give our subnet access to the outside world
resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.default.id}"
}

# Grant the VPC internet access on its main route table
resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.default.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.default.id}"
}

# Create a subnet to launch our instances into
resource "aws_subnet" "default" {
  vpc_id                  = "${aws_vpc.default.id}"
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
}
*/


resource "aws_security_group" "win" {
  name        = "Terraform Win Security Group"
  description = "Used in the terraform"
#  vpc_id      = "${data.aws_vpc.selected.id}"

  # SALT access from anywhere
  ingress {
	from_port   = "${var.salt_minion_port}"
	to_port     = "${var.salt_minion_port}"
	protocol    = "tcp"
	cidr_blocks = ["0.0.0.0/0"]
  }

# SALT_MASTER access from anywhere
ingress {
	from_port   = 4505
	to_port     = 4506
	protocol    = "tcp"
	cidr_blocks = ["0.0.0.0/0"]
  }

# RDP access from anywhere
ingress {
	from_port   = 3389
	to_port     = 3389
	protocol    = "tcp"
	cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access from anywhere
  ingress {
	from_port   = 80
	to_port     = 80
	protocol    = "tcp"
	cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
	from_port   = 0
	to_port     = 0
	protocol    = "-1"
	cidr_blocks = ["0.0.0.0/0"]
  }

	tags {
		Name = "${var.tags["Name"]}",
		Owner = "${var.tags["Owner"]}"
	}
}

resource "aws_security_group" "salt_master" {
  name        = "Terraform SaltMaster Security Group"
  description = "Used in the terraform"

  # SSH access from anywhere
  ingress {
	from_port   = 22
	to_port     = 22
	protocol    = "tcp"
	cidr_blocks = ["0.0.0.0/0"]
  }

# SALT_MASTER access from anywhere
ingress {
	from_port   = 4505
	to_port     = 4506
	protocol    = "tcp"
	cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
	from_port   = 0
	to_port     = 0
	protocol    = "-1"
	cidr_blocks = ["0.0.0.0/0"]
  }

	tags {
		Name = "${var.tags["Name"]}",
		Owner = "${var.tags["Owner"]}"
	}
}
