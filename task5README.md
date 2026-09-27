# Task 5 — Predictive Analytics in Virtual Construction (Power BI)

This repo contains the full deliverable for the Week 5 task: *Implementing
Predictive Analytics in Virtual Construction*.

## Contents

| File | Description |
|---|---|
| `Task5_Predictive_Analytics_Virtual_Construction.docx` | Main report — methodology, algorithm selection, Power BI integration workflow, business impact & risk mitigation. |
| `historical_construction_data.csv` | Synthetic sample dataset (25 projects, weekly grain) matching the star-schema described in the report. Use this to test the pipeline or as a Power BI sample source. |
| `predictive_models.py` | Python script that trains the models described in the report: regression + classification for budget overrun, Random Forest for schedule delay, exponential smoothing for resource-demand forecasting. Outputs `scored_predictions.csv`. |
| `dax_measures.md` | DAX measures for the Power BI semantic model (CPI, SPI, overrun probability, delay risk, rolling resource demand, etc.). |

## How to reproduce

```bash
pip install pandas numpy scikit-learn statsmodels
python predictive_models.py
```

This produces `scored_predictions.csv` — connect Power BI's Power Query to
this file (or to the equivalent table in your Azure SQL / Data Lake source)
and load the DAX measures from `dax_measures.md` to complete the semantic
model described in Section 6 of the report.

## Data dictionary (historical_construction_data.csv)

| Column | Meaning |
|---|---|
| ProjectID | Unique project key |
| ProjectType | Commercial / Residential / Infrastructure / Industrial |
| Region | North / South / East / West |
| WeekNo | Week index since project start |
| PctComplete | % schedule complete |
| OriginalBudget | Approved budget (project total) |
| ActualCostToDate | Cumulative actual cost |
| CPI / SPI | Cost / Schedule Performance Index |
| PctFloatConsumed | % of schedule float used |
| ChangeOrderRatePct | Change-order rate (%) |
| WeatherDelayDays | Cumulative weather delay days |
| ProcurementLeadVarianceDays | Procurement lead-time variance |
| ClashCount | BIM clash-detection count |
| LabourHoursPlanned / Actual | Weekly labour hours |
| OverrunPct / OverrunFlag | Budget overrun target (regression / classification) |
| DelayFlag | Schedule delay target (classification) |
