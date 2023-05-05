# TODO: use openstack provider
# https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs/resources/compute_instance_v2

#resource "openstack_compute_instance_v2" "instance_1" {
#  name            = "basic"
#  image_id        = "ad091b52-742f-469e-8f3c-fd81cadf0743"
#  flavor_id       = "3"
#  key_pair        = "my_key_pair_name"
#  security_groups = ["default"]
#  user_data       = "#cloud-config\nhostname: instance_1.example.com\nfqdn: instance_1.example.com"
#
#  network {
#    name = "my_network"
#  }
#}
