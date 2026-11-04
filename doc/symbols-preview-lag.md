# Symbols preview lag

## Problem and evidence

Rapid arrow-key navigation in the Symbols sidebar can stall visible updates.
Automatic previews are enabled by `sidebar.preview.show_always = true` in
`lua/plugins/symbols.lua`. The installed symbols.nvim implementation closes and
recreates its floating preview on sidebar cursor movement and again on sidebar
scrolling. Each update therefore does window lifecycle work instead of simply
changing the displayed selection.

An isolated headless test used the installed plugin, a mocked symbol provider,
1,000 synthetic symbols, and 200 explicitly dispatched cursor-movement events:

| Automatic previews | Preview windows created | Elapsed time |
| --- | ---: | ---: |
| Enabled | 200 | approximately 1,533 ms |
| Disabled | 0 | approximately 1.5 ms |

These measurements establish substantial preview overhead in that test. They
exclude Neovide rendering and do not reproduce the reported visible freeze.
They also do not establish the cause of the broader mouse-scrolling stalls in
side-by-side diffs from different sources or possibly ordinary editing windows.
That problem needs separate diagnosis.

## Proposed behavior

Keep automatic previews, but show them only after 200 ms without cursor movement
or scrolling in the Symbols sidebar:

- Hide the existing preview when navigation resumes.
- Restart the pending update on each sidebar cursor movement or scroll.
- When the delay expires, preview only the latest selection, provided the sidebar
  is still valid and focused and automatic previews remain enabled.
- Cancel pending updates when leaving or closing the sidebar or disabling
  automatic previews. A stale callback must not reopen a preview.
- Keep manual `K` previews immediate; cancel any pending automatic update when
  opening one manually so it cannot replace the manual preview.

This should avoid repeated preview creation while navigating. The delay applies
only to automatic previews, not symbol retrieval, sidebar navigation, or other
sidebar features.

## Implementation direction

The installed plugin has no automatic-preview delay setting. Prefer adding the
debounce to the plugin's preview lifecycle, covering both cursor movement and
sidebar scrolling with one pending update per sidebar. Do not delay the entire
sidebar event handler, which also handles other features.

If implemented through this config instead, keep the behavior in the existing
`lua/plugin-utils/symbols.lua` helper and the plugin spec mostly declarative.
Preserve its `guard_scroll_events()` integration: it ignores synthetic
`WinScrolled` events without a numeric window ID. That guard addresses a separate
event-compatibility issue and does not debounce previews.

## Verification before shipping a fix

- Hold an arrow key: navigation continues without creating a preview for every
  intermediate selection; after stopping, the latest selection appears after
  approximately 200 ms.
- Scroll the sidebar with the mouse: scrolling restarts the same delay and the
  preview is positioned for the final viewport.
- Move again before the timer expires: the previous update never opens a stale
  preview.
- Leave or close the sidebar, or disable automatic previews, while an update is
  pending: no preview reopens and no invalid-window error occurs.
- Press `K`: the preview opens immediately and retains the existing manual
  preview interaction.
- Verify independent pending updates for multiple sidebars and preserve handling
  of synthetic scroll events.
- Repeat the isolated benchmark, checking preview creation counts as well as
  elapsed time, then verify the visible behavior in Neovide.

This document proposes a fix; it does not change runtime behavior.
