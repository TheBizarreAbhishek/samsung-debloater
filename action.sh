#!/system/bin/sh
# =========================================================
# Samsung Safe Debloater - KernelSU Action Button
# Author: Abhishek Babbu
# =========================================================

MODDIR=${0%/*}
TOOL="$MODDIR/system/bin/debloater"
[ -f "$TOOL" ] || TOOL="/system/bin/debloater"

if [ ! -f "$TOOL" ]; then
    echo "[!] Debloater tool not found!"
    exit 1
fi

# If running in an interactive terminal (e.g. Termux), launch full menu
if [ -t 0 ]; then
    sh "$TOOL" menu
    exit 0
fi

# KernelSU Action Button Modal (Interactive Volume Keys)
echo "================================================="
echo "       S A M S U N G   D E B L O A T E R         "
echo "             Author: Abhishek Babbu              "
echo "================================================="
echo ""
echo " Choose an action (5s timeout):"
echo "   [ Vol UP (+) ]   : Re-apply Debloat (Sync)"
echo "   [ Vol DOWN (-) ] : RESTORE ALL (Stock Reset)"
echo "-------------------------------------------------"
echo " Waiting for key press (Auto-sync in 5s)..."

key_file="/tmp/action_key_event"
rm -f "$key_file"

( getevent -lqc 1 > "$key_file" 2>/dev/null ) &
event_pid=$!
timer=0
action_choice="SYNC"

while kill -0 "$event_pid" 2>/dev/null; do
    sleep 1
    timer=$((timer + 1))
    if [ "$timer" -ge 5 ]; then
        kill -9 "$event_pid" 2>/dev/null
        break
    fi
done

if [ -f "$key_file" ]; then
    if grep -qiE 'KEY_VOLUMEDOWN|0072' "$key_file"; then
        action_choice="RESTORE"
    elif grep -qiE 'KEY_VOLUMEUP|0073' "$key_file"; then
        action_choice="SYNC"
    fi
    rm -f "$key_file"
fi

echo ""
if [ "$action_choice" = "RESTORE" ]; then
    echo " [✓] Selected: RESTORE ALL (Vol DOWN pressed)"
    echo " [*] Reinstalling all stock bloatware apps..."
    echo ""
    sh "$TOOL" reset
    echo ""
    echo "[✓] Stock reset complete! All apps are active."
else
    echo " [✓] Selected: SYNC DEBLOAT (Default / Vol UP)"
    echo " [*] Syncing debloat & user config rules..."
    echo ""
    sh "$TOOL" sync
    echo ""
    sh "$TOOL" status
fi

echo ""
echo "================================================="
echo " Tip: Run 'su -c debloater' in Termux for CLI"
echo "================================================="
exit 0
