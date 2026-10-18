# Releasing Matinee

Matinee updates itself with [Sparkle](https://sparkle-project.org). Every release attaches
`appcast.xml` to the GitHub release; installed copies check
`https://github.com/Treposting/Matinee/releases/latest/download/appcast.xml` once a day.

When a newer version is found in the background, Matinee shows a red dot on its menu bar
icon, an "update available" banner in its window, and a notification. Clicking **Update**
(or the notification) opens Sparkle's update window. **Install and Relaunch** downloads the
update, checks its EdDSA signature, quits the running Matinee, replaces the app and opens
the new version.

## One-time setup (on your Mac)

The updater stays switched off until this is done, so local builds never show Sparkle errors.

1. Download Sparkle's tools (same version as `project.yml`) and create a signing key. The
   private key is stored in your login Keychain.

   ```sh
   curl -L -o /tmp/sparkle.tar.xz https://github.com/sparkle-project/Sparkle/releases/download/2.10.0/Sparkle-2.10.0.tar.xz
   mkdir -p /tmp/sparkle && tar -xJf /tmp/sparkle.tar.xz -C /tmp/sparkle
   /tmp/sparkle/bin/generate_keys
   ```

   It prints a public key. Put it in `project.yml`:

   ```yaml
   SPARKLE_PUBLIC_KEY: "<public key>"
   ```

   The public key is safe to commit.

2. Export the private key and store it as a GitHub Actions secret, then delete the file:

   ```sh
   /tmp/sparkle/bin/generate_keys -x /tmp/matinee-sparkle.key
   gh secret set SPARKLE_PRIVATE_KEY --repo Treposting/Matinee < /tmp/matinee-sparkle.key
   rm /tmp/matinee-sparkle.key
   ```

   Or paste the file's contents into GitHub → Settings → Secrets and variables → Actions →
   New repository secret, named `SPARKLE_PRIVATE_KEY`.

   Keep the Keychain copy backed up. If the private key is lost, installed copies can't
   verify new updates and users have to download Matinee again by hand.

## Publishing a release

```sh
git tag v0.1.0
git push origin v0.1.0
```

The **Release** workflow builds the app with that version, zips it, signs the zip with
the private key, writes `appcast.xml`, and publishes both on a GitHub release. The build
number is the workflow run number, so it always grows; Sparkle uses it to decide what's
newer.

## Installing without a Developer ID

Releases are signed ad-hoc and not notarized yet, so macOS blocks the first launch of a
downloaded copy:

1. Unzip and move **Matinee.app** to **/Applications** first. Sparkle can't update an
   app that runs straight from Downloads.
2. Open it. When macOS says it can't verify the app, go to System Settings → Privacy &
   Security and click **Open Anyway**.
   (Terminal alternative: `xattr -dr com.apple.quarantine /Applications/Matinee.app`.)

You only do this once. Updates installed by Sparkle open normally.

When there's a Developer ID: add signing and notarization to the Release workflow and turn
`ENABLE_HARDENED_RUNTIME` back on in `project.yml`.

## Testing the update flow

1. Publish `v0.1.0`, install it as above and launch it once.
2. Publish `v0.1.1`.
3. Force a background check: quit Matinee, run
   `defaults delete com.nahid.matinee SULastCheckTime`, and open it again.
   To see what Sparkle is doing, keep this running in Terminal:
   `log stream --predicate 'subsystem == "org.sparkle-project.Sparkle"' --level debug`
4. Expect, without any Sparkle window popping up:
   - a red dot on the menu bar icon (and next to the countdown while a timer runs),
   - the "Matinee 0.1.1 is available" banner in the menu bar window,
   - a notification (allow notifications when asked).
5. Click the notification or **Update**. Sparkle's window shows 0.1.1; the red dot and the
   notification go away.
6. Click **Install and Relaunch**. Matinee quits, then 0.1.1 opens from /Applications.
   Check with `defaults read /Applications/Matinee.app/Contents/Info.plist CFBundleShortVersionString`
   and confirm only one Matinee is running: `pgrep -lx Matinee`.
7. Open the menu bar window and click **Check for Updates…**. It should say 0.1.1 is the
   latest version.

Delete the two test releases and their tags afterwards if you don't want them public.
