# DAX Measures — Power BI Semantic Model

Companion reference for **Task5_Predictive_Analytics_Virtual_Construction.docx**
(Section 6, Step 5). Paste these into the measures table of `Fact_ProjectPeriod`
in Power BI Desktop. Column names assume the schema produced by
`historical_construction_data.csv` / `scored_predictions.csv`.

---

## Core Performance Indices

```dax
Cost Performance Index (CPI) =
DIVIDE ( SUM ( Fact_ProjectPeriod[EarnedValue] ), SUM ( Fact_ProjectPeriod[ActualCostToDate] ) )
```

```dax
Schedule Performance Index (SPI) =
DIVIDE ( SUM ( Fact_ProjectPeriod[EarnedValue] ), SUM ( Fact_ProjectPeriod[PlannedValue] ) )
```

```dax
Avg CPI = AVERAGE ( Fact_ProjectPeriod[CPI] )
Avg SPI = AVERAGE ( Fact_ProjectPeriod[SPI] )
```

## Budget Overrun Measures

```dax
Overrun % (Actual) =
DIVIDE (
    SUM ( Fact_ProjectPeriod[ActualCostToDate] ) - SUM ( Fact_ProjectPeriod[BudgetToDate] ),
    SUM ( Fact_ProjectPeriod[BudgetToDate] )
)
```

```dax
Predicted Overrun Probability =
AVERAGE ( Fact_ProjectPeriod[Predicted_OverrunProbability] )
```

```dax
Overrun Risk Band =
VAR p = [Predicted Overrun Probability]
RETURN
    SWITCH (
        TRUE (),
        p >= 0.70, "High Risk",
        p >= 0.40, "Watch",
        "Low Risk"
    )
```

## Schedule Delay Measures

```dax
% Float Consumed = AVERAGE ( Fact_ProjectPeriod[PctFloatConsumed] )

Predicted Delay Probability =
AVERAGE ( Fact_ProjectPeriod[Predicted_DelayProbability] )

Delay Risk Flag =
IF ( [Predicted Delay Probability] >= 0.5, "At Risk", "On Track" )
```

## Resource Demand Measures

```dax
Rolling 4-Week Labour Hours (Actual) =
CALCULATE (
    SUM ( Fact_ProjectPeriod[LabourHoursActual] ),
    DATESINPERIOD ( Dim_Date[Date], MAX ( Dim_Date[Date] ), -4, WEEK )
)

Forecast Variance % =
DIVIDE (
    SUM ( Fact_ProjectPeriod[LabourHoursActual] ) - SUM ( Fact_ProjectPeriod[LabourHoursPlanned] ),
    SUM ( Fact_ProjectPeriod[LabourHoursPlanned] )
)
```

## Change Order / Procurement Measures

```dax
Change Order Rate % = AVERAGE ( Fact_ProjectPeriod[ChangeOrderRatePct] )

Weather Delay Days (Cumulative) =
CALCULATE (
    SUM ( Fact_ProjectPeriod[WeatherDelayDays] ),
    FILTER ( ALL ( Dim_Date[Date] ), Dim_Date[Date] <= MAX ( Dim_Date[Date] ) )
)
```

---

### Notes
- All measures assume `Predicted_OverrunProbability` and `Predicted_DelayProbability`
  are loaded from `scored_predictions.csv` (see `predictive_models.py`) via
  Power Query, joined into `Fact_ProjectPeriod` on `ProjectID` + `WeekNo`.
- Risk-band measures (`Overrun Risk Band`, `Delay Risk Flag`) drive the
  conditional formatting and Power BI data-driven alerts described in
  Section 6, Step 7 of the main report.
