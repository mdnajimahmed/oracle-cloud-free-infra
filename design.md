# Turinghatch Design Language

> This document is the single source of truth for all Turinghatch product UIs.
> Every component, state, spacing value, animation, and color is defined here.
> **No guessing. No interpretation. If it is not written here, ask before inventing.**

---

## 1. Brand Identity

**Name:** turinghatch (always lowercase, even at sentence start)  
**Tagline:** Your personal productivity platform  
**Character:** Calm, precise, minimal. Not playful. Not corporate. Purposeful.  
**Dominant color:** Teal. Every product shares this foundation.

---

## 2. Color System

### Primary Palette (Teal)

| Token | Hex | Usage |
|---|---|---|
| `teal-50` | `#f0faf9` | Page background |
| `teal-100` | `#ccfbf1` | Card borders, dividers, subtle fills |
| `teal-200` | `#99f6e4` | Header accent text, decorative |
| `teal-300` | `#5eead4` | Hover fills on light backgrounds |
| `teal-400` | `#2dd4bf` | Focus rings, active indicators |
| `teal-500` | `#14b8a6` | Primary accent — borders, arrows, icons, links |
| `teal-600` | `#0d9488` | Section labels, secondary interactive text |
| `teal-700` | `#0f766e` | Header background, card titles, strong CTAs |
| `teal-800` | `#115e59` | Pressed/active state on dark surfaces |
| `teal-900` | `#134e4a` | Primary body text |

### Neutral Palette

| Token | Hex | Usage |
|---|---|---|
| `neutral-0` | `#ffffff` | Card backgrounds, input backgrounds |
| `neutral-100` | `#f3f4f6` | Subtle section backgrounds |
| `neutral-200` | `#e5e7eb` | Table row stripes, skeleton loaders |
| `neutral-400` | `#9ca3af` | Placeholder text, footer text, disabled text |
| `neutral-600` | `#4b5563` | Secondary body text, descriptions |
| `neutral-900` | `#111827` | Fallback dark text (use `teal-900` on teal backgrounds) |

### Semantic Palette

| Token | Hex | Usage |
|---|---|---|
| `success-bg` | `#f0fdf4` | Success alert background |
| `success-border` | `#86efac` | Success alert border |
| `success-text` | `#166534` | Success alert text |
| `success-icon` | `#22c55e` | Success icon fill |
| `warning-bg` | `#fffbeb` | Warning alert background |
| `warning-border` | `#fcd34d` | Warning alert border |
| `warning-text` | `#92400e` | Warning alert text |
| `warning-icon` | `#f59e0b` | Warning icon fill |
| `error-bg` | `#fef2f2` | Error alert background |
| `error-border` | `#fca5a5` | Error alert border |
| `error-text` | `#991b1b` | Error alert text |
| `error-icon` | `#ef4444` | Error icon fill |
| `info-bg` | `#eff6ff` | Info alert background |
| `info-border` | `#93c5fd` | Info alert border |
| `info-text` | `#1e40af` | Info alert text |
| `info-icon` | `#3b82f6` | Info icon fill |

### Color Rules

- **Never** use pure black (`#000000`) anywhere.
- **Never** use a teal shade lighter than `teal-600` for interactive text (fails contrast).
- Body text on `teal-50` background: `teal-900`.
- Body text on `teal-700`+ background: `#ffffff`.
- Muted text on white cards: `neutral-600`.
- Placeholder text: `neutral-400`.
- All interactive elements must have a **visible focus ring**: `2px solid teal-400`, `outline-offset: 2px`.

---

## 3. Typography

### Font Stack

```css
font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto,
             'Helvetica Neue', Arial, sans-serif;
```

No external font services (no Google Fonts). System fonts only.

### Type Scale

| Role | Size | Weight | Line Height | Letter Spacing | Color |
|---|---|---|---|---|---|
| Page title (H1) | `2rem / 32px` | 700 | 1.2 | `0.04em` | `teal-900` or white |
| Section title (H2) | `1.5rem / 24px` | 700 | 1.25 | `0.02em` | `teal-900` |
| Card title (H3) | `1.125rem / 18px` | 600 | 1.3 | `0` | `teal-700` |
| Body | `1rem / 16px` | 400 | 1.6 | `0` | `teal-900` |
| Body small | `0.875rem / 14px` | 400 | 1.5 | `0` | `neutral-600` |
| Label / Section label | `0.72rem / 11.5px` | 600 | 1 | `0.12em` | `teal-600` |
| Caption | `0.75rem / 12px` | 400 | 1.4 | `0` | `neutral-400` |
| Button | `0.875rem / 14px` | 600 | 1 | `0.01em` | (per variant) |
| Code / Mono | `0.875rem / 14px` | 400 | 1.6 | `0` | `teal-900` |

