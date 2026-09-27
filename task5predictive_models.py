"""
Predictive Analytics in Virtual Construction — Model Training Script
======================================================================
Companion script for: Task5_Predictive_Analytics_Virtual_Construction.docx

Trains the three model families described in the report, using
historical_construction_data.csv as input:

  1. Budget Overrun      -> Regression (Linear + Gradient Boosting)
                             + Classification (Logistic Regression) for
                               the binary "overrun risk" flag.
  2. Resource Demand      -> Time-series forecast (Holt-Winters / SARIMA-style)
                               of weekly labour hours per project.
  3. Schedule Delay       -> Classification (Random Forest) for delay-flag,
                               with feature importances for the Power BI
                               Key Influencers / Decomposition Tree visuals.

Output: writes `scored_predictions.csv`, which is the table Power BI
should connect to (via Power Query / a Data Lake / Azure SQL table) as
described in Section 6, Step 4 ("Scoring Pipeline") of the report.

Usage:
    pip install pandas numpy scikit-learn statsmodels --break-system-packages
    python predictive_models.py
"""

import numpy as np
import pandas as pd
from sklearn.model_selection import GroupShuffleSplit
from sklearn.linear_model import LinearRegression, LogisticRegression
from sklearn.ensemble import GradientBoostingRegressor, RandomForestClassifier
from sklearn.metrics import (
    mean_absolute_error, r2_score,
    accuracy_score, precision_score, recall_score, f1_score, roc_auc_score
)

RANDOM_STATE = 42


def load_data(path="historical_construction_data.csv"):
    df = pd.read_csv(path)
    return df


def project_level_split(df, target_cols, test_size=0.25):
    """
    Split by ProjectID (not by row) so an entire project is held out for
    validation -- avoids the data-leakage risk flagged in Section 5.2 /
    Section 10 of the report.
    """
    splitter = GroupShuffleSplit(n_splits=1, test_size=test_size, random_state=RANDOM_STATE)
    idx_train, idx_test = next(splitter.split(df, groups=df["ProjectID"]))
    return df.iloc[idx_train].copy(), df.iloc[idx_test].copy()


FEATURES = [
    "PctComplete", "CPI", "SPI", "PctFloatConsumed", "ChangeOrderRatePct",
    "WeatherDelayDays", "ProcurementLeadVarianceDays", "ClashCount",
]
CATEGORICAL = ["ProjectType", "Region"]


def encode_categoricals(df):
    return pd.get_dummies(df, columns=CATEGORICAL, drop_first=True)


# ---------------------------------------------------------------------
# 1. BUDGET OVERRUN MODELS
# ---------------------------------------------------------------------
def train_overrun_models(train, test):
    train_enc = encode_categoricals(train)
    test_enc = encode_categoricals(test)
    test_enc = test_enc.reindex(columns=train_enc.columns, fill_value=0)

    feat_cols = [c for c in train_enc.columns if c in FEATURES or
                 any(c.startswith(p + "_") for p in CATEGORICAL)]

    X_train, y_train = train_enc[feat_cols], train_enc["OverrunPct"]
    X_test, y_test = test_enc[feat_cols], test_enc["OverrunPct"]

    # --- Regression: linear (interpretable) + gradient boosted (accuracy) ---
    lin = LinearRegression().fit(X_train, y_train)
    gbr = GradientBoostingRegressor(random_state=RANDOM_STATE).fit(X_train, y_train)

    pred_lin = lin.predict(X_test)
    pred_gbr = gbr.predict(X_test)

    print("\n--- Budget Overrun % (Regression) ---")
    print(f"Linear Regression   MAE={mean_absolute_error(y_test, pred_lin):.2f}  R2={r2_score(y_test, pred_lin):.3f}")
    print(f"Gradient Boosting   MAE={mean_absolute_error(y_test, pred_gbr):.2f}  R2={r2_score(y_test, pred_gbr):.3f}")

    # --- Classification: overrun flag (>5%) ---
    y_train_flag, y_test_flag = train_enc["OverrunFlag"], test_enc["OverrunFlag"]
    logit = LogisticRegression(max_iter=1000).fit(X_train, y_train_flag)
    proba = logit.predict_proba(X_test)[:, 1]
    pred_flag = (proba >= 0.5).astype(int)

    print("\n--- Overrun Flag (Classification) ---")
    print(f"Accuracy={accuracy_score(y_test_flag, pred_flag):.3f}  "
          f"Precision={precision_score(y_test_flag, pred_flag, zero_division=0):.3f}  "
          f"Recall={recall_score(y_test_flag, pred_flag, zero_division=0):.3f}  "
          f"F1={f1_score(y_test_flag, pred_flag, zero_division=0):.3f}")
    try:
        print(f"AUC-ROC={roc_auc_score(y_test_flag, proba):.3f}")
    except ValueError:
        pass

    test = test.copy()
    test["Predicted_OverrunPct_GBR"] = pred_gbr
    test["Predicted_OverrunProbability"] = proba
    return test, dict(zip(feat_cols, logit.coef_[0]))


