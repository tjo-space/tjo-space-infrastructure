nodes = {
  pink = {
    host         = "jakku"
    cores        = 2
    memory       = 8096
    boot_storage = "local-nvme"
    boot_size    = 16

    data_fast_storage = "local-nvme"
    data_fast_size    = 64

    data_large_storage = "local-hdd"
    data_large_size    = 100

    data_ephemeral_storage = "local-hdd"
    data_ephemeral_size    = 101
  }
}