**Mono font stack:**
```css
font-family: 'SF Mono', 'Fira Code', 'Cascadia Code', Consolas, monospace;
```

### Typography Rules

- Section labels are ALWAYS uppercase.
- H1 appears once per page.
- H2/H3 do not use all-caps.
- Never use font-weight below 400.
- Line length: max `72ch` for body text blocks. Use `max-width` to enforce.

---

## 4. Spacing Scale

All spacing is derived from a base-4 scale (multiples of `4px`):

| Token | Value | CSS |
|---|---|---|
| `space-1` | 4px | `0.25rem` |
| `space-2` | 8px | `0.5rem` |
| `space-3` | 12px | `0.75rem` |
| `space-4` | 16px | `1rem` |
| `space-5` | 20px | `1.25rem` |
| `space-6` | 24px | `1.5rem` |
| `space-8` | 32px | `2rem` |
| `space-10` | 40px | `2.5rem` |
| `space-12` | 48px | `3rem` |
| `space-16` | 64px | `4rem` |

**Rules:**
- Component internal padding: multiples of `space-4` or `space-6`.
- Gap between sibling components: `space-3` (0.75rem) for dense lists, `space-6` (1.5rem) for sections.
- Page horizontal padding: `space-6` (1.5rem) on mobile, `space-8` (2rem) on desktop.
- Section vertical margin: `space-12` (3rem).

---

## 5. Shape & Borders

### Border Radius

| Context | Radius |
|---|---|
| Cards, panels, modals | `10px` |
| Buttons | `8px` |
| Inputs, selects, textareas | `8px` |
| Badges, pills, tags | `9999px` (full pill) |
| Tooltips | `6px` |
| Avatars | `50%` (circle) |
| Table | `10px` (wrapper only, cells have 0) |
| Toast notifications | `10px` |

### Borders

- Cards: `1px solid teal-100`, with `4px solid teal-500` left accent border.
- Inputs (default): `1px solid teal-100`.
- Inputs (focus): `1px solid teal-500`.
- Inputs (error): `1px solid error-border` (`#fca5a5`).
- Dividers: `1px solid teal-100`.
- Header: no bottom border; use `box-shadow: 0 2px 8px rgba(0,0,0,0.12)` instead.

---

## 6. Shadows

| Token | Value | Usage |
|---|---|---|
| `shadow-sm` | `0 1px 3px rgba(0,0,0,0.08)` | Inputs, quiet cards |
| `shadow-md` | `0 4px 12px rgba(0,0,0,0.10)` | Dropdown menus, popovers |
| `shadow-card-hover` | `0 6px 20px rgba(20,184,166,0.15)` | Card hover state |
| `shadow-modal` | `0 20px 60px rgba(0,0,0,0.18)` | Modals, dialogs |
| `shadow-header` | `0 2px 8px rgba(0,0,0,0.12)` | Top navigation bar |

**Rules:**
- Teal-tinted shadow (`rgba(20,184,166,...)`) only on hover states.
- Never use shadows on elements that are already on a colored background.

---

## 7. Motion & Animation

### Durations

| Type | Duration | Easing |
|---|---|---|
| Micro (hover, focus) | `100ms` | `ease-out` |
| Standard (card, button) | `150ms` | `ease-out` |
| Entrance (modal, toast) | `200ms` | `cubic-bezier(0.16,1,0.3,1)` |
| Exit (modal, toast) | `150ms` | `ease-in` |
| Skeleton pulse | `1.5s` | `ease-in-out`, infinite |

### Animation Catalogue

**Card hover:** `transform: translateY(-2px)` + `shadow-card-hover`. Duration: `150ms ease-out`. Reset on mouse-leave: `150ms ease-out`.

**Button press:** `transform: scale(0.98)` on `:active`. Duration: `80ms ease-out`.

**Focus ring:** Appears instantly (0ms delay). Never animated — jarring for keyboard users.

**Modal entrance:** Backdrop fades in `opacity: 0 → 1`, panel slides up `translateY(8px) → translateY(0)` + `opacity: 0 → 1`. Duration: `200ms`.

**Toast entrance:** Slides in from right: `translateX(110%) → translateX(0)` + `opacity: 0 → 1`. Duration: `200ms cubic-bezier(0.16,1,0.3,1)`.

