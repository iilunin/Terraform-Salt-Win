variable "tags" {
	type = "map"

	default = {
	
		Name = "Terraform",
		Owner = "iilunin",
		SaltSlave = "SaltSlave",
		SaltMaster = "SaltMaster"
	
	}
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
