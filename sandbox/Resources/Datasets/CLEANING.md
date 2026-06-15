# Dataset Cleaning Log

The CSV files in this directory are **modified** versions of public-source
datasets. They have been cleaned for use as teaching examples in the Quiver
Notebook so students can focus on Quiver workflows, not data wrangling. Each
modification is documented below for citation transparency.

If you need the original raw form for any of these datasets, fetch from the
upstream source listed for each file — do not assume the CSV in this
directory matches what you would download from the source.

---

## iris.csv

**Source:** UCI Machine Learning Repository — Iris Data Set (R. A. Fisher, 1936).

**Modifications:**
- Stripped the `Iris-` prefix from the `species` column. Values are now
  `setosa`, `versicolor`, `virginica` (was `Iris-setosa`, etc.).

**Final shape:** 150 rows, 5 columns. No missing values.

---

## titanic.csv

**Source:** Kaggle "Titanic — Machine Learning from Disaster" competition,
training set (`train.csv`).

**Modifications:**
- Dropped four columns: `PassengerId` (row index, no signal), `Name`
  (high-cardinality string with embedded commas), `Ticket` (high-cardinality
  string, low signal), `Cabin` (77.1% missing, low signal).
- Median-filled 177 missing `Age` values with the median age of 28.0
  (computed from non-missing rows in the original file).
- Dropped the 2 rows with missing `Embarked` values (originally 891 rows,
  now 889).

**Final shape:** 889 rows, 8 columns: `Survived`, `Pclass`, `Sex`, `Age`,
`SibSp`, `Parch`, `Fare`, `Embarked`. No missing values.

---

## california-housing.csv

**Source:** California census housing data (1990), as redistributed by
StatLib (CMU) and popularized through the scikit-learn fetcher and Aurélien
Géron's *Hands-On Machine Learning*.

**Modifications:**
- Median-filled 207 missing `total_bedrooms` values with the median of 435
  (computed from non-missing rows in the original file).
- Recoded the `ocean_proximity` column to snake_case tokens to remove
  embedded spaces and special characters: `NEAR BAY` → `near_bay`,
  `<1H OCEAN` → `lt_1h_ocean`, `INLAND` → `inland`, `ISLAND` → `island`,
  `NEAR OCEAN` → `near_ocean`.

**Final shape:** 20,640 rows, 10 columns. No missing values.

---

## bike-sharing.csv

**Source:** UCI Machine Learning Repository — Bike Sharing Dataset
(Hadi Fanaee-T, Capital Bikeshare via University of Porto), `day.csv`.

**Modifications:**
- Converted the `dteday` column from ISO 8601 date strings (`2011-01-01`,
  `2011-01-02`, …) to Unix timestamps as integers (`1293840000`,
  `1293926400`, …, UTC midnight per day). This lets TabularData's CSV
  reader infer the column as numeric so it lands in the `Panel` directly
  as `Double` values rather than being alphabetically encoded as a
  categorical column with 731 unique categories. Anyone who needs the
  original ISO dates can divide a timestamp by 86,400 to recover days
  since 1970-01-01 or convert via `Date(timeIntervalSince1970:)`.

**Final shape:** 731 rows, 16 columns. No missing values.

---

## student-performance.csv

**Source:** UCI Machine Learning Repository — Student Performance Dataset
(Paulo Cortez, University of Minho), Portuguese-language course subset
(`student-por.csv`).

**Modifications:**
- Converted delimiter from `;` to `,` (the upstream UCI file is
  semicolon-delimited per Portuguese locale convention).
- Stripped per-field quotation marks. The original file inconsistently
  quoted some string fields (`"GP"`, `"F"`) and some integer fields
  (`"5"`, `"6"`) while leaving others unquoted; all 33 columns now ship
  as plain unquoted comma-separated values. No field contains a comma or
  embedded quote, so no quoting is needed for correctness.

**Final shape:** 395 rows, 33 columns. No missing values.

---

## simulated-run.csv

**Source:** Synthetic. The CSV was generated against a physiological
constraint spec authored by the project's exercise-science advisor
(2026-05-16) and a generative-math design authored by the project's
mathematics advisor (2026-05-16). No real Apple Watch data was captured or
distributed. The generator itself is maintained outside this repository in
the project's planning workspace; the CSV here is the canonical artifact.

**Generative model:**
- 60-second tempo run for a 70 kg moderately trained runner, sampled at 1 Hz.
- `pace` is approximately constant at 3.60 m/s with σ = 0.05 m/s — no drift,
  which is the load-bearing TES decoupling signal.
