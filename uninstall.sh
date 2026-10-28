#!/system/bin/sh
# =========================================================
# Samsung Safe Debloater - Auto-Restore on Uninstall
# Author: Abhishek Babbu
# =========================================================

export PATH="/system/bin:/system/xbin:/data/adb/ap/bin:/data/adb/ksu/bin:$PATH"

# Run restore directly in a detached background subshell
# This guarantees execution whether uninstalled live or during reboot
(
    # If phone is still booting, wait until Android Package Manager Service is ready
    until [ "$(getprop sys.boot_completed)" = "1" ]; do
        sleep 2
    done
    sleep 2

    LOG_FILE="/sdcard/SamsungDebloater/uninstall.log"
    mkdir -p "/sdcard/SamsungDebloater" 2>/dev/null

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

    # Restore from persistent backup lists
    restore_file "/sdcard/SamsungDebloater/packages_backup.txt"
    restore_file "/sdcard/SamsungDebloater/extra_packages_backup.txt"

    echo "=== Auto-Restore Completed Successfully ===" >> "$LOG_FILE" 2>/dev/null
) >/dev/null 2>&1 </dev/null &

exit 0
