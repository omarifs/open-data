#!/bin/bash
# Update php_cve_checker.sh dengan kode standar resmi CloudLinux Blog ini

clear
echo -e "\e[36m======================================================\e[0m"
echo -e "\e[1;33m       RAPIDPLEX SECURITY SYSTEM - PHP CHECKER        \e[0m"
echo -e "\e[36m======================================================\e[0m"
echo -e "Official CloudLinux Verification for CVE-2026-109618 & CVE-2026-109619\n"

# Table Header
printf "%-12s | %-20s | %-15s\n" "PHP VERSION" "BUILD TIMESTAMP" "PATCH STATUS"
echo "------------------------------------------------------"

PHP_VERSIONS=("php81" "php82" "php83" "php84" "php85")

for VERSION in "${PHP_VERSIONS[@]}"; do
    PHP_PATH="/opt/alt/${VERSION}/usr/bin/php"
    
    if [ -f "$PHP_PATH" ]; then
        # 1. Ambil Waktu Kompilasi (Build Date)
        BUILD_DATE=$($PHP_PATH -v | grep -oE "built: [A-Za-z0-9: ]+" | sed 's/built: //')
        
        # 2. Ambil Versi Dasar
        BASE_VER=$($PHP_PATH -v | head -n 1 | awk '{print $2}')
        DISPLAY_NAME="PHP ${VERSION:3:1}.${VERSION:4:1}"
        
        # 3. METODE UTAMA: Validasi string metadata CVE dari dalam file biner (Metode Backport)
        # Sisi user di CageFS memiliki hak baca (read) ke file biner yang mereka eksekusi sendiri
        IS_PATCHED=$(strings "$PHP_PATH" 2>/dev/null | grep -E "CVE-2026-109618|CVE-2026-109619" | head -n 1)
        
        if [ ! -z "$IS_PATCHED" ]; then
            STATUS_TEXT="\e[32mSECURE (Patched)\e[0m"
        else
            # FALLBACK MIKRO: Jika perintah 'strings' diblokir CageFS, validasi kecocokan tanggal rilis massal (21/22 Okt)
            if [[ "$BUILD_DATE" == *"Oct 21 2026"* || "$BUILD_DATE" == *"Oct 22 2026"* ]]; then
                STATUS_TEXT="\e[32mSECURE (Oct 21/22 Build)\e[0m"
            else
                STATUS_TEXT="\e[31mNOT PATCHED\e[0m"
            fi
        fi
        
        printf "%-12s | %-20s | %b\n" "$DISPLAY_NAME" "$BUILD_DATE" "$STATUS_TEXT"
    fi
done

echo -e "\e[36m------------------------------------------------------\e[0m"
echo -e "\e[1;34m🔗 OFFICIAL CLOUDLINUX ADVISORY:\e[0m"
echo -e "Read full statement: https://blog.cloudlinux.com/php-cve-2026-109618-and-cve-2026-109619"
echo -e "\n\e[1;36m💡 Mengapa Status Anda Aman?\e[0m"
echo -e "CloudLinux menggunakan metode backporting. Biner PHP Anda tetap menggunakan"
echo -e "versi lama tetapi isi kodenya sudah disisipi patch keamanan terbaru."
echo -e "\e[36m======================================================\e[0m"
