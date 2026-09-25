// =====================================================================
// Query name to use in Power BI:  dim_region
// Fully self-contained. Bridges country/region labels used by different
// publishers (US Census, BLS, ONS, CBS) onto one shared geography key.
// Add rows as new source regions are onboarded.
// =====================================================================

let
    Source = Table.FromRows(
        {
            {"US",  "United States",  "North America"},
            {"UK",  "United Kingdom", "Europe"},
            {"NL",  "Netherlands",    "Europe"}
        },
        {"RegionCode", "RegionName", "Continent"}
    ),
    #"Changed Type" = Table.TransformColumnTypes(Source,
        {{"RegionCode", type text}, {"RegionName", type text}, {"Continent", type text}})
in
    #"Changed Type"
