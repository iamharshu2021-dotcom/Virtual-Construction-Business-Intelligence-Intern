// =====================================================================
// Query name to use in Power BI:  src_fpds_construction_contracts
// Source: Federal Procurement Data System – Next Generation (FPDS-NG)
//         construction-contracts extract, published as open-access
//         supplementary data with:
//         Stout, T. et al. (2020), "Construction contract data ...",
//         Data in Brief. https://scholar.afit.edu/facpub/650
// Download the CSV extract locally, then point FilePath below at it.
// Columns below follow the fields documented in that publication
// (contract type, construction type, delivery method, award date,
// award value, period of performance); rename to match your exact
// download if column headers differ slightly.
// =====================================================================

let
    FilePath = "C:\ConstructionBI\Sources\fpds_construction_contracts.csv",

    Source = Csv.Document(File.Contents(FilePath),
        [Delimiter = ",", Columns = null, Encoding = 65001, QuoteStyle = QuoteStyle.Csv]),
    #"Promoted Headers" = Table.PromoteHeaders(Source, [PromoteAllScalars = true]),

    #"Changed Type" = Table.TransformColumnTypes(#"Promoted Headers", {
        {"ContractID", type text},
        {"ConstructionType", type text},
        {"DeliveryMethod", type text},
        {"AwardDate", type date},
        {"PeriodOfPerformanceStart", type date},
        {"PeriodOfPerformanceEnd", type date},
        {"AwardValue_USD", type number},
        {"State", type text}
    }),

    #"Added Duration Days" = Table.AddColumn(#"Changed Type", "PlannedDurationDays",
        each Duration.Days([PeriodOfPerformanceEnd] - [PeriodOfPerformanceStart]), Int64.Type),

    #"Filtered Nulls" = Table.SelectRows(#"Added Duration Days", each [AwardValue_USD] <> null),

    #"Final Columns" = Table.SelectColumns(#"Filtered Nulls",
        {"ContractID", "ConstructionType", "DeliveryMethod", "AwardDate",
         "PeriodOfPerformanceStart", "PeriodOfPerformanceEnd",
         "PlannedDurationDays", "AwardValue_USD", "State"})
in
    #"Final Columns"
