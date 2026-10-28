#!/system/bin/sh
# =========================================================
# Samsung Safe Debloater - Auto-Restore on Uninstall
# Author: Abhishek Babbu
# =========================================================

export PATH="/system/bin:/system/xbin:/data/adb/ap/bin:/data/adb/ksu/bin:$PATH"

LOG_FILE="/sdcard/SamsungDebloater/uninstall.log"
echo "=== Samsung Debloater Uninstall Triggered ===" > "$LOG_FILE" 2>/dev/null
echo "Timestamp: $(date 2>/dev/null)" >> "$LOG_FILE" 2>/dev/null

# 1. Multi-source directory discovery
MODDIR=""
if [ -d "${0%/*}" ] && [ "${0%/*}" != "$0" ] && [ -f "${0%/*}/packages.txt" ]; then
    MODDIR="${0%/*}"
elif [ -n "$1" ] && [ -f "/data/adb/modules/$1/packages.txt" ]; then
    MODDIR="/data/adb/modules/$1"
elif [ -f "/data/adb/modules/samsung_debloater/packages.txt" ]; then
    MODDIR="/data/adb/modules/samsung_debloater"
elif [ -f "/sdcard/SamsungDebloater/packages_backup.txt" ]; then
    MODDIR="/sdcard/SamsungDebloater"
fi

echo "Resolved MODDIR: $MODDIR" >> "$LOG_FILE" 2>/dev/null

restore_file() {
    local file="$1"
    [ -f "$file" ] || return 0
    echo "[*] Restoring from $file..." >> "$LOG_FILE" 2>/dev/null
    while IFS= read -r pkg || [ -n "$pkg" ]; do
        case "$pkg" in
            \#*|"") continue ;;
        esac
        pkg=$(echo "$pkg" | tr -d ' \r\n')
        [ -n "$pkg" ] || continue
        
        # Execute restore
        if cmd package install-existing "$pkg" >/dev/null 2>&1; then
            echo "  [✓] Restored: $pkg" >> "$LOG_FILE" 2>/dev/null
        elif pm install-existing "$pkg" >/dev/null 2>&1; then
            echo "  [✓] Restored (pm): $pkg" >> "$LOG_FILE" 2>/dev/null
        fi
    done < "$file"
}

# 2. Restore all standard and backup sources
if [ -n "$MODDIR" ]; then
    restore_file "$MODDIR/packages.txt"
    restore_file "$MODDIR/extra_packages.txt"
fi

# Fallback to persistent storage backups if MODDIR was wiped
restore_file "/sdcard/SamsungDebloater/packages_backup.txt"
restore_file "/sdcard/SamsungDebloater/extra_packages_backup.txt"

echo "=== Auto-Restore Completed Successfully ===" >> "$LOG_FILE" 2>/dev/null
exit 0
