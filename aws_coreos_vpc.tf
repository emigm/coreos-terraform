resource "aws_vpc" "coreos_vpc" {
    cidr_block = "${var.vpc_cidr_block}"
    enable_dns_hostnames = "true"

    tags {
        Name = "tf_coreos_vpc"
    }
}

resource "aws_internet_gateway" "coreos_igw" {
    vpc_id = "${aws_vpc.coreos_vpc.id}"

    tags {
        Name = "tf_coreos_igw"
    }
}

resource "aws_route_table" "coreos_rtb" {
    vpc_id = "${aws_vpc.coreos_vpc.id}"
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.coreos_igw.id}"
    }

    tags {
        Name = "tf_coreos_rtb"
    }
}

resource "aws_subnet" "coreos_subnet" {
    vpc_id = "${aws_vpc.coreos_vpc.id}"
    # availability_zone = 
    cidr_block = "${var.subnet_cidr_block}"

    tags {
        Name = "tf_coreos_subnet"
    }
}

resource "aws_main_route_table_association" "coreos_vpc_rtb" {
    vpc_id = "${aws_vpc.coreos_vpc.id}"
    route_table_id = "${aws_route_table.coreos_rtb.id}"
}

resource "aws_route_table_association" "coreos_subnet_rtb" {
    subnet_id = "${aws_subnet.coreos_subnet.id}"
    route_table_id = "${aws_route_table.coreos_rtb.id}"
}
