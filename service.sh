#!/system/bin/sh
# Samsung Safe Debloater - Boot Service
# Author: Abhishek Babbu

MODDIR=${0%/*}
CONFIG_DIR="/sdcard/SamsungDebloater"
WHITELIST="$CONFIG_DIR/whitelist.txt"
BLACKLIST="$CONFIG_DIR/blacklist.txt"

# Wait until boot is complete
until [ "$(getprop sys.boot_completed)" = "1" ]; do
    sleep 3
done

# Wait for package manager to settle
sleep 10

is_whitelisted() {
    local target="$1"
    [ -f "$WHITELIST" ] || return 1
    while IFS= read -r line || [ -n "$line" ]; do
        case "$line" in
            \#*|"") continue ;;
        esac
        line=$(echo "$line" | tr -d ' \r\n')
        if [ "$line" = "$target" ]; then
            return 0
        fi
    done < "$WHITELIST"
    return 1
}

debloat_from_file() {
    local file="$1"
    [ -f "$file" ] || return 0
    while IFS= read -r pkg || [ -n "$pkg" ]; do
        case "$pkg" in
            \#*|"") continue ;;
        esac
        
        # If user whitelisted this package, ensure it is restored
        if is_whitelisted "$pkg"; then
            cmd package install-existing "$pkg" >/dev/null 2>&1
            continue
        fi

        if pm list packages --user 0 | grep -q "^package:${pkg}$"; then
            pm uninstall --user 0 "$pkg" >/dev/null 2>&1
        fi
    done < "$file"
}

# 1. Process default packages
debloat_from_file "$MODDIR/packages.txt"

# 2. Process extra packages if enabled by user
if [ -f "$MODDIR/extra_enabled" ]; then
    debloat_from_file "$MODDIR/extra_packages.txt"
fi

# 3. Process custom user blacklist
if [ -f "$BLACKLIST" ]; then
    debloat_from_file "$BLACKLIST"
fi

exit 0