- `heartRate` follows a deterministic linear ramp from 162 to 168 BPM (the
  +6 BPM cardiac-drift signal) with σ = 1.0 BPM Gaussian noise added in a
  second pass, then clamped to [158, 172] BPM.
- `cadence` is approximately constant at 170 spm with σ = 1.0 spm noise.
- `altitude` is a gentle sinusoid (1.8 m peak-to-peak, one cycle per minute)
  rounded to 0.1 m, modelling the altimeter quantization on Apple Watch.
- `power` is a 265 W baseline plus a grade-coupled term (≈10 W per 0.5%
  grade) plus σ = 6 W Gaussian noise. Power is intentionally decoupled
  from heart rate inside this 60-second window.
- Random numbers are drawn from a custom xorshift64 generator with
  top-53-bit-to-Double conversion and Box-Muller normals. Canonical seed
  is `42`. Per-column draw order is load-bearing for reproducibility —
  see the script header for the contract.

**Final shape:** 60 rows, 6 columns: `time`, `heartRate`, `pace`, `cadence`,
`power`, `altitude`. No missing values.

**Pairs with:** `simulated-run-accel.csv` — the same simulated run viewed at
50 Hz through the wrist accelerometer.

---

## simulated-run-accel.csv

**Source:** Synthetic. Generated by the same script as `simulated-run.csv`
in the same generator invocation, against the same physiological spec. The
two CSVs describe the same 60-second event at different sample rates.

**Generative model:**
- Wrist accelerometer magnitude in m/s², sampled at 50 Hz over 60 seconds
  (3,000 samples).
- `magnitude = g + A₁·sin(2π·f₁·τ) + A₂·sin(2π·2·f₁·τ) + ε`, where
  `g = 9.81 m/s²`, `f₁ = 2.833 Hz` (cadence at 170 spm), `A₁ = 0.6g`
  (footstrike amplitude), `A₂ = 0.25·A₁` (two-legged gait harmonic), and
  `ε ~ N(0, (0.08g)²)` (broadband sensor noise).
- Sinusoid phase is computed from the sample index, not accumulated step
  by step, to avoid ULP-scale drift across 3,000 samples.
- Random numbers are drawn from the same xorshift64 stream as
  `simulated-run.csv`, in sequence after the slow-rate columns. The seed
  contract is therefore joint across both files; regenerating one without
  the other would change the noise draws in the second.

**Final shape:** 3,000 rows, 2 columns: `time`, `magnitude`. No missing values.

**Pairs with:** `simulated-run.csv` — the per-second feature trace of the
same run, with heart rate, pace, cadence, power, and altitude.

---

## glove-50d.csv

**Source:** Stanford NLP — GloVe pre-trained word vectors, `glove.6B.50d.txt`
(Pennington, Socher, Manning, 2014). Trained on a 6-billion-token corpus
combining Wikipedia 2014 and Gigaword 5. Apache 2.0 license.

**Modifications:**
- Sliced the first 25,000 lines from the upstream file. The source ships
  sorted by corpus frequency (most common first), so the first 25,000 lines
  are the top-25K most-frequent words in the 6B-token corpus. Reduces the
  bundle from ~163 MB (400K vocabulary) to ~11 MB.
- Reformatted from space-delimited to comma-delimited. Source rows are
  `word v1 v2 ... v50`; output rows are RFC 4180 CSV with a header row.
- Added a header row: `word,rank,magnitude,dim_01,dim_02,...,dim_50`.
  Dimension columns use zero-padded two-digit names so they sort correctly
  in `head()` output. The `rank` column preserves the upstream frequency
  order, and `magnitude` is the precomputed vector length.
- Wrapped tokens containing commas, quotes, or whitespace in RFC 4180
  quoting per CSV convention; no other token modifications.

**Final shape:** 25,000 rows, 53 columns (`word`, `rank`, `magnitude`, plus
`dim_01` through `dim_50`). No missing values. Generated by
`Scripts/glove-preprocess.swift`.

---

## Why these modifications

The Quiver Notebook is a teaching environment. Students working through
case studies should focus on Quiver workflows — `Dataset.iris.toPanel()`,
`panel.head()`, `LinearRegression.fit(...)` — not on parsing inconsistent
quoting, dropping rows for missing fields, recoding categorical labels,
or hand-converting date strings to numeric features.

For real-world data work where preserving upstream form matters, fetch
from the original source.
