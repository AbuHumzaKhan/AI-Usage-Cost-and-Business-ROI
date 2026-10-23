# Data Dictionary

All data are synthetic, generated with seed `20261023`, with task dates from 2026-04-01 to 2026-09-30. FX is fixed at 83.5 INR per USD for reproducibility.

## `fact_ai_usage.csv` — request grain

| Field | Meaning |
|---|---|
| request_id | Unique synthetic AI request ID |
| request_timestamp | Synthetic timestamp; no timezone implied |
| task_id | Parent business task; multiple requests can map to one task |
| team_id, model_id | Team and model keys |
| task_type | Work category |
| input_tokens, output_tokens | Tokens per request |
| cached_input_tokens | Cached subset of input tokens; cannot exceed input tokens |
| tool_cost_usd | Synthetic allocated tool/infrastructure cost |
| request_status | success or failed |
| latency_seconds | Synthetic request latency |
| usd_inr_fx | Fixed illustrative USD/INR rate (83.5) |
| api_cost_usd | Token cost from synthetic model pricing |
| total_cost_usd | API token cost plus allocated tool cost |
| total_cost_inr | Total request cost converted to INR |

## `fact_work_outcome.csv` — task grain

| Field | Meaning |
|---|---|
| task_id | Unique synthetic work task |
| task_date | Task date |
| team_id, task_type | Team and category |
| ai_assisted | 1 if AI was used, otherwise 0 |
| tasks_completed | One row represents one task |
| baseline_minutes | Estimated minutes without AI |
| actual_minutes | Observed synthetic task minutes |
| rework_minutes | Synthetic rework time |
| quality_score | Score from 0 to 1 |
| accepted | 1 if the output passed its synthetic acceptance rule |
| business_output | Team-specific output label |

## Dimensions
- `dim_team.csv`: team names, output labels, primary KPI and synthetic loaded labor cost/hour.
- `dim_model_pricing.csv`: illustrative provider/model prices and effective dates.
- `dim_date.csv`: calendar attributes from 2026-04-01 to 2026-09-30.
- `dim_task_type.csv`: task types and owning team.

## Metric definitions
- **AI cost:** sum of `total_cost_inr` at request grain.
- **Cost per accepted AI-assisted output:** AI usage cost allocated to tasks divided by accepted outputs among AI-assisted tasks. Also report the accepted-output count.
- **Gross time saved:** baseline minutes minus actual minutes.
- **Net time saved:** gross time saved minus rework minutes.
- **Estimated capacity value:** positive net minutes saved / 60 × team loaded labor rate. This is capacity value, not realized cash savings.
- **Estimated net benefit:** estimated capacity value minus AI usage/tool costs; excludes unmodeled implementation and ongoing costs.
- **Estimated ROI:** estimated net benefit / AI cost. Treat as directional, not fully loaded financial ROI.
