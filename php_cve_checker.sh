#!/bin/bash
# Save this file as cve-checker.sh on your GitHub repository

clear
echo -e "\e[36m======================================================\e[0m"
echo -e "\e[1;33m       RAPIDPLEX SECURITY SYSTEM - PHP CHECKER        \e[0m"
echo -e "\e[36m======================================================\e[0m"
echo -e "Automated patch verification for CVE-2026-109618 & CVE-2026-109619\n"

# Table Header
printf "%-12s | %-20s | %-15s\n" "PHP VERSION" "FULL RELEASE VERSION" "PATCH STATUS"
echo "------------------------------------------------------"

# List of alt-php versions to scan
PHP_VERSIONS=("php81" "php82" "php83" "php84" "php85")

for VERSION in "${PHP_VERSIONS[@]}"; do
    PHP_PATH="/opt/alt/${VERSION}/usr/bin/php"
    
    if [ -f "$PHP_PATH" ]; then
        # 1. Get base version (e.g., 8.5.11)
        BASE_VER=$($PHP_PATH -v | head -n 1 | awk '{print $2}')
        
        # 2. Extract CloudLinux full release build tag from binary strings (e.g., 8.5.11-4)
        # CageFS allows users to read the binary file they execute
        FULL_VER=$(strings "$PHP_PATH" 2>/dev/null | grep -E "^[0-9]+\.[0-9]+\.[0-9]+-[0-9]+" | head -n 1)
        
        # Fallback if strings tracking is restricted
        if [ -z "$FULL_VER" ]; then
            RELEASE_BUILD=$($PHP_PATH -v | grep -oE "built: [A-Za-z0-9: ]+" | sed 's/built: //')
            FULL_VER="${BASE_VER} (Custom Build)"
            
            # Epoch check fallback (Oct 21 2026 22:22:00)
            BUILD_EPOCH=$(date -d "$RELEASE_BUILD" +%s 2>/dev/null)
            if [ "$BUILD_EPOCH" -ge 1792621320 ]; then
                STATUS_TEXT="\e[32mSECURE (Build -4+)\e[0m"
            else
                STATUS_TEXT="\e[31mNOT PATCHED\e[0m"
            fi
        else
            # Extract the build number after the dash (e.g., the '4' in 8.5.11-4)
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
echo -e "You can cross-reference your Full Release Version directly with CloudLinux:"
echo -e "👉 \e[4;32mhttps://changelog.cloudlinux.com/alt-php85\e[0m"
echo -e "\n\e[1;36m💡 Verification Guide:\e[0m"
echo -e "If your release version shows \e[1;32m-4\e[0m or higher, your account is fully secure"
echo -e "and successfully protected against the latest CVE vulnerabilities."
echo -e "\e[36m======================================================\e[0m"
