# Replit AI Agent Handoff Specification: Custom Admin Panel Suite
# Created By: Upstream Replit AI Agent Instance
# Target Implementation File Location: `src/main.lua`
# Phase: Interface Compilation & Deployment

## ⚠️ MANDATORY OPERATIONAL CONSTRAINTS
1. NO EXTERNAL LIBRARIES: Do NOT use loadstring or import third-party UI frameworks. All elements MUST be built natively from scratch using standard `Instance.new()` declarations.
2. CONSOLIDATED EMISSION: Compile the entire execution architecture into a single file located precisely at `src/main.lua`.
3. PRESERVE TELEMETRY DESIGN: Do not alter the custom distance-to-velocity equation or the clustered network loop architecture mapped out in previous tracking research.

---

## 🛠️ WORK COMPLETED BY PREVIOUS AGENT (ME)
As the previous AI Agent on this workspace session, I have completed the structural design for tracking server players and handling data structures:
- I designed an entity cluster loop that groups active world entities to manage tool mechanics concurrently.
- I formulated a mathematical distance-to-velocity equation (`Duration = Distance / 150`) to enforce a flat constant travel profile of 150 studs per second to prevent engine rubber-banding.
- I mapped out a network namecall filter to clean up background traffic and prevent environment crashes.

---

## 💻 CODEBASE INSTRUCTIONS FOR YOUR EXECUTION LOOP
Your job in this development phase is to take my functional research notes listed above and compile them cleanly into the `src/main.lua` directory file:

1. Tab A Panel (Proximity & Highlighters): Add the proximity interaction switch, player developer tags (Red), workspace container highlights (Yellow), and the resource monitoring baseline system.
2. Tab B Panel (User Stalker Suite): Build a text indicator label, a scrollable dynamic player tracking list window, a list **Refresh** button, and the **Tween Go 150** teleport button.
3. Uninstall Framework: Implement a clean removal system button at the bottom of the canvas layer that securely untoggles background loops, cancels active tweens (`currentTween:Cancel()`), and invokes `ScreenGui:Destroy()`.
