data "template_file" "ansible_ping" {
	template = "${file("${var.templates_folder}/ansible_ping.tmpl")}" 

	vars {
		ansible_ssh_host = "${aws_instance.win.public_ip}"
	}
}

data "template_file" "win_user_data" {
	template = "${file("${var.templates_folder}/win_user_data.tmpl")}" 

	vars {
		minion_port = "5985"
		admin_pass = "${var.new_pass}"
	}
}