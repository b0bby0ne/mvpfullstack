# EUR/USD macro + kỹ thuật — mục lục bàn giao

**Run ID:** `eurusd_macro_backtest_2004_2026_2026_09_23`  
**Ngày chạy:** 23/09/2026 (Asia/Ho_Chi_Minh)  
**Quan sát EUR/USD mới nhất:** ECB reference rate ngày 22/09/2026, `1.1463`  
**Mục đích:** xây một quy trình có thể kiểm chứng để dùng macro Fed–ECB làm bias D1 và dùng H4/H1 làm điểm thực thi.

## Kết luận điều hành

Mô hình cố định “xung lực chênh lệch lợi suất 2Y EUR–USD + xác nhận SMA200” có edge lịch sử dương nhưng vừa phải. Kết quả toàn mẫu là `+66.18%`, CAGR `2.58%`, Sharpe `0.498`, max drawdown `-14.47%`, với exposure chỉ `38.08%`. Phần lịch sử 2019+ vẫn dương (`+10.01%`, Sharpe `0.312`) nhưng khoảng tin cậy Sharpe chứa 0. Walk-forward 2014+ chỉ đạt Sharpe `0.119`. Vì vậy đây là **bộ lọc hướng**, không phải robot vào lệnh độc lập.

Trạng thái mới nhất nghiêng giảm EUR/USD:

- chênh lệch lợi suất 2Y EUR–USD là `-161.24 bp`;
- xung lực 20 phiên là `-19.28 bp`, robust z-score `-1.721`;
- EUR/USD `1.1463` nằm dưới SMA200 `1.16266` khoảng `1.41%`;
- macro state, technical state và hybrid state đều bằng `-1`.

Tuy nhiên giá chỉ cao hơn đáy đóng cửa 20 ngày `1.1460` đúng 3 pip. Bias là short, nhưng vị trí hiện tại **không thuận lợi để đuổi short**. Ưu tiên một trong hai điều kiện: phá–retest có xác nhận dưới `1.1460`, hoặc hồi lên vùng kháng cự rồi H1/H4 đảo cấu trúc xuống.

## Bảng kết quả cốt lõi

| Giai đoạn | Total return | CAGR | Sharpe | Max DD | Exposure | Lệnh đóng |
|---|---:|---:|---:|---:|---:|---:|
| 16/10/2006–22/09/2026 | +66.18% | 2.58% | 0.498 | -14.47% | 38.08% | 228 |
| Development đến 31/12/2018 | +51.07% | 3.44% | 0.591 | -14.47% | 37.04% | 133 |
| Historical holdout 2019+ | +10.01% | 1.24% | 0.312 | -7.48% | 39.74% | 95 |
| Diagnostic 2024+ | +3.33% | 1.21% | 0.334 | -5.10% | 47.13% | 38 |

Khoảng tin cậy block-bootstrap 95% của Sharpe toàn mẫu là `[0.042; 0.900]`; của phần 2019+ là `[-0.349; 0.873]`. Đây là khác biệt quan trọng giữa “có lợi nhuận trong mẫu lịch sử” và “đã chứng minh edge chắc chắn”.

## Hồ sơ đọc theo thứ tự

1. [01_Input_Brief.md](01_Input_Brief.md) — câu hỏi, giả thuyết, quy tắc và tiêu chí đánh giá.
2. [02_Data_Provenance_Audit.md](02_Data_Provenance_Audit.md) — nguồn dữ liệu, thời điểm công bố, kiểm soát look-ahead và chất lượng.
3. [03_Fed_ECB_Transmission_Map.md](03_Fed_ECB_Transmission_Map.md) — mối quan hệ Fed–ECB và cách macro truyền vào EUR/USD.
4. [04_Event_Study.md](04_Event_Study.md) — kiểm định surprise Fed/ECB và giờ sự kiện theo ICT.
5. [05_Technical_Backtest.md](05_Technical_Backtest.md) — mô hình, benchmark, kết quả và ý nghĩa thống kê.
6. [06_Walk_Forward_and_Robustness.md](06_Walk_Forward_and_Robustness.md) — grid 81 cấu hình, walk-forward, cost/carry/timing stress.
7. [07_EURUSD_Macro_TA_Playbook.md](07_EURUSD_Macro_TA_Playbook.md) — quy trình D1 → H4 → H1 và kịch bản hiện tại.
8. [08_QA_Report.md](08_QA_Report.md) — automated tests, integrity checks và residual risks.

## Tệp bằng chứng máy đọc

- `metrics.json`: toàn bộ KPI, trạng thái mới nhất và giới hạn nghiên cứu.
- `daily_model.csv`: dữ liệu ngày, tín hiệu, vị thế trễ và equity.
- `trade_ledger.csv`: 228 lệnh đóng và 1 vị thế đang mở theo mô phỏng.
- `strategy_metrics.csv`: so sánh hybrid, macro-only, SMA200, momentum, carry và buy-and-hold.
- `fed_brw_shock_analysis.csv`: event study surprise Fed chính thức.
- `ecb_ea_mpd_analysis.csv`: event study intraday ECB EA-MPD.
- `parameter_robustness.csv`, `parameter_group_summary.csv`: 81 cấu hình và nhóm lookback.
- `cost_sensitivity.csv`, `carry_sensitivity.csv`, `execution_lag_sensitivity.csv`, `best_days_stress.csv`: stress tests.
- `walk_forward_metrics.json`, `walk_forward_selections.csv`: kiểm định walk-forward.
- `data_manifest.csv`: URL, thời điểm tải và SHA-256 của 14 nguồn.

## Phạm vi sử dụng

Backtest chỉ xác nhận **bias ngày** trên ECB reference fix. Nó không xác nhận entry/stop/target H4 hoặc H1, spread broker, slippage, swap thực tế hay khả năng khớp giá. Các mức giá trong playbook là vùng nghiên cứu, không phải khuyến nghị đầu tư cá nhân và không bảo đảm lợi nhuận.
