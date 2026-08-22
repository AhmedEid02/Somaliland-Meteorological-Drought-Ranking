README.md
# Somaliland Meteorological Drought Ranking (1981–2024) — CHIRPS (Gu (MAM) & Deyr (OND))

This mini project ranks Somaliland’s worst **meteorological (rainfall-only) drought seasons** using **CHIRPS rainfall** for:
- **Gu (MAM)**: March–April–May  
- **Deyr (OND)**: October–November–December  

Drought severity is measured using:
- **% of normal rainfall** (relative to a baseline climatology)
- **rainfall anomaly (mm)** (year seasonal total minus baseline mean)

Baseline period: **1981–2010**  
Analysis period: **1981–2024**  
AOI: **Somaliland Admin-0 boundary** (GEE Asset)

---

## Why this matters
Seasonal rainfall failure drives drought impacts across livelihoods. This workflow provides a quick, reproducible way to:
- identify historical drought extremes by season,
- check whether Gu and Deyr failures happen in the same years (compound drought),
- visualize spatial rainfall anomaly patterns for selected extreme seasons.

---

## Key results (from this run)
- **Worst Gu (MAM): 2022** — **53.5%** of normal (≈ **−43.7 mm**)  
- **Worst Deyr (OND): 1986** — **37.5%** of normal (≈ **−28.5 mm**)  
- **Compound drought (≤80% of normal in both seasons)** is rare; strongest years include **1984 and 1988**.

> Note: “Worst” here means **largest rainfall deficit relative to the 1981–2010 baseline**, not necessarily the greatest socio-economic impacts.

---

## Repository structure


somaliland-meteorological-drought-ranking/
├─ README.md
├─ LICENSE
├─ .gitignore
├─ scripts/
│ ├─ gee/
│ │ └─ 01_chirps_seasonal_drought_ranking.js
│ └─ r/
│ ├─ 01_analysis_tables_figures.R
│ └─ 02_maps_panel_shared_legend.R
├─ data/
│ ├─ tables/
│ │ ├─ Somaliland_Gu_MAM_CHIRPS_Table_1981_2024.csv
│ │ ├─ Somaliland_Gu_MAM_Top10_DroughtYears_1981_2024.csv
│ │ ├─ Somaliland_Deyr_OND_CHIRPS_Table_1981_2024.csv
│ │ └─ Somaliland_Deyr_OND_Top10_DroughtYears_1981_2024.csv
│ └─ geotiff/
│ ├─ Somaliland_Gu_MAM_Anomaly_mm_2022_vs_1981_2010.tif
│ ├─ Somaliland_Gu_MAM_Anomaly_mm_2009_vs_1981_2010.tif
│ ├─ Somaliland_Deyr_OND_Anomaly_mm_1986_vs_1981_2010.tif
│ └─ Somaliland_Deyr_OND_Anomaly_mm_2020_vs_1981_2010.tif
└─ outputs/
├─ figures/
│ ├─ Top10_Gu_Deyr_Combined_Polished.png
│ ├─ Compound_Drought_Scatter_Polished.png
│ └─ MAP_PANEL_FINAL_SHAREDLEGEND.png
└─ tables/
├─ Gu_MAM_Top5.csv
└─ Deyr_OND_Top5.csv


---

## Data sources
- **CHIRPS precipitation** (seasonal totals) via Google Earth Engine  
- Somaliland Admin-0 boundary: GEE Asset (user-provided)

---

## Methods

### Seasonal metrics
For each year and season:
- Seasonal rainfall total (mm)
- Baseline seasonal mean (1981–2010)
- **Anomaly (mm)** = seasonal rainfall − baseline mean
- **% of normal** = (seasonal rainfall / baseline mean) × 100

### Compound drought check
A “compound drought year” is defined as:
- **Gu (MAM) ≤ 80%** and **Deyr (OND) ≤ 80%** in the same year.

---

## How to reproduce

### A) Google Earth Engine (GEE)
1. Open the GEE Code Editor
2. Paste/run: `scripts/gee/01_chirps_seasonal_drought_ranking.js`
3. Export outputs (CSV tables and GeoTIFF anomaly maps) to populate:
   - `data/tables/`
   - `data/geotiff/`

### B) RStudio (R analysis + visualization)
Run these scripts in order:

1) `scripts/r/01_analysis_tables_figures.R`  
- Reads `data/tables/`
- Writes figures to `outputs/figures/`
- Writes tables to `outputs/tables/`

2) `scripts/r/02_maps_panel_shared_legend.R`  
- Reads `data/geotiff/`
- Exports the final 2×2 map panel to `outputs/figures/`

---

## Notes on Machine Learning (ML)
A simple ML baseline forecasting test was performed separately for skills demonstration.  
This repository focuses on the reproducible **GEE + R** workflow for drought ranking, mapping, and visualization.

---

## License
MIT License (see `LICENSE`).
LICENSE (MIT)
MIT License

Copyright (c) 2026 Ahmed Hussein Ismail

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
.gitignore



