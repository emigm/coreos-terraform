resource "aws_security_group" "ssh_sg" {
    description = "Allow ssh connections"
    name = "ssh"
    vpc_id = "${aws_vpc.coreos_vpc.id}"

    tags {
        Name = "tf_ssh_sg"
    }
}

resource "aws_security_group_rule" "ingress_22" {
    type = "ingress"
    from_port = "22"
    to_port = "22"
    protocol = "tcp"

    cidr_blocks = [
        "0.0.0.0/0"
    ]
    security_group_id = "${aws_security_group.ssh_sg.id}"
}

resource "aws_security_group" "coreos_sg" {
    description = "Allow communications between the CoreOS components"
    name = "coreos"
    vpc_id = "${aws_vpc.coreos_vpc.id}"

    tags {
        Name = "tf_coreos_sg"
    }
}

resource "aws_security_group_rule" "ingress_4001" {
    type = "ingress"
    from_port = "4001"
    to_port = "4001"
    protocol = "tcp"

    security_group_id = "${aws_security_group.coreos_sg.id}"
    source_security_group_id = "${aws_security_group.coreos_sg.id}" 
}

resource "aws_security_group_rule" "ingress_2379" {
    type = "ingress"
    from_port = "2379"
    to_port = "2379"
    protocol = "tcp"

    security_group_id = "${aws_security_group.coreos_sg.id}"
    source_security_group_id = "${aws_security_group.coreos_sg.id}" 
}

resource "aws_security_group_rule" "ingress_2380" {
    type = "ingress"
    from_port = "2380"
    to_port = "2380"
    protocol = "tcp"

    security_group_id = "${aws_security_group.coreos_sg.id}"
    source_security_group_id = "${aws_security_group.coreos_sg.id}"
}

resource "aws_security_group" "flannel_sg" {
    description = "Allow communications between the flannel components"
    name = "flannel"
    vpc_id = "${aws_vpc.coreos_vpc.id}"

    tags {
        Name = "tf_flannel_sg"
    }
}

resource "aws_security_group_rule" "ingress_8285" {
    type = "ingress"
    from_port = "8285"
    to_port = "8285"
    protocol = "udp"

    security_group_id = "${aws_security_group.flannel_sg.id}"
    source_security_group_id = "${aws_security_group.flannel_sg.id}"
}

resource "aws_security_group_rule" "ingress_8472" {
    type = "ingress"
    from_port = "8472"
    to_port = "8472"
    protocol = "udp"

    security_group_id = "${aws_security_group.flannel_sg.id}"
    source_security_group_id = "${aws_security_group.flannel_sg.id}"
}

resource "aws_security_group" "docker_registry_sg" {
    description = "Allow communication with docker registry"
    name = "docker_registry"
    vpc_id = "${aws_vpc.coreos_vpc.id}"

    tags {
        Name = "tf_docker_registry_sg"
    }
}

resource "aws_security_group_rule" "ingress_5000" {
    type = "ingress"
    from_port = "5000"
    to_port = "5000"
    protocol = "tcp"

    security_group_id = "${aws_security_group.docker_registry_sg.id}"
    self = "true"
    source_security_group_id = "${aws_security_group.coreos_sg.id}"
}

resource "aws_security_group" "outbound_sg" {
    description = "Allow all outbound traffic"
    name = "outbound"
    vpc_id = "${aws_vpc.coreos_vpc.id}"

    tags {
        Name = "tf_outobund_sg"
    }
}

resource "aws_security_group_rule" "egress_all_tcp" {
    type = "egress"
    from_port = "0"
    to_port = "65535"
    protocol = "tcp"
    cidr_blocks = [
        "0.0.0.0/0"
    ]

    security_group_id = "${aws_security_group.outbound_sg.id}"
}

resource "aws_security_group_rule" "egress_all_udp" {
    type = "egress"
    from_port = "0"
    to_port = "65535"
    protocol = "udp"
    cidr_blocks = [
        "0.0.0.0/0"
    ]

    security_group_id = "${aws_security_group.outbound_sg.id}"
}

resource "template_file" "cloud_config_minion" {
    filename = "templates/cloud_config_hosts.tpl"
    vars {
        docker_registry_record = "${aws_route53_record.docker_registry_rec.fqdn}"
        etcd_cluster_discovery_url = "${var.etcd_cluster_discovery_url}"
        etcd_advertised_ip_address = "${var.etcd_advertised_ip_address}"
        fleet_unit_role = "minion"
        quayio_secret_key = "${var.quayio_secret_key}"
        quayio_email = "${var.quayio_email}"
    }
}

resource "aws_instance" "coreos_minion" {
    ami = "${lookup(var.amis_stable_channel, var.aws_region)}"
    associate_public_ip_address = "true"
    iam_instance_profile = "${aws_iam_instance_profile.rtb_updater_iam_instance_profile.name}"
    instance_type = "${var.aws_instance_type}"
    count = "${var.cluster_size.minions}"
    key_name = "${var.key_name}"
    subnet_id = "${aws_subnet.coreos_subnet.id}"
    source_dest_check = "false"
    vpc_security_group_ids = [
        "${aws_security_group.ssh_sg.id}",
        "${aws_security_group.coreos_sg.id}",
        "${aws_security_group.flannel_sg.id}",
        "${aws_security_group.outbound_sg.id}"
    ]
    user_data = "${template_file.cloud_config_minion.rendered}"

    tags {
        Name = "tf_minion_${count.index+1}"
    }
}

resource "template_file" "cloud_config_docker_registry" {
    filename = "templates/cloud_config_docker_registry.tpl"
    vars {
        etcd_cluster_discovery_url = "${var.etcd_cluster_discovery_url}"
        etcd_advertised_ip_address = "${var.etcd_advertised_ip_address}"
        fleet_unit_role = "registry"
    }
}

resource "aws_instance" "coreos_docker_registry" {
    ami = "${lookup(var.amis_stable_channel, var.aws_region)}"
    associate_public_ip_address = "true"
    iam_instance_profile = "${aws_iam_instance_profile.rtb_updater_iam_instance_profile.name}"   
    instance_type = "${var.aws_instance_type}"
    key_name = "${var.key_name}"
    subnet_id = "${aws_subnet.coreos_subnet.id}"
    vpc_security_group_ids = [
        "${aws_security_group.ssh_sg.id}",
        "${aws_security_group.coreos_sg.id}",
        "${aws_security_group.flannel_sg.id}",
        "${aws_security_group.docker_registry_sg.id}",
        "${aws_security_group.outbound_sg.id}"
    ]
    user_data = "${template_file.cloud_config_docker_registry.rendered}"

    tags {
        Name = "tf_docker_registry"
    }
}
