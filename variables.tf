variable "tags" {
	type = "map"

	default = {
	
		Name = "Terraform",
		Owner = "iilunin",
		SaltSlave = "SaltSlave",
		SaltMaster = "SaltMaster"
	
	}
}

variable "aws_instance_type"{
#  default = "t2.large"
  default = "m4.xlarge"
}

variable "new_pass" {
	default = "newPwd123!"
}

variable "key_name" {
	default = "trf"
}

variable "public_key_path" {
	default = "~/.ssh/trf.pub"
}

variable "templates_folder" {
	default = "templates"
}

variable "output_folder" {
	default = "output"
}

variable "ansible_file" {
	default = "output/ansible_ping"
}

variable "ansible_ping_res" {
	default = "output/ping.txt"
}

variable "default_vpc_id"{
	default = "vpc-470f6622"
}

variable "winrm_port"{
	default = "5985"
}