# ---------------------------------------------------------------------
# 2. SCHEDULE DELAY MODEL
# ---------------------------------------------------------------------
def train_delay_model(train, test):
    train_enc = encode_categoricals(train)
    test_enc = encode_categoricals(test)
    test_enc = test_enc.reindex(columns=train_enc.columns, fill_value=0)

    feat_cols = [c for c in train_enc.columns if c in FEATURES or
                 any(c.startswith(p + "_") for p in CATEGORICAL)]

    X_train, y_train = train_enc[feat_cols], train_enc["DelayFlag"]
    X_test, y_test = test_enc[feat_cols], test_enc["DelayFlag"]

    rf = RandomForestClassifier(n_estimators=300, max_depth=6, random_state=RANDOM_STATE)
    rf.fit(X_train, y_train)
    proba = rf.predict_proba(X_test)[:, 1]
    pred = (proba >= 0.5).astype(int)

    print("\n--- Schedule Delay Flag (Random Forest) ---")
    print(f"Accuracy={accuracy_score(y_test, pred):.3f}  "
          f"Precision={precision_score(y_test, pred, zero_division=0):.3f}  "
          f"Recall={recall_score(y_test, pred, zero_division=0):.3f}  "
          f"F1={f1_score(y_test, pred, zero_division=0):.3f}")

    importances = dict(sorted(
        zip(feat_cols, rf.feature_importances_), key=lambda x: -x[1]
    ))
    print("Top delay-risk drivers (feature importance):")
    for k, v in list(importances.items())[:5]:
        print(f"   {k}: {v:.3f}")

    test = test.copy()
    test["Predicted_DelayProbability"] = proba
    return test, importances


# ---------------------------------------------------------------------
# 3. RESOURCE DEMAND FORECAST (simple exponential smoothing, per project)
# ---------------------------------------------------------------------
def forecast_resource_demand(df, project_id, horizon=4):
    """
    Holt's exponential smoothing forecast for weekly labour hours,
    mirroring the Power BI native 'Forecast' analytics-pane feature
    described in Section 4.1 of the report.
    """
    from statsmodels.tsa.holtwinters import ExponentialSmoothing

    series = (
        df[df["ProjectID"] == project_id]
        .sort_values("WeekNo")["LabourHoursActual"]
        .reset_index(drop=True)
    )
    if len(series) < 8:
        return None

    model = ExponentialSmoothing(series, trend="add", damped_trend=True)
    fit = model.fit()
    forecast = fit.forecast(horizon)
    return forecast


def main():
    df = load_data()
    train, test = project_level_split(df, ["OverrunPct", "DelayFlag"])

    scored, overrun_coefs = train_overrun_models(train, test)
    scored, delay_importances = train_delay_model(train, scored)

    sample_project = df["ProjectID"].iloc[0]
    fc = forecast_resource_demand(df, sample_project, horizon=4)
    print(f"\n--- Resource Demand Forecast (next 4 weeks, {sample_project}) ---")
    print(fc)

    scored.to_csv("scored_predictions.csv", index=False)
    print("\nSaved scored_predictions.csv -- point Power BI's Power Query at this table.")


if __name__ == "__main__":
    main()
