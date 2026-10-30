# 08 — QA report

**Run:** `eurusd_macro_backtest_2004_2026_2026_09_23`  
**QA time:** 23/09/2026  
**Status:** PASS với các giới hạn đã công bố.

## Automated tests

`npm test` đạt `9/9`:

- quoted CSV parsing;
- forward-fill không backfill và tôn trọng staleness;
- two-bar execution lag;
- đảo vị thế tính hai one-way cost units;
- no-trade equity flat;
- carried-in/open trade tại sample boundary;
- robust warm-up;
- weekend event alignment;
- post-fixing event alignment.

## Artifact integrity

| Check | Kết quả |
|---|---:|
| Daily rows | 5.646 |
| Blank/zero/negative prices | 0 |
| Missing evaluation returns | 0 |
| Literal `NaN`/`Infinity` hits | 0 |
| Expected final equity | 1.661816 |
| Actual final equity | 1.6618155 |
| Absolute difference | 0.0000005 |
| Trade ledger rows | 229 |
| Open trades | 1 |
| Manifest sources | 14 |
| Fed BRW 1D all-event N | 130 |
| ECB full-event all N | 299 |
| Missing report files | 0 |

Equity difference chỉ do CSV/JSON rounding ở chữ số thập phân cuối.

## Manual audit points đã xử lý

- Empty numeric cells được bỏ qua, không parse thành 0.
- Price phải hữu hạn và dương.
- Daily equity bắt đầu đúng tại common evaluation window.
- Open trade có `exit_date` trống và mark-to-market date riêng.
- BRW duplicate headers được đọc theo vị trí cột rõ ràng.
- FOMC holiday/weekend dùng pre/post event fixes.
- Predictive diagnostics dùng post-next-fix return, không contemporaneous return giả làm dự báo.
- VIX high/normal threshold là rolling trailing percentile, không full-sample percentile.
- Historical holdout được ghi rõ là `not_preregistered`.

## Residual risks

QA không thể loại bỏ:

- revision/current-vintage bias của upstream data;
- difference giữa ECB fixing và executable bid/ask;
- broker spread/slippage/swap;
- data-snooping từ nghiên cứu hậu nghiệm;
- extrapolation từ D1 sang H4/H1;
- structural break tương lai.

Do đó PASS nghĩa là artifacts nhất quán với đặc tả, không nghĩa là chiến lược chắc chắn sinh lời.
