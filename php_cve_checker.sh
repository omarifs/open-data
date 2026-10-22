#!/bin/bash
# Multi-Panel Intelligent PHP Patch Checker with Dynamic Changelog Mapping

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

# 2. Control Panel Engine Discovery
PANEL_TYPE="Unknown"
if [ -d "/usr/local/lsws" ] || [ -d "/usr/local/CyberPanel" ]; then
    PANEL_TYPE="olspanel / CyberPanel (OpenLiteSpeed)"
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
    PANEL_CODE="aapanel"
else
    PANEL_TYPE="Standard CloudLinux / LVE Isolated System"
    PANEL_CODE="cloudlinux"
fi

echo -e "🖥️  \e[1;34mDETECTED PANEL:\e[0m System running under \e[1;32m$PANEL_TYPE\e[0m hosting infrastructure.\n"

# Table Header with Changelog Reference Column
printf "%-22s | %-20s | %-16s | %-45s\n" "PHP HANDLER / VER" "BUILD DATE" "PATCH STATUS" "CHANGELOG REFERENCE"
echo "----------------------------------------------------------------------------------------------------------------"

# Supported target matrix 
VERSIONS=("56" "70" "71" "72" "73" "74" "80" "81" "82" "83" "84" "85")

check_php_binary() {
    local label=$1
    local bin_path=$2
    local v_num=$3

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
        
        # Dynamic Changelog Link Generation
        CHANGELOG_URL="https://cloudlinux.com{v_num}"
        
        printf "%-32s | %-20s | %-25b | \e[4;34m%s\e[0m\n" "$label ($BASE_VER)" "$BUILD_DATE" "$STATUS_TEXT" "$CHANGELOG_URL"
    fi
}

# 3. Conditional Array Processor
for V in "${VERSIONS[@]}"; do
    DOT_VER="${V:0:1}.${V:1:1}"
    
    case $PANEL_CODE in
        ols)
            check_php_binary "OLSP-lsphp $DOT_VER" "/usr/local/lsws/lsphp${V}/bin/php" "$V"
            ;;
        cpanel)
            check_php_binary "Alt-PHP $DOT_VER" "/opt/alt/php${V}/usr/bin/php" "$V"
            check_php_binary "ea-PHP $DOT_VER" "/opt/cpanel/ea-php${V}/root/usr/bin/php" "$V"
            ;;
        plesk)
            check_php_binary "Plesk-PHP $DOT_VER" "/opt/plesk/php/$DOT_VER/bin/php" "$V"
            check_php_binary "Alt-PHP $DOT_VER" "/opt/alt/php${V}/usr/bin/php" "$V"
            ;;
        directadmin)
            check_php_binary "DA-Custom $DOT_VER" "/usr/local/php${V}/bin/php" "$V"
            check_php_binary "Alt-PHP $DOT_VER" "/opt/alt/php${V}/usr/bin/php" "$V"
            ;;
        aapanel)
            check_php_binary "aaPanel-PHP $DOT_VER" "/www/server/php/${V}/bin/php" "$V"
            ;;
        cloudlinux)
            check_php_binary "Alt-PHP $DOT_VER" "/opt/alt/php${V}/usr/bin/php" "$V"
            check_php_binary "System-PHP Native" "/usr/bin/php" "$V"
            ;;
    esac
done

echo "----------------------------------------------------------------------------------------------------------------"
echo -e "\e[1;36m💡 Info Validasi Keamanan:\e[0m"
echo -e "Sistem kami menerapkan patch via 'Backporting'. Angka versi PHP Anda akan tetap sama,"
echo -e "namun kode keamanan di dalamnya telah diperbarui. Silakan klik/buka tautan referensi"
echo -e "di atas untuk mencocokkan log rilis resmi dari CloudLinux secara detail."
echo -e "\e[36m====================================================================================================\e[0m"
