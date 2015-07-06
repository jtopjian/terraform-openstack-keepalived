resource "openstack_compute_keypair_v2" "keepalived" {
  name = "keepalived"
  public_key = "${file("key/id_rsa.pub")}"
}

resource "openstack_compute_secgroup_v2" "keepalived" {
  name = "keepalived"
  description = "Rules for keepalived tests"
  rule {
    from_port = 22
    to_port = 22
    ip_protocol = "tcp"
    cidr = "0.0.0.0/0"
  }
  rule {
    from_port = 22
    to_port = 22
    ip_protocol = "tcp"
    cidr = "::/0"
  }
  rule {
    from_port = 80
    to_port = 80
    ip_protocol = "tcp"
    cidr = "0.0.0.0/0"
  }
  rule {
    from_port = 80
    to_port = 80
    ip_protocol = "tcp"
    cidr = "::/0"
  }
  rule {
    from_port = 1
    to_port = 65535
    ip_protocol = "tcp"
    self = true
  }
  rule {
    from_port = 1
    to_port = 65535
    ip_protocol = "udp"
    self = true
  }
}

resource "openstack_compute_servergroup_v2" "keepalived" {
  name = "keepalived"
  policies = ["anti-affinity"]
}

resource "openstack_compute_floatingip_v2" "keepalived" {
  pool = "nova"
}

resource "openstack_compute_instance_v2" "keepalived-1" {
  name = "keepalived-1"
  image_name = "Ubuntu 14.04"
  flavor_name = "m1.tiny"
  key_pair = "${openstack_compute_keypair_v2.keepalived.name}"
  security_groups = ["${openstack_compute_secgroup_v2.keepalived.name}"]
  scheduler_hints {
    group = "${openstack_compute_servergroup_v2.keepalived.id}"
  }
}

resource "openstack_compute_instance_v2" "keepalived-2" {
  name = "keepalived-2"
  image_name = "Ubuntu 14.04"
  flavor_name = "m1.tiny"
  key_pair = "${openstack_compute_keypair_v2.keepalived.name}"
  security_groups = ["${openstack_compute_secgroup_v2.keepalived.name}"]
  scheduler_hints {
    group = "${openstack_compute_servergroup_v2.keepalived.id}"
  }
}

resource "template_file" "keepalived-1" {
  filename = "templates/keepalived.conf.tpl"
  vars {
    my_uuid = "${openstack_compute_instance_v2.keepalived-1.id}"
    peer_uuid = "${openstack_compute_instance_v2.keepalived-2.id}"
    my_ip = "${openstack_compute_instance_v2.keepalived-1.access_ip_v4}"
    peer_ip = "${openstack_compute_instance_v2.keepalived-2.access_ip_v4}"
    floating_ip = "${openstack_compute_floatingip_v2.keepalived.address}"
    my_state = "MASTER"
    my_priority = "101"
  }

  connection {
    user = "ubuntu"
    key_file = "key/id_rsa"
    host = "${openstack_compute_instance_v2.keepalived-1.access_ip_v6}"
  }

  provisioner "local-exec" {
    command = "echo \"${template_file.keepalived-1.rendered}\" > scripts/keepalived-1.conf"
  }

  provisioner file {
    source = "scripts"
    destination = "scripts"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo bash /home/ubuntu/scripts/bootstrap.sh"
    ]
  }
}

resource "template_file" "keepalived-2" {
  filename = "templates/keepalived.conf.tpl"
  vars {
    my_uuid = "${openstack_compute_instance_v2.keepalived-2.id}"
    peer_uuid = "${openstack_compute_instance_v2.keepalived-1.id}"
    my_ip = "${openstack_compute_instance_v2.keepalived-2.access_ip_v4}"
    peer_ip = "${openstack_compute_instance_v2.keepalived-1.access_ip_v4}"
    floating_ip = "${openstack_compute_floatingip_v2.keepalived.address}"
    my_state = "BACKUP"
    my_priority = "100"
  }

  connection {
    user = "ubuntu"
    key_file = "key/id_rsa"
    host = "${openstack_compute_instance_v2.keepalived-2.access_ip_v6}"
  }

  provisioner "local-exec" {
    command = "echo \"${template_file.keepalived-2.rendered}\" > scripts/keepalived-2.conf"
  }

  provisioner file {
    source = "scripts"
    destination = "scripts"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo bash /home/ubuntu/scripts/bootstrap.sh"
    ]
  }
}
