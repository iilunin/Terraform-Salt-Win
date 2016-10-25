output "salt_master.ip" {
  value = "ssh -i \"trf.pem\" ubuntu@${aws_instance.salt_master.public_ip}"
}


output "win.ip" {
  value = "${aws_instance.win.public_ip}"
}

/*
output "ansible_ping" {
  value = "${file("${var.ansible_ping_res}")}"
}
*/
