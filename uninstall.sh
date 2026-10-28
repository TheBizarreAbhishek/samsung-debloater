#!/system/bin/sh
# =========================================================
# Samsung Safe Debloater - Auto-Restore on Uninstall
# Author: Abhishek Babbu
# =========================================================

export PATH="/system/bin:/system/xbin:/data/adb/ap/bin:/data/adb/ksu/bin:$PATH"

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

# Ensure /data/adb/samsung_debloat_packages.txt is populated
RESTORE_LIST="/data/adb/samsung_debloat_packages.txt"
if [ ! -s "$RESTORE_LIST" ]; then
    if [ -n "$MODDIR" ] && [ -f "$MODDIR/packages.txt" ]; then
        cat "$MODDIR/packages.txt" "$MODDIR/extra_packages.txt" 2>/dev/null > "$RESTORE_LIST"
    elif [ -f "/sdcard/SamsungDebloater/packages_backup.txt" ]; then
        cat "/sdcard/SamsungDebloater/packages_backup.txt" "/sdcard/SamsungDebloater/extra_packages_backup.txt" 2>/dev/null > "$RESTORE_LIST"
    fi
fi
chmod 644 "$RESTORE_LIST" 2>/dev/null

restore_now() {
    LOG_FILE="/sdcard/SamsungDebloater/uninstall.log"
    echo "=== Samsung Debloater Auto-Restore Triggered ===" > "$LOG_FILE" 2>/dev/null
    echo "Timestamp: $(date 2>/dev/null)" >> "$LOG_FILE" 2>/dev/null

    restore_file() {
        local file="$1"
        [ -f "$file" ] || return 0
        echo "[*] Restoring from $file..." >> "$LOG_FILE" 2>/dev/null
        cat "$file" | while IFS= read -r pkg || [ -n "$pkg" ]; do
            case "$pkg" in
                \#*|"") continue ;;
            esac
            pkg=$(echo "$pkg" | tr -d ' \r\n')
            [ -n "$pkg" ] || continue
            
            if cmd package install-existing "$pkg" >/dev/null 2>&1; then
                echo "  [✓] Restored: $pkg" >> "$LOG_FILE" 2>/dev/null
            elif pm install-existing "$pkg" >/dev/null 2>&1; then
                echo "  [✓] Restored (pm): $pkg" >> "$LOG_FILE" 2>/dev/null
            fi
        done
    }

    restore_file "$RESTORE_LIST"
    restore_file "/sdcard/SamsungDebloater/packages_backup.txt"
    restore_file "/sdcard/SamsungDebloater/extra_packages_backup.txt"

    echo "=== Auto-Restore Completed Successfully ===" >> "$LOG_FILE" 2>/dev/null
    rm -f "$RESTORE_LIST" 2>/dev/null
}

# 2. Check if Android runtime / Package Manager is ready
# If sys.boot_completed is 1, we can restore immediately!
if [ "$(getprop sys.boot_completed)" = "1" ]; then
    restore_now
    exit 0
fi

# 3. If running during early boot (post-fs-data stage in KernelSU/Magisk):
# Package Manager is not alive yet and /sdcard is not mounted.
# Queue a one-shot restore script into /data/adb/boot-completed.d and /data/adb/service.d!
mkdir -p /data/adb/boot-completed.d 2>/dev/null
mkdir -p /data/adb/service.d 2>/dev/null

cat << 'EOF' > /data/adb/boot-completed.d/samsung_debloater_restore.sh
#!/system/bin/sh
export PATH="/system/bin:/system/xbin:/data/adb/ap/bin:/data/adb/ksu/bin:$PATH"

# Wait until boot is completely finished
while [ "$(getprop sys.boot_completed)" != "1" ]; do
    sleep 2
done

# Wait extra 2 seconds for Package Manager Service to settle
sleep 2

RESTORE_LIST="/data/adb/samsung_debloat_packages.txt"
LOG_FILE="/sdcard/SamsungDebloater/uninstall.log"
mkdir -p "/sdcard/SamsungDebloater" 2>/dev/null

echo "=== Samsung Debloater Auto-Restore (Boot Completed) ===" > "$LOG_FILE" 2>/dev/null
echo "Timestamp: $(date 2>/dev/null)" >> "$LOG_FILE" 2>/dev/null

restore_file() {
    local file="$1"
    [ -f "$file" ] || return 0
    echo "[*] Restoring from $file..." >> "$LOG_FILE" 2>/dev/null
    cat "$file" | while IFS= read -r pkg || [ -n "$pkg" ]; do
        case "$pkg" in
            \#*|"") continue ;;
        esac
        pkg=$(echo "$pkg" | tr -d ' \r\n')
        [ -n "$pkg" ] || continue
        
        if cmd package install-existing "$pkg" >/dev/null 2>&1; then
            echo "  [✓] Restored: $pkg" >> "$LOG_FILE" 2>/dev/null
        elif pm install-existing "$pkg" >/dev/null 2>&1; then
            echo "  [✓] Restored (pm): $pkg" >> "$LOG_FILE" 2>/dev/null
        fi
    done
}

restore_file "$RESTORE_LIST"
restore_file "/sdcard/SamsungDebloater/packages_backup.txt"
restore_file "/sdcard/SamsungDebloater/extra_packages_backup.txt"

echo "=== Auto-Restore Completed Successfully ===" >> "$LOG_FILE" 2>/dev/null

# Clean up one-shot files
rm -f "$RESTORE_LIST" 2>/dev/null
rm -f "/data/adb/boot-completed.d/samsung_debloater_restore.sh" 2>/dev/null
rm -f "/data/adb/service.d/samsung_debloater_restore.sh" 2>/dev/null
exit 0
EOF

chmod 755 /data/adb/boot-completed.d/samsung_debloater_restore.sh 2>/dev/null
cp -f /data/adb/boot-completed.d/samsung_debloater_restore.sh /data/adb/service.d/samsung_debloater_restore.sh 2>/dev/null
chmod 755 /data/adb/service.d/samsung_debloater_restore.sh 2>/dev/null

exit 0
