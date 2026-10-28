#!/system/bin/sh
SKIPUNZIP=0

ui_print "================================================="
ui_print "       S A M S U N G   D E B L O A T E R         "
ui_print "================================================="
ui_print "  * Version: v1.0                                "
ui_print "  * Author: Abhishek Babbu                       "
ui_print "================================================="
ui_print ""
ui_print "[*] Target Device: Samsung Galaxy / One UI"
ui_print "[*] Mode: Safe Battery & Performance Optimization"
ui_print ""

# 0. Setup /sdcard/SamsungDebloater Config Directory
CONFIG_DIR="/sdcard/SamsungDebloater"
WHITELIST="$CONFIG_DIR/whitelist.txt"
BLACKLIST="$CONFIG_DIR/blacklist.txt"
mkdir -p "$CONFIG_DIR" 2>/dev/null

if [ ! -f "$WHITELIST" ]; then
    cat << 'EOF' > "$WHITELIST"
# =========================================================
# Samsung Debloater - User Whitelist
# Add package names here that you want to KEEP or RESTORE.
# Any package listed here will NEVER be debloated.
# Lines starting with # are comments and ignored.
# =========================================================
# Examples (uncomment to keep):
# com.google.android.apps.photos
# com.samsung.android.app.aodservice
# com.samsung.android.forest
EOF
fi

if [ ! -f "$BLACKLIST" ]; then
    cat << 'EOF' > "$BLACKLIST"
# =========================================================
# Samsung Debloater - User Blacklist
# Add extra custom package names here to DEBLOAT.
# Any package listed here will be automatically uninstalled.
# Lines starting with # are comments and ignored.
# =========================================================
EOF
fi

# Copy permanent package backup lists for fail-safe uninstallation
cp -f "$MODPATH/packages.txt" "$CONFIG_DIR/packages_backup.txt" 2>/dev/null
cp -f "$MODPATH/extra_packages.txt" "$CONFIG_DIR/extra_packages_backup.txt" 2>/dev/null

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

# 1. Process Default Debloat List
DEBLOAT_LIST="$MODPATH/packages.txt"
ui_print "[+] Processing default bloatware & telemetry removal..."
COUNT=0
while IFS= read -r pkg || [ -n "$pkg" ]; do
    case "$pkg" in
        \#*|"") continue ;;
    esac
    
    if is_whitelisted "$pkg"; then
        ui_print "  [*] Whitelisted (Preserved): $pkg"
        cmd package install-existing "$pkg" >/dev/null 2>&1
        continue
    fi

    if pm list packages --user 0 | grep -q "^package:${pkg}$"; then
        if pm uninstall --user 0 "$pkg" >/dev/null 2>&1; then
            ui_print "  [-] Removed: $pkg"
            COUNT=$((COUNT + 1))
        fi
    fi
done < "$DEBLOAT_LIST"

ui_print ""
ui_print "[+] Default debloat complete! ($COUNT packages removed)"
ui_print ""

# 2. Interactive Volume Key Selector for Extra Aggressive Battery Savers
EXTRA_LIST="$MODPATH/extra_packages.txt"

if [ -f "$EXTRA_LIST" ]; then
    ui_print "-------------------------------------------------"
    ui_print "   EXTRA AGGRESSIVE BATTERY SAVER OPTIONS        "
    ui_print "-------------------------------------------------"
    ui_print " These apps break features but save extra battery:"
    ui_print "   • Bixby Voice Assistant & Wakeup Listener"
    ui_print "   • Google Assistant & 'Hey Google' / Gemini"
    ui_print "   • Android System Intelligence (ASI)"
    ui_print "   • Digital Wellbeing (Screen Time Tracker)"
    ui_print "   • Always On Display (AOD)"
    ui_print "   • Smart Stay & Smart Face"
    ui_print "   • Edge Panels & Smart Call (Hiya)"
    ui_print "   • Google Photos & Device Health (Turbo)"
    ui_print "-------------------------------------------------"
    ui_print "   [ Vol UP (+) ]   : REMOVE ALL (Max Battery)   "
    ui_print "   [ Vol DOWN (-) ] : SKIP (Keep Features - DEFAULT)"
    ui_print "-------------------------------------------------"
    ui_print " Waiting for key press (Auto-skip in 25s)..."

    key_file="/tmp/debloat_key_event"
    rm -f "$key_file"
    
    ( getevent -lqc 1 > "$key_file" 2>/dev/null ) &
    event_pid=$!
    timer=0
    user_choice="SKIP"

    while kill -0 "$event_pid" 2>/dev/null; do
        sleep 1
        timer=$((timer + 1))
        if [ "$timer" -ge 25 ]; then
            kill -9 "$event_pid" 2>/dev/null
            ui_print " [!] Timed out (25s)! Default action: SKIP."
            user_choice="SKIP"
            break
        fi
    done

    if [ -f "$key_file" ]; then
        if grep -qiE 'KEY_VOLUMEUP|0073' "$key_file"; then
            user_choice="REMOVE"
        elif grep -qiE 'KEY_VOLUMEDOWN|0072' "$key_file"; then
            user_choice="SKIP"
        fi
        rm -f "$key_file"
    fi

    if [ "$user_choice" = "REMOVE" ]; then
        ui_print ""
        ui_print " [✓] Selection: REMOVE (Vol UP pressed)"
        ui_print " [+] Applying extra aggressive battery optimizations..."
        touch "$MODPATH/extra_enabled"
        EXTRA_COUNT=0
        while IFS= read -r pkg || [ -n "$pkg" ]; do
            case "$pkg" in
                \#*|"") continue ;;
            esac
            if is_whitelisted "$pkg"; then
                ui_print "  [*] Whitelisted (Preserved): $pkg"
                cmd package install-existing "$pkg" >/dev/null 2>&1
                continue
            fi
            if pm list packages --user 0 | grep -q "^package:${pkg}$"; then
                if pm uninstall --user 0 "$pkg" >/dev/null 2>&1; then
                    ui_print "  [-] Extra Removed: $pkg"
                    EXTRA_COUNT=$((EXTRA_COUNT + 1))
                fi
            fi
        done < "$EXTRA_LIST"
        ui_print " [+] Extra debloat complete! ($EXTRA_COUNT additional packages removed)"
    else
        ui_print ""
        ui_print " [✓] Selection: SKIP (Default)"
        ui_print " [*] Extra features kept intact (Bixby, Google Assistant, AOD, etc. preserved)."
    fi
fi

ui_print ""
ui_print "================================================="
ui_print "  [i] Debloater CLI Tool Installed!              "
ui_print "      Run 'su -c debloater' in Termux anytime    "
ui_print "  [i] User Config Created:                       "
ui_print "      /sdcard/SamsungDebloater/whitelist.txt     "
ui_print "      /sdcard/SamsungDebloater/blacklist.txt     "
ui_print "================================================="
ui_print "  [!] NOTE: First boot will take a few minutes   "
ui_print "      while Android cleans package caches.       "
ui_print "================================================="
ui_print "  Installed successfully by Abhishek Babbu!      "
ui_print "================================================="

set_perm_recursive "$MODPATH" 0 0 0755 0644
set_perm "$MODPATH/service.sh" 0 0 0755
set_perm "$MODPATH/action.sh" 0 0 0755
set_perm "$MODPATH/uninstall.sh" 0 0 0755
set_perm "$MODPATH/system/bin/debloater" 0 0 0755
