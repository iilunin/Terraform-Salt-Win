provider "aws" {
  region     = "us-east-1"
}

/*
resource "aws_key_pair" "auth" {
  key_name   = "${var.key_name}"
  public_key = "${file(var.public_key_path)}"
}
*/

/*
resource "aws_instance" "salt_master" {
#ubuntu
  ami           = "ami-2d39803a" 
  instance_type = "t2.nano"

	tags {
		"${var.tags["KEY_NAME"]}" = "${var.tags[var.tags["KEY_NAME"]]}",
		"${var.tags["KEY_SALT"]}" = "${var.tags["SaltMaster"]}"
	}

#	key_name = "${aws_key_pair.auth.id}"
	key_name = "${var.key_name}"
  

#	user_data = <<EOF
#	EOF

}
*/

resource "aws_instance" "win" {
  ami           = "ami-ee7805f9"
  instance_type = "t2.micro"

	tags {
		Name = "${var.tags["Name"]}",
		Salt = "${var.tags["SaltSlave"]}",
		Owner = "${var.tags["Owner"]}"
	}

#	key_name = "${aws_key_pair.auth.id}"
	key_name = "${var.key_name}"
  
	user_data = "${data.template_file.win_user_data.rendered}"
}

output "aws_instance.ip" {
  value = "${aws_instance.win.public_ip}"
}

output "ansible_ping" {
  value = "${file("${var.ansible_ping_res}")}"
}

resource "null_resource" "ansible_ping" {

	provisioner "local-exec" "ansible" {
		command = <<EOF
		rm ${var.ansible_file}
		mkdir ${var.output_folder}
		echo '${data.template_file.ansible_ping.rendered}' > ${var.ansible_file}
		sleep 240
		ansible win -i ${var.ansible_file} -m win_ping > ${var.ansible_ping_res}
		sleep 3
		EOF
	}

	depends_on=["aws_instance.win"]
}

/*
resource "null_resource" "salt_minion" {

  connection {
		type = "winrm"
		port = "5985"
		user = "Administrator"
		password = "${var.new_pass}"
		host = "${aws_instance.win.public_ip}"
		insecure = "true"
	}

	provisioner "remote-exec" {
        inline = [
        "PowerShell curl https://repo.saltstack.com/windows/Salt-Minion-2016.3.3-AMD64-Setup.exe -OutFile c:\\temp\\Salt-Minion-2016.3.3-AMD64-Setup.exe",
        "PowerShell c:\\temp\\Salt-Minion-2016.3.3-AMD64-Setup.exe /S /master=yoursaltmaster /minion-name=yourminionname /start-service=1"
        ]
    }

	depends_on=["aws_instance.win"]
}

*/