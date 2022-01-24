#variable "ssh_key" {
#}

locals {
    BASENAME = "kh-terra"
    ZONE     = "us-east-1"
}

resource "ibm_is_vpc" "vpc" {
    name = "${local.BASENAME}-vpc"
}

resource "ibm_is_security_group" "sg1" {
    name = "${local.BASENAME}-sg1"
    vpc  = ibm_is_vpc.vpc.id
    resource_group = var.resource_group_id
}

# allow all incoming network traffic on port 22
resource "ibm_is_security_group_rule" "ingress_ssh_all" {
    group     = ibm_is_security_group.sg1.id
    direction = "inbound"
    remote    = "0.0.0.0/0"

    tcp {
      port_min = 22
      port_max = 22
    }
}


resource "ibm_is_security_group_rule" "icmp_all" {
    group     = ibm_is_security_group.sg1.id
    direction = "inbound"
    remote    = "0.0.0.0/0"

    icmp {
      type = 8
    }
}


resource "ibm_is_security_group_rule" "sg_outbound" {
  group     = ibm_is_security_group.sg1.id
  direction = "outbound"
  remote    = "0.0.0.0/0"
}


resource "ibm_is_subnet" "subnet1" {
    name                     = "${local.BASENAME}-subnet1"
    vpc                      = ibm_is_vpc.vpc.id
    zone                     = local.ZONE
    resource_group = var.resource_group_id
    total_ipv4_address_count = 256
}

data "ibm_is_image" "centos" {
    name = "ibm-centos-7-6-minimal-amd64-1"
}

data "ibm_is_ssh_key" "ssh_key_id" {
    name = var.ssh_key
}

resource "ibm_is_instance" "vsi1" {
    name    = "${local.BASENAME}-vsi1"
    vpc     = ibm_is_vpc.vpc.id
    resource_group = var.resource_group_id
    zone    = local.ZONE
    keys    = [data.ibm_is_ssh_key.ssh_key_id.id]
    image   = data.ibm_is_image.centos.id
    profile = "cx2-2x4"

    primary_network_interface {
        subnet          = ibm_is_subnet.subnet1.id
        security_groups = [ibm_is_security_group.sg1.id]
    }
}

resource "ibm_is_floating_ip" "fip1" {
    name   = "${local.BASENAME}-fip1"
    target = ibm_is_instance.vsi1.primary_network_interface[0].id
    }

  output "sshcommand" {
    value = "ssh root@${ibm_is_floating_ip.fip1.address}"
    }


# Adding a volume to test if the volume can be successfully deleted when it is associated with a FIP.

resource "ibm_is_volume" "iac_app_volume" {
  count    = var.home_fs_size > 0 ? 1 : 0
  name     = "${local.BASENAME}-volume-01"
  profile  = "5iops-tier"
  resource_group = var.resource_group_id
  zone     = local.ZONE
  capacity = var.home_fs_size
}


resource "ibm_is_instance_volume_attachment" "iac_attach_app_volume" {

#  depends_on = [ ibm_is_floating_ip.fip1 ]

  count    = var.home_fs_size > 0 ? 1 : 0
  instance = ibm_is_instance.vsi1.id
  name = "${local.BASENAME}-volume-01-att"
  volume = ibm_is_volume.iac_app_volume[0].id

}

