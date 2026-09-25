// =====================================================================
// Query name to use in Power BI:  dim_construction_type
// Fully self-contained. Maps each source's own category labels onto one
// shared classification, so slicers and relationships do not silently
// split one real-world category into several. Extend the rows as new
// source-label variants are discovered during load.
// =====================================================================

let
    Source = Table.FromRows(
        {
            {"Residential",        "Residential",     "residential"},
            {"Non-Residential",    "Non-Residential", "non-residential"},
            {"Non-residential",    "Non-Residential", "non-residential"},
            {"Nonresidential",     "Non-Residential", "non-residential"},
            {"Civil",              "Civil / Infrastructure", "civil"},
            {"Infrastructure",     "Civil / Infrastructure", "civil"},
            {"Heavy Construction", "Civil / Infrastructure", "civil"},
            {"Institutional",      "Institutional & Commercial", "institutional-commercial"},
            {"Commercial",         "Institutional & Commercial", "institutional-commercial"},
            {"Repair & Maintenance","Repair & Maintenance", "repair-maintenance"}
        },
        {"SourceLabel", "StandardCategory", "CategoryKey"}
    ),
    #"Changed Type" = Table.TransformColumnTypes(Source,
        {{"SourceLabel", type text}, {"StandardCategory", type text}, {"CategoryKey", type text}})
in
    #"Changed Type"
