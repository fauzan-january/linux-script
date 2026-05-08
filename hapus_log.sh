#!/bin/bash

# Bersihkan log sistem dengan aman
# Dibuat oleh Fauzan January

echo "🔧 Membersihkan log sistem..."

# 1. Truncate file log utama (tanpa menghapus file-nya)
find /var/log -type f -name "*.log" -exec truncate -s 0 {} \;

# 2. Hapus log yang sudah di-rotate (biasanya berekstensi.gz,.1,.old)
find /var/log -type f \( -name "*.gz" -o -name "*.1" -o -name "*.old" \) -delete

# 3. Bersihkan log systemd journal yang lebih dari 7 hari
journalctl --vacuum-time=7d

# 4. Bersihkan log apt (jika Debian/Ubuntu)
rm -f /var/log/apt/*.log /var/log/apt/*.gz

# 5. Bersihkan log dari layanan tertentu (opsional)
rm -f /var/log/nginx/* /var/log/mysql/* /var/log/php*/php*.log 2>/dev/null

echo "✅ Pembersihan log selesai."
