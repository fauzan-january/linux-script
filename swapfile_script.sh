#!/bin/bash

SWAPFILE="/swapfile"
SWAPSIZE=""

check_root() {
    if [ "$EUID" -ne 0 ]; then
        echo "Script harus dijalankan dengan user root atau user dengan hak akses sudo."
        exit 1
    fi
}

check_swap() {
    if [ -f $SWAPFILE ]; then
        echo "Berkas swap sudah ada."
        sudo swapon --show
        free -h
        exit 0
    else
        echo "Berkas swap belum ada."
        read -p "Apakah ingin membuat swapnya sekarang? (y/n): " create_swap
        if [ "$create_swap" != "y" ]; then
            echo "Script ditutup."
            exit 0
        fi
    fi
}

check_disk_space() {
    df -h
    read -p "Apakah ingin melanjutkan pembuatan berkas swap? (y/n): " proceed
    if [ "$proceed" != "y" ]; then
        echo "Script ditutup."
        exit 0
    fi
}

create_swapfile() {
    read -p "Masukkan jumlah swap yang ingin dibuat (contoh: 1G, 2G): " SWAPSIZE
    sudo fallocate -l $SWAPSIZE $SWAPFILE
    sudo chmod 600 $SWAPFILE
    sudo mkswap $SWAPFILE
    sudo swapon $SWAPFILE
    sudo swapon --show
    free -h
    sudo cp /etc/fstab /etc/fstab.bak
    echo "$SWAPFILE none swap sw 0 0" | sudo tee -a /etc/fstab
    echo "Swap berhasil dibuat dan diaktifkan."
}

set_swappiness_and_cache_pressure() {
    echo "Pengaturan tambahan untuk swappiness dan vfs_cache_pressure..."
    sudo sysctl vm.swappiness=10
    echo "vm.swappiness=10" | sudo tee -a /etc/sysctl.conf
    sudo sysctl vm.vfs_cache_pressure=50
    echo "vm.vfs_cache_pressure=50" | sudo tee -a /etc/sysctl.conf
}

# Main script
check_root
check_swap
check_disk_space
create_swapfile
set_swappiness_and_cache_pressure

echo "Script selesai."