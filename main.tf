provider "aws" {
  region     = "us-east-1"
}

/*
resource "aws_key_pair" "auth" {
  key_name   = "${var.key_name}"
  public_key = "${file(var.public_key_path)}"
}
*/


#ubuntu salt master
resource "aws_instance" "salt_master" {
  ami           = "ami-2d39803a" 
  instance_type = "${var.aws_instance_type}"

	tags {
		Name = "${var.tags["Name"]}",
		Salt = "${var.tags["SaltMaster"]}",
		Owner = "${var.tags["Owner"]}"
	}

#	key_name = "${aws_key_pair.auth.id}"
	key_name = "${var.key_name}"

	vpc_security_group_ids = ["${aws_security_group.salt_master.id}"]
}

resource "null_resource" "get_salt_master_fpkey"{

	connection {
		type = "ssh",
		host = "${aws_instance.salt_master.public_ip}",
		user = "ubuntu",
		private_key = "${file("trf.pem")}"
	}

	provisioner "remote-exec"{
		inline = [
		"curl -L https://bootstrap.saltstack.com -o install_salt.sh",
		"sudo sh install_salt.sh -P -M -N",
		"sudo salt-key -F master > salt_master_key.txt"
		]
	}

	#sudo salt-key -A -y

	provisioner "local-exec"{
		command = "scp -i \"trf.pem\" -o \"StrictHostKeyChecking no\" ubuntu@${aws_instance.salt_master.public_ip}:salt_master_key.txt output/salt_master_key.txt"
	}

	provisioner "local-exec"{
		command = "python get_finger_print.py output/salt_master_key.txt > output/fp.txt"
	}

	depends_on=["aws_instance.salt_master"]
}



resource "aws_instance" "win" {
  ami           = "ami-ee7805f9"
  instance_type = "${var.aws_instance_type}"

	tags {
		Name = "${var.tags["Name"]}",
		Salt = "${var.tags["SaltSlave"]}",
		Owner = "${var.tags["Owner"]}"
	}

#	key_name = "${aws_key_pair.auth.id}"
	key_name = "${var.key_name}"
  
	user_data = "${data.template_file.win_user_data.rendered}"
	vpc_security_group_ids = ["${aws_security_group.win.id}"]
}

/*
resource "null_resource" "ansible_ping_test"{
	
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
*/

resource "null_resource" "salt_minion_config" {

  connection {
		type = "winrm"
		port = "5985"
		user = "Administrator"
		password = "${var.new_pass}"
		host = "${aws_instance.win.public_ip}"
		insecure = "true"
		timeout = "10m"
	}

	provisioner "remote-exec" {
		inline = [
		"PowerShell curl https://repo.saltstack.com/windows/Salt-Minion-2016.3.3-AMD64-Setup.exe -OutFile C:\\temp\\Salt-Minion-2016.3.3-AMD64-Setup.exe ; C:\\temp\\Salt-Minion-2016.3.3-AMD64-Setup.exe /S /master=${aws_instance.salt_master.public_ip} /minion-name=win_minion /start-service=0",
		"PowerShell Start-Sleep 20"
		]
	}

	provisioner "file" {
		source = "output/fp.txt"
		destination = "c:/temp/fp.txt"
		#destination = "c:/salt/conf/minion"
	}

	provisioner "remote-exec" {
		inline = [
		"PowerShell type c:/temp/fp.txt >> c:/salt/conf/minion",
#		"PowerShell echo \"${file("output/fp.txt")}\" >> c:/salt/conf/minion",
		"PowerShell Start-Service salt-minion",
		"PowerShell Start-Sleep 20"]
	}

#	depends_on=["null_resource.ansible_ping_test"]
	depends_on=["aws_instance.win", "null_resource.get_salt_master_fpkey"]
}

resource "null_resource" "salt_master_accept_minion_keys"{

	connection {
		type = "ssh",
		host = "${aws_instance.salt_master.public_ip}",
		user = "ubuntu",
		private_key = "${file("trf.pem")}",
		timeout = "10m"
	}

#change to python script running on salt-master

	provisioner "remote-exec" {
		inline = [
		"sleep 60",
		"sudo salt-key -F master",
		"sleep 10",
		"sudo salt-key -A -y",
		"sleep 10",
		"sudo salt '*' test.ping --timeout=500"
		]
	}

	depends_on=["null_resource.salt_minion_config"]
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