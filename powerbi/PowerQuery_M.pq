// Replace ProjectRoot with the absolute local path to the project's data/raw folder.
let
    ProjectRoot = "C:\\PATH\\TO\\AI-Usage-Cost-and-Business-ROI-Analytics\\data\\raw\\",
    LoadCsv = (FileName as text) as table => Csv.Document(File.Contents(ProjectRoot & FileName), [Delimiter=",", Encoding=65001, QuoteStyle=QuoteStyle.Csv]),
    Promote = (FileName as text) as table => Table.PromoteHeaders(LoadCsv(FileName), [PromoteAllScalars=true]),
    UsageRaw = Promote("fact_ai_usage.csv"),
    UsageTypes = Table.TransformColumnTypes(UsageRaw, {{"request_id", type text},{"request_timestamp", type datetime},{"task_id", type text},{"team_id", type text},{"model_id", type text},{"input_tokens", Int64.Type},{"output_tokens", Int64.Type},{"cached_input_tokens", Int64.Type},{"total_cost_usd", type number},{"total_cost_inr", type number},{"latency_seconds", type number}}),
    OutcomesRaw = Promote("fact_work_outcome.csv"),
    OutcomesTypes = Table.TransformColumnTypes(OutcomesRaw, {{"task_id", type text},{"task_date", type date},{"team_id", type text},{"ai_assisted", Int64.Type},{"baseline_minutes", type number},{"actual_minutes", type number},{"rework_minutes", type number},{"quality_score", type number},{"accepted", Int64.Type}}),
    TeamsRaw = Promote("dim_team.csv"),
    TeamsTypes = Table.TransformColumnTypes(TeamsRaw, {{"team_id", type text},{"team_name", type text},{"loaded_labor_rate_inr_per_hour", type number}}),
    ModelsRaw = Promote("dim_model_pricing.csv"),
    ModelsTypes = Table.TransformColumnTypes(ModelsRaw, {{"model_id", type text},{"input_price_usd_per_million", type number},{"output_price_usd_per_million", type number},{"cached_input_price_usd_per_million", type number}}),
    DatesRaw = Promote("dim_date.csv"),
    DatesTypes = Table.TransformColumnTypes(DatesRaw, {{"date_key", type date},{"date", type date},{"year", Int64.Type},{"month_number", Int64.Type},{"week_number", Int64.Type}})
in
    [FactAIUsage=UsageTypes, FactWorkOutcome=OutcomesTypes, DimTeam=TeamsTypes, DimModelPricing=ModelsTypes, DimDate=DatesTypes]
