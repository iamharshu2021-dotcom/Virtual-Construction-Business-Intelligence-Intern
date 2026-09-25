// =====================================================================
// Query name to use in Power BI:  src_census_construction_spending
// Source: U.S. Census Bureau — Construction Spending (Value of
//         Construction Put in Place), Survey C30.
// Release page: https://www.census.gov/construction/c30/c30index.html
// Download the monthly CSV/XLSX releases into one local folder, then
// point FolderPath below at that folder. Each file is combined
// automatically — no need to import releases one by one.
// =====================================================================

let
    FolderPath = "C:\ConstructionBI\Sources\CensusSpending\",  // <-- set to your local folder

    Source          = Folder.Files(FolderPath),
    #"Filtered CSV" = Table.SelectRows(Source, each Text.EndsWith([Name], ".csv")),
    #"Added Custom" = Table.AddColumn(#"Filtered CSV", "ParsedCsv",
        each Csv.Document([Content], [Delimiter = ",", Encoding = 1252, QuoteStyle = QuoteStyle.Csv])),

    #"Removed Other Columns" = Table.SelectColumns(#"Added Custom", {"Name", "ParsedCsv"}),
    #"Expanded ParsedCsv" = Table.ExpandTableColumn(#"Removed Other Columns", "ParsedCsv",
        {"Column1", "Column2", "Column3", "Column4"},
        {"Period", "Segment", "ValuePutInPlace_USD_Millions", "SeasonallyAdjusted"}),

    // First row of each Census CSV release is usually a header row — remove it, then set types
    #"Filtered Header Rows" = Table.SelectRows(#"Expanded ParsedCsv", each [Period] <> "Period"),
    #"Changed Type" = Table.TransformColumnTypes(#"Filtered Header Rows",
        {{"Period", type text}, {"Segment", type text},
         {"ValuePutInPlace_USD_Millions", type number}, {"SeasonallyAdjusted", type text}}),

    #"Added Date" = Table.AddColumn(#"Changed Type", "Date",
        each Date.FromText([Period]), type date),

    #"Final Columns" = Table.SelectColumns(#"Added Date",
        {"Date", "Segment", "ValuePutInPlace_USD_Millions", "SeasonallyAdjusted", "Name"})
in
    #"Final Columns"

// -----------------------------------------------------------------------
// If you prefer a single downloaded workbook instead of a folder of CSVs,
// replace the Source/steps above with the Excel pattern below:
//
// let
//     Source    = Excel.Workbook(File.Contents("C:\ConstructionBI\Sources\c30_latest.xlsx"), null, true),
//     DataSheet = Source{[Item = "Value_of_Construction", Kind = "Sheet"]}[Data],
//     #"Promoted Headers" = Table.PromoteHeaders(DataSheet, [PromoteAllScalars = true])
// in
//     #"Promoted Headers"
// -----------------------------------------------------------------------