**Toast exit:** Slides out right: `translateX(0) → translateX(110%)` + `opacity: 1 → 0`. Duration: `150ms ease-in`.

**Skeleton loader:** Background animates between `teal-100` and `neutral-200`. Keyframes: `0% background-position: -200px 0`, `100% background-position: calc(200px + 100%) 0`. Use `background: linear-gradient(90deg, #ccfbf1 25%, #e5e7eb 50%, #ccfbf1 75%)` with `background-size: 400px 100%`.

**Spinner:** 24×24px circle with `border: 3px solid teal-100`, `border-top-color: teal-600`. Rotates `360deg` in `700ms linear infinite`.

**Rules:**
- `prefers-reduced-motion`: wrap all animations in `@media (prefers-reduced-motion: no-preference)`. When reduced motion is preferred, remove transforms and use opacity-only or instant transitions.
- Never animate layout properties (`width`, `height`, `padding`). Use `transform` and `opacity` only.

---

## 8. Layout & Grid

### Page Structure

```
┌─────────────────────────────────────┐
│  HEADER (full width, teal-700)      │
├─────────────────────────────────────┤
│  PAGE CONTENT (max-width: 1100px)   │
│  centered, padding: 0 space-6       │
├─────────────────────────────────────┤
│  FOOTER (full width)                │
└─────────────────────────────────────┘
```

### Content Widths

| Context | Max Width |
|---|---|
| Prose / single-column content | `720px` |
| App shell (header + sidebar + content) | `1100px` |
| Modal | `480px` (small), `640px` (medium), `900px` (large) |
| Toast container | `380px` |

### Breakpoints

| Name | Min Width | Notes |
|---|---|---|
| mobile | 0 | Default, single column |
| tablet | 640px | 2 columns where applicable |
| desktop | 1024px | Full layout |

---

## 9. Component Specifications

---

### 9.1 Buttons

#### Variants

**Primary**
```
background: teal-700 (#0f766e)
color: #ffffff
border: none
padding: 10px 20px
border-radius: 8px
font-size: 14px
font-weight: 600
letter-spacing: 0.01em
shadow: shadow-sm
```
- Hover: `background: teal-800 (#115e59)`, `transform: none` (no lift on buttons)
- Active: `transform: scale(0.98)`, `background: teal-800`
- Focus: `outline: 2px solid teal-400`, `outline-offset: 2px`
- Disabled: `background: neutral-200`, `color: neutral-400`, `cursor: not-allowed`, no shadow

**Secondary (Outline)**
```
background: transparent
color: teal-700
border: 1.5px solid teal-500
padding: 9px 19px  (1px less to compensate border)
border-radius: 8px
font-size: 14px
font-weight: 600
```
- Hover: `background: teal-50`, `border-color: teal-700`
- Active: `background: teal-100`, `transform: scale(0.98)`
- Disabled: `color: neutral-400`, `border-color: neutral-200`, `cursor: not-allowed`

**Ghost**
```
background: transparent
color: teal-700
border: none
padding: 10px 20px
border-radius: 8px
font-size: 14px
font-weight: 600
```
- Hover: `background: teal-50`
- Active: `background: teal-100`, `transform: scale(0.98)`
- Disabled: `color: neutral-400`, `cursor: not-allowed`

**Danger**
```
background: #ef4444
color: #ffffff
border: none
padding: 10px 20px
border-radius: 8px
font-size: 14px
font-weight: 600
```
- Hover: `background: #dc2626`
- Active: `transform: scale(0.98)`, `background: #b91c1c`
- Disabled: `background: neutral-200`, `color: neutral-400`

#### Sizes

| Size | Padding | Font | Min Width |
|---|---|---|---|
| Small | `6px 14px` | `12px` | — |
| Medium (default) | `10px 20px` | `14px` | — |
| Large | `14px 28px` | `16px` | — |
| Full width | `10px 20px` | `14px` | `100%` |

#### Icon Buttons

- Icon only: `10px` padding all sides, `border-radius: 8px`.
- Icon + label: icon is `16px`, gap between icon and label is `8px`, icon aligned center.
- Spinner replaces icon during loading state; label remains visible.

#### Button Rules

- Every button must have an accessible `aria-label` if icon-only.
- Loading state: show spinner (24px) left of label, `cursor: wait`, disabled interaction.
- Never use `<div>` or `<a>` styled as buttons for form actions. Use `<button>`.

---

### 9.2 Input Fields

#### Text Input (default state)

```
height: 40px
background: #ffffff
border: 1px solid teal-100 (#ccfbf1)
border-radius: 8px
padding: 0 12px
font-size: 14px
color: teal-900 (#134e4a)
shadow: shadow-sm
```

