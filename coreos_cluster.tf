provider "aws" {
    access_key = "${var.access_key}"
    secret_key = "${var.secret_key}"
    region = "${var.region}"
}

resource "aws_security_group" "coreos" {
    name = "coreos"
    description = "CoreOS security group"
    tags {
        Name = "${var.tag_name}-sg"
    }

    ingress {
        from_port = "22"
        to_port = "22"
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_security_group_rule" "ingress_4001" {
    type = "ingress"
    from_port = "4001"
    to_port = "4001"
    protocol = "tcp"

    security_group_id = "${aws_security_group.coreos.id}"
    source_security_group_id = "${aws_security_group.coreos.id}" 
}

resource "aws_security_group_rule" "ingress_2379" {
    type = "ingress"
    from_port = "2379"
    to_port = "2379"
    protocol = "tcp"

    security_group_id = "${aws_security_group.coreos.id}"
    source_security_group_id = "${aws_security_group.coreos.id}" 
}

resource "aws_security_group_rule" "ingress_2380" {
    type = "ingress"
    from_port = "2380"
    to_port = "2380"
    protocol = "tcp"

    security_group_id = "${aws_security_group.coreos.id}"
    source_security_group_id = "${aws_security_group.coreos.id}" 
}

resource "aws_security_group_rule" "egress_all" {
    type = "egress"
    from_port = "0"
    to_port = "65535"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

    security_group_id = "${aws_security_group.coreos.id}"
}

resource "template_file" "cloud_config_master" {
    filename = "templates/cloud_config.tpl"
    vars {
        etcd_cluster_discovery_url = "${var.etcd_cluster_discovery_url}"
        etcd_advertised_ip_address = "${var.etcd_advertised_ip_address}"
        fleet_unit_role = "master"
        quayio_secret_key = "${var.quayio_secret_key}"
        quayio_email = "${var.quayio_email}"
    }
}

resource "aws_instance" "coreos_master" {
    ami = "${lookup(var.amis, var.region)}"
    iam_instance_profile = "elb-member"
    instance_type = "${var.instance_type}"
    count = "${var.cluster_size.masters}"
    key_name = "${var.key_name}"
    security_groups = [
        "${aws_security_group.coreos.name}"
    ]
    user_data = "${template_file.cloud_config_master.rendered}"
    tags = {
        Name = "${var.tag_name}-master-${count.index+1}"
    }
}

resource "template_file" "cloud_config_minion" {
    filename = "templates/cloud_config.tpl"
    vars {
        etcd_cluster_discovery_url = "${var.etcd_cluster_discovery_url}"
        etcd_advertised_ip_address = "${var.etcd_advertised_ip_address}"
        fleet_unit_role = "minion"
        quayio_secret_key = "${var.quayio_secret_key}"
        quayio_email = "${var.quayio_email}"
    }
}

resource "aws_instance" "coreos_minion" {
    ami = "${lookup(var.amis, var.region)}"
    instance_type = "${var.instance_type}"
    count = "${var.cluster_size.minions}"
    key_name = "${var.key_name}"
    security_groups = [
        "${aws_security_group.coreos.name}"
    ]
    user_data = "${template_file.cloud_config_minion.rendered}"
    tags = {
        Name = "${var.tag_name}-minion-${count.index+1}"
    }
}
