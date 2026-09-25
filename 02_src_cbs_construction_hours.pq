// =====================================================================
// Query name to use in Power BI:  src_cbs_construction_hours
// Source: Statistics Netherlands (CBS) Open Data StatLine — OData v3
// Table: 81158eng — "Construction industry; productive hours in
//        construction of buildings" (quarterly, CC-BY 4.0)
// Landing page: https://opendata.cbs.nl/statline/portal.html?_la=en&_catalog=CBS&tableId=81158eng
//
// IMPORTANT: CBS measure-column names are auto-generated codes (e.g.
// "ProductiveHoursPerEmployee_1") that can change between table revisions.
// After the first load, run:  = Table.ColumnNames(Source)  in a blank
// query to confirm the exact measure column name, then adjust the
// #"Renamed" step below to match.
// =====================================================================

let
    Source          = OData.Feed("https://opendata.cbs.nl/ODataApi/OData/81158eng/TypedDataSet"),
    #"Changed Type" = Table.TransformColumnTypes(Source, {{"Perioden", type text}}),

    // Perioden values look like "2023KW01" (quarter) or "2023JJ00" (year) — keep quarters only
    #"Filtered Quarters" = Table.SelectRows(#"Changed Type", each Text.Contains([Perioden], "KW")),

    #"Added Year" = Table.AddColumn(#"Filtered Quarters", "Year",
        each Number.FromText(Text.Start([Perioden], 4)), Int64.Type),
    #"Added Quarter" = Table.AddColumn(#"Added Year", "Quarter",
        each Number.FromText(Text.End([Perioden], 2)), Int64.Type),
    #"Added Date" = Table.AddColumn(#"Added Quarter", "Date",
        each #date([Year], ([Quarter] - 1) * 3 + 1, 1), type date),

    #"Renamed" = Table.RenameColumns(#"Added Date",
        {{"ProductiveHoursPerEmployee_1", "ProductiveHoursPerEmployee"}}, MissingField.Ignore),

    #"Final Columns" = Table.SelectColumns(#"Renamed",
        {"Date", "Year", "Quarter", "ProductiveHoursPerEmployee"}, MissingField.UseNull)
in
    #"Final Columns"
