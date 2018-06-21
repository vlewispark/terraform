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
  name          = "windows2012r2"
  datacenter_id   = "${data.vsphere_datacenter.dc.id}"
}

resource "vsphere_folder" "folder" {
  path              = "${var.vm_folder}"
  type              = "vm"
  datacenter_id     = "${data.vsphere_datacenter.dc.id}"
}

resource "vsphere_virtual_machine" "vm" {
  count = "2"
  name              = "${var.vm_name}-${count.index +1}"
  resource_pool_id  = "${data.vsphere_resource_pool.pool.id}"
  datastore_id      = "${data.vsphere_datastore.datastore.id}"
  folder            = "${vsphere_folder.folder.path}"

  num_cpus  = "1"
  memory    = "2048"
  guest_id  = "windows8Server64Guest"

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
         windows_options {
           computer_name = "${var.vm_name}-${count.index +1}"
           join_domain = "lp.local"
           domain_admin_user =  "administrator"
           domain_admin_password = "${var.win_domain_pass}"
      }
    

      network_interface {
        ipv4_address    = "192.168.10.${250 + count.index}"
        ipv4_netmask    = "${element(split("/", var.network_address), 1)}"
      }
      ipv4_gateway      = "${var.net_gateway}"
      dns_suffix_list   = ["${var.domain_name}"]
      dns_server_list   = "${split(",", var.dns_servers)}"
    }
  }
}