**Focus:**
```
border-color: teal-500 (#14b8a6)
outline: 2px solid teal-400 (#2dd4bf)
outline-offset: 0
shadow: none (outline replaces shadow)
```

**Error:**
```
border-color: #fca5a5
outline: 2px solid #fca5a5
```

**Disabled:**
```
background: neutral-100 (#f3f4f6)
color: neutral-400
cursor: not-allowed
border-color: neutral-200
```

**Placeholder:** `color: neutral-400 (#9ca3af)`

**With left icon:**
- Icon sits at `12px` from left, `16×16px`, `color: neutral-400`.
- Padding-left becomes `38px`.

**With right action (e.g. clear button, show/hide password):**
- Button `24×24px`, positioned `8px` from right.
- Padding-right becomes `40px`.

#### Textarea

Same as text input with:
```
height: auto
min-height: 80px
padding: 10px 12px
resize: vertical
line-height: 1.6
```

#### Select / Dropdown

Same as text input visually, plus:
- Custom chevron icon (`16×16`, `teal-500`) positioned `12px` from right.
- `appearance: none` to remove native arrow.
- `padding-right: 38px`.
- Dropdown list: `background: white`, `border: 1px solid teal-100`, `border-radius: 8px`, `shadow: shadow-md`, appears `4px` below input.
- Dropdown option: `padding: 8px 12px`, `font-size: 14px`, `color: teal-900`.
- Dropdown option hover: `background: teal-50`.
- Dropdown option selected: `background: teal-50`, `color: teal-700`, `font-weight: 600`.

#### Checkbox

```
width: 18px
height: 18px
border: 1.5px solid teal-300
border-radius: 4px
background: white
appearance: none
cursor: pointer
```
- Checked: `background: teal-600`, `border-color: teal-600`, white checkmark SVG centered.
- Focus: `outline: 2px solid teal-400`, `outline-offset: 2px`.
- Disabled: `background: neutral-100`, `border-color: neutral-200`.
- Label: `font-size: 14px`, `color: teal-900`, gap `8px` from checkbox.

#### Radio Button

Same dimensions as checkbox, `border-radius: 50%`.
- Selected: `border-color: teal-600`, inner filled circle `8×8px`, `background: teal-600`.

#### Toggle / Switch

```
width: 42px
height: 24px
border-radius: 9999px
background: neutral-200 (off) / teal-600 (on)
transition: background 150ms ease-out
```
- Knob: `18×18px` circle, `background: white`, `box-shadow: 0 1px 3px rgba(0,0,0,0.2)`.
- Off: knob at `left: 3px`.
- On: knob at `left: 21px`.
- Knob transition: `transform: translateX()` `150ms ease-out`.
- Focus: `outline: 2px solid teal-400` on the wrapper, `outline-offset: 2px`.

---

### 9.3 Form Groups

Every input must be accompanied by a label and optional helper/error text.

```
Form Group structure:
┌──────────────────────────────────┐
│ Label (12px, 600, teal-600)      │
│ [Input / Textarea / Select]      │
│ Helper or error text (12px)      │
└──────────────────────────────────┘
```

- Label: `font-size: 12px`, `font-weight: 600`, `color: teal-600`, `margin-bottom: 6px`, always uppercase with `letter-spacing: 0.08em`.
- Helper text: `font-size: 12px`, `color: neutral-400`, `margin-top: 4px`.
- Error text: `font-size: 12px`, `color: #991b1b`, `margin-top: 4px`. Prefixed with `⚠ `.
- Required indicator: `color: #ef4444`, `font-size: 14px`, rendered as `*`, placed after label text with `margin-left: 2px`.
- Gap between form groups: `space-6` (24px).

---

### 9.4 Cards

```
background: #ffffff
border: 1px solid teal-100 (#ccfbf1)
border-left: 4px solid teal-500 (#14b8a6)
border-radius: 10px
padding: 20px 24px
```

- Hover (when card is a link/interactive): `transform: translateY(-2px)`, `shadow: shadow-card-hover`, `150ms ease-out`.
- Card title: H3 spec (`18px`, `600`, `teal-700`).
- Card body text: body-small spec (`14px`, `400`, `neutral-600`).
- Card with icon: icon `24×24px`, `color: teal-500`, positioned top-left of content area with `margin-right: 16px`.
- Card footer (actions): `border-top: 1px solid teal-100`, `margin-top: 16px`, `padding-top: 16px`.

#### Card Variants

