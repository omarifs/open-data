#!/bin/bash
# Save this file as checker.sh on your GitHub repository

clear
echo -e "\e[36m======================================================\e[0m"
echo -e "\e[1;33m       RAPIDPLEX SECURITY SYSTEM - PHP CHECKER        \e[0m"
echo -e "\e[36m======================================================\e[0m"
echo -e "Automated patch verification for CVE-2026-109618 & CVE-2026-109619\n"

# Table Header
printf "%-12s | %-22s | %-15s\n" "PHP VERSION" "BUILD TIMESTAMP" "PATCH STATUS"
echo "------------------------------------------------------"

# List of alt-php versions to scan
PHP_VERSIONS=("php81" "php82" "php83" "php84" "php85")

# Official CloudLinux Secure Release Timestamp (Oct 21, 2026 22:22:00)
SAFE_TIMESTAMP=1792621320 

HAS_OUTDATED=0

for VERSION in "${PHP_VERSIONS[@]}"; do
    PHP_PATH="/opt/alt/${VERSION}/usr/bin/php"
    
    if [ -f "$PHP_PATH" ]; then
        # Extract the build date from php -v
        BUILD_DATE=$($PHP_PATH -v | grep -oE "built: [A-Za-z0-9: ]+" | sed 's/built: //')
        
        if [ ! -z "$BUILD_DATE" ]; then
            # Convert build date to Epoch seconds
            BUILD_EPOCH=$(date -d "$BUILD_DATE" +%s 2>/dev/null)
            
            # Format display name (e.g., PHP 8.5)
            DISPLAY_NAME="PHP ${VERSION:3:1}.${VERSION:4:1}"
            
            if [ "$BUILD_EPOCH" -ge "$SAFE_TIMESTAMP" ]; then
                STATUS_TEXT="\e[32mSECURE (Build -4+)\e[0m"
            else
                STATUS_TEXT="\e[31mNOT PATCHED\e[0m"
                HAS_OUTDATED=1
            fi
            
            printf "%-12s | %-22s | %b\n" "$DISPLAY_NAME" "$BUILD_DATE" "$STATUS_TEXT"
        fi
    fi
done

echo -e "\e[36m------------------------------------------------------\e[0m"

# Educational Note to prevent user confusion about the "Oct 21" date
echo -e "\e[1;34m💡 NOTE ABOUT THE DATE:\e[0m"
echo -e "CloudLinux officially released the secure patch build on \e[33mOctober 21, 2026\e[0m."
echo -e "If your timestamp shows Oct 21 (Night Build), it means your account was"
echo -e "successfully updated to the latest secure version immediately when it dropped.\n"
echo -e "Official Changelog reference: https://cloudlinux.com"
echo -e "\e[36m======================================================\e[0m"
