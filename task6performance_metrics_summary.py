"""
performance_metrics_summary.py
================================
Companion script for: Task6_Comprehensive_Evaluation_Performance_Report.docx

Recomputes the Section 7 ("Predictive Analytics Impact") metrics directly
from the Week 5 artifacts, so the Week 6 evaluation can be refreshed
without manually re-typing numbers.

Inputs expected in the same folder (copy them over from the Week 5
deliverables if running standalone):
    - historical_construction_data.csv
    - scored_predictions.csv   (produced by predictive_models.py)

Output:
    - performance_metrics_summary.csv  -- one row per metric, matching the
      "Predictive Model Metrics" sheet of Task6_Evaluation_Scorecard.xlsx

Usage:
    pip install pandas numpy scikit-learn --break-system-packages
    python performance_metrics_summary.py
"""

import pandas as pd
import numpy as np
from sklearn.metrics import (
    accuracy_score, precision_score, recall_score, f1_score,
    roc_auc_score, mean_absolute_error, r2_score
)

TARGETS = {
    ("Overrun Flag", "Accuracy"): 0.70,
    ("Overrun Flag", "Precision"): 0.65,
    ("Overrun Flag", "Recall"): 0.65,
    ("Overrun Flag", "F1 Score"): 0.70,
    ("Overrun Flag", "AUC-ROC"): 0.75,
    ("Schedule Delay Flag", "Accuracy"): 0.70,
    ("Schedule Delay Flag", "Precision"): 0.65,
    ("Schedule Delay Flag", "Recall"): 0.65,
    ("Schedule Delay Flag", "F1 Score"): 0.70,
}


def summarize(scored_path="scored_predictions.csv"):
    """
    Expects scored_predictions.csv to contain the ground-truth flags
    (OverrunFlag, DelayFlag) alongside the model's predicted probabilities
    (Predicted_OverrunProbability, Predicted_DelayProbability), which is
    exactly what predictive_models.py writes out.
    """
    df = pd.read_csv(scored_path)
    rows = []

    if {"OverrunFlag", "Predicted_OverrunProbability"}.issubset(df.columns):
        y_true = df["OverrunFlag"]
        proba = df["Predicted_OverrunProbability"]
        y_pred = (proba >= 0.5).astype(int)
        rows += [
            ("Overrun Flag", "Accuracy", accuracy_score(y_true, y_pred)),
            ("Overrun Flag", "Precision", precision_score(y_true, y_pred, zero_division=0)),
            ("Overrun Flag", "Recall", recall_score(y_true, y_pred, zero_division=0)),
            ("Overrun Flag", "F1 Score", f1_score(y_true, y_pred, zero_division=0)),
        ]
        try:
            rows.append(("Overrun Flag", "AUC-ROC", roc_auc_score(y_true, proba)))
        except ValueError:
            pass

    if {"DelayFlag", "Predicted_DelayProbability"}.issubset(df.columns):
        y_true = df["DelayFlag"]
        proba = df["Predicted_DelayProbability"]
        y_pred = (proba >= 0.5).astype(int)
        rows += [
            ("Schedule Delay Flag", "Accuracy", accuracy_score(y_true, y_pred)),
            ("Schedule Delay Flag", "Precision", precision_score(y_true, y_pred, zero_division=0)),
            ("Schedule Delay Flag", "Recall", recall_score(y_true, y_pred, zero_division=0)),
            ("Schedule Delay Flag", "F1 Score", f1_score(y_true, y_pred, zero_division=0)),
        ]

    if {"OverrunPct", "Predicted_OverrunPct_GBR"}.issubset(df.columns):
        y_true = df["OverrunPct"]
        y_pred = df["Predicted_OverrunPct_GBR"]
        rows += [
            ("Overrun % (Gradient Boosting)", "MAE", mean_absolute_error(y_true, y_pred)),
            ("Overrun % (Gradient Boosting)", "R2", r2_score(y_true, y_pred)),
        ]

    out = pd.DataFrame(rows, columns=["Model", "Metric", "Actual Value"])
    out["Target"] = out.apply(
        lambda r: TARGETS.get((r["Model"], r["Metric"]), np.nan), axis=1
    )
    out["Status"] = out.apply(
        lambda r: (
            "N/A" if pd.isna(r["Target"]) else
            ("Met" if (r["Metric"] == "MAE" and r["Actual Value"] <= r["Target"])
             or (r["Metric"] != "MAE" and r["Actual Value"] >= r["Target"])
             else "Below Target")
        ),
        axis=1,
    )
    return out


def main():
    summary = summarize()
    print(summary.to_string(index=False))
    summary.to_csv("performance_metrics_summary.csv", index=False)
    print("\nSaved performance_metrics_summary.csv")


if __name__ == "__main__":
    main()
