# Samsung Debloater

<p align="center">
  <img src="https://img.shields.io/badge/Root-KernelSU%20%7C%20APatch%20%7C%20Magisk-blue?style=for-the-badge&logo=android" alt="Root">
  <img src="https://img.shields.io/badge/Target-Samsung%20One%20UI-1428a0?style=for-the-badge&logo=samsung" alt="Samsung One UI">
  <img src="https://img.shields.io/badge/Version-v1.0-green?style=for-the-badge" alt="Version">
  <img src="https://img.shields.io/badge/Author-Abhishek%20Babbu-orange?style=for-the-badge" alt="Author">
</p>

<p align="center">
  <b>Tells Samsung & Google's background trackers to fuck off. Saves battery & kills ads.</b>
</p>

---

## ⚡ Overview

**Samsung Debloater** is a systemless, safe, high-performance debloater module tailored specifically for **Samsung One UI** (One UI 5.x / 6.x / 7.x). 

Unlike destructive debloat scripts that break Knox Guard or trigger `KG Lock (Error 8135)`, this module cleans out over **90+ background battery hogs, silent diagnostic loggers, ad promoters, and AI profilers** while strictly safeguarding the Samsung ecosystem, KnoxPatch-supported apps, Secure Folder, and camera capabilities.

---

## 🌟 Key Features

* **🔋 Massive Idle Battery & Thermal Savings:**
  Eliminates continuous silent logging daemons (`logwriter`, `imslogger`, `dqagent`), heavy AI screen profilers (`rubin.app`, `smartsuggestions`), and Facebook/Aura marketing services.
* **🛡️ 100% Knox Guard & E-Fuse Safe:**
  Zero risk of KG Lockout (`Error 8135`). Strictly preserves `com.samsung.android.kgclient` and device integrity brokers.
* **🔒 Ecosystem & KnoxPatch Protected:**
  Guarantees full compatibility with:
  * ✅ **Secure Folder** & Knox Container engines
  * ✅ **Samsung Health & Health Monitor**
  * ✅ **Samsung Pay Mini** (UPI Payments intact)
  * ✅ **Galaxy Wearable & Buds**
  * ✅ **SmartThings & Smart View**
  * ✅ **Stock Camera Snapchat Kit plugin**
* **🔊 Interactive Volume Key Installer:**
  During installation, an interactive prompt gives you **25 seconds** to optionally remove extra aggressive battery savers (Bixby Voice, Always On Display, Google Assistant, Android System Intelligence) via **[Vol UP (+)]**, or skip and preserve features with **[Vol DOWN (-)]** (default).
* **💻 Built-in `debloater` CLI Tool:**
  Injects a global CLI tool into `/system/bin/debloater`. Run `su -c debloater` in Termux anytime for an interactive terminal menu or direct package management.
* **📝 User Whitelist & Blacklist (`/sdcard/SamsungDebloater/`):**
  Add any package name to `whitelist.txt` to instantly protect/restore it, or to `blacklist.txt` to remove custom bloatware.
* **🔄 Fail-Safe Auto-Restore:**
  Includes automated uninstallation hooks and backups. If the module is ever removed, all debloated packages are automatically restored for User 0!

---

## 📦 What Gets Debloated (Default 91 Packages)

| Category | Targeted Daemons / Packages |
|---|---|
| **Continuous Silent Logging** | `com.samsung.logwriter`, `com.sec.imslogger`, `com.samsung.slsi.telephony.silentlogging`, `com.samsung.android.dqagent`, `com.sec.android.diagmonagent`, `com.samsung.android.scpm`, `com.sec.android.soagent`, `com.wssyncmldm`, `com.sec.location.nsflp2`, etc. |
| **AI Profilers & Habit Analyzers** | `com.samsung.android.rubin.app` (Runestone), `com.samsung.android.smartsuggestions`, `com.samsung.faceservice`, `com.samsung.storyservice` |
| **Adware & App Promoters** | `com.aura.oobe.samsung`, `com.mygalaxy`, `com.opera.max.oem`, `com.samsung.discover`, `com.sec.android.app.billing`, `com.facebook.appmanager`, `com.facebook.services`, `com.facebook.system` |
| **Google Telemetry & Scanners** | `com.google.android.adservices.api`, `com.google.android.gms.location.history`, `com.google.android.projection.gearhead` (Android Auto), `com.google.ar.core`, `com.google.android.printservice.recommendation`, `com.google.android.feedback` |
| **Knox 0x1 Dead-Weight** | `com.samsung.android.samsungpass` & `samsungpassautofill` (Broken on Knox 0x1), `com.samsung.klmsagent`, `com.samsung.android.knox.kpecore`, `com.samsung.android.sm.devicesecurity` (McAfee) |
| **GOS & Migration Daemons** | `com.samsung.android.game.gos`, `com.samsung.android.game.gamehome`, `com.sec.android.easyMover` (Smart Switch) |
| **Unused Samsung Bloat & TTS** | `com.samsung.android.kidsinstaller`, `com.samsung.android.aremoji`, `com.samsung.SMT` (Samsung Offline TTS + 15 unused language packs) |

---

## 🚀 Installation

1. Download the latest **`Samsung_Debloater.zip`** from [Releases](https://github.com/TheBizarreAbhishek/samsung-debloater/releases).
2. Open your root manager:
   * **KernelSU Manager** $\rightarrow$ Modules $\rightarrow$ Install $\rightarrow$ Select `Samsung_Debloater.zip`
   * **APatch Manager** $\rightarrow$ Install Module $\rightarrow$ Select `Samsung_Debloater.zip`
   * **Magisk App** $\rightarrow$ Modules $\rightarrow$ Install from Storage $\rightarrow$ Select `Samsung_Debloater.zip`
3. During installation:
   * **[Vol UP (+)]**: Remove extra aggressive battery-saving features (Bixby, AOD, Assistant, etc.).
   * **[Vol DOWN (-)]**: Keep extra features intact (Default - auto-selected after 25s).
4. Reboot your phone. *(Note: The first boot takes a few moments while Android cleans package caches).*

---

## 🛠️ CLI Usage (`debloater`)

Open **Termux** or any terminal with root access:

```bash
# Open Interactive Terminal Menu
su -c debloater

# Show Full Help & Command Reference
debloater --help

# Restore (Reinstall) a specific app
su -c debloater restore com.google.android.apps.photos

# Debloat (Uninstall) a specific app
su -c debloater remove com.samsung.android.bixby.wakeup

# Re-apply debloat & sync with whitelist
su -c debloater sync

# Show live debloat vs active package statistics
su -c debloater status

# Full Stock Reset (Restores ALL debloated packages)
su -c debloater reset
```

---

## 📁 Custom Configs (`/sdcard/SamsungDebloater/`)

Edit these text files anytime using any file manager (no reboot needed):

* **`whitelist.txt`**: Add package names you want to **keep or restore**. The module will never touch them and will automatically re-link them.
  ```text
  com.google.android.apps.photos
  com.samsung.android.app.aodservice
  ```
* **`blacklist.txt`**: Add custom package names you want to **debloat**.

*Tap the **Action** button on the module in KernelSU to apply whitelist/blacklist changes instantly!*

---

## 👨‍💻 Author

* **Abhishek Babbu** ([@TheBizarreAbhishek](https://github.com/TheBizarreAbhishek))
* Android Kernel & Systems Developer

---

## 📜 License

This project is licensed under the **GNU General Public License v3.0**.
