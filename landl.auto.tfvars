# vim: ft=terraform
# VSphere variables that will determine where the resources are deployed
# These need to be accurate
vm_datastore         = "vsanDatastore"
vm_datacenter        = "Lab"
vm_cluster           = "vSAN"
vm_resource_pool     = ""                           # If using a cluster, may omit
vm_folder            = "TerraformVM"                # folder name, we can share!
vm_network           = "VM Network"     # Name of network from vsphere
vm_disk              = 40                           # Disk Size
vm_name              = "Terraform"        # VM name, must be unique


# Network variables
# We could include these in with the vm sections above which would allow deploying
# VMs to different networks in the future.
domain_name         = "lp.local"
dns_servers         = "192.168.10.50"
net_gateway         = "192.168.10.1"
network_address     = "192.168.10.0/24"
ip_address          = "192.168.10.253"

# vsphere credentiails
vsphere_user          = "administrator@vsphere.local" 
vsphere_pass          = "Newride197^"
vsphere_server        = "vc.lp.local"
win_domain_pass       = "Newride197^"
