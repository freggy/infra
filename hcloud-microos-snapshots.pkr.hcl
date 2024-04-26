/*
 * file originally from github.com/kube-hetzner/terraform-hcloud-kube-hetzner/packer-template/hcloud-microos-snapshots.pkr.hcl
 * but adjusted to fit my needs.
 */
packer {
  required_plugins {
    hcloud = {
      version = "~> 1"
      source  = "github.com/hetznercloud/hcloud"
    }
  }
}

variable "hcloud_token" {
  type      = string
  default   = env("HCLOUD_TOKEN")
  sensitive = true
}

# We download the OpenSUSE MicroOS x86 image from an automatically selected mirror.
variable "opensuse_microos_x86_mirror_link" {
  type    = string
  default = "https://download.opensuse.org/tumbleweed/appliances/openSUSE-MicroOS.x86_64-ContainerHost-OpenStack-Cloud.qcow2"
}

# We download the OpenSUSE MicroOS ARM image from an automatically selected mirror.
variable "opensuse_microos_arm_mirror_link" {
  type    = string
  default = "https://download.opensuse.org/ports/aarch64/tumbleweed/appliances/openSUSE-MicroOS.aarch64-ContainerHost-OpenStack-Cloud.qcow2"
}

locals {
  # packages that should be present on every machine
  packages  = "bash-completion mtr tcpdump"
  download_image = "wget --timeout=5 --waitretry=5 --tries=5 --retry-connrefused --inet4-only "

  write_image = <<-EOT
    set -ex
    echo 'MicroOS image loaded, writing to disk... '
    qemu-img convert -p -f qcow2 -O host_device $(ls -a | grep -ie '^opensuse.*microos.*qcow2$') /dev/sda
    echo 'done. Rebooting...'
    sleep 1 && udevadm settle && reboot
  EOT

  install_packages = <<-EOT
    set -ex
    echo "First reboot successful, installing base packages..."
    transactional-update --continue pkg install -y ${local.packages}
    transactional-update --continue shell <<- EOF
    EOF
    sleep 1 && udevadm settle && reboot
  EOT

  clean_up = <<-EOT
    set -ex
    echo "Second reboot successful, cleaning-up..."
    rm -rf /etc/ssh/ssh_host_*
    echo "Make sure to use NetworkManager"
    touch /etc/NetworkManager/NetworkManager.conf
    sleep 1 && udevadm settle
  EOT
}

source "hcloud" "microos-x86-snapshot" {
  image       = "ubuntu-22.04"
  rescue      = "linux64"
  location    = "fsn1"
  server_type = "cpx11" # disk size of >= 40GiB is needed to install the MicroOS image
  snapshot_name = "opensuse-microos-x86"
  ssh_username  = "root"
  token         = var.hcloud_token
}

source "hcloud" "microos-arm-snapshot" {
  image       = "ubuntu-22.04"
  rescue      = "linux64"
  location    = "fsn1"
  server_type = "cax11" # disk size of >= 40GiB is needed to install the MicroOS image
  snapshot_name = "opensuse-microos-arm"
  ssh_username  = "root"
  token         = var.hcloud_token
}

# Build the MicroOS x86 snapshot
build {
  sources = ["source.hcloud.microos-x86-snapshot"]

  provisioner "shell" {
    inline = ["${local.download_image}${var.opensuse_microos_x86_mirror_link}"]
  }

  provisioner "shell" {
    inline            = [local.write_image]
    expect_disconnect = true
  }

  provisioner "shell" {
    pause_before      = "5s"
    inline            = [local.install_packages]
    expect_disconnect = true
  }

  provisioner "shell" {
    pause_before = "5s"
    inline       = [local.clean_up]
  }
}

# Build the MicroOS ARM snapshot
build {
  sources = ["source.hcloud.microos-arm-snapshot"]

  provisioner "shell" {
    inline = ["${local.download_image}${var.opensuse_microos_arm_mirror_link}"]
  }

  provisioner "shell" {
    inline            = [local.write_image]
    expect_disconnect = true
  }

  provisioner "shell" {
    pause_before      = "5s"
    inline            = [local.install_packages]
    expect_disconnect = true
  }

  provisioner "shell" {
    pause_before = "5s"
    inline       = [local.clean_up]
  }
}