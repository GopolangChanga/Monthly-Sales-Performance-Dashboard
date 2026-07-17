# 🎨 Dashboard Design System
## Monthly Sales Performance Dashboard — AdventureWorks

This document defines the complete design language for the Monthly Sales Performance Dashboard.
It covers colour palette, typography, and component-level specifications — serving as a reference
for anyone maintaining, extending, or replicating this report.

---

## 📌 Font Families

| Font | Source | Usage |
|---|---|---|
| **Space Grotesk** | Google Fonts | All headline numbers, KPI values, titles, dates — anything that needs to stand out |
| **Inter** | Google Fonts | All body text, labels, tooltips, table content, descriptions — everything readable |

> **Rule:** Big numbers = Space Grotesk bold. Labels and body = Inter regular/medium.

---

## 🖥️ Base & Background Colours

| Element | Hex | Usage |
|---|---|---|
| Page background | `#1a0f2e` | Main canvas background |
| Panel / card surface | `#241545` | All panel and card backgrounds |
| Secondary surface | `#2e1a58` | Inputs, slicers, inner containers |
| Border | `rgba(160,120,255,0.15)` | All panel and card borders |

---

## 💜 Purple Scale

| Name | Hex | Usage |
|---|---|---|
| Purple 1 — Deep | `#7c3aed` | Buttons, bar fills, line chart base, treemap lowest |
| Purple 2 — Mid | `#a855f7` | Dots, legends, accents, slicer borders |
| Purple 3 — Light | `#c084fc` | Category labels, rank numbers, panel tags |
| Accent — Pink Purple | `#e879f9` | Forecast line, treemap values, highlights, gradient ends |

---

## 🔤 Typography Scale

| Element | Font | Size | Weight | Case |
|---|---|---|---|---|
| Report title | Space Grotesk | `18px` | 700 | Title case |
| Date badge | Space Grotesk | `13px` | 600 | Uppercase |
| Month slicer | Inter | `13px` | 400 | Normal |
| Reset button | Inter | `12px` | 400 | Normal |
| Logo icon | Inter (emoji) | `18px` | — | — |

---

## 🔤 Typography Colours

| Element | Hex |
|---|---|
| Primary text | `#f1e9ff` |
| Muted / label text | `#9d8ec4` |
| Dim / secondary text | `#6b5f8a` |

---

## 🚦 Status / Performance Colours

Used in the **Product Performance Matrix** conditional formatting and any performance indicators.

| Performance Level | Business Rule | Background | Text |
|---|---|---|---|
| Exceptional | > 120% of average | `#065f46` | `#6ee7b7` |
| Above Average | 100% – 120% of average | `#064e3b` | `#34d399` |
| On Track | 80% – 100% of average | `#78350f` | `#fbbf24` |
| Below Average | 60% – 80% of average | `#7c2d12` | `#fb923c` |
| Critical | < 60% of average | `#7f1d1d` | `#f87171` |

> **Business Rule:** Performance is measured as `Current Month Sales ÷ Average Monthly Sales`
> across all months in the dataset, with category filter retained.

---

## ⚡ HTML Dynamic Summary Card

| Element | Font | Size | Weight | Colour |
|---|---|---|---|---|
| Section label | Inter | `10px` | 600 | `#9d8ec4` |
| Summary sentence | Inter | `14px` | 400 | `#f1e9ff` |
| Highlighted text | Inter | `14px` | 600 | `#c084fc` |
| Positive % | Inter | `14px` | 600 | `#34d399` |
| Negative % | Inter | `14px` | 600 | `#f87171` |
| Mini stat values | Space Grotesk | `20px` | 700 | `#34d399` / `#fbbf24` |
| Mini stat labels | Inter | `10px` | 400 | `#9d8ec4` |
| Card background | — | — | — | Gradient `#241545` → `#3a1a6e` |
| Card border | — | — | — | `rgba(168,85,247,0.3)` |

---

## 📊 KPI Cards

| Element | Font | Size | Weight | Colour |
|---|---|---|---|---|
| Card label | Inter | `10px` | 600 | `#9d8ec4` |
| Card value | Space Grotesk | `22px` | 700 | `#f1e9ff` |
| Positive change | Inter | `11px` | 500 | `#34d399` |
| Negative change | Inter | `11px` | 500 | `#f87171` |
| Neutral change | Inter | `11px` | 500 | `#9d8ec4` |
| Top accent bar | — | `3px` height | — | Gradient `#7c3aed` → `#e879f9` |
| Card background | — | — | — | `#241545` |
| Card border | — | — | — | `rgba(160,120,255,0.15)` |

---

## 🏷️ Panel Headers (All Visuals)

| Element | Font | Size | Weight | Colour |
|---|---|---|---|---|
| Panel title | Space Grotesk | `13px` | 700 | `#f1e9ff` |
| Panel tag badge | Inter | `10px` | 500 | `#c084fc` |
| Tag background | — | — | — | `rgba(124,58,237,0.2)` |
| Tag border | — | — | — | `rgba(124,58,237,0.4)` |

---

## 📈 24-Month Trend Line Chart

