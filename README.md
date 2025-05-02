# proxmox-flatcar

A proxmox tool to create Flatcar VM template on Proxmox 8.x.

# Requirements

- Tested on Proxmox VE 8.1.4
- Installs `flatcar-config-transpiler` and `yq` to `/usr/local/bin/` on Proxmox node.

# Usage

1. Clone this repository on your Proxmox server
2. Configure template parameter by modifying `template_deploy.conf` file as following:

```bash
# template vm vars
TEMPLATE_NAME="TMPL-flatcar" #Template VM name append with <flactar_version> in Proxmox GUI
TEMPLATE_RECREATE="false" #Fore recreate template ?
#Note: If you want only update hook script and Template_Ignition file, you can keep it as false, these files are always overwritten
TEMPLATE_POOL="domain.lan"# domain name written in cloudinit config
TEMPLATE_VMSTORAGE="local" #target storage for Template VM
SNIPPET_STORAGE="local" #target storage for Snippets files
VMDISK_OPTIONS=""

TEMPLATE_IGNITION="fcar-base-tmplt.yaml" #Name of template ignition file

# flatcar image version
VERSION=latest # default: latest, possible values: <version_num>, latest, current
PLATFORM=qemu
BASEURL=https://stable.release.flatcar-linux.net
```

3. Got to proxmox-flatcar directory
4. run `./template_deploy.sh`
   - If you want to recreate you need to delete the local file `TMPL-flatcar-current.id`
5. Clone the template on same host.
6. BEFORE first boot: update CloudInit config in Proxmox GUI (no update after first boot)
7. Wait for multiple reboot then enjoy

# Details of what the script does

This script runs on the proxmox server. The `hook-fcar.sh` install yp and ingintion binaries to `TOOLS_PATH`, default `/usr/local/bin` on the proxmox host.

1. First so checking for the template and if to recreate it. The standard error checking.
2. Copies the ignition template and hook script to the snippets folder.
3. Update the hook script to use the configured ignition template.
4. Downloads the configured flatcar image
5. Creates a new VM

- The script configures the VM, configuration is hard coded.
- The flatcar image is imported and set as the VMs disk
- Resize the VM adding 8 GB and set as template
- Add the hookscript to the VM
- Sets the VM as a template

6. When the VM is run, phase `pre-start` the hook script gets the VM ID to check if the ignition template is created if not it creates it.
7. The hook script uses `qm cloudinit` to get the config to fill out the ignition template.
8. Add configuration `opt/org.flatcar-linux/config` to VM to use ignition template.

# Script Details

## template_deploy.sh

The main deployment script that handles the creation and configuration of Flatcar VM templates. Key functions:

- Validates storage configuration and requirements
- Downloads and configures Flatcar Linux image
- Creates and configures the VM template with specified settings
- Sets up cloud-init and hook scripts
- Handles template recreation if requested
- Configures VM resources (memory, CPU, disk)

## hook-fcar.sh

A Proxmox hook script that runs during VM lifecycle events. Main functionality:

- Installs and manages required tools (`flatcar-config-transpiler`, `butane-config-transpiler`, `yq`)
- Runs during VM pre-start phase to:
  - Generate YAML configuration from cloud-init settings
  - Create network configuration files
  - Generate Ignition configuration
  - Apply configuration to the VM
- Handles user authentication (password/SSH keys)
- Manages network interface configuration
- Integrates with template configuration files

## debug.sh

A utility script for troubleshooting VM configuration issues. Features:

- Regenerates Ignition configuration for a specific VM
- Allows manual testing of hook script functionality
- Helps diagnose configuration problems
- Can be used to force configuration updates

# Known issues

- Cloned VM from template don't update it's ignition file when modifying CloudInit config in Proxmox VE GUI
- If not shared storage is used to deploy template VM you can only deploy VM on same host as template VM (can't migrate)
- Only IPv4 is supported

# Credits

Forked from awesome [Geco-It fedora-coreos-proxmox](https://git.geco-it.net/GECO-IT-PUBLIC/fedora-coreos-proxmox) ([Rev baff530f20](https://git.geco-it.net/GECO-IT-PUBLIC/fedora-coreos-proxmox/commit/baff530f200a708de8b61cb41ca4ba756b8e422d))

Source [GPL V3](https://git.geco-it.net/GECO-IT-PUBLIC/fedora-coreos-proxmox/src/commit/baff530f200a708de8b61cb41ca4ba756b8e422d/LICENSE):
![](resources/captures/Capture_211110134630.png)
