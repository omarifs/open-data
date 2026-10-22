#!/bin/bash
# Update php_cve_checker.sh dengan kode ini

clear
echo -e "\e[36m======================================================\e[0m"
echo -e "\e[1;33m       RAPIDPLEX SECURITY SYSTEM - PHP CHECKER        \e[0m"
echo -e "\e[36m======================================================\e[0m"
echo -e "Automated patch verification for CVE-2026-109618 & CVE-2026-109619\n"

# Table Header
printf "%-12s | %-20s | %-15s\n" "PHP VERSION" "FULL RELEASE VERSION" "PATCH STATUS"
echo "------------------------------------------------------"

PHP_VERSIONS=("php81" "php82" "php83" "php84" "php85")

for VERSION in "${PHP_VERSIONS[@]}"; do
    PHP_PATH="/opt/alt/${VERSION}/usr/bin/php"
    
    if [ -f "$PHP_PATH" ]; then
        # 1. Ambil versi dasar PHP (misal 8.5.11)
        BASE_VER=$($PHP_PATH -v | head -n 1 | awk '{print $2}')
        
        # 2. Ekstrak rilis build lengkap CloudLinux langsung dari dalam biner PHP (misal: 8.5.11-4)
        FULL_VER=$(strings "$PHP_PATH" 2>/dev/null | grep -E "^[0-9]+\.[0-9]+\.[0-9]+-[0-9]+" | head -n 1)
        
        # Jika perintah strings dibatasi CageFS, gunakan fallback deteksi teks kompilasi tanggal 21 Okt
        if [ -z "$FULL_VER" ]; then
            BUILD_DATE=$($PHP_PATH -v | grep -oE "built: [A-Za-z0-9: ]+" | sed 's/built: //')
            FULL_VER="$BASE_VER"
            
            if [[ "$BUILD_DATE" == *"Oct 21 2026"* || "$BUILD_DATE" == *"Oct 22 2026"* ]]; then
                STATUS_TEXT="\e[32mSECURE (Build -4+)\e[0m"
            else
                STATUS_TEXT="\e[31mNOT PATCHED\e[0m"
            fi
        else
            # Ambil angka build rilis paling belakang setelah tanda minus (-4)
            BUILD_NUM=$(echo "$FULL_VER" | cut -d'-' -f2)
            
            if [ "$BUILD_NUM" -ge 4 ]; then
                STATUS_TEXT="\e[32mSECURE (Build -$BUILD_NUM)\e[0m"
            else
                STATUS_TEXT="\e[31mNOT PATCHED (-$BUILD_NUM)\e[0m"
            fi
        fi
        
        DISPLAY_NAME="PHP ${VERSION:3:1}.${VERSION:4:1}"
        printf "%-12s | %-20s | %b\n" "$DISPLAY_NAME" "$FULL_VER" "$STATUS_TEXT"
    fi
done

echo -e "\e[36m------------------------------------------------------\e[0m"
echo -e "\e[1;34m🔗 OFFICIAL CHANGELOG REFERENCE:\e[0m"
echo -e "Cross-reference your Full Release Version here:"
echo -e "👉 \e[4;32mhttps://cloudlinux.com\e[0m"
echo -e "\n\e[1;36m💡 Verification Guide:\e[0m"
echo -e "If your release version shows \e[1;32m-4\e[0m or higher (or compiled on Oct 21/22), your"
echo -e "hosting account is fully secure and protected against the vulnerabilities."
echo -e "\e[36m======================================================\e[0m"