| Element | Font | Size | Weight | Colour |
|---|---|---|---|---|
| Y-axis labels | Inter (SVG) | `9px` | 400 | `#6b5f8a` |
| X-axis labels | Inter (SVG) | `8px` | 400 | `#6b5f8a` |
| Current month label | Inter (SVG) | `8px` | 700 | `#c084fc` |
| Forecast label | Inter (SVG) | `8px` | 400 | `#e879f9` |
| Average label | Inter (SVG) | `8px` | 400 | `#fbbf24` |
| Callout bubble value | Inter (SVG) | `9px` | 400 | `#ffffff` |
| Legend items | Inter | `11px` | 400 | `#9d8ec4` |
| Area fill | — | — | — | `#7c3aed` → transparent |
| Line stroke | — | — | — | Gradient `#7c3aed` → `#a855f7` |
| Forecast line | — | — | — | `#e879f9` (dashed) |
| Forecast band | — | — | — | `rgba(232,121,249,0.08)` |
| Average line | — | — | — | `#fbbf24` (dashed) |
| Data point dot | — | — | — | `#a855f7` |
| Callout bubble bg | — | — | — | `#7c3aed` |
| Grid lines | — | — | — | `rgba(255,255,255,0.05)` |

---

## 🎯 Gauge Visual (Sales vs Target)

| Element | Font | Size | Weight | Colour |
|---|---|---|---|---|
| Min / Max labels | Inter | `10px` | 400 | `#9d8ec4` |
| Main % value | Space Grotesk | `26px` | 700 | `#34d399` |
| Sub label | Inter | `10px` | 400 | `#9d8ec4` |
| Warning label | Inter | `11px` | 400 | `#fbbf24` |
| Track background | — | — | — | `rgba(255,255,255,0.08)` |
| Fill gradient | — | — | — | `#7c3aed` → `#34d399` |
| Needle | — | `2px` stroke | — | `#fbbf24` |
| Needle pivot | — | `5px` radius | — | `#fbbf24` |

---

## 🟪 Product Performance Matrix

| Element | Font | Size | Weight | Colour |
|---|---|---|---|---|
| Column headers | Inter | `10px` | 500 | `#9d8ec4` |
| Category rows | Inter | `11px` | 700 | `#c084fc` |
| Sub-category rows | Inter | `10px` | 400 | `#9d8ec4` |
| Cell values | Inter | `11px` | 400 | `#f1e9ff` |
| Expand icon | Inter | `9px` | 400 | `#c084fc` |
| Row hover background | — | — | — | `rgba(124,58,237,0.08)` |
| Header border | — | — | — | `rgba(160,120,255,0.15)` |
| Row divider | — | — | — | `rgba(255,255,255,0.04)` |

### Conditional Formatting Cells
| Level | Background | Text |
|---|---|---|
| Exceptional | `#065f46` | `#6ee7b7` |
| Above Average | `#064e3b` | `#34d399` |
| On Track | `#78350f` | `#fbbf24` |
| Below Average | `#7c2d12` | `#fb923c` |
| Critical | `#7f1d1d` | `#f87171` |

---

## 👤 Top 10 Customers Table

| Element | Font | Size | Weight | Colour |
|---|---|---|---|---|
| Column headers | Inter | `10px` | 500 | `#9d8ec4` |
| Rank number | Space Grotesk | `10px` | 700 | `#c084fc` |
| Customer name | Inter | `11px` | 400 | `#f1e9ff` |
| Sales value | Inter | `11px` | 400 | `#f1e9ff` |
| % contribution value | Inter | `10px` | 400 | `#9d8ec4` |
| Contribution bar fill | — | `4px` height | — | Gradient `#7c3aed` → `#e879f9` |
| Row hover | — | — | — | `rgba(124,58,237,0.08)` |

---

## 📦 Sales by Category (Bar Chart)

| Element | Font | Size | Weight | Colour |
|---|---|---|---|---|
| Category label | Inter | `10px` | 400 | `#9d8ec4` |
| Sales value | Inter | `10px` | 400 | `#f1e9ff` |
| Legend items | Inter | `11px` | 400 | `#9d8ec4` |
| Current month bar | — | `8px` height | — | `#8250C4` |
| Prior month bar | — | `8px` height | — | `#FFA500` |
| Bar track background | — | — | — | `#ffffff44` |

---

## 🗺️ Treemap (Sales by Territory)

| Element | Font | Size | Weight | Colour |
|---|---|---|---|---|
| Territory name | Space Grotesk (SVG) | `11px` | 700 | `#c084fc` |
| Sales value | Space Grotesk (SVG) | `14px` | 700 | `#e879f9` |
| % share label | Inter (SVG) | `9px` | 400 | `#9d8ec4` |
| Legend items | Inter | `11px` | 400 | `#9d8ec4` |

### Region Colours
| Region | Hex |
|---|---|
| North America | `#3b82f6` |
| Europe | `#f59e0b` |
| Pacific | `#e879f9` |

### Territory Performance Tier Colours (Tooltip)
| Tier | Indicator |
|---|---|
| High | 🟢 |
| Medium | 🟡 |
| Low | 🔴 |

---

## 📐 Design Rules Summary

| Rule | Value |
|---|---|
| Big numbers always | Space Grotesk, bold (700) |
| Labels always | Inter, small, uppercase, letter-spaced |
| Body text always | Inter, regular (400) or medium (500) |
| Minimum font size | `8px` (SVG axis labels only) |
| Maximum font size | `26px` (Gauge main value) |
| Border radius — cards | `12px` – `14px` |
| Border radius — badges | `20px` |
| Border radius — buttons | `8px` |
| Panel padding | `18px` |
| Page padding | `18px 24px` |
| Gap between sections | `16px` |

---

*Last updated: July 2026*
