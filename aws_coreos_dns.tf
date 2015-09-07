resource "aws_route53_record" "docker_registry_rec" {
    zone_id = "${var.r53_hosted_zone_id}"
    name = "docker-registry.${var.r53_domain_name}"
    records = [
        "${aws_instance.coreos_docker_registry.public_ip}"
    ]
    ttl = "300"
    type = "A"
}

# Output variables

output "docker-registry" {
    value =  "${aws_route53_record.docker_registry_rec.fqdn}"
}
