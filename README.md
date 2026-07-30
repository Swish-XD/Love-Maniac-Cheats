# 🎭 LoveManiac Cheats & SDK

![Header Image](https://placehold.co)

Adds a convenient cheat menu with many features to Love Maniac.

![Godot Version](https://img.shields.io/badge/Godot_version-4.5-blue)
![Game Version](https://img.shields.io/badge/Supported_Love_Maniac_Ver-0.3.5_EA4-red)
![License](https://img.shields.io/badge/License-MIT-yellow)

---

## 📝 About the Mod
**Love Maniac Cheats** adds cheat functions to the game in a special menu that allow access to all in-game content with just a few clicks. 

The mod is currently available on **Windows**, but I plan to release it for other platforms, such as **Android** and **Linux** *(it might work on Linux right now, but I haven't tested it yet)*. It is built on a robust, semi-automatic dynamic architecture that seamlessly integrates into Godot 4 games and withstands official game updates.

---

## 🔥 Features & Tabs

### ⚔️ COMBAT Tab (100% Stable)
* **God Mode** — Complete immortality, blocks all incoming damage.
* **Damage Multiplier** — Precise damage scaling adjusted down to tenths (inflict massive 117+ HP hits).
* **Chara Dress Control** — Layer-by-layer clothing removal (`Sweater`, `Shorts`, `Bra`, `Panties`) and an `Undress All` function with native support for clothes-tearing effects.
* **Chara Scenes Control** — Seamless dynamic execution of any NSFW scene right in the middle of a battle without engine crashes.

### 💰 EXPLOITS Tab (Economy Bypass)
* **Disable Nebby Cat** — Ultimate bypass for the anti-cheat cat. The script monitors the scene tree in `_process` and wipes the dynamic `nebby_cat` node from existence using `queue_free()`, completely ignoring the strict `G 10000` wallet limit inside the game's `reload()` function.
* **Unlock All Nebby Cats** — Instantly updates your save file to `4/4` cats collected, safely unlocking gallery reward cards.
* **Mysterious Item Unlock** — Permanently removes the cash limit. You can now hold `10001 G` and buy the mysterious item *(Warning: triggers the developer's hidden screamer!)*.

---

## 📊 Inventory & Save Management

| Tab | Feature | Description | Status |
| :--- | :--- | :--- | :--- |
| **Inventory** | `Give Chocolate` | Instantly adds Chocolate to your bag | 🟢 Working |
| **Inventory** | `Give Gelly Fish` | Adds Gelly Fish (activates custom slime gel) | 🟢 Working |
| **Inventory** | `Give Legendary Hero` | Adds Legendary Hero item | 🟢 Working |
| **Inventory** | `Give Mysterious Item`| Directly forces the Mysterious Item into slots | 🟢 Working |
| **Save Manager**| `Unlock All Costumes` | Immediately unlocks all alternative Chara skins | 🟢 Working |
| **Save Manager**| `Unlock All Scenes` | Complete gallery unlock without grinding | 🟢 Working |

---

## 🕹️ How to Use
To open the mod menu, press the **`Insert`** key. This will toggle the cheat window interface, which can be freely dragged around, moved, and expanded.

---

## 🛠️ How to Install
The mod uses the dynamic `loadot` modloader format.

1. Go to the **[Releases](https://github.com)** page and download the latest archive.
   * *Note: Keep an eye on release info! If the developers push a brand new patch, I might not update the mod fast enough, so older releases could break on newer game versions.*
2. Extract the archive contents directly into the game's **root folder**.
3. Launch the game and enjoy!

---

## 🐛 Troubleshooting & Bug Reports
If you encounter any issues or crashes, follow these steps to capture accurate engine logs:

1. Open the game's **root folder**.
2. Click the address bar in your File Explorer.
3. Erase the current path, type `cmd` to open the terminal, and execute:
   ```bash
   "Love Maniac.exe"
   ```
4. Trigger the bug in-game and copy the console outputs.
5. Open an **Issue Ticket** on this GitHub repository, paste your logs, and wait for a patch or a response from me!

---

## 🗺️ Development Roadmap

- [ ] **Automatic Character Database population** — Automatic asset folder scanning (`res://`) at startup to eliminate manual path hardcoding (75% immunity to future game updates).
- [ ] **Standalone CheatSDK Release** — Extracting the modular menu framework (accordions, checkboxes, automatic layouts) as a separate SDK for other Godot 4 modders.
- [X] **Auto-Update Checker** — Implementation of a semi-automatic update downloader hooking directly into the GitHub Releases API.

---

## 📜 Disclaimer
*This project is created strictly for educational purposes, practicing reverse-engineering, and analyzing the Godot 4.5 engine structure. All rights to the original game assets belong to Team Nebula.*
