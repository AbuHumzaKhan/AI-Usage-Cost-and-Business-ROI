# Power BI Build Guide

## Import and model
1. Open Power BI Desktop and choose **Get data → Blank query** (or Text/CSV for each source).
2. Use `powerbi/PowerQuery_M.pq`; replace `C:\\PATH\\TO\\...` with the local project path.
3. Load `FactAIUsage`, `FactWorkOutcome`, `DimTeam`, `DimModelPricing`, and `DimDate`. Optionally load `DimTaskType`.
4. Create relationships: `DimTeam[team_id]` 1:* to both facts; `FactWorkOutcome[task_id]` 1:* to `FactAIUsage[task_id]`; `DimDate[date_key]` 1:* to `FactWorkOutcome[task_date]`; `DimModelPricing[model_id]` 1:* to `FactAIUsage[model_id]`. Use single-direction filters from dimensions.
5. Keep task-to-request one-to-many. Do not merge request rows directly into the task table and then sum task-level minutes or benefit.
6. Add measures from `powerbi/DAX_Measures.dax`; create them individually if necessary.

## Report pages
- **Executive Overview:** total AI cost, estimated net benefit, estimated ROI, adoption rate, positive net hours saved, monthly cost trend and net benefit by team.
- **Team ROI:** cost, accepted outputs, cost per accepted AI-assisted output, net hours saved, estimated capacity value, net benefit, quality and adoption.
- **Token & Model Economics:** cost by model/provider, token mix, latency and request failure rate.
- **Productivity & Quality:** AI-assisted vs non-AI tasks by team, minutes saved, acceptance, quality and rework. Flag the data as synthetic and observational.
- **Request Audit:** request ID, task ID, timestamp, team, model, tokens, costs, latency and status.

## Slicers
Date, team, model/provider, task type, AI-assisted flag and request status.

## Design
Use a restrained executive theme, clear INR labels, percent formatting and explicit **Estimated** labels for capacity value and ROI. Avoid mixing USD and INR without labels.

## Limitations
This project supplies data, Power Query M, DAX and a build guide, not a native `.pbix`. Assemble and save the report in Power BI Desktop, then verify relationships and totals.
