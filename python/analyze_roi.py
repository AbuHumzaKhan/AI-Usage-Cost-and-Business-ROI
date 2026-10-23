from pathlib import Path
import pandas as pd

ROOT = Path(__file__).resolve().parents[1]
DATA = ROOT / "data" / "raw"
OUT = ROOT / "outputs"
OUT.mkdir(exist_ok=True)
usage = pd.read_csv(DATA / "fact_ai_usage.csv")
outcomes = pd.read_csv(DATA / "fact_work_outcome.csv")
teams = pd.read_csv(DATA / "dim_team.csv")

# Roll request-grain spend up to task grain before joining outcomes.
by_task = usage.groupby("task_id", as_index=False).agg(
    ai_cost_inr=("total_cost_inr", "sum"),
    request_count=("request_id", "count"),
    input_tokens=("input_tokens", "sum"),
    output_tokens=("output_tokens", "sum"),
)
analysis = outcomes.merge(by_task, on="task_id", how="left", validate="one_to_one").merge(
    teams[["team_id", "team_name", "primary_output", "loaded_labor_rate_inr_per_hour"]],
    on="team_id", how="left", validate="many_to_one",
)
for col in ["ai_cost_inr", "request_count", "input_tokens", "output_tokens"]:
    analysis[col] = analysis[col].fillna(0)
analysis["gross_minutes_saved"] = analysis["baseline_minutes"] - analysis["actual_minutes"]
analysis["net_minutes_saved_after_rework"] = analysis["gross_minutes_saved"] - analysis["rework_minutes"]
analysis["capacity_value_inr"] = (
    analysis["net_minutes_saved_after_rework"].clip(lower=0) / 60
    * analysis["loaded_labor_rate_inr_per_hour"]
)
analysis["net_benefit_inr"] = analysis["capacity_value_inr"] - analysis["ai_cost_inr"]
analysis["accepted_ai_output"] = ((analysis["ai_assisted"] == 1) & (analysis["accepted"] == 1)).astype(int)
summary = analysis.groupby(["team_name", "primary_output"], as_index=False).agg(
    tasks=("task_id", "count"), ai_assisted_tasks=("ai_assisted", "sum"),
    accepted_outputs=("accepted", "sum"), accepted_ai_outputs=("accepted_ai_output", "sum"),
    ai_cost_inr=("ai_cost_inr", "sum"), gross_minutes_saved=("gross_minutes_saved", "sum"),
    net_minutes_saved=("net_minutes_saved_after_rework", "sum"),
    capacity_value_inr=("capacity_value_inr", "sum"), net_benefit_inr=("net_benefit_inr", "sum"),
    avg_quality=("quality_score", "mean"), request_count=("request_count", "sum"),
)
summary["cost_per_accepted_ai_output_inr"] = summary["ai_cost_inr"] / summary["accepted_ai_outputs"].replace(0, pd.NA)
summary["roi_pct"] = summary["net_benefit_inr"] / summary["ai_cost_inr"].replace(0, pd.NA) * 100
summary["adoption_rate"] = summary["ai_assisted_tasks"] / summary["tasks"]
summary.to_csv(OUT / "team_roi_summary.csv", index=False)

# Basic checks are also covered in tests/test_data_quality.py.
assert usage["request_id"].is_unique
assert outcomes["task_id"].is_unique
assert usage["task_id"].isin(outcomes["task_id"]).all()
assert (usage["cached_input_tokens"] <= usage["input_tokens"]).all()
assert (usage["total_cost_inr"] >= 0).all()
print(f"Validated {len(usage):,} AI requests and {len(outcomes):,} work outcomes.")
print(summary[["team_name", "ai_cost_inr", "cost_per_accepted_ai_output_inr", "net_benefit_inr", "avg_quality"]].round(2).to_string(index=False))
