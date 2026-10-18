# Matinee: Focus App Plan

Oct 19, 2026 · @Nahid Hassan Bulbul

## Overview

Matinee is a standalone Mac focus and screen-time app that replaces Session / Focus: a Pomodoro timer that blocks distracting apps and sites during work sessions and shows daily stats on where time actually went.

It ships separately from Marquee, not as a module inside it:

- **Different kind of app:** Marquee is an on-demand toolbox; Matinee runs all day in the background.
- **Permissions:** website blocking needs an admin-level helper and tab tracking needs Automation permission, which Marquee users shouldn't have to grant.
- **Own audience and identity:** separate repo, separate users, and the Matinee name keeps its theatre pairing with Marquee.

The two apps share a Swift package (settings UI, styles, hotkeys, menu bar helpers) and the same visual style. Light integration, such as Marquee pausing clipboard history during a session, can come later.

## Design: macOS 27 and Liquid Glass

Every screen in Matinee uses the macOS 27 Liquid Glass design; no legacy or custom-flat styling.

- **Deployment target:** macOS 27 minimum, so the app always gets the current system look.
- **Native SwiftUI first:** standard controls, toolbars, sidebars, menus and sheets, which pick up Liquid Glass automatically.
- **Custom surfaces:** use the system glass APIs (`glassEffect`, `GlassEffectContainer`) for the floating timer, focus overlay and stats cards; never fake glass with manual blur and opacity.
- **Legibility first:** keep text on solid or lightly tinted layers, and respect the user's system transparency setting.
- **Menu bar and overlays:** the menu bar popover and the "you're in focus mode" overlay follow the same glass style as system menus.
- **App icon:** designed in the Liquid Glass icon style (layered, made with Icon Composer), matching Marquee's icon family.
- **Rule for every new feature:** if a screen doesn't look like a native macOS 27 app, it isn't done.

## Core features

### 1. Focus timer

- Pomodoro-style sessions (25 min work / 5 min break), with custom lengths
- Start from the menu bar or a global hotkey
- A small floating countdown or menu bar timer
- Optional session labels like "MDF," "Konlora," or "Finnish study"

### 2. Blocking during sessions

- **Apps:** opening a blocked app (Discord, YouTube Music) during focus hides or closes it with a gentle "you're in focus mode" overlay
- **Websites:** block sites like facebook.com, youtube.com and reddit.com during sessions
- Allowlist mode (block everything except what you choose) for deep work
- A "hard mode" option so a session can't easily be cancelled halfway

### 3. Time tracking and stats

- Tracks which app is active and for how long, all locally
- Daily and weekly charts, e.g. "VS Code 4h 12m, Chrome 2h 30m, Facebook 1h 05m"
- Focus streaks, total focused hours and sessions completed
- Optional browser tab/domain tracking, so "Chrome 3h" becomes "GitHub 1h, Stripe docs 40m, Facebook 1h"

### 4. Extras

- Break reminders that dim the screen
- Auto-enable macOS Do Not Disturb during sessions
- Ambient sounds (rain, café, white noise)
- An end-of-day summary notification

## How it works on macOS

Website blocking is the only genuinely hard part; everything else uses standard, well-documented APIs.

| Feature | How it's done | Difficulty |
| --- | --- | --- |
| Active app tracking | `NSWorkspace` notifications when the frontmost app changes; no special permission | Easy |
| App blocking | Watch app launches/activation, then hide or terminate the app | Easy |
| Browser tab tracking | AppleScript reads the active tab URL from Safari/Chrome/Arc; needs Automation permission | Medium |
| Website blocking | Edit `/etc/hosts` via a privileged helper, a browser extension, or a Network Extension content filter (most robust, most complex) | Hard |
| Stats storage | SwiftData or SQLite, stored locally | Easy |
| Charts | Swift Charts (built in) | Easy |

Start with the `/etc/hosts` method plus a privileged helper, then upgrade to a Network Extension later if needed.

## Build order (MVP first)

Steps 1 to 3 alone make a usable app.

- [ ] Menu bar timer with start, pause and stop
- [ ] Active app tracking + daily stats screen
- [ ] App blocking during sessions
- [ ] Website blocking
- [ ] Polish: streaks, sounds, hard mode, weekly reports