**Flat card** (no hover, informational only): Remove border-left accent, use `border: 1px solid teal-100` on all sides.

**Highlight card** (featured or active): `border-left: 4px solid teal-700`, `background: teal-50`.

**Danger card** (error, destructive action): `border-left: 4px solid #ef4444`, `border-color: #fca5a5`.

---

### 9.5 Navigation

#### Top Header

```
background: teal-700 (#0f766e)
padding: 0 32px
height: 64px
display: flex, align-items: center, justify-content: space-between
box-shadow: shadow-header
position: sticky, top: 0, z-index: 100
```

**Logo / Brand name:**
- `font-size: 20px`, `font-weight: 700`, `color: #ffffff`, `letter-spacing: 0.04em`.
- Always lowercase: `turinghatch`.

**Nav links (in header):**
- `font-size: 14px`, `font-weight: 500`, `color: teal-200 (#99f6e4)`.
- Hover: `color: #ffffff`.
- Active/current page: `color: #ffffff`, `font-weight: 600`.
- Underline: `2px solid teal-400` appears on active, not on hover.
- Gap between links: `24px`.

**Header right area (user menu, actions):**
- Avatar: `32×32px` circle, `background: teal-800`, initials in `teal-200`, `font-size: 13px`, `font-weight: 600`.
- Dropdown opens on click: `background: white`, `border: 1px solid teal-100`, `border-radius: 10px`, `shadow: shadow-md`, `min-width: 180px`.

#### Sidebar (for app shell)

```
width: 220px
background: #ffffff
border-right: 1px solid teal-100
padding: 24px 0
height: 100vh
position: sticky, top: 64px
```

**Sidebar nav item:**
```
padding: 8px 20px
font-size: 14px
font-weight: 500
color: neutral-600
border-radius: 0 (no radius on individual items)
display: flex, align-items: center
gap: 10px
```
- Icon: `18×18px`, `color: neutral-400`.
- Hover: `background: teal-50`, `color: teal-700`, icon `color: teal-500`.
- Active: `background: teal-50`, `color: teal-700`, `font-weight: 600`, icon `color: teal-600`, `border-right: 3px solid teal-600`.

**Sidebar section label:**
- `font-size: 11px`, `font-weight: 600`, uppercase, `letter-spacing: 0.12em`, `color: neutral-400`.
- Padding: `16px 20px 6px`.

#### Breadcrumbs

```
font-size: 13px
color: neutral-400
display: flex, align-items: center, gap: 6px
```
- Separator: `›` character, `color: neutral-400`.
- Current page: `color: teal-700`, `font-weight: 500`.
- Previous pages: links, `color: teal-600`, hover `color: teal-700`, no underline by default, underline on hover.

#### Tabs

```
border-bottom: 1px solid teal-100
display: flex, gap: 0
```

**Tab item:**
```
padding: 10px 20px
font-size: 14px
font-weight: 500
color: neutral-400
cursor: pointer
border-bottom: 2px solid transparent
margin-bottom: -1px
```
- Hover: `color: teal-700`.
- Active: `color: teal-700`, `font-weight: 600`, `border-bottom-color: teal-600`.
- Tab content area: `padding-top: 24px`.

---

### 9.6 Tables

```
width: 100%
border-collapse: collapse
border-radius: 10px
overflow: hidden
border: 1px solid teal-100
```

**Table header row:**
```
background: teal-50 (#f0faf9)
border-bottom: 1px solid teal-100
```

**Header cell (th):**
```
padding: 10px 16px
font-size: 11px
font-weight: 600
color: teal-600
text-transform: uppercase
letter-spacing: 0.10em
text-align: left
```

**Body row (tr):**
- Default: `background: white`.
- Striped even rows: `background: teal-50`.
- Hover: `background: teal-50` (even if not striped).

**Body cell (td):**
```
padding: 12px 16px
font-size: 14px
color: teal-900
border-bottom: 1px solid teal-100
vertical-align: middle
```
- Last row: `border-bottom: none`.

**Sortable column:** Header cell shows `↕` icon (`12px`, `neutral-400`). Active sort shows `↑` or `↓` (`teal-600`). Cursor `pointer` on sortable headers.

**Row actions:** Rightmost cell contains action buttons (ghost small). Visible on row hover via `opacity: 0 → 1`, `150ms`.

**Empty table state:** Single row, full colspan, centered text: `font-size: 14px`, `color: neutral-400`, `padding: 40px 16px`. Include an icon above text (see §9.11 Empty States).

---

### 9.7 Lists

#### App Card List (homepage pattern)

```
display: flex
flex-direction: column
gap: 12px
```

Each item: full card spec (§9.4) with `display: flex`, `align-items: center`, `justify-content: space-between`.

Arrow icon: `→` or SVG, `color: teal-500`, `font-size: 20px`. On hover: `transform: translateX(3px)`, `150ms ease-out`.

#### Bullet List

```
list-style: none
padding: 0
display: flex, flex-direction: column, gap: 8px
```
Each item: `padding-left: 20px`, `position: relative`.
Bullet: `::before` pseudo-element, `content: '•'`, `color: teal-500`, `position: absolute`, `left: 0`.

#### Ordered List

Same as bullet list but `counter-increment` based. Number rendered as `::before`, `color: teal-600`, `font-weight: 600`, `min-width: 20px`.

#### Key-Value List (detail panels)

```
display: grid
grid-template-columns: auto 1fr
gap: 8px 24px
```
Key: `font-size: 12px`, `font-weight: 600`, `color: teal-600`, uppercase, `letter-spacing: 0.08em`.
Value: `font-size: 14px`, `color: teal-900`.

---

### 9.8 Badges & Tags

```
display: inline-flex
align-items: center
border-radius: 9999px
font-size: 12px
font-weight: 600
padding: 2px 10px
letter-spacing: 0.02em
```

| Variant | Background | Text | Border |
|---|---|---|---|
| Default / Neutral | `neutral-100` | `neutral-600` | none |
| Primary | `teal-100` | `teal-700` | none |
| Success | `#f0fdf4` | `#166534` | none |
| Warning | `#fffbeb` | `#92400e` | none |
| Error | `#fef2f2` | `#991b1b` | none |
| Outline | transparent | `teal-600` | `1px solid teal-300` |

**Dot badge (status indicator):**
- `8×8px` circle, no text. Colors: `teal-500` (active), `neutral-400` (inactive), `#22c55e` (online), `#ef4444` (error).
- Placed `top-right` of avatar or icon, `2px` offset.

---

### 9.9 Modals & Dialogs

#### Backdrop

```
position: fixed, inset: 0
background: rgba(19, 78, 74, 0.45)  ← teal-tinted, not pure black
z-index: 200
```

#### Panel

```
position: fixed
top: 50%, left: 50%
transform: translate(-50%, -50%)
background: white
border-radius: 10px
box-shadow: shadow-modal
width: 480px (small), 640px (medium), 900px (large)
max-width: calc(100vw - 32px)
max-height: calc(100vh - 64px)
overflow-y: auto
z-index: 201
```

#### Modal Structure

```
┌─────────────────────────────────────────────┐
│ Header: padding 24px 24px 16px              │
│   Title: H2 spec (24px, 700, teal-900)      │
│   Close button: top-right corner            │
├─────────────────────────────────────────────┤
│ Body: padding 0 24px 24px                   │
│   Subtitle (optional): 14px, neutral-600    │
│   Content                                   │
├─────────────────────────────────────────────┤
│ Footer: padding 16px 24px, border-top       │
│   border-top: 1px solid teal-100            │
│   Actions: flex, justify-content: flex-end  │
│   gap: 12px                                 │
└─────────────────────────────────────────────┘
```

**Close button:** `32×32px`, ghost variant, icon-only (`×`), positioned `absolute top: 16px, right: 16px`.

**Confirm/Destructive dialog:** Body contains warning icon (`32×32px`, `#ef4444`), centered above text. Primary action is Danger button variant.

**Rules:**
- Modal opens/closes with entrance/exit animation (§7).
- Clicking backdrop closes modal (unless `required` prop set).
- Focus trapped inside modal while open.
- `Escape` key closes modal.
- Body scroll locked when modal is open.

---

### 9.10 Toasts & Alerts

#### Toast Notifications

Position: `fixed, bottom: 24px, right: 24px`, `z-index: 300`, stacked with `12px` gap.

```
background: white
border-left: 4px solid <semantic color>
border-radius: 10px
box-shadow: shadow-modal
padding: 14px 16px
min-width: 280px
max-width: 380px
display: flex
align-items: flex-start
gap: 12px
```

**Icon:** `20×20px`, semantic color. Sits left of text content.
**Title:** `14px`, `600`, `teal-900`.
**Message:** `13px`, `neutral-600`, `margin-top: 2px`.
**Dismiss button:** `×`, `16px`, `neutral-400`, `position: absolute, top: 10px, right: 10px`.

Auto-dismiss: 4000ms for success/info, 0ms (manual only) for errors.

Progress bar at bottom of toast: `3px` height, animates from `width: 100%` to `width: 0` over the auto-dismiss duration.

#### Inline Alerts

```
border-radius: 8px
padding: 12px 16px
display: flex
align-items: flex-start
gap: 10px
font-size: 14px
```

Use semantic palette for background, border, and text (see §2).
Icon: `18×18px`, semantic icon color.
Dismissible variant adds `×` button flush right.

---

### 9.11 Loading States

#### Page / Section Skeleton

Skeleton blocks replace content while loading:
```
background: linear-gradient(90deg, teal-100 25%, neutral-200 50%, teal-100 75%)
background-size: 400px 100%
animation: shimmer 1.5s ease-in-out infinite
border-radius: same as the element being replaced
```

Skeleton shapes:
- Text line: `height: 14px`, `border-radius: 4px`, `width: varies (60-90%)`.
- Card: full card dimensions, `border-radius: 10px`.
- Avatar: `32×32px`, `border-radius: 50%`.
- Never show more than 3 skeleton cards in a list.

#### Inline Spinner

```
width: 20px
height: 20px
border: 2.5px solid teal-100
border-top-color: teal-600
border-radius: 50%
animation: spin 700ms linear infinite
```

Centered in its container. For button loading: spinner replaces left icon, `cursor: wait`.

#### Full-Page Loader

Spinner centered in viewport, `48×48px` version. Below spinner: `font-size: 14px`, `color: neutral-400`, loading message.

---

### 9.12 Empty States

```
display: flex
flex-direction: column
align-items: center
padding: 48px 24px
text-align: center
```

**Icon:** `48×48px`, `color: teal-200`, centered. Use an outline-style icon relevant to the context.
**Title:** `16px`, `600`, `teal-900`, `margin-top: 16px`.
**Subtitle:** `14px`, `neutral-400`, `margin-top: 6px`, `max-width: 320px`.
**Action button:** Primary or secondary button, `margin-top: 20px`.

---

### 9.13 Error States

#### Inline Field Error (see §9.3)

#### Page-Level Error

Same structure as empty state but:
- Icon: `48×48px`, `color: #fca5a5` (error-border).
- Title: `16px`, `600`, `#991b1b`.
- Subtitle: `14px`, `neutral-600`.
- Actions: "Try again" (Primary) + "Go home" (Ghost), side by side.

#### 404 / Not Found Page

- Large numeral `404`: `96px`, `700`, `teal-100`.
- Below: title `24px`, `700`, `teal-900`.
- Below: subtitle `16px`, `neutral-600`.
- Below: "Return to Home" Primary button.

---

### 9.14 Avatars

**Circle only. Never square.**

| Size | Diameter | Font size |
|---|---|---|
| xs | 24px | 10px |
| sm | 32px | 13px |
| md | 40px | 16px |
| lg | 56px | 22px |
| xl | 80px | 32px |

**Initials avatar:** `background: teal-700`, `color: #ffffff`, `font-weight: 600`.
**Image avatar:** `object-fit: cover`, `border-radius: 50%`.
**Avatar group:** Avatars overlap by `8px`, `border: 2px solid white`. Max show 4; fifth slot shows `+N` count with `background: teal-100`, `color: teal-700`.

---

### 9.15 Tooltips

Triggered on hover or focus.

```
background: teal-900 (#134e4a)
color: #ffffff
font-size: 12px
font-weight: 500
padding: 5px 10px
border-radius: 6px
white-space: nowrap
max-width: 200px
```

Arrow: `6×6px` triangle, same background color, positioned at edge pointing toward trigger.
Entrance: `opacity: 0 → 1`, `100ms ease-out`. Exit: `opacity: 1 → 0`, `80ms`.
Position: prefer `top`, fall back to `bottom`/`side` if clipped.

---

### 9.16 Progress Bars

```
height: 8px
background: teal-100
border-radius: 9999px
overflow: hidden
```

**Fill:**
```
height: 100%
background: teal-600
border-radius: 9999px
transition: width 300ms ease-out
```

Labeled variant: percentage shown `right: 0` above bar, `font-size: 12px`, `color: teal-600`, `font-weight: 600`.

Striped variant (indeterminate): animated diagonal stripes, `background: repeating-linear-gradient(45deg, teal-600 0px, teal-600 10px, teal-500 10px, teal-500 20px)`. Animates `background-position` continuously.

---

### 9.17 Pagination

```
display: flex
align-items: center
gap: 4px
```

