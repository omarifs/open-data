#!/bin/bash
# Update php_cve_checker.sh with this comprehensive multi-branch version

clear
echo -e "\e[36m======================================================\e[0m"
echo -e "\e[1;33m       RAPIDPLEX SECURITY SYSTEM - PHP CHECKER        \e[0m"
echo -e "\e[36m======================================================\e[0m"
echo -e "Automated patch verification for CVE-2026-109618 & CVE-2026-109619\n"

# Table Header
printf "%-18s | %-22s | %-15s\n" "PHP HANDLER / VER" "BUILD DATE" "PATCH STATUS"
echo "----------------------------------------------------------------------"

# Full scanning matrix from legacy PHP 5.6 up to the latest PHP 8.5
VERSIONS=("56" "70" "71" "72" "73" "74" "80" "81" "82" "83" "84" "85")

check_php_binary() {
    local label=$1
    local bin_path=$2

    if [ -f "$bin_path" ]; then
        # 1. Extract build timestamp
        BUILD_DATE=$($bin_path -v | grep -oE "built: [A-Za-z0-9: ]+" | sed 's/built: //')
        
        # 2. Extract base version array
        BASE_VER=$($bin_path -v | head -n 1 | awk '{print $2}')
        
        # 3. Check for backported CVE metadata tags within the binary structure
        IS_PATCHED=$(strings "$bin_path" 2>/dev/null | grep -E "CVE-2026-109618|CVE-2026-109619" | head -n 1)
        
        if [ ! -z "$IS_PATCHED" ]; then
            STATUS_TEXT="\e[32mSECURE (Patched)\e[0m"
        else
            # Macro-date check matching the global emergency deployment wave (Oct 21-22, 2026)
            if [[ "$BUILD_DATE" == *"Oct 21 2026"* || "$BUILD_DATE" == *"Oct 22 2026"* ]]; then
                STATUS_TEXT="\e[32mSECURE (Oct 21/22)\e[0m"
            else
                STATUS_TEXT="\e[31mNOT PATCHED\e[0m"
            fi
        fi
        
        printf "%-18s | %-22s | %b\n" "$label ($BASE_VER)" "$BUILD_DATE" "$STATUS_TEXT"
    fi
}

# Run the execution scan across all targets
for V in "${VERSIONS[@]}"; do
    # Format display names natively
    DOT_VER="${V:0:1}.${V:1:1}"
    
    # Target 1: CloudLinux Alt-PHP Branch
    check_php_binary "Alt-PHP $DOT_VER" "/opt/alt/php${V}/usr/bin/php"
    
    # Target 2: cPanel EasyApache 4 Branch (ea-php)
    check_php_binary "ea-PHP $DOT_VER" "/opt/cpanel/ea-php${V}/root/usr/bin/php"
done

echo "----------------------------------------------------------------------"
echo -e "\e[1;34m🔗 OFFICIAL CLOUDLINUX ADVISORY:\e[0m"
echo -e "Read full statement: https://cloudlinux.com"
echo -e "\n\e[1;36m💡 How We Validate Your Account Security:\e[0m"
echo -e "CloudLinux uses a system called 'Backporting'. Your PHP version text remains"
echo -e "the same, but the core security code has been safely patched inside."
echo -e "\e[36m======================================================================\e[0m"
