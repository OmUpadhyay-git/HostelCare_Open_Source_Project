# Design.md — HostelCare
## Visual System

Design priority: **operational clarity over decoration.** This is a tool staff and wardens will use dozens of times a day, and students will use under stress (something in their room is broken). Every screen should be scannable in seconds.

---

## 1. Design Language

- **Material 3**, adapted for a utilitarian operations tool rather than a consumer/lifestyle app.
- Flat, low-decoration surfaces. No heavy gradients, no drop-shadow stacks, minimal animation (only for state transitions/loading, not for flourish).
- Status must always be communicated with **text + color together**, never color alone (accessibility requirement from `PRD.md`/`Rules.md`).
- Support both light and dark theme; dark theme is the primary/default given the operational, always-on nature of warden/staff use (many complaints get handled at odd hours).

---

## 2. Color System

### 2.1 Base palette

| Token | Light | Dark | Use |
|---|---|---|---|
| `surface` | `#FFFFFF` | `#121212` | App background |
| `surface-variant` | `#F2F2F5` | `#1E1E1E` | Cards, list rows |
| `surface-elevated` | `#FFFFFF` (with shadow) | `#242424` | Dialogs, sheets |
| `on-surface` | `#1A1A1A` | `#EDEDED` | Primary text |
| `on-surface-muted` | `#6B6B6F` | `#A0A0A5` | Secondary text, timestamps |
| `outline` | `#DADADD` | `#33333A` | Borders, dividers |

### 2.2 Brand / primary

| Token | Value | Use |
|---|---|---|
| `primary` | `#2F6FED` | Primary actions, active nav, links |
| `primary-container` | `#E4ECFD` (light) / `#16264A` (dark) | Selected states, chips |
| `on-primary` | `#FFFFFF` | Text/icons on primary |

### 2.3 Status colors (complaint status + priority)

Every status color pairs with a text label — never color-only.

| Status | Color | Token |
|---|---|---|
| PENDING | Amber `#E0A100` | `status-pending` |
| ACCEPTED | Blue `#2F6FED` | `status-accepted` |
| ASSIGNED | Indigo `#5B5FEF` | `status-assigned` |
| IN_PROGRESS | Teal `#0E8A7D` | `status-in-progress` |
| RESOLVED | Green `#2E9E44` | `status-resolved` |
| VERIFIED | Green (deep) `#1F7A34` | `status-verified` |
| CLOSED | Neutral gray `#6B6B6F` | `status-closed` |
| REJECTED / CANCELLED | Red `#D64545` | `status-negative` |
| REOPENED | Orange `#E0672C` | `status-reopened` |
| ON_HOLD | Slate `#7A7F87` | `status-on-hold` |

| Priority | Color | Token |
|---|---|---|
| LOW | `#6B6B6F` (gray) | `priority-low` |
| MEDIUM | `#2F6FED` (blue) | `priority-medium` |
| HIGH | `#E0672C` (orange) | `priority-high` |
| URGENT | `#D64545` (red) | `priority-urgent` |

### 2.4 Semantic

| Token | Value | Use |
|---|---|---|
| `success` | `#2E9E44` | Confirmations, SLA-within |
| `warning` | `#E0A100` | SLA approaching |
| `error` | `#D64545` | Validation errors, SLA breached |
| `info` | `#2F6FED` | Informational banners |

---

## 3. Typography