**Page button:**
```
width: 36px
height: 36px
border-radius: 8px
font-size: 14px
font-weight: 500
color: teal-700
background: transparent
border: none
```
- Hover: `background: teal-50`.
- Active/current: `background: teal-700`, `color: white`.

**Prev / Next buttons:** Ghost variant, `padding: 0 12px`, `height: 36px`. Disabled when at boundary.

**Ellipsis:** `…` styled same as page button, no hover, `cursor: default`.

---

### 9.18 Search

```
position: relative
```

**Input:** Full text input spec (§9.2), `padding-left: 38px`, `height: 40px`.
**Search icon:** `16×16px`, `color: neutral-400`, `position: absolute, left: 12px, top: 50%, transform: translateY(-50%)`.
**Clear button:** `×` icon, `16×16px`, `color: neutral-400`, `position: absolute, right: 10px`, visible only when input has value.

Results dropdown (if inline search):
- `background: white`, `border: 1px solid teal-100`, `border-radius: 10px`, `shadow: shadow-md`.
- Appears `4px` below input.
- Result item: `padding: 10px 14px`, `font-size: 14px`, `color: teal-900`.
- Result item hover: `background: teal-50`.
- Match highlight: `font-weight: 600`, `color: teal-700`.

---

## 10. Page-Level Patterns

### Header + Subheader Pattern

```
┌──────────────────────────────────────────┐
│ Page Title (H1 spec)        [Action Btn] │
│ Subtitle (14px, neutral-600)             │
└──────────────────────────────────────────┘
border-bottom: 1px solid teal-100
padding-bottom: 20px
margin-bottom: 32px
```

### Section Pattern

```
margin-bottom: 48px
```
Section label (§3 Label spec) precedes each section.
Gap between label and section content: `16px`.

### Form Page Pattern

Form contained in a card (§9.4), `max-width: 560px`, centered.
Submit action: Primary button, right-aligned in card footer.
Cancel: Ghost button, left of submit.

### Dashboard / Grid Pattern

```
display: grid
grid-template-columns: repeat(auto-fill, minmax(280px, 1fr))
gap: 20px
```

---

## 11. Iconography

- Icon style: **outline** (not filled). 24px grid. Stroke width `1.5px`.
- Icon color: always inherits from context or explicitly set to a palette color.
- Never scale icons with `font-size`. Use `width` and `height` explicitly.
- Recommended library: Heroicons (outline variant) — matches the stroke weight.
- Custom icons must follow the same `1.5px` stroke, 24px grid, rounded linecaps.

---

## 12. Imagery

- No stock photography. Illustrations only (if used).
- Illustration palette: uses teal-100, teal-200, teal-500 as primary colors with white.
- Aspect ratios: `16:9` for hero images, `1:1` for avatars.
- `border-radius: 10px` on all images that are inside cards.
- Images always include `alt` text. Decorative images use `alt=""`.

---

## 13. Accessibility

- **Contrast:** All text must meet WCAG AA. Body text on `teal-50` background (`teal-900` text) passes at 12.9:1. Interactive text minimum `4.5:1`.
- **Focus:** Every interactive element has a visible focus indicator: `2px solid teal-400`, `outline-offset: 2px`. Never `outline: none` without a custom replacement.
- **Keyboard:** All interactions achievable without a mouse. Tab order follows visual order.
- **ARIA:** All icon-only buttons have `aria-label`. Modals use `role="dialog"`, `aria-modal="true"`, `aria-labelledby`. Toasts use `role="status"` (info/success) or `role="alert"` (error).
- **Motion:** All animations wrapped in `@media (prefers-reduced-motion: no-preference)`.
- **Forms:** Every input has a `<label>` with `for` pointing to input `id`. Error messages linked via `aria-describedby`.

---

## 14. Do's and Don'ts

| ✅ Do | ❌ Don't |
|---|---|
| Use teal as the single brand color | Introduce purple, orange, or other accent colors |
| Use system font stack | Import Google Fonts or custom typefaces |
| Use `transform` for animation | Animate `width`, `height`, `top`, `left` |
| Write lowercase `turinghatch` everywhere | Write `TuringHatch` or `Turing Hatch` |
| Use reserved, defined spacing values | Use arbitrary px values like `13px`, `17px` |
| Use semantic color tokens for alerts | Use raw hex codes for semantic states |
| Lazy-load images | Block render with heavy assets |
| Keep max content width at 1100px | Allow content to stretch full viewport |
| Test with keyboard only | Assume mouse-only users |
| Test with `prefers-reduced-motion: reduce` | Ship animations without the media query guard |

---

*Last updated: 2026-05-31. This document is version-controlled alongside the codebase.*
