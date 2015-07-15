# Terraform scripts to manage a basic CoreOS cluster

Create plan to build the infrastructure:

terraform plan \
    -var access_key=<accessKey> \
    -var secret_key=<secretKey> \
    -var etcd_cluster_discovery_url=https://discovery.etcd.io/<token> \
    -var key_name=<key name> \
    -var key_path=<key path> \
    -var quayio_secret_key=<quay.io secret> \
    -var quayio_email=<quay.io email>

Apply plan to build the infrastructure:

terraform apply \
    -var access_key=<accessKey> \
    -var secret_key=<secretKey> \
    -var etcd_cluster_discovery_url=https://discovery.etcd.io/<token> \
    -var key_name=<key name> \
    -var key_path=<key path> \
    -var quayio_secret_key=<quay.io secret> \
    -var quayio_email=<quay.io email>

Destroy the infrastructure:

terraform destroy \
    -var access_key=<accessKey> \
    -var secret_key=<secretKey> \
    -var etcd_cluster_discovery_url=https://discovery.etcd.io/<token> \
    -var key_name=<key name> \
    -var key_path=<key path> \
    -var quayio_secret_key=<quay.io secret> \
    -var quayio_email=<quay.io email>
