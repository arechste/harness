---
form: explanation
last-verified: 2026-05-30
owner: RECON (research); TOWER (synthesis)
status: draft
audience: principal
---

# Browser Identity Separation: Primer and Setup Plan

## Why This Document Exists

Harness's core contract is traceability and bounded blast radius — every automated action must be attributable to a specific identity in a specific context. Right now, on fragtnix, Chrome has a single unsegregated profile ("Default") with no signed-in Google account. Before harness can deterministically route browser automation or credential work through a named profile, that profile must exist and map cleanly to one identity. This document explains the concepts, recommends a split, and gives numbered setup steps.

---

## Part 1: Three Concepts You Need to Know

### Profile

A **browser profile** is a siloed container living on disk. Each profile has its own:

- cookies and session tokens (who you are currently logged into)
- saved passwords
- browsing history
- bookmarks
- extensions (and their settings)
- autofill data (addresses, credit cards)
- local settings (theme, startup pages)

Profiles are completely independent of each other. What you do in one profile has no visibility into any other profile on the same machine.

On macOS, Chrome stores profiles here:

```
~/Library/Application Support/Google/Chrome/
  Default/         ← your first (and currently only) profile
  Profile 1/       ← second profile, when you create it
  Profile 2/       ← third profile, etc.
  Local State      ← JSON file mapping those directory names to display names
```

Brave uses the same Chromium layout at:

```
~/Library/Application Support/BraveSoftware/Brave-Browser/
```

### Account

A **browser account** (Google account for Chrome, no account needed for Brave) is an optional cloud identity you sign into inside a profile. Signing in:

- unlocks sync (see below)
- ties the profile's cloud backups to that identity
- does NOT merge or affect other profiles

You can have a profile with no signed-in account at all. That is the current state of your Chrome Default profile.

### Sync

**Sync** is the mechanism that copies a profile's data to the cloud so it survives a wipe and is available on other devices. Sync is per-profile.

| | Chrome Sync | Brave Sync |
|---|---|---|
| Requires an account? | Yes — Google account | No — just a 24-word passphrase |
| Where data is stored | Google's servers, linked to your Google identity | Brave-operated servers, encrypted with your passphrase |
| End-to-end encrypted? | Partially (passwords yes by default, history/bookmarks optionally with a separate passphrase) | Yes, always — Brave never holds the key |
| Privacy implication | Google can associate sync data with your Google account | Brave cannot read your data even if compelled |

Key takeaway: sync is optional and does not need to be turned on to use profiles. Profiles are useful for separation even without sync enabled.

---

## Part 2: Why Separation Matters — What Leaks Without It

When everything runs through one profile, these things bleed together:

| Data type | Leakage risk |
|---|---|
| Session cookies | Logging into work Gmail in one tab while personal Gmail is open in another — Chrome can mix signals, and some SSO flows pick up the wrong session |
| Saved passwords | Work and personal credentials in one vault; an automation script that calls "fill from saved passwords" has access to all of them |
| Extensions | A password manager extension installed for work captures personal logins (and vice versa). A work-IT-managed extension can see personal browsing |
| History | A work browser automation log entry shows up next to personal searches |
| Autofill | Work address/card data offered on personal shopping sites |
| Identity confusion for automation | If harness runs `open -na "Google Chrome"` with no profile flag, Chrome opens whichever profile was last active. The action is not attributable to a specific identity |

The last point is the direct harness blocker: without named profiles, automation cannot be deterministically scoped.

---

## Part 3: Brave vs Chrome — Honest Comparison for This Use Case

Both Brave and Chrome are Chromium-based. Mechanically they work identically: profiles, extensions, the `--profile-directory` flag, the on-disk layout. The differences are at the sync and privacy layer.

| Dimension | Chrome | Brave |
|---|---|---|
| Default tracker/ad blocking | None | Aggressive (Shields) |
| Fingerprint resistance | Minimal | Built-in (random noise to fingerprint vectors) |
| Sync requires Google account | Yes | No |
| Sync data readable by vendor | Potentially (depends on sync settings) | No — E2E encrypted |
| Enterprise policy support (MDM) | Strong | Basic |
| Extension ecosystem | Full Chrome Web Store | Full Chrome Web Store (same store) |
| Automation compatibility | High | High (same Chromium flags work) |

