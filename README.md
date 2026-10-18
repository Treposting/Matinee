<p align="center">
  <img src="docs/images/icon.png" width="128" height="128" alt="Matinee icon">
</p>

<h1 align="center">Matinee</h1>

<p align="center">A focus timer that lives in your Mac's menu bar.</p>

Matinee is a Pomodoro-style focus timer for macOS. It sits in the menu bar and counts down your
work sessions and breaks. Later versions will add app and website blocking and daily stats on
where your time went (see [the plan](docs/PLAN.md)). It's a companion to Marquee from the same
developer.

## Features

- **Menu bar timer**: start, pause and stop focus sessions and breaks from the menu bar, with
  the countdown shown next to the icon. Focus and break lengths are adjustable.
- **Break reminders**: when a session ends, a full-screen overlay reminds you to stand up,
  drink water, rest your eyes, stretch, or anything you write yourself.
- **Caffeine mode**: keeps your Mac and its screen awake while the timer runs.
- **Automatic updates**: Matinee checks for new versions once a day. When one is out, a red
  dot appears on the menu bar icon and a notification lets you install it in one click.

Everything stays on your Mac. Matinee has no accounts and no analytics.

## Install

Requires macOS 27 or later.

1. Download the latest `Matinee-<version>.dmg` from
   [Releases](https://github.com/Treposting/Matinee/releases/latest).
2. Open it and drag **Matinee** onto **Applications**.
3. Open Matinee from Applications. The first time, macOS says it can't verify the app because
   it isn't notarized yet. Go to **System Settings → Privacy & Security** and click
   **Open Anyway**. You only need to do this once; updates open normally.

## Releasing

Change `MARKETING_VERSION` in `project.yml` and merge to `main`. GitHub Actions builds,
signs and publishes the release with a DMG and the update feed. Setup and details are in
[docs/RELEASING.md](docs/RELEASING.md).
