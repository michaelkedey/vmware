# vSphere Infrastructure
This repo demonstrates how to use terraform to deploy vmware on-prem.

Terraform config to provision VMs on vSphere, with Ansible handling baseline
OS hardening afterward.

## Stack

- **Terraform** `v1.15.8`, provider `vmware/vsphere ~> 2.16.1`
- **govc** for manual vSphere inspection/debugging
- **Ansible** for post-provision OS hardening

## Layout

```
../../
├── LICENSE
├── README.md
└── src
    └── infra
        ├── baseline_config.sh
        ├── base-setup.yml
        ├── env
        ├── inventory.ini
        ├── locals.tf
        ├── main.tf
        ├── modules
        │   ├── cluster
        │   │   ├── main.tf
        │   │   ├── outputs.tf
        │   │   └── vars.tf
        │   ├── data_center
        │   │   ├── main.tf
        │   │   ├── outputs.tf
        │   │   └── vars.tf
        │   ├── datastore
        │   │   ├── main.tf
        │   │   ├── outputs.tf
        │   │   └── vars.tf
        │   ├── esxi_host
        │   │   ├── main.tf
        │   │   ├── outputs.tf
        │   │   └── vars.tf
        │   ├── port_group
        │   │   ├── main.tf
        │   │   ├── outputs.tf
        │   │   └── vars.tf
        │   ├── vms
        │   │   ├── main.tf
        │   │   ├── outputs.tf
        │   │   └── vars.tf
        │   └── vswitch
        │       ├── main.tf
        │       ├── outputs.tf
        │       └── vars.tf
        ├── outputs.tf
        ├── terraform.tfstate
        ├── terraform.tfstate.backup
        ├── tfplan
        └── variables.tf

12 directories, 33 files
```

## Usage

```bash
terraform init
terraform fmt -recursive
terraform validate
terraform plan -var-file=".terraform.tfvars" -out=tfplan
terraform apply "tfplan"
```

Destroy a single VM:

```bash
terraform destroy -target='module.vm["<key>"].vsphere_virtual_machine.vm["<key>"]' -var-file=".terraform.tfvars"
```

## Template requirements

The clone source VM must be built correctly or customization silently hangs:

- **Firmware must match the disk's partition table** — `bios` for a
  BIOS-installed template, `efi` only if you built a separate EFI template.

- **Keep a CD-ROM device on the template** — vSphere delivers the
  customization package through it. (The `vms` module also forces this via
  `cdrom { client_device = true }` on every clone.)

- **`open-vm-tools` installed and running** — required for customization
  and `govc guest.*` commands.

- **`guest_id` matches the actual OS.**

  

## Config (`.terraform.tfvars`)

```hcl
vsphere_user     = "administrator@vsphere.local"
vsphere_password = "*****"
vsphere_server   = "x.x.x.x"

default_firmware = "bios"
default_vm_domain = "local" 

datacenters = {
  "datacenter1" = "datacenter1"
}
clusters = {
  "cluster1" = { 
    datacenter_key = "datacenter1" 
    }
}

esxi_hosts = {
  "x.x.x.x" = {
    datacenter_key = "datacenter1"
    cluster_key    = "cluster1"
    username       = ""
    password       = "*****"
    devices        = ["vmnic1", "vmnic2"]
  },
   "x.x.x.x" = {
    datacenter_key = "datacenter1"
    cluster_key    = "cluster1"
    username       = ""
    password       = "*****"
    devices        = ["vmnic1", "vmnic2"]
  }
}

datastores = {
  "datastore1 (1)" = { 
    datacenter_key = "datacenter1" 
    }
}

vswitches = {
  "vswitch1" = { 
    datacenter_key = "datacenter1" 
  }
}

port_groups = {
  "pg-vlan10-mgmt" = { 
    vswitch_key = "vswitch1"
    vlan_id = 10 
    }
  "pg-vlan20-app"  = { 
    vswitch_key = "vswitch1"
    vlan_id = 20 
    }
}

vms = {
  "app1" = {
    datacenter_key = "datacenter1"
    cluster_key    = "cluster1"
    datastore_key  = "datastore1 (1)"
    network_keys   = ["VM Network", "pg-vlan20-app"]
    nic_ips        = ["x.x.x.x", "x.x.x.x"]
    subnet_mask    = 24
    gateway        = "x.x.x.x"
    num_cpus       = 2
    memory         = 8096
    disk_size      = 100
    guest_id       = "centos9_64Guest"
    template_name  = "centos-template-vm"
    vm_domain      = "app1.local"
    firmware       = "bios"
  },
  "app2" = {
    datacenter_key = "datacenter1"
    cluster_key    = "cluster1"
    datastore_key  = "datastore1 (1)"
    network_keys   = ["VM Network", "pg-vlan10-mgmt", "pg-vlan20-app"]
    nic_ips        = ["x.x.x.x", "x.x.x.x", "x.x.x.x"]
    subnet_mask    = 24
    gateway        = "x.x.x.x"
    num_cpus       = 2
    memory         = 8096
    disk_size      = 100
    guest_id       = "centos9_64Guest"
    template_name  = "centos-template-vm"
    vm_domain      = "app2.local"
    firmware       = "bios"
  }
}
```

`nic_ips` and `network_keys` must be the same length and order.



## Ansible

Runs after Terraform finishes, against the newly customized VMs.

```bash
./baseline_config.sh
```

## Security

- `.terraform.tfvars` has real credentials in plaintext — keep it in
  `.gitignore` (`*.tfvars`), or better, use `TF_VAR_*` env vars / a secrets
  manager.
  
- `allow_unverified_ssl = true` skips TLS validation — fine for a lab,
  revisit before production.
  
  

## Troubleshooting

| Symptom                                      | Cause                                                        |
| -------------------------------------------- | ------------------------------------------------------------ |
| Customization timeout                        | Firmware mismatch, missing CD-ROM, or bad `customize` block  |
| "No operating system was found"              | `firmware = "efi"` on a BIOS-partitioned template            |
| Guest ops agent unreachable                  | VM hasn't booted, or Tools not running                       |
| Default value not applying despite being set | `optional()` fields are always present as `null` — `lookup()` won't fall back, use `coalesce()` |
| Module errors: missing/unsupported attribute | Root `variables.tf` and module `vars.tf` both declare `vms` type independently — keep them in sync |

Check real state via vCenter events (more reliable than guest logs if it never boots

```bash
govc events -n 50 /datacenter1/vm/<vm-name>
```