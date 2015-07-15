# Terraform scripts to manage a basic CoreOS cluster in AWS

Create plan to build the infrastructure:

<pre><code>
terraform plan
    -var access_key="access key"
    -var secret_key="secret key"
    -var etcd_cluster_discovery_url=https://discovery.etcd.io/"token"
    -var key_name="key name"
    -var key_path="key path"
    -var quayio_secret_key="quay.io secret"
    -var quayio_email="quay.io email"
</code></pre>

Apply plan to build the infrastructure:

<pre><code>
terraform apply
    -var access_key="access key"
    -var secret_key="secret key"
    -var etcd_cluster_discovery_url=https://discovery.etcd.io/"token"
    -var key_name="key name"
    -var key_path="key path"
    -var quayio_secret_key="quay.io secret"
    -var quayio_email="quay.io email"
</code></pre>

Destroy the infrastructure:

<code><pre>
terraform destroy
    -var access_key="access key"
    -var secret_key="secret key"
    -var etcd_cluster_discovery_url=https://discovery.etcd.io/"token"
    -var key_name="key name"
    -var key_path="key path"
    -var quayio_secret_key="quay.io secret"
    -var quayio_email="quay.io email"
</code></pre>