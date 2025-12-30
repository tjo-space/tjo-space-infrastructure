nodes = {
  pink = {
    host         = "jakku"
    cores        = 4
    memory       = 32768
    boot_storage = "local-nvme"

    data_fast_storage = "local-nvme"
    data_fast_size    = 96

    data_large_storage = "local-hdd"
    data_large_size    = 13500

    data_ephemeral_storage = "local-hdd"
    data_ephemeral_size    = 101
  }
}
