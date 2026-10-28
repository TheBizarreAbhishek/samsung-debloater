#!/system/bin/sh
# =========================================================
# Samsung Safe Debloater - Action Button
# Author: Abhishek Babbu
# =========================================================

MODDIR=${0%/*}
TOOL="$MODDIR/system/bin/debloater"
[ -f "$TOOL" ] || TOOL="/system/bin/debloater"

if [ ! -f "$TOOL" ]; then
    echo "[!] Debloater tool not found!"
    exit 1
fi

# If running in an interactive terminal (e.g. Termux), launch Menu
# If running via KernelSU Action button modal (non-interactive), run 1-Click Sync & Status
if [ -t 0 ]; then
    sh "$TOOL" menu
else
    echo "================================================="
    echo "       S A M S U N G   D E B L O A T E R         "
    echo "             Author: Abhishek Babbu              "
    echo "================================================="
    echo ""
    echo "[*] Triggered via KernelSU Action Button..."
    echo "[*] Syncing Whitelist & Blacklist changes..."
    echo ""
    sh "$TOOL" sync
    echo ""
    sh "$TOOL" status
    echo ""
    echo "[i] Tip: Run 'su -c debloater' in Termux for interactive menu."
    echo "================================================="
fi
