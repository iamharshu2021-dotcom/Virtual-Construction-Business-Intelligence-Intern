# Advanced Data Models and DAX Calculations — Virtual Construction Business

Week 3 Task: a Power BI data model design and DAX measure set for a virtual
construction business, relating project timelines, budgets, and resource
allocations, with KPIs for cost variance, cumulative cost, EVM performance,
and predictive project completion.

## Repository contents

| File | Description |
|---|---|
| `Advanced_Data_Model_DAX_Report.docx` | Main deliverable: data model design, ERD, DAX explanations, relationships, assumptions, and reflection. |
| `erd_diagram.png` | Star-schema entity-relationship diagram used in the report. |
| `DAX_Measures.dax` | Every DAX measure from the report as plain text, ready to paste into Power BI Desktop (Modeling > New Measure). |
| `data/DimProject.csv` | Dimension: one row per construction project. |
| `data/DimTask.csv` | Dimension: WBS-level tasks per project. |
| `data/DimResource.csv` | Dimension: labor, equipment, and material resources. |
| `data/DimBudgetCategory.csv` | Dimension: cost category groupings (Labor/Material/Equipment/Overhead/Contingency). |
| `data/DimDate.csv` | Standard calendar table for time intelligence. |
| `data/FactCost.csv` | Fact: budgeted/committed/actual cost transactions. |
| `data/FactResourceAllocation.csv` | Fact: planned vs. actual resource hours. |
| `data/FactProjectProgress.csv` | Fact: planned vs. actual % complete snapshots (feeds Earned Value). |

## How to load this into Power BI Desktop

1. Open Power BI Desktop -> **Get Data** -> **Text/CSV**, and import all eight
   files from the `data/` folder.
2. In **Model view**, create the relationships listed in Section 2.3 of the
   report (all dimension -> fact, single direction, 1-to-many).
3. Mark `DimDate` as a **Date Table** (Table tools -> Mark as Date Table),
   using the `Date` column.
4. Open `DAX_Measures.dax` and paste each measure into
   **Modeling -> New Measure**, one at a time.
5. Build report visuals (matrix, line/S-curve chart, cards) using the
   measures — e.g. `Cumulative Actual Cost` and `Cumulative Budgeted Cost`
   together on a line chart by `DimDate[Date]` produce a cost S-curve.

## KPI summary

- **Cost Variance %** — actual vs. budgeted spend, any slice.
- **Cumulative Actual/Budgeted Cost** — running totals for S-curve reporting.
- **CPI / SPI** — Earned Value Management cost and schedule performance.
- **EAC / Forecasted Completion Date** — predictive cost and schedule forecast.
- **Resource Utilization Rate** — planned vs. actual resource hours.
- **MoM Cost Growth %** — time-intelligence based month-over-month trend.

See `Advanced_Data_Model_DAX_Report.docx` for full explanations, assumptions,
and a strengths/limitations reflection.
