// =====================================================================
// Query name to use in Power BI:  src_bls_construction_employment
// Source: U.S. Bureau of Labor Statistics — Public Data API v2
// Series used: CES2000000001 = "All Employees, Construction" (thousands, SA)
// Docs: https://www.bls.gov/developers/api_signature_v2.htm
// Note: works without a key (limited to 25 requests/day, 10 yrs of data).
// If you have a free BLS registration key, paste it into RegKey below
// to raise the daily limit — the query still works with RegKey = "".
// =====================================================================

let
    SeriesId   = "CES2000000001",
    StartYear  = "2015",
    EndYear    = "2026",
    RegKey     = "",   // optional: paste your BLS API key here

    KeyParam   = if RegKey = "" then "" else "&registrationkey=" & RegKey,
    Url        = "https://api.bls.gov/publicAPI/v2/timeseries/data/"
                 & SeriesId
                 & "?startyear=" & StartYear
                 & "&endyear=" & EndYear
                 & KeyParam,

    Source     = Json.Document(Web.Contents(Url)),
    Results    = Source[Results],
    SeriesList = Results[series],
    FirstSeries = SeriesList{0},
    DataRows   = FirstSeries[data],

    ToTable    = Table.FromList(DataRows, Splitter.SplitByNothing(), null, null, ExtraValues.Error),
    Expanded   = Table.ExpandRecordColumn(ToTable, "Column1",
                    {"year", "period", "periodName", "value", "footnotes"},
                    {"Year", "Period", "PeriodName", "Value", "Footnotes"}),

    #"Changed Type" = Table.TransformColumnTypes(Expanded,
        {{"Year", Int64.Type}, {"Period", type text}, {"PeriodName", type text}, {"Value", type number}}),

    // Keep monthly periods only (Period like "M01".."M12"), drop annual-average "M13"
    #"Filtered Months" = Table.SelectRows(#"Changed Type", each Text.StartsWith([Period], "M") and [Period] <> "M13"),

    #"Added Month Number" = Table.AddColumn(#"Filtered Months", "MonthNumber",
        each Number.FromText(Text.AfterDelimiter([Period], "M")), Int64.Type),

    #"Added Date" = Table.AddColumn(#"Added Month Number", "Date",
        each #date([Year], [MonthNumber], 1), type date),

    #"Renamed" = Table.RenameColumns(#"Added Date", {{"Value", "EmploymentThousands"}}),
    #"Added Source Column" = Table.AddColumn(#"Renamed", "SourceSeries", each SeriesId, type text),

    #"Final Columns" = Table.SelectColumns(#"Added Source Column",
        {"Date", "Year", "MonthNumber", "EmploymentThousands", "SourceSeries"})
in
    #"Final Columns"
