// =====================================================================
// Query name to use in Power BI:  fact_construction_metrics
// Combines the source queries (steps 01–04) into one fact table at
// monthly grain, tagged with RegionCode and CategoryKey so it relates
// cleanly to dim_date, dim_region, and dim_construction_type.
//
// PREREQUISITE: load 01–07 as their own queries first (name each query
// exactly as shown at the top of each file), with "Enable Load" turned
// ON only for the ones you want visible in the model — these source
// queries can stay staging-only (Enable Load OFF) if you prefer, since
// this query references them directly.
// =====================================================================

let
    // --- US employment (BLS), reshaped to the common fact grain ---
    Employment = src_bls_construction_employment,
    EmploymentFact = Table.AddColumn(
        Table.AddColumn(Employment, "RegionCode", each "US", type text),
        "MetricName", each "EmploymentThousands", type text
    ),
    EmploymentFact2 = Table.RenameColumns(EmploymentFact, {{"EmploymentThousands", "MetricValue"}}),
    EmploymentFinal = Table.SelectColumns(EmploymentFact2, {"Date", "RegionCode", "MetricName", "MetricValue"}),

    // --- Netherlands productive hours (CBS), reshaped to the common grain ---
    Hours = src_cbs_construction_hours,
    HoursFact = Table.AddColumn(Hours, "RegionCode", each "NL", type text),
    HoursFact2 = Table.AddColumn(HoursFact, "MetricName", each "ProductiveHoursPerEmployee", type text),
    HoursFact3 = Table.RenameColumns(HoursFact2, {{"ProductiveHoursPerEmployee", "MetricValue"}}),
    HoursFinal = Table.SelectColumns(HoursFact3, {"Date", "RegionCode", "MetricName", "MetricValue"}),

    // --- Stack (append) both metric streams — same grain: Date, RegionCode, MetricName, MetricValue ---
    Combined = Table.Combine({EmploymentFinal, HoursFinal}),

    // --- Attach the shared Region dimension (validates RegionCode exists) ---
    #"Merged with Region" = Table.NestedJoin(Combined, {"RegionCode"}, dim_region, {"RegionCode"}, "RegionInfo", JoinKind.LeftOuter),
    #"Expanded Region" = Table.ExpandTableColumn(#"Merged with Region", "RegionInfo", {"RegionName", "Continent"}),

    #"Changed Type" = Table.TransformColumnTypes(#"Expanded Region",
        {{"Date", type date}, {"RegionCode", type text}, {"MetricName", type text},
         {"MetricValue", type number}, {"RegionName", type text}, {"Continent", type text}}
    )
in
    #"Changed Type"

// -----------------------------------------------------------------------
// To add the FPDS-NG contracts (cost + schedule at project grain) and the
// Census spending series (cost at national grain) into the same star
// schema, append them the same way: reshape each source to
// {Date, RegionCode, MetricName, MetricValue[, ConstructionType]}, then
// Table.Combine into `Combined` above, and merge ConstructionType against
// dim_construction_type using the same Table.NestedJoin pattern used for
// dim_region here.
// -----------------------------------------------------------------------
