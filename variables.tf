# vim: ft=terraform
# VSphere variables that will determine where the resources are deployed
# These need to be accurate
variable vm_datastore         {}
variable vm_datacenter        {}
variable vm_cluster           {}
variable vm_resource_pool     {}
variable vm_folder            {}
variable vm_network           {}
variable vm_disk              {}
variable vm_name              {}

# Network variables
# We could include these in with the vm sections above which would allow deploying
# VMs to different networks in the future.
variable domain_name          {}
variable dns_servers          {}
variable net_gateway          {}
variable network_address      {} 
variable ip_address           {} 

# vsphere credentiails
variable vsphere_user         {}
variable vsphere_pass         {}
variable vsphere_server       {}