**Recommendation for this setup (not dogma):**

- **Brave = personal browser.** Privacy defaults protect personal browsing without configuration. Brave Sync requires no Google account, reducing personal data exposure to Google.
- **Chrome = work browser.** Chrome integrates more cleanly with Google Workspace (work Google account, Google Meet, Google Drive flows). Enterprise/automation tooling (Selenium, Playwright, harness flows) is most tested against Chrome. Cleaner mental model: "Chrome is work."

This is a clean split with no cross-contamination. Both browsers can have multiple profiles if you later need sub-contexts (e.g., a client context within work). For now, one profile per browser is sufficient.

---

## Part 4: Concrete Setup Steps

### 4A: Create a Named Work Profile in Chrome

Chrome currently has one profile ("Default"). Rename it and create a personal profile, or flip the assignment per the recommendation above (Default = work, new profile = personal). Given the recommendation of Chrome = work, treat "Default" as work and create a fresh personal profile only if you ever need personal in Chrome. For now, focus on making Default clearly identifiable as work.

**Step 1 — Rename the Default profile to "Work"**

1. Open Chrome.
2. Click the profile avatar icon (top-right corner, shows a silhouette or initial).
3. Click the pencil/edit icon or "Manage Chrome profiles."
4. Click the three-dot menu next to "Default" → Edit.
5. Change the name to something unambiguous: `Work` or `Work - [yourname]`.
6. Choose a distinct color (e.g., blue for work).
7. Save.

**Step 2 — Sign the Work profile into your work Google account**

1. In Chrome, go to `chrome://settings/`.
2. Click "Sign in to Chrome" (top of page).
3. Sign in with your **work** Google account (e.g., `you@company.com`).
4. Choose whether to turn on sync (recommended if you want bookmarks/passwords to survive a wipe). If turning on sync, the sync data is tied to the work account.

**Step 3 — Find the on-disk directory name (needed for automation)**

1. With the Work profile active, navigate to `chrome://version/`.
2. Find the line **Profile Path**. It will look like:
   ```
   /Users/arechste/Library/Application Support/Google/Chrome/Default
   ```
   The last path component (`Default`) is the directory name the `--profile-directory` flag needs.

3. Alternatively, inspect the Local State file to see all profiles at once:
   ```
   cat ~/Library/Application\ Support/Google/Chrome/Local\ State | \
     python3 -c "import sys,json; d=json.load(sys.stdin); \
     [print(k, '->', v['name']) for k,v in d['profile']['info_cache'].items()]"
   ```
   Output will be like:
   ```
   Default -> Work
   Profile 1 -> Personal
   ```

**Step 4 — (Optional) Create a Personal Chrome profile**

If you ever need personal browsing in Chrome (not recommended given Brave handles this):

1. Click profile avatar → "Add Chrome profile."
2. Name it `Personal`, choose a different color (e.g., green).
3. Optionally sign into your personal Google account.
4. Note its directory name via `chrome://version/` as above (will be `Profile 1` or similar).

### 4B: Visual Differentiation (Critical for Preventing Mistakes)

Chrome shows the profile color in the toolbar and on the profile avatar. Set them to be obviously different:

- Work profile: one color (e.g., blue, the default)
- Personal profile: clearly different color (e.g., green or red)

Consider also setting a distinctive background theme per profile (`chrome://settings/appearance`). At a glance you should instantly know which profile is active.

### 4C: Brave — Profile Setup

Brave uses the same profile mechanism. The current recommendation keeps personal browsing in Brave's default profile.

**Step 1 — Rename Brave's Default profile**

1. Open Brave.
2. Click the profile avatar (top-right).
3. Click the pencil icon → rename to `Personal`.
4. Choose a distinct color (e.g., green).

**Step 2 — Set up Brave Sync (optional but recommended for resilience)**

Brave Sync creates a chain of devices sharing encrypted data. The "key" is a 24-word passphrase generated by Brave. No account is needed.

1. Open Brave → `brave://settings/braveSync/setup`.
2. Click **Start a new Sync Chain**.
3. Brave displays a 24-word passphrase and a QR code.
4. **Before clicking anything else: store this passphrase in 1Password.**
   - Create a new Secure Note in 1Password titled `Brave Sync — fragtnix personal`.
   - Paste the 24 words verbatim.
   - Never share this passphrase over email, chat, or paste it into any tool (including harness). It is a secret equivalent to a master password.
