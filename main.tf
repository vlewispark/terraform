provider "vsphere" {
  user              = "${var.vsphere_user}"
  password          = "${var.vsphere_pass}"
  vsphere_server    = "${var.vsphere_server}"
  allow_unverified_ssl = true
}

data "vsphere_datacenter" "dc" {
  name = "${var.vm_datacenter}"
}

data "vsphere_datastore" "datastore" {
  name          = "${var.vm_datastore}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_resource_pool" "pool" {
  name          = "${var.vm_cluster}/Resources"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_network" "network" {
  name          = "${var.vm_network}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_virtual_machine" "template" {
  name          = "I.T-RH7.3-RAW"
  datacenter_id   = "${data.vsphere_datacenter.dc.id}"
}

resource "vsphere_folder" "folder" {
  path              = "${var.vm_folder}"
  type              = "vm"
  datacenter_id     = "${data.vsphere_datacenter.dc.id}"
}

resource "vsphere_virtual_machine" "vm" {
  name              = "${var.vm_name}"
  resource_pool_id  = "${data.vsphere_resource_pool.pool.id}"
  datastore_id      = "${data.vsphere_datastore.datastore.id}"
  folder            = "${vsphere_folder.folder.path}"

  num_cpus  = "2"
  memory    = "2048"
  guest_id  = "rhel7_64Guest"

  scsi_type = "${data.vsphere_virtual_machine.template.scsi_type}"

  network_interface {
    network_id      = "${data.vsphere_network.network.id}"
    adapter_type    = "${data.vsphere_virtual_machine.template.network_interface_types[0]}"
  }
  disk {
    label            = "disk0"
    size             = "${var.vm_disk >= data.vsphere_virtual_machine.template.disks.0.size ? var.vm_disk : data.vsphere_virtual_machine.template.disks.0.size}"
    eagerly_scrub    = "${data.vsphere_virtual_machine.template.disks.0.eagerly_scrub}"
    thin_provisioned = "${data.vsphere_virtual_machine.template.disks.0.thin_provisioned}"
  }
  clone {
    template_uuid    = "${data.vsphere_virtual_machine.template.id}"

    customize {
      linux_options {
        host_name    = "${var.vm_name}"
        domain       = "${var.domain_name}"
      }

      network_interface {
        ipv4_address    = "${var.ip_address}"
        ipv4_netmask    = "${element(split("/", var.network_address), 1)}"
      }
      ipv4_gateway      = "${var.net_gateway}"
      dns_suffix_list   = ["${var.domain_name}"]
      dns_server_list   = "${split(",", var.dns_servers)}"
    }
  }
}
