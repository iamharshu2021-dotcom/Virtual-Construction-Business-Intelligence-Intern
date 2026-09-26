# Task 4 — Interactive Power BI Dashboard Design for Construction Analytics

Dashboard design blueprint for a virtual construction business, built on the star-schema data
model and DAX measures from **Task 3 — Advanced Data Model & DAX Calculations**. This task does
not build the live Power BI file; it delivers the complete, ready-to-implement design: which
metrics to visualize, a three-page storyboard, and the interactivity plan.

## Contents

| File | Description |
|---|---|
| `Dashboard_Design_Document.docx` | The full design document: objective, KPI conceptualization table, page-by-page storyboard (with embedded mockups), interactivity plan, visual-component specification, business narrative, and review/reflection. |
| `Dashboard_Narrative.md` | Plain-text version of the "how this dashboard serves the business" narrative, for quick reading on GitHub. |
| `mockups/page1_executive_overview.png` (+ `.svg`) | Storyboard for the landing page — portfolio KPIs, S-curve, cost variance by project, site map, project table. |
| `mockups/page2_cost_schedule_performance.png` (+ `.svg`) | Storyboard for the cost/schedule deep-dive — reached via drill-through from Page 1. |
| `mockups/page3_resource_management.png` (+ `.svg`) | Storyboard for the resource-planning page — utilization heatmap, resource table, allocation KPIs. |

## How this builds on Task 3

Every visual on every page is bound to a named measure or table from the Task 3 model (star
schema: `DimProject`, `DimTask`, `DimResource`, `DimBudgetCategory`, `DimDate` +
`FactCost`, `FactResourceAllocation`, `FactProjectProgress`; measures: Cost Variance %,
Cost/Schedule Performance Index, Cumulative Actual Cost, Estimate at Completion, Forecasted
Completion Date, Resource Utilization Rate). See that task's report and `DAX_Measures.dax` for
the underlying formulas.

## Dashboard structure

1. **Executive Overview** — single-screen portfolio health check for a ~30-second read.
2. **Cost & Schedule Performance** — project-level root-cause and forecast view.
3. **Resource Management** — crew/equipment utilization and allocation view.

Slicers (Project, Date Range, Task Status, Category, Resource Type) are synced across all three
pages; drill-through connects Page 1 to Page 2, and both the WBS task table and resource table
support drill-down to a finer grain.

## Note on the mockups

The `mockups/` images are storyboard-fidelity wireframes (layout, hierarchy, and interactivity
intent) generated for this design phase — not screenshots of a built Power BI report. Building
the live `.pbix` file from this blueprint is the next step once site-coordinate data is added to
`DimProject` for the map visuals.
