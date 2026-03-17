# Rent & Homelessness in Washington State (2015–2024)

**Are rising rent prices associated with increased homelessness in Washington State?**

This project analyzes the relationship between housing costs and homelessness across Washington State from 2015 to 2024, using Zillow's Observed Rent Index (ZORI) and HUD's annual Point-in-Time (PIT) homeless counts.

> University of Washington Bothell — Data Analysis Project  
> Authors: Alisa Seng Chea, Duke Sarankhuu, Tarang Jammalamadaka

---

## Key Findings

- **Both rent and homelessness rose ~60%** between 2015 and 2024, suggesting a strong positive association between housing costs and housing instability
- **2024 reached all-time highs** for both average rent (~$1,650/mo) and total homelessness (31,554 individuals)
- **2021 is a notable outlier** — homelessness dropped sharply to 11,511 despite rising rent, attributable to COVID-19 eviction moratoriums and federal emergency rental assistance
- **Correlation coefficient: r ≈ 0.78** (all years); **r ≈ 0.97** excluding the 2021 outlier — a strong positive relationship

---

## Visualizations

### Chart 1 — Average Monthly Rent (2015–2024)
![Chart 1](output/chart1_avg_rent.png)

### Chart 2 — Total Homelessness (2015–2024)
![Chart 2](output/chart2_homelessness.png)

### Chart 3 — Rent vs. Homelessness Scatter (Key Chart)
![Chart 3](output/chart3_rent_vs_homelessness.png)

> Each point represents one year. The dashed trend line shows a clear upward relationship between rent and homelessness. 2021 stands out below the trend due to COVID-era housing protections.

---

## Data Sources

| Dataset | Source | Link |
|---|---|---|
| Zillow Observed Rent Index (ZORI) | Zillow Research | [zillow.com/research/data](https://www.zillow.com/research/data/) |
| Point-in-Time Estimates by State | U.S. Dept. of Housing & Urban Development (HUD) | [hudexchange.info](https://www.hudexchange.info/resource/3031/pit-and-hic-data-since-2007/) |

---

## Project Structure

```
wa-housing-homelessness/
│
├── data/
│   ├── zillow_rent_index_wa.csv       # Zillow ZORI — all metros (wide format)
│   └── hud_pit_wa_2015_2024.csv       # HUD PIT counts for Washington State
│
├── scripts/
│   └── analysis.R                     # Full R analysis: cleaning, merging, charts
│
├── output/
│   ├── chart1_avg_rent.png
│   ├── chart2_homelessness.png
│   └── chart3_rent_vs_homelessness.png
│
└── README.md
```

---

## How to Run

**Requirements:** R 4.0+ with the following packages:
```r
install.packages(c("tidyverse", "readr", "ggplot2", "scales"))
```

**Run the analysis:**
```r
setwd("wa-housing-homelessness")
source("scripts/analysis.R")
```

Charts will be saved to the `output/` folder. Console output will print the correlation stats and key findings.

---

## Methodology Notes

- **Rent data**: Monthly ZORI values for all Washington State metros were averaged by year to produce a single statewide annual figure
- **Homelessness data**: HUD PIT counts represent a single-night count conducted each January — they are an undercount by design but are the most consistent longitudinal measure available
- **Causation caveat**: This analysis identifies a correlation, not causation. Homelessness is driven by multiple factors including mental health, substance use, and policy. Rising rent is one contributing pressure

---

## Additional References

- Rental Housing Association of Washington. COVID-19 Resources. https://www.rhawa.org/covid-19  
- U.S. Department of the Treasury. Emergency Rental Assistance Program. https://home.treasury.gov/policy-issues/coronavirus/assistance-for-state-local-and-tribal-governments/emergency-rental-assistance-program
