#resource "aws_route53_zone" "coreos_hosted_zone" {
#    name = "tf.poc.net"
#}

resource "aws_route53_record" "docker_registry_rec" {
    #zone_id = "${aws_route53_zone.coreos_hosted_zone.zone_id}"
    zone_id = "${var.r53_hosted_zone_id}"
    name = "docker-registry.fsws.infra-host.com"
    records = [
        "${aws_instance.coreos_docker_registry.public_ip}"
    ]
    ttl = "300"
    type = "A"
}
