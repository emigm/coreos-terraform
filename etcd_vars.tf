# etcd configuration variables
variable "etcd_cluster_discovery_url" {
    description = "etcd cluster discovery URL"
}

variable "etcd_advertised_ip_address" {
    description = "Use $private or $public based on you cluster configuration"
    default = "$private"
}