- **Font family:** Inter (or system default `Roboto`/`SF Pro` if Inter isn't bundled — chosen for high legibility at small sizes and good numeral clarity for complaint numbers/timestamps).
- Scale (Material 3 type roles, adapted):

| Role | Size / Weight | Use |
|---|---|---|
| `display` | 28sp / Bold | Rare — splash/empty-state headlines only |
| `headline` | 22sp / SemiBold | Screen titles |
| `title` | 18sp / SemiBold | Section headers, complaint title in detail view |
| `body-large` | 16sp / Regular | Primary body text, descriptions |
| `body` | 14sp / Regular | Default UI text |
| `label` | 12sp / Medium | Chips, status badges, metadata (dates, IDs) |
| `caption` | 11sp / Regular | Timestamps, fine print |

- Minimum body text size: 14sp. Support Flutter's text-scaling for accessibility (`MediaQuery.textScaler`) up to at least 130% without layout breakage.
- Numerals (complaint numbers, dates, counts) use tabular figures where available for alignment in lists/tables.

---

## 4. Spacing & Layout

- 4pt base spacing grid: 4, 8, 12, 16, 24, 32, 48.
- Standard screen padding: 16px horizontal.
- Card padding: 16px.
- List row minimum height: 64px (comfortable touch target, fits 2 lines of metadata).
- Minimum touch target: 48x48dp for all interactive elements.

---

## 5. Components

### 5.1 Status badge
Pill-shaped, filled with the status's container color, text label in the corresponding on-color, `label` typography, always includes the text (e.g. "IN PROGRESS"), never a bare color dot.

### 5.2 Priority indicator
Small square/triangle icon + text label, using the priority color token. Urgent complaints may additionally use a subtle icon (e.g. exclamation) — never rely on red alone.

### 5.3 Complaint card
```
┌─────────────────────────────┐
│ HC-2026-00124                │
│ Bathroom water leakage       │
│ Plumbing • [HIGH]            │
│ [IN PROGRESS]                │
│ 17 Sep 2026                  │
└─────────────────────────────┘
```
- Title: `title` style, 1–2 line max with ellipsis.
- Category + priority: `label` style, inline.
- Status: badge component (§5.1).
- Date: `caption` style, `on-surface-muted`.

### 5.4 Timeline / history entry
Icon (per action type) + action label (`body`) + performer name & role (`label`) + remark (`body`, optional) + timestamp (`caption`), connected vertically by a thin `outline`-colored line.

### 5.5 Empty state
Icon or simple illustration (flat, single-color, no stock photography) + short headline (`title`) + one-line supporting text (`body`) + primary action button if applicable (e.g. "Raise a Complaint").

### 5.6 Loading state
Skeleton loaders for lists (not spinners) to reduce perceived latency; a centered spinner only for full-screen blocking actions (e.g. login).

### 5.7 Error state
Icon + user-friendly message (never raw error text) + retry button where applicable.

### 5.8 Buttons
- Primary: filled, `primary` color, used once per screen for the main action.
- Secondary: outlined, `outline` border.
- Destructive (reject, cancel, deactivate): `error` color, always behind a confirmation dialog.

---

## 6. Iconography

- Material Symbols (outlined style for inactive/default, filled for active/selected states — e.g. bottom nav).
- Category icons: consistent single-color line icons per complaint category (electrical → bolt, plumbing → wrench/drop, Wi-Fi → signal, etc.) used in category pickers and complaint cards for fast visual scanning.

---

## 7. Motion

- Minimal, purposeful only: screen transitions (default Material page transitions), status-change confirmation (brief checkmark animation on resolve/close), pull-to-refresh spinner.
- No decorative animation, no parallax, no bouncing elements.

---

## 8. Dashboards & Charts (Admin)

- Charts must remain readable on mobile: prefer horizontal bar charts over pie charts for category/hostel breakdowns (easier to read many categories on a narrow screen).
- Chart colors reuse the status/priority tokens where the data maps to them (e.g. a status-breakdown chart uses the exact status colors from §2.3) for consistency with the rest of the app.
- Numbers displayed only when backed by real data (see `Rules.md` §4) — no placeholder charts with fabricated values in production builds.

---

## 9. Accessibility Checklist

- Contrast ratio ≥ 4.5:1 for body text against its background in both themes.
- All interactive elements have semantic labels for screen readers.
- Status/priority never conveyed by color alone — always paired with text.
- Touch targets ≥ 48x48dp.
- Supports system text scaling without breaking layout.
