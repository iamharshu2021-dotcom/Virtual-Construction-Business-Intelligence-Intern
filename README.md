# Power Query (M) Scripts — Construction Metrics Data Pipeline

Real, working Power Query M code implementing the sourcing → import →
cleansing → transformation pipeline described in the Week 2 report, with
no proprietary datasets — only public government/open-data sources.

## Files

| File | Query name to use | Type | External dependency |
|---|---|---|---|
| `01_src_bls_construction_employment.pq` | `src_bls_construction_employment` | Source | Live API call (no key required) |
| `02_src_cbs_construction_hours.pq` | `src_cbs_construction_hours` | Source | Live OData feed (no key required) |
| `03_src_census_construction_spending.pq` | `src_census_construction_spending` | Source | Local folder of downloaded CSV/XLSX releases |
| `04_src_fpds_construction_contracts.pq` | `src_fpds_construction_contracts` | Source | Local CSV (downloaded extract) |
| `05_dim_date.pq` | `dim_date` | Dimension | None — fully self-contained |
| `06_dim_construction_type.pq` | `dim_construction_type` | Dimension | None — fully self-contained |
| `07_dim_region.pq` | `dim_region` | Dimension | None — fully self-contained |
| `08_fact_construction_metrics.pq` | `fact_construction_metrics` | Fact | References queries 01, 02, 07 |

## How to load each one into Power BI Desktop

1. Open Power BI Desktop → **Home → Transform Data** to open Power Query Editor.
2. Right-click in the **Queries** pane → **New Query → Blank Query**.
3. Right-click the new blank query → **Advanced Editor**.
4. Delete the placeholder code, paste the full contents of one `.pq` file, click **Done**.
5. Rename the query (double-click it in the Queries pane) to match the **Query name** column above — the fact query references the source/dimension queries **by that exact name**, so naming must match.
6. Repeat for all 8 files, in this order: `05 → 06 → 07 → 01 → 02 → 03 → 04 → 08` (dimensions and independent sources first, so `08` finds them already defined when you paste it).
7. For files `03` and `04`, edit the `FolderPath` / `FilePath` variable near the top to point at where you saved the downloaded public-data files locally.
8. Click **Close & Apply**. Queries `01`, `02`, `05`, `06`, `07`, `08` will run immediately (no file needed); `03` and `04` will run once their paths are set.

## Notes on live sources

- **BLS (`01`)** — works without an API key at a lower daily request limit. Get a free key at https://data.bls.gov/registrationEngine/ and paste it into the `RegKey` variable to raise the limit.
- **CBS StatLine (`02`)** — the OData feed is public with no key. CBS's auto-generated measure-column name may change between table revisions; the script includes a one-line check (`Table.ColumnNames(Source)`) to confirm it before renaming.
- **Census (`03`) and FPDS-NG (`04`)** — these two are not exposed as simple public APIs, so the realistic pattern is: download the published release file(s) once, then let Power Query's Folder/CSV connector re-import and refresh them automatically on every subsequent open.

## Extending the star schema

`08_fact_construction_metrics.pq` currently demonstrates the merge pattern with two live sources (BLS employment, CBS hours) joined to `dim_region`. The commented block at the end of that file shows exactly how to fold in the Census spending and FPDS-NG contract data (cost and schedule metrics) using the same reshape-then-`Table.Combine`-then-`Table.NestedJoin` pattern, once `03` and `04` are pointed at real local files.
