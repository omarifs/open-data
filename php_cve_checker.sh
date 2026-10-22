#!/bin/bash
# Update php_cve_checker.sh dengan kode ini

clear
echo -e "\e[36m======================================================\e[0m"
echo -e "\e[1;33m       RAPIDPLEX SECURITY SYSTEM - PHP CHECKER        \e[0m"
echo -e "\e[36m======================================================\e[0m"
echo -e "Automated patch verification for CVE-2026-109618 & CVE-2026-109619\n"

# Table Header dengan kolom info yang lebih komprehensif
printf "%-12s | %-22s | %-15s\n" "PHP VERSION" "BUILD DATE" "PATCH STATUS"
echo "------------------------------------------------------"

PHP_VERSIONS=("php81" "php82" "php83" "php84" "php85")

for VERSION in "${PHP_VERSIONS[@]}"; do
    PHP_PATH="/opt/alt/${VERSION}/usr/bin/php"
    
    if [ -f "$PHP_PATH" ]; then
        # 1. Ambil tanggal kompilasi biner secara mentah
        BUILD_DATE=$($PHP_PATH -v | grep -oE "built: [A-Za-z0-9: ]+" | sed 's/built: //')
        
        # 2. Ambil versi dasar PHP (misal 8.5.11)
        BASE_VER=$($PHP_PATH -v | head -n 1 | awk '{print $2}')
        
        # 3. Cek struktur internal rilis paket (misal mencari kecocokan tag 8.5.11-4)
        FULL_TAG=$(strings "$PHP_PATH" 2>/dev/null | grep -E "^[0-9]+\.[0-9]+\.[0-9]+-[0-9]+" | head -n 1)
        
        DISPLAY_NAME="PHP ${VERSION:3:1}.${VERSION:4:1}"
        
        # Logika Validasi Utama:
        # Jika biner terbukti dikompilasi pada siklus rilis tanggal 21 atau 22 Oktober 2026, status dipastikan aman.
        if [[ "$BUILD_DATE" == *"Oct 21 2026"* || "$BUILD_DATE" == *"Oct 22 2026"* ]]; then
            STATUS_TEXT="\e[32mSECURE (Patched)\e[0m"
        else
            # Jika rilis build eksplisit ditemukan (misal dari string internal terdeteksi akhiran >= -4)
            BUILD_NUM=$(echo "$FULL_TAG" | cut -d'-' -f2 2>/dev/null)
            if [[ ! -z "$BUILD_NUM" && "$BUILD_NUM" -ge 4 ]]; then
                STATUS_TEXT="\e[32mSECURE (Build -$BUILD_NUM)\e[0m"
            else
                STATUS_TEXT="\e[31mNOT PATCHED\e[0m"
            fi
        fi
        
        printf "%-12s | %-22s | %b\n" "$DISPLAY_NAME" "$BUILD_DATE" "$STATUS_TEXT"
    fi
done

echo -e "\e[36m------------------------------------------------------\e[0m"
echo -e "\e[1;34m🔗 OFFICIAL CHANGELOG REFERENCE:\e[0m"
echo -e "You can cross-reference your build version logs here:"
echo -e "👉 \e[4;32mhttps://cloudlinux.com\e[0m"
echo -e "\n\e[1;36m💡 Verification Note:\e[0m"
echo -e "CloudLinux pushed the secure builds on October 21, 2026."
echo -e "All PHP binaries built on Oct 21/22 contain the security fixes."
echo -e "\e[36m======================================================\e[0m"
