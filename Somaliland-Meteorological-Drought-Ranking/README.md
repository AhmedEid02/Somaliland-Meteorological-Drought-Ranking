# Somaliland Meteorological Drought Ranking (1981–2024) — CHIRPS (Gu MAM & Deyr OND)

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
