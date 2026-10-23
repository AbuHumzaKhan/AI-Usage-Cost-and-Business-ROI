# AI Usage, Token Cost & Business ROI Analytics

**Portfolio Project 03 | Excel, SQL, Python and Power BI**

## Why this project
AI usage reports often stop at request counts and token spend. That does not answer the business question: what work did the spend support, and was the result worth the cost?

This project links synthetic AI requests to business tasks, then compares usage cost with task acceptance, quality, rework and estimated time saved. It covers six teams with different outputs: Research, Development, Customer Support, Marketing, Operations and Finance.

## What is included
- Relational schema and seven SQLite analysis queries
- Python analysis script and data-quality tests
- Excel workbook for reconciliation and PivotTable analysis
- Power Query M, DAX measures and a Power BI report build guide
- Synthetic source tables, a loaded SQLite database, team summaries and QA results

## Repository layout
```text
data/                  Synthetic CSVs and loaded SQLite database
docs/                  Data dictionary, metric definitions and Power BI guide
excel/                 Excel analysis workbook
outputs/               Team summary and QA results
powerbi/               Power Query M and DAX measures
python/                Reproducible analysis script
sql/                   Schema and analysis queries
tests/                 Data-quality unit tests
```

## Run the analysis
Use Python 3.10 or later.

```bash
python -m pip install -r requirements.txt
python python/analyze_roi.py
python -m unittest discover -s tests -v
```

The SQLite database is already loaded. Open it with any SQLite-compatible tool and run the queries in `sql/analysis_queries.sql`.

## Start with Excel
Open `excel/AI_Usage_ROI_Analysis.xlsx`. Begin with `Read_Me` and `QA_Checks`, then review the request-level usage and task-level outcome sheets. Build PivotTables for spend by team/model/month and cost per accepted AI-assisted output. Reconcile results with `outputs/team_roi_summary.csv`.

## Build the Power BI report
Follow `docs/POWER_BI_BUILD_GUIDE.md`, update the local CSV folder path in `powerbi/PowerQuery_M.pq`, create the relationships, and add the measures from `powerbi/DAX_Measures.dax`.

A native `.pbix` file is not included. The report still needs to be assembled and saved in Power BI Desktop.

## Metric logic
1. Calculate token and allocated tool costs at AI-request grain.
2. Aggregate request costs to task grain before joining task outcomes. This avoids multiplying business value when a task has multiple AI requests.
3. Compare baseline minutes with actual minutes, then subtract rework.
4. Estimate capacity value from positive net minutes saved and a team-specific loaded labor rate.
5. Compare estimated capacity value with AI usage cost, while tracking quality and acceptance as guardrails.

## Read the results carefully
- **All data is synthetic.** These records are generated for this portfolio project; they are not real employee activity, provider invoices or customer records.
- Model names, pricing and the fixed ₹83.50/USD conversion are illustrative assumptions, not current vendor rates.
- Capacity value is not the same as cash savings. It becomes realized value only when released time translates into measurable throughput, lower overtime or contractor spend, avoided hiring, or another evidenced benefit.
- The AI-assisted and non-AI groups are synthetic and observational. They do not establish causal impact.
- Subscription, integration, security, legal, training, human review and maintenance costs are not fully represented. Add them before using this method for an actual investment decision.
- Outputs differ by team. Cost per support ticket, for example, should not be treated as directly equivalent to cost per research brief.

## Suggested next step for a real deployment
Connect provider billing exports to approved task or ticket identifiers, validate each team's accepted-output definition with its business owner, and report realized benefits separately from estimated capacity value. Apply privacy and retention controls before storing request-level records.

## Credits
- Created by: Abu Humza Khan
- GitHub: https://github.com/AbuHumzaKhan
- LinkedIn: https://www.linkedin.com/in/abu-humza-khan/
- Source: ChatGPT
- Design Idea: ChatGPT
