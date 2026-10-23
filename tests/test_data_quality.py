import unittest
from pathlib import Path
import pandas as pd
ROOT=Path(__file__).resolve().parents[1]
class TestDataQuality(unittest.TestCase):
 @classmethod
 def setUpClass(cls):
  cls.u=pd.read_csv(ROOT/"data/raw/fact_ai_usage.csv"); cls.o=pd.read_csv(ROOT/"data/raw/fact_work_outcome.csv")
 def test_unique_grains(self):
  self.assertTrue(self.u.request_id.is_unique); self.assertTrue(self.o.task_id.is_unique)
 def test_relationships(self):
  self.assertTrue(self.u.task_id.isin(self.o.task_id).all())
 def test_tokens_and_costs(self):
  self.assertTrue((self.u.cached_input_tokens<=self.u.input_tokens).all()); self.assertTrue((self.u.total_cost_inr>=0).all())
 def test_quality_range(self):
  self.assertTrue(self.o.quality_score.between(0,1).all())
if __name__=="__main__": unittest.main()