5. After saving in 1Password, click **Done** / confirm in Brave.
6. To add another device later: on the new device, go to Brave Sync settings → **Enter a Sync Chain code** → enter the 24 words.

**Step 3 — Find Brave's profile directory (if you later need Brave automation)**

```
cat ~/Library/Application\ Support/BraveSoftware/Brave-Browser/Local\ State | \
  python3 -c "import sys,json; d=json.load(sys.stdin); \
  [print(k, '->', v['name']) for k,v in d['profile']['info_cache'].items()]"
```

### 4D: Verify the Separation Worked

Run through this checklist after setup:

| Check | How to verify |
|---|---|
| Chrome shows "Work" profile with work color | Look at the avatar area; hover to see name |
| Brave shows "Personal" profile | Same as above |
| Chrome Work profile is signed into work Google account | `chrome://settings/` → top of page shows work email |
| Chrome Work profile has NO personal Google cookies | Go to accounts.google.com in Chrome — only work account should appear |
| Brave has no work logins | Go to accounts.google.com in Brave — only personal (or none) should appear |
| `chrome://version/` in Chrome shows `Default` in Profile Path | Confirms directory name for automation |
| Brave Sync passphrase is in 1Password | Check 1Password before closing the Brave sync setup screen |

---

## Part 5: How This Connects to Harness Automation

Once profiles are named and their on-disk directory names are known, harness can target them deterministically.

**The command pattern:**

```bash
open -na "Google Chrome" --args --profile-directory="Default"
```

- `-n` forces a new instance (even if Chrome is already open with a different profile).
- `-a "Google Chrome"` specifies the application.
- `--args` passes everything after to the browser binary.
- `--profile-directory="Default"` is the on-disk directory name, NOT the display name.

For Brave:

```bash
open -na "Brave Browser" --args --profile-directory="Default"
```

**Why the directory name matters, not the display name:**

The display name ("Work", "Personal") is stored in `Local State` as metadata. The `--profile-directory` flag reads the filesystem. If you rename a profile's display name, the directory name does not change. `Default` is always `Default` even if you rename the profile to "Work." This is why the `chrome://version/` check in Step 4A.3 is the ground truth.

**Harness config implication:** When harness stores a browser target, it should store both the display name (human-readable) and the directory name (the actual flag value). The `Local State` query in Step 4A.3 gives both at once and can be run at any time to verify the mapping.

---

## Part 6: Decision List for the Principal

Before implementing the steps above, confirm these five decisions:

| # | Decision | Recommended default | Your choice |
|---|---|---|---|
| 1 | Which browser = work? | Chrome | |
| 2 | Which browser = personal? | Brave | |
| 3 | Sign Chrome Work profile into work Google account? | Yes (enables sync and clean identity) | |
| 4 | Enable Chrome Sync on work profile? | Yes if you want cross-device resilience; No if you prefer zero data off-machine | |
| 5 | Enable Brave Sync and store passphrase in 1Password? | Yes | |

Once these are decided, the setup steps in Part 4 follow in order and take approximately 10 minutes.

---

## Sources

| Source | Tier | URL |
|---|---|---|
| Google Chrome Help — Manage multiple profiles | Official vendor doc | https://support.google.com/chrome/answer/2364824 |
| Chromium Source — User Data Directory spec | Official upstream source | https://chromium.googlesource.com/chromium/src/+/master/docs/user_data_dir.md |
| Brave Help Center — How do I set up Sync? | Official vendor doc | https://support.brave.app/hc/en-us/articles/360021218111 |
| Brave Sync v2 announcement | Official vendor blog | https://brave.com/blog/sync-v2/ |
| Brave Sync FAQ | Official vendor doc | https://support.brave.app/hc/en-us/articles/360047642371 |
| Browserfy — Brave Sync setup walkthrough (2025-05-31) | Third-party; consistent with Brave docs | https://browserfy.net/index.php/2025/05/31/how-to-activate-and-use-brave-sync-to-synchronize-devices/ |
| Ninio.ninarski — Chrome profile from Terminal (2024-08) | Third-party practitioner; verified against Chromium docs | https://ninio.ninarski.com/2024/08/22/open-a-specific-google-chrome-profile-from-the-mac-osx-terminal/ |
