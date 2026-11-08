# Product specs (hardware cards)

Transcribed from the 2018 spec-sheet PDFs (`CoolWallet Pro spec_sheet.pdf` and `CoolWallet S spec_sheet.pdf`; the PDFs were removed). These numbers are from 2018. **Check them with the product team before you publish them.** Use this file for placeholder or mock copy, not for final marketing claims.

The two cards share the same spec, except for the secure-element certification.

| | CoolWallet Pro | CoolWallet S (legacy) |
|---|---|---|
| Secure element | Common Criteria **EAL6+** certified | Common Criteria **EAL5+** certified |

## Hardware

| Item | Value |
|---|---|
| Form factor | Card, 85.6 (L) × 54 (H) × 0.8 (T) mm |
| Display | E Ink e-paper, black & white |
| Contrast ratio | 7:1 (typical) |
| View angle | ~180° |
| View window | 22.50 × 13.50 mm |
| Material | Plastic |
| Button | 1 metal dome button, tactile feedback |
| Battery | Lithium-ion rechargeable, 4.2 V, 15 mAh |
| Charging | 2 hours to full charge |
| Communication | Bluetooth (BLE 4.2) |
| Working temperature | 10 °C to 40 °C |
| Storage temperature | −10 °C to 50 °C |
| Secure element chip | Tamper-proof; true random number generator; hardware crypto accelerator |

## Function

| Item | Value |
|---|---|
| Signing algorithm | ECDSA transaction signing with the secp256k1 elliptic curve |
| BIP-32 | HD wallet |
| BIP-44 | Multiple coin types and accounts. Each account includes up to 2^32 external and internal Bitcoin transaction addresses |
| Seed creation | Generate a seed, or import a CoolWallet seed, via the app |
| BIP-39 | Standard wallet recovery mnemonic |
| OTP algorithm | OATH HOTP (supported in software) |
| iPhone | CoolWallet iPhone app via BLE |
| Android | CoolWallet Android app via BLE. The sheet labels this row "OTP algorithm" by mistake. |

## Taglines seen in official material

- "A Natural Selection for Evolved Crypto Cold Storage" (CoolWallet and CoolWallet Pro ad banners)
- "The Ultimate Bitcoin Safe" (printed on the CoolWallet S card)
- "Powered by CoolBitX" (printed on both cards)
