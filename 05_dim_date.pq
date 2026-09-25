// =====================================================================
// Query name to use in Power BI:  dim_date
// Fully self-contained — no external source. Generates one row per day
// between StartDate and EndDate, plus year/quarter/month attributes
// used to relate every fact table regardless of its native granularity
// (daily, monthly, quarterly).
// =====================================================================

let
    StartDate = #date(2015, 1, 1),
    EndDate   = #date(2027, 12, 31),
    DayCount  = Duration.Days(EndDate - StartDate) + 1,

    DateList  = List.Dates(StartDate, DayCount, #duration(1, 0, 0, 0)),
    #"Converted to Table" = Table.FromList(DateList, Splitter.SplitByNothing(), {"Date"}),
    #"Changed Type" = Table.TransformColumnTypes(#"Converted to Table", {{"Date", type date}}),

    #"Added Year"        = Table.AddColumn(#"Changed Type", "Year", each Date.Year([Date]), Int64.Type),
    #"Added Quarter"     = Table.AddColumn(#"Added Year", "Quarter", each Date.QuarterOfYear([Date]), Int64.Type),
    #"Added Month"       = Table.AddColumn(#"Added Quarter", "MonthNumber", each Date.Month([Date]), Int64.Type),
    #"Added MonthName"   = Table.AddColumn(#"Added Month", "MonthName", each Date.MonthName([Date]), type text),
    #"Added YearMonth"   = Table.AddColumn(#"Added MonthName", "YearMonth",
        each Number.ToText([Year]) & "-" & Text.PadStart(Number.ToText([MonthNumber]), 2, "0"), type text),
    #"Added YearQuarter" = Table.AddColumn(#"Added YearMonth", "YearQuarter",
        each Number.ToText([Year]) & "-Q" & Number.ToText([Quarter]), type text),
    #"Added DateKey"     = Table.AddColumn(#"Added YearQuarter", "DateKey",
        each Date.ToText([Date], "yyyyMMdd"), type text)
in
    #"Added DateKey"
