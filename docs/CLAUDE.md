# Matinee

Matinee is a standalone macOS focus and screen-time app: a Pomodoro timer that blocks
distracting apps and websites during work sessions and shows daily stats on where time went.
It is a companion to Marquee (same developer, same visual style) but a separate app.

## Read first

- Before starting any task, read `docs/PLAN.md`. It is the source of truth for features,
  technical approach and build order.
- Work through the build order in `docs/PLAN.md` one step at a time. Don't start a later
  step until the current one is done, unless asked.
- If a request conflicts with `docs/PLAN.md` or this file, point out the conflict before
  writing code.

## Platform and stack

- macOS 27 minimum deployment target. Don't add availability checks or fallbacks for
  older macOS versions.
- Swift 6 and SwiftUI. Use AppKit only where SwiftUI can't do the job (for example,
  NSWorkspace app tracking, NSStatusItem details, window-level overlays).
- Swift Concurrency (async/await, actors) instead of callbacks or Combine where practical.
- Persistence: SwiftData. All data stays local on the Mac; no analytics, no network calls
  except what a feature explicitly needs.
- Charts: Swift Charts.
- No third-party dependencies without asking first.

## Design rules (always)

Every screen must look like a native macOS 27 app using the Liquid Glass design.

- Prefer standard SwiftUI controls, toolbars, sidebars, menus and sheets, which adopt
  Liquid Glass automatically.
- For custom surfaces (floating timer, focus overlay, stats cards, menu bar popover), use
  the system glass APIs (`glassEffect`, `GlassEffectContainer`).
- Never fake glass with manual blur, materials hacks or hard-coded opacity.
- Keep text legible: put dense text on solid or lightly tinted layers, and respect the
  user's system transparency and accessibility settings.
- Use system fonts, SF Symbols, semantic colors and standard spacing. Support light and
  dark mode.
- A screen that doesn't look like a native macOS 27 app is not finished.

## Project structure

- Use XcodeGen. The project is defined in `project.yml`; never commit an `.xcodeproj`
  (add it to `.gitignore`).
- Layout:
  - `Matinee/App/`: app entry point, menu bar setup
  - `Matinee/Features/<FeatureName>/`: one folder per feature (Timer, Blocking,
    Tracking, Stats, Settings)
  - `Matinee/Shared/`: models, helpers, design components
  - `MatineeTests/`: unit tests
  - `docs/`: plan and notes
- Code meant to be shared with Marquee (settings UI, styles, hotkeys, menu bar helpers)
  goes in a local Swift package under `Packages/`, so it can be extracted later.

## Working in cloud sessions

- Cloud sessions run on Linux and cannot build or run macOS apps. Never claim the app
  builds or works unless it was actually compiled on a Mac or in CI.
- Write code carefully so it compiles on the first try: correct imports, exact API names,
  `@MainActor` where UI is touched.
- After each change, list what to test on the Mac.
- When I paste Xcode errors, fix the root cause, not just the symptom.
- A GitHub Actions workflow on a macOS runner builds every push. Check its result when
  available.

## Permissions and safety

- Website blocking uses a privileged helper. Keep it minimal: it should only edit the
  Matinee-managed section of `/etc/hosts` and always restore it when a session ends or
  the app quits.
- Ask for permissions (Automation, Accessibility) only when the feature that needs them
  is first used, with a clear explanation.
- Never block or close system apps (Finder, System Settings, Xcode, Terminal) by default.

## Code style

- Small, focused files and types. Clear names over comments.
- One feature per commit, with a short descriptive commit message.
- Add unit tests for logic (timer state, stats calculations, blocklist matching).
