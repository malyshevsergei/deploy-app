terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
      version = "0.85.0"
    }
  }
}

provider "yandex" {
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  zone      = var.zone
  service_account_key_file = file("service_account_key_file.json")
}

resource "yandex_compute_instance" "app" {
  name = "app"
  zone = var.zone

  resources {
    cores  = 2
    memory = 4
  }

  network_interface {
    subnet_id = data.yandex_vpc_network.network.subnet_ids[2]
    nat = true
  }

  boot_disk {
    initialize_params {
      name = "disk-app"
      size = 30
      type = "network-hdd"
      image_id = "fd8hvlnfb66dgavf0e1a"
    }
  }

  labels = {
    task_name = "devops-final",
    user_email = "malyshev.s.a@yandex.ru"
  }

  metadata = {
    foo      = "bar"
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }


  provisioner "remote-exec" {
    inline = ["echo connected to ${self.name}!"]

    connection {
      host = self.network_interface[0].nat_ip_address
      type = "ssh"
      user = "ubuntu"
      private_key = file("~/.ssh/id_rsa")
    }
  }

  provisioner "local-exec" {
    command = "ssh-keyscan ${yandex_compute_instance.app.network_interface.*.nat_ip_address[0]} >> ~/.ssh/known_hosts"
  }
}

resource "yandex_compute_instance" "logging" {
  name = "logging"
  zone = var.zone

  resources {
    cores  = 4
    memory = 8
  }

  network_interface {
    subnet_id = data.yandex_vpc_network.network.subnet_ids[2]
    nat = true
  }

  boot_disk {
    initialize_params {
      name = "disk-logging"
      size = 30
      type = "network-hdd"
      image_id = "fd8hvlnfb66dgavf0e1a"
    }
  }

  labels = {
    task_name = "devops-final",
    user_email = "malyshev.s.a@yandex.ru"
  }

  metadata = {
    foo      = "bar"
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }


  provisioner "remote-exec" {
    inline = ["echo connected to ${self.name}!"]

    connection {
      host = self.network_interface[0].nat_ip_address
      type = "ssh"
      user = "ubuntu"
      private_key = file("~/.ssh/id_rsa")
    }
  }

    provisioner "local-exec" {
      command = "ssh-keyscan ${yandex_compute_instance.logging.network_interface.*.nat_ip_address[0]} >> ~/.ssh/known_hosts"
  }
}

resource "yandex_compute_instance" "monitoring" {
  name = "monitoring"
  zone = var.zone

  resources {
    cores  = 2
    memory = 4
  }

  network_interface {
    subnet_id = data.yandex_vpc_network.network.subnet_ids[2]
    nat = true
  }

  boot_disk {
    initialize_params {
      name = "disk-monitoring"
      size = 30
      type = "network-hdd"
      image_id = "fd8hvlnfb66dgavf0e1a"
    }
  }

  labels = {
    task_name = "devops-final",
    user_email = "malyshev.s.a@yandex.ru"
  }

  metadata = {
    foo      = "bar"
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }


  provisioner "remote-exec" {
    inline = ["echo connected to ${self.name}!"]

    connection {
      host = self.network_interface[0].nat_ip_address
      type = "ssh"
      user = "ubuntu"
      private_key = file("~/.ssh/id_rsa")
    }
  }

    provisioner "local-exec" {
      command = "ssh-keyscan ${yandex_compute_instance.monitoring.network_interface.*.nat_ip_address[0]} >> ~/.ssh/known_hosts"
  }
}

resource "local_file" "inventory_for_app" {
  filename = "../ansible/inventory"
  content = templatefile("templates/inventory.tftpl", 
  {yandex_compute_name_for_app=yandex_compute_instance.app.name,
  app_ip=yandex_compute_instance.app.network_interface.*.nat_ip_address[0],
  private_logging_ip=yandex_compute_instance.logging.network_interface[0].ip_address,
  yandex_compute_name_for_logging=yandex_compute_instance.logging.name,
  logging_ip=yandex_compute_instance.logging.network_interface.*.nat_ip_address[0],
  yandex_compute_name_for_monitoring=yandex_compute_instance.monitoring.name,
  monitoring_ip=yandex_compute_instance.monitoring.network_interface.*.nat_ip_address[0],
  private_app_ip=yandex_compute_instance.app.network_interface[0].ip_address,
  private_logging_ip=yandex_compute_instance.logging.network_interface[0].ip_address})
}