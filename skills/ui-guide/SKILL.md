---
name: ui-guide
description: >
  Brand rules and assets for building CoolBitX and CoolWallet interfaces: design tokens (CSS variables
  and W3C JSON), Montserrat/Barlow fonts, official logo files for CoolBitX, CoolWallet, CoolWallet Pro
  and CoolWallet S, product photography, and color, contrast and logo-usage rules from the official
  brand guides. Use whenever you build, restyle or review a UI, web page, app screen, email, banner,
  slide or mock-up for CoolBitX, CoolWallet, CoolWallet Pro, Go or S (庫幣科技, 冷錢包), or when you
  need a CoolBitX or CoolWallet logo, brand color, font or product image.
---

# CoolBitX UI guide

## Find the guide files

This skill's base directory is `<guide>/skills/ui-guide`, so the guide root is **two levels up**:
`<guide> = <base directory>/../..`. Every path below is relative to `<guide>`.

Read `<guide>/AGENTS.md` before you design anything. It holds the full rules, and this file is only
the summary. It has sections on brand architecture, color and contrast, typography, logos, observed
UI patterns and voice.

## Use the assets correctly

- **Copy, don't link.** Copy the files you need into the user's project (for example `tokens/tokens.css`,
  `fonts/`, and the specific logo SVGs into `public/brand/`). The plugin's install path is machine-local
  and changes with every update, so never reference it from project code.
- Load `fonts/fonts.css` before `tokens/tokens.css`. Set `data-brand` (`coolwallet` | `coolwallet-pro` |
  `coolbitx`) and `data-theme` (`light` | `dark`) on the root element, then build on the semantic
  tokens (`--color-bg`, `--color-text`, `--color-accent`, `--color-on-accent`, `--color-link`, …).
- For a working reference implementation, see `examples/index.html`.
- To choose photos, use `images/INDEX.md` (tone: dark/light/cutout) and `images/<product>/contact-sheet.jpg`.
- When in doubt about a rule, read the official guide renders in `reference/brand-guides/*.png`.

## Non-negotiable rules

1. **Pick the brand first.** Product and app UI uses CoolWallet. A page about the Pro card uses CoolWallet Pro. Company,
   investor and careers pages use CoolBitX. CoolWallet S is legacy: use it only when S is the subject.
1. **Logos come from `logos/` only.** Never retype a wordmark in a font, and never recolor (except solid
   black, white, or CoolWallet yellow in dark mode), stretch, or add effects. Keep clear space of ½ the
   shield height. Put the full-color logo only on black or white; on any other background, use a monochrome logo.
1. **Yellow `#F7B419` is a fill on light backgrounds, never text** (1.8:1 on white). Text on yellow is
   charcoal `#1B202A`, not white. The same applies to Pro gold and CoolBitX gold. For accent-colored text
   on light backgrounds, use `--color-link`.
1. **Gray `#939393` is for dark backgrounds only.** For secondary text on light backgrounds, use `--color-text-muted`.
1. **Type:** CoolWallet uses Montserrat for headings and Barlow for body and numbers (use `tabular-nums` for amounts). CoolBitX
   uses Open Sans (not bundled: load it from Google Fonts). For Chinese or Japanese, add Noto Sans TC or Noto Sans JP.
1. **Missing assets: don't invent them.** There is no CoolWallet Go logo and no standalone CoolBitX ∞ mark.
   Use a clearly labeled placeholder and tell the user.
1. **Claims:** product specs in `reference/product-specs.md` date from 2018. Present them as
   placeholders for the user to verify, not as final marketing copy.
