#!/bin/bash
# Multi-Panel Intelligent Custom PHP Patch Checker

clear
echo -e "\e[36m======================================================================\e[0m"
echo -e "\e[1;33m               RAPIDPLEX SECURITY SYSTEM - PHP CHECKER                \e[0m"
echo -e "\e[36m======================================================================\e[0m"
echo -e "Automated patch verification for CVE-2026-109618 & CVE-2026-109619\n"

# 1. Detect Active Environment Shell PHP
ACTIVE_PHP_BIN=$(which php 2>/dev/null)
if [ ! -z "$ACTIVE_PHP_BIN" ]; then
    ACTIVE_VER=$($ACTIVE_PHP_BIN -v | head -n 1 | awk '{print $2}')
    echo -e "👉 \e[1;35mACTIVE CLI PHP:\e[0m Your current active shell version is \e[1;33m$ACTIVE_VER\e[0m ($ACTIVE_PHP_BIN)"
else
    echo -e "👉 \e[1;31mACTIVE CLI PHP:\e[0m Standard 'php' alias command not found in this environment."
fi

# 2. Control Panel Engine Discovery & Path Dynamic Mapping
PANEL_TYPE="Unknown"
declare -a SCAN_PATHS

if [ -d "/usr/local/lsws" ] || [ -d "/usr/local/CyberPanel" ]; then
    PANEL_TYPE="olspanel / CyberPanel (OpenLiteSpeed)"
    # olspanel maps binaries directly into /usr/local/lsws/lsphpXX/bin/php
    SCAN_PATHS=("/usr/local/lsws/lsphp" "/usr/local/lsws/lsphp")
    PANEL_CODE="ols"
elif [ -d "/usr/local/cpanel" ]; then
    PANEL_TYPE="cPanel"
    PANEL_CODE="cpanel"
elif [ -d "/usr/local/psa" ]; then
    PANEL_TYPE="Plesk"
    PANEL_CODE="plesk"
elif [ -d "/usr/local/directadmin" ]; then
    PANEL_TYPE="DirectAdmin"
    PANEL_CODE="directadmin"
elif [ -d "/www/server/panel" ]; then
    PANEL_TYPE="aaPanel"
    # aaPanel tracks binaries inside /www/server/php/XX/bin/php
    PANEL_CODE="aapanel"
else
    # Fallback for vanilla standalone CloudLinux / Ubuntu distributions
    PANEL_TYPE="Standard CloudLinux / LVE Isolated System"
    PANEL_CODE="cloudlinux"
fi

echo -e "🖥️  \e[1;34mDETECTED PANEL:\e[0m System running under \e[1;32m$PANEL_TYPE\e[0m hosting infrastructure.\n"

# Table Header
printf "%-24s | %-22s | %-15s\n" "PANEL PHP HANDLER" "BUILD DATE" "PATCH STATUS"
echo "----------------------------------------------------------------------"

# Supported target matrix 
VERSIONS=("56" "70" "71" "72" "73" "74" "80" "81" "82" "83" "84" "85")

check_php_binary() {
    local label=$1
    local bin_path=$2

    unset BUILD_DATE BASE_VER IS_PATCHED STATUS_TEXT
    if [ -f "$bin_path" ]; then
        BUILD_DATE=$($bin_path -v | grep -oE "built: [A-Za-z0-9: ]+" | sed 's/built: //')
        BASE_VER=$($bin_path -v | head -n 1 | awk '{print $2}')
        
        # Binary structural scanning for backported CVE data blocks
        IS_PATCHED=$(strings "$bin_path" 2>/dev/null | grep -E "CVE-2026-109618|CVE-2026-109619" | head -n 1)
        
        if [ ! -z "$IS_PATCHED" ]; then
            STATUS_TEXT="\e[32mSECURE (Patched)\e[0m"
        else
            if [[ "$BUILD_DATE" == *"Oct 21 2026"* || "$BUILD_DATE" == *"Oct 22 2026"* ]]; then
                STATUS_TEXT="\e[32mSECURE (Oct 21/22)\e[0m"
            else
                STATUS_TEXT="\e[31mNOT PATCHED\e[0m"
            fi
        fi
        
        if [ "$bin_path" == "$ACTIVE_PHP_BIN" ]; then
            label="$label \e[1;35m(ACTIVE)\e[0m"
        fi
        
        printf "%-34s | %-22s | %b\n" "$label ($BASE_VER)" "$BUILD_DATE" "$STATUS_TEXT"
    fi
}

# 3. Conditional Array Processor (Ensures ONLY the active panel rules are executed)
for V in "${VERSIONS[@]}"; do
    DOT_VER="${V:0:1}.${V:1:1}"
    
    case $PANEL_CODE in
        ols)
            # Scan exclusive to OpenLiteSpeed Panel (olspanel) architectures
            check_php_binary "OLSP-lsphp $DOT_VER" "/usr/local/lsws/lsphp${V}/bin/php"
            ;;
        cpanel)
            check_php_binary "Alt-PHP $DOT_VER" "/opt/alt/php${V}/usr/bin/php"
            check_php_binary "ea-PHP $DOT_VER" "/opt/cpanel/ea-php${V}/root/usr/bin/php"
            ;;
        plesk)
            check_php_binary "Plesk-PHP $DOT_VER" "/opt/plesk/php/$DOT_VER/bin/php"
            check_php_binary "Alt-PHP $DOT_VER" "/opt/alt/php${V}/usr/bin/php"
            ;;
        directadmin)
            check_php_binary "DA-Custom $DOT_VER" "/usr/local/php${V}/bin/php"
            check_php_binary "Alt-PHP $DOT_VER" "/opt/alt/php${V}/usr/bin/php"
            ;;
        aapanel)
            check_php_binary "aaPanel-PHP $DOT_VER" "/www/server/php/${V}/bin/php"
            ;;
        cloudlinux)
            check_php_binary "Alt-PHP $DOT_VER" "/opt/alt/php${V}/usr/bin/php"
            check_php_binary "System-PHP Native" "/usr/bin/php"
            ;;
    esac
done

echo "----------------------------------------------------------------------"
echo -e "\e[1;34m🔗 OFFICIAL SECURITY BULLETIN:\e[0m"
echo -e "Read vendor data logs: https://cloudlinux.com"
echo -e "\n\e[1;36m💡 How We Validate Your Account Security:\e[0m"
echo -e "Web hosts use a system called 'Backporting'. Your PHP version text remains"
echo -e "the same, but the core security code has been safely patched inside."
echo -e "\e[36m======================================================================\e[0m"
