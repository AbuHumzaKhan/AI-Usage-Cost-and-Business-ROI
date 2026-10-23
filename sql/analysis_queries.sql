-- AI Usage, Token Cost & Business ROI Analytics (SQLite-compatible)
-- One row per AI request in fact_ai_usage; one row per task in fact_work_outcome.

-- 1. Executive overview. Aggregate usage to task grain before joining outcomes.
WITH usage_by_task AS (
 SELECT task_id, SUM(total_cost_inr) AS ai_cost_inr, COUNT(*) AS request_count,
        SUM(input_tokens) AS input_tokens, SUM(output_tokens) AS output_tokens
 FROM fact_ai_usage GROUP BY task_id
), task_value AS (
 SELECT o.*, t.team_name, t.loaded_labor_rate_inr_per_hour,
        COALESCE(u.ai_cost_inr,0) AS ai_cost_inr, COALESCE(u.request_count,0) AS request_count,
        o.baseline_minutes-o.actual_minutes AS gross_minutes_saved,
        (o.baseline_minutes-o.actual_minutes-o.rework_minutes) AS net_minutes_saved
 FROM fact_work_outcome o JOIN dim_team t ON o.team_id=t.team_id
 LEFT JOIN usage_by_task u ON o.task_id=u.task_id
)
SELECT team_name, COUNT(*) AS tasks, SUM(ai_assisted) AS ai_assisted_tasks,
       SUM(ai_cost_inr) AS ai_cost_inr,
       SUM(CASE WHEN net_minutes_saved>0 THEN net_minutes_saved ELSE 0 END)/60.0 AS hours_saved,
       SUM(CASE WHEN net_minutes_saved>0 THEN net_minutes_saved ELSE 0 END)/60.0*loaded_labor_rate_inr_per_hour AS capacity_value_inr,
       SUM(accepted) AS accepted_outputs,
       SUM(CASE WHEN net_minutes_saved>0 THEN net_minutes_saved ELSE 0 END)/60.0*loaded_labor_rate_inr_per_hour-SUM(ai_cost_inr) AS estimated_net_benefit_inr
FROM task_value GROUP BY team_name ORDER BY estimated_net_benefit_inr DESC;

-- 2. Cost per accepted AI-assisted output by team.
WITH usage_by_task AS (SELECT task_id, SUM(total_cost_inr) AS ai_cost_inr FROM fact_ai_usage GROUP BY task_id)
SELECT t.team_name, o.business_output, SUM(COALESCE(u.ai_cost_inr,0)) AS ai_cost_inr,
       SUM(CASE WHEN o.ai_assisted=1 AND o.accepted=1 THEN 1 ELSE 0 END) AS accepted_ai_outputs,
       SUM(COALESCE(u.ai_cost_inr,0))*1.0/NULLIF(SUM(CASE WHEN o.ai_assisted=1 AND o.accepted=1 THEN 1 ELSE 0 END),0) AS cost_per_accepted_ai_output_inr
FROM fact_work_outcome o JOIN dim_team t ON o.team_id=t.team_id LEFT JOIN usage_by_task u ON o.task_id=u.task_id
GROUP BY t.team_name,o.business_output ORDER BY cost_per_accepted_ai_output_inr;

-- 3. Model economics. Spend alone is not a quality-adjusted value measure.
SELECT m.model_name, m.provider, COUNT(*) AS requests, SUM(u.input_tokens) AS input_tokens,
       SUM(u.output_tokens) AS output_tokens, SUM(u.total_cost_inr) AS total_cost_inr,
       AVG(u.latency_seconds) AS avg_latency_seconds,
       SUM(CASE WHEN u.request_status='failed' THEN 1 ELSE 0 END)*1.0/COUNT(*) AS failure_rate
FROM fact_ai_usage u JOIN dim_model_pricing m ON u.model_id=m.model_id
GROUP BY m.model_name,m.provider ORDER BY total_cost_inr DESC;

-- 4. AI-assisted vs non-AI comparison. Observational, not causal proof.
SELECT t.team_name, o.ai_assisted, COUNT(*) AS tasks,
       AVG(o.baseline_minutes-o.actual_minutes) AS avg_gross_minutes_saved,
       AVG(o.quality_score) AS avg_quality_score, AVG(o.rework_minutes) AS avg_rework_minutes,
       AVG(o.accepted*1.0) AS acceptance_rate
FROM fact_work_outcome o JOIN dim_team t ON o.team_id=t.team_id
GROUP BY t.team_name,o.ai_assisted ORDER BY t.team_name,o.ai_assisted DESC;

-- 5. Daily cost trend.
SELECT substr(request_timestamp,1,10) AS request_date, t.team_name,
       SUM(u.total_cost_inr) AS total_cost_inr, COUNT(*) AS requests
FROM fact_ai_usage u JOIN dim_team t ON u.team_id=t.team_id
GROUP BY substr(request_timestamp,1,10),t.team_name ORDER BY request_date,t.team_name;

-- 6. Quality and rework guardrails.
SELECT t.team_name, COUNT(*) AS tasks, AVG(o.quality_score) AS avg_quality,
       AVG(o.rework_minutes) AS avg_rework_minutes,
       SUM(CASE WHEN o.accepted=1 THEN 1 ELSE 0 END)*1.0/COUNT(*) AS acceptance_rate
FROM fact_work_outcome o JOIN dim_team t ON o.team_id=t.team_id GROUP BY t.team_name;

-- 7. Request-to-task audit trail.
SELECT u.request_id,u.request_timestamp,u.task_id,t.team_name,m.model_name,
       u.input_tokens,u.output_tokens,u.cached_input_tokens,u.total_cost_usd,u.total_cost_inr,u.request_status
FROM fact_ai_usage u JOIN dim_team t ON u.team_id=t.team_id JOIN dim_model_pricing m ON u.model_id=m.model_id
ORDER BY u.request_timestamp DESC LIMIT 100;
