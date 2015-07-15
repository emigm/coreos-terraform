# AWS credentials
variable "access_key" {
    description = "AWS access key"
}

variable "secret_key" {
    description = "AWS secret key"
}

# AWS EC2 configurations
variable "amis" {
    description = "Mapping between AWS regions and AMIs"
    default = {
        ap-northeast-1 = "ami-1a6fca1a"   
        ap-southeast-1 = "ami-da030788"
        ap-southeast-2 = "ami-23641e19"
        eu-central-1 = "ami-eae5ddf7"
        eu-west-1 = "ami-5f2f5528"
        sa-east-1 = "ami-b1cb49ac"
        us-east-1 = "ami-93ea17f8"
        us-west-1 = "ami-c967938d"
        us-west-2 = "ami-5d4d486d"
        us-gov-west-1 = "ami-e99fffca"
    }
}

variable "region" {
    description = "The region of AWS for AMI lookups"
    default = "us-east-1"
}

variable "user" {
    default = {
        coreos = "core"
    }
}

variable "instance_type" {
    description = "AWS EC2 instance type"
    default = "t2.micro"
}

variable "tag_name" {
    description = "Name tag for the instances"
    default = "terraform-coreos"
}

# SSH key configurations
variable "key_name" {
    description = "SSH key name in your AWS account for AWS intances"
}

variable "key_path" {
    description = "Path to the private key specified by key_name variable"
}

# CoreOS cluster configurations
variable "cluster_size" {
    description = "Number of servers in the cluster"
    default = {
        masters = "1"
        minions = "3"
    }
}

variable "etcd_cluster_discovery_url" {
    description = "A unique etcd cluster discovery URL"
}

variable "etcd_advertised_ip_address" {
    description = "Use $private or $public based on you cluster configuration"
    default = "$private"
}
