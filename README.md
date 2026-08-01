# 💘 LoveManiac Cheats & SDK

<p align="center">
  <img src="https://i.ibb.co/tT0CbnL5/image.png" width="100%" alt="LoveManiac Cheats SDK Header">
</p>

Adds a convenient cheat menu with many features to Love Maniac.

![Godot Version](https://img.shields.io/badge/Godot_version-4.5-blue)
![Game Version](https://img.shields.io/badge/Supported_Love_Maniac_Ver-0.3.5_EA4-red)
![License](https://img.shields.io/badge/License-MIT-yellow)
---

## 📝 About the Mod
**Love Maniac Cheats & SDK** adds an advanced cheat and modification framework to the game via a custom in-game overlay. It grants total control over all gameplay systems, variables, and asset layers with just a few clicks.

Built on a robust, semi-automatic dynamic architecture, this SDK seamlessly hooks into Godot 4.5 instances and is engineered to withstand official game updates without breaking core modules. Currently optimized for **Windows**, with experimental support for **Linux** and plans for an **Android** build.

---

## 🔥 Features & Tabs

### 🎨 CUSTOMIZATION Tab
* **Interface Hotkey Bind** — Dynamically reassign the menu toggle key (defaults to `Insert`) directly in the UI to avoid conflicts with other mods.
* **Theme Manager** — Switch between multiple sleek UI styles on the fly, driven by an OOP inheritance architecture (including the community favorite *Dark Cyan* preset).
* **Enable UI Animations** — Toggles responsive, hardware-accelerated interface animations and smooth hover transitions.

### ⚔️ COMBAT Tab (100% Stable)
* **God Mode** — Grants complete immortality by blocking all incoming damage and hit registration.
* **Damage Multiplier** — Precise real-time damage scaling adjusted down to tenths, allowing you to inflict massive 117+ HP critical strikes.
* **Chara Dress Control** — Advanced layer-by-layer clothing manipulation (`Sweater`, `Shorts`, `Bra`, `Panties`) and an `Undress All` trigger with native support for clothes-tearing visuals.
* **Chara Scenes Control** — Safe, runtime execution of any NSFW battle variant or animation phase without risking engine memory leaks or game crashes.

### 💾 SAVE MANIPULATION Tab
* **Save File Editor** — Directly modifies active save parameters at runtime. Instantly unlocks all alternative Chara skins and completes the gallery unlock process without any tedious grinding.

### 📦 INVENTORY Tab
* **Item Spawner** — Directly forces any item from the game database into your active inventory slots (including Chocolate, Gelly Fish, Legendary Hero, and the Mysterious Item).

### 👁️ VISUALS Tab
* **Hitbox & Trigger Viewer** — Globally toggles the engine debug renderer to expose collision shapes (`StaticBody2D`), event triggers (`Area2D`), and AI pathways (`NavigationLink2D`) through walls.

### 🎬 SCENES Tab
* **Level Navigator** — Grants developer-level map-selection tools to bypass regular story triggers and teleports the player directly to any scene included in the current game build.

### 💰 EXPLOITS Tab (Economy Bypass)
* **Disable Nebby Cat** — Ultimate bypass for the stupid nebby cat. >:(
* **Unlock All Nebby Cats** — Instantly updates your save file to `4/4` cats collected, safely unlocking gallery reward cards.
* **Mysterious Item Unlock** — permanently adds a mystical item to your inventory (MAY REQUIRE RE-ENTERING THE ITEM MENU)*.

---

## 🕹️ How to Use
To open the mod menu, press the **`Insert`** key (can be rebound at any time in the **Customization** tab). This will toggle the high-contrast UI overlay, which features smooth drag-and-drop movement, custom layout folding, and scalable menus.

---

## 🛠️ How to Install
The mod utilizes the dynamic `loadot` modloader standard format.

1. Navigate to the **[Releases](https://github.com/Swish-XD/Love-Maniac-Cheats/releases)** section of this repository and fetch the latest build archive.
   * *Note: If the game developers push a massive structural patch, older mod releases might require an alignment update.*
2. Extract the archive contents directly into the game's **root folder** (where the main executable resides).
3. Boot up the game and enjoy the SDK!

---

## 🐛 Troubleshooting & Bug Reports
If you encounter any engine exceptions, lockups, or script crashes, run the game through the command line to capture raw output logs:

1. Open the game's **root folder**.
2. Click the address bar in your Windows File Explorer, type `cmd`, and press Enter.
3. Launch the instance by executing:
   ```bash
   "Love Maniac.exe"
   ```
4. Reproduce the bug in-game, copy the terminal console logs, and open a new **Issue Ticket** here.

---

## 🗺️ Development Roadmap

- [ ] **Automatic Character Database Population** — Implementation of an automatic asset folder scanner (`res://`) at startup to eliminate manual path hardcoding, achieving 75% immunity to future game updates.
- [ ] **Standalone CheatSDK Release** — Extracting the modular framework (accordions, customized sliders, recursive themes) as a standalone template for other Godot 4 developers.
- [X] **Auto-Update Checker** — Integration of a live update verification system hooking into the GitHub Releases API with automated HTTP header error handling.

---

## 📜 Disclaimer
*This project is created strictly for educational purposes, practicing reverse-engineering, and analyzing the Godot 4.5 engine framework structure. All rights to the original game logic and character assets belong entirely to Team Nebula.*
