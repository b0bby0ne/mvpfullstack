# Bob Volman H1 v1.40 — ma trận setup × Wyckoff

Ngày kiểm thử: 2026-10-07. MT5 Demo: `D:\Demo SMMA`. Symbol `XAUUSDm`, H1, vốn 10.000 USD, leverage 1:100, rủi ro 1% equity mỗi lệnh.

## Thay đổi trong v1.40

- Mỗi setup có event mask Wyckoff riêng.
- Mỗi setup có tuổi event tối đa và khoảng cách trigger-level theo ATR riêng.
- Có quản lý hòa vốn độc lập cho SB và BB.
- Các bộ lọc khoảng cách và hòa vốn được giữ trong code nhưng mặc định tắt vì không qua validation.
- Ma trận mặc định là bản bảo thủ: chỉ loại các cặp setup-event có chuỗi thua rõ, không siết các setup có mẫu nhỏ.

Bit mask: Spring=2, Upthrust=4, SOS=8, SOW=16, Test=32, LPS=64, LPSY=128.

| Setup | Mask cuối | Ý nghĩa |
|---|---:|---|
| DDB | 120 | Loại Spring |
| FB | 122 | Giữ mọi event toàn cục hợp hướng |
| SB | 122 | Giữ mọi event toàn cục hợp hướng |
| BB | 120 | Loại Spring |
| RB | 122 | Không tối ưu thêm vì mẫu nhỏ |
| IRB | 122 | Không tối ưu thêm vì mẫu rất nhỏ |
| ARB | 114 | Loại SOS |

Upthrust và LPSY vẫn bị tắt ở tầng global như v1.31. Tuổi event của mọi setup giữ 12 nến; giới hạn khoảng cách ATR mặc định bằng 0, tức không áp dụng.

## Quy trình lựa chọn

1. Train: 2023–2024.
2. Validation: 2025.
3. Out-of-sample không dùng để tạo rule: 2026 đến 27/09.
4. Chỉ chấp nhận thay đổi nếu cải thiện ít nhất ba năm và không làm xấu năm còn lại.

Ma trận thử nghiệm ban đầu quá chặt: cải thiện 2024–2025 nhưng giảm 2023 và 2026. Bản đó bị loại.

Ma trận bảo thủ chỉ loại ba nhóm đã thua liên tục trong baseline:

- `BB + Spring`: 4/4 lệnh thua, xuất hiện trong 2023–2025.
- `ARB + SOS`: 3/3 lệnh thua, xuất hiện trong 2024–2025.
- `DDB + Spring`: 1/1 lệnh thua trong 2025.

Không nhóm nào trong ba nhóm trên xuất hiện ở 2026, do đó rule không được xây dựng từ tập out-of-sample.

## So sánh v1.31 và v1.40

| Chỉ số | v1.31 Wyckoff bias | v1.40 matrix |
|---|---:|---:|
| Net Profit | +5.013,38 | **+6.044,21** |
| Profit Factor | 2,40 | **3,09** |
| Recovery Factor | 9,63 | **10,87** |
| Equity DD | 3,52% | **3,51%** |
| Trades | 75 | 68 |
| Win rate | 61,33% | **67,65%** |

Win rate tăng 6,32 điểm phần trăm và Net Profit tăng 1.030,83 USD, trong khi giảm bảy lệnh.

## Kết quả theo năm

| Giai đoạn | Net Profit | PF | RF | Equity DD | Trades | Win rate |
|---|---:|---:|---:|---:|---:|---:|
| 2023 | +1.246,10 | 2,70 | 4,17 | 2,76% | 21 | 66,67% |
| 2024 | +1.684,74 | 4,70 | 5,40 | 2,60% | 14 | 71,43% |
| 2025 validation | +1.781,76 | 3,29 | 6,58 | 2,25% | 23 | 69,57% |
| 2026 OOS | +309,82 | 1,78 | 1,17 | 2,57% | 10 | 60,00% |

So với v1.31, bản mới cải thiện 2023–2025 và giữ nguyên chính xác kết quả 2026 OOS.

## Đóng góp setup trên toàn history

| Setup | Net Profit | Trades | Win rate |
|---|---:|---:|---:|
| SB | +3.293,09 | 30 | 63,33% |
| BB | +1.077,78 | 11 | 54,55% |
| DDB | +736,08 | 11 | 72,73% |
| ARB | +669,34 | 7 | 71,43% |
| FB | +517,47 | 5 | 100,00% |
| RB | +251,71 | 3 | 100,00% |
| IRB | -127,74 | 1 | 0,00% |

Cả bảy setup đều phát sinh lệnh. Không tiếp tục tinh chỉnh IRB vì chỉ có một mẫu.

## Những thử nghiệm bị loại

### Khoảng cách tới Wyckoff level

Tối ưu 81 tổ hợp trên train cho kết quả đẹp tới 70% win rate. Tuy nhiên cấu hình cân bằng nhất giảm validation 2025 từ 69,57% xuống 66,67% và Net Profit từ 1.781,76 xuống 1.030,90 USD. Vì vậy mọi giới hạn distance mặc định vẫn bằng 0.

### Hòa vốn

- SB hòa vốn tại +1R: validation giảm WR 69,57% xuống 65,22%, Net Profit giảm còn 1.127,52 USD.
- BB hòa vốn tại +1R: không cải thiện validation và giảm Net Profit train.
- Cả hai chức năng được giữ để nghiên cứu nhưng mặc định `false`.

## Đối chiếu Q3/2026

| Model | Net Profit | PF | RF | Equity DD | Trades | Win rate |
|---|---:|---:|---:|---:|---:|---:|
| M1 OHLC | +165,24 | 2,68 | 1,22 | 1,35% | 3 | 66,67% |
| Real ticks | +171,91 | 2,74 | 1,51 | 1,14% | 3 | 66,67% |

Hai model đồng thuận về số lệnh và win rate, nhưng ba lệnh là mẫu quá nhỏ.

## Kết luận vận hành

- Compile v1.40: 0 lỗi, 0 cảnh báo.
- SL ban đầu vẫn nằm ngoài nến tín hiệu.
- 1R vẫn bằng 1% equity.
- Chỉ giữ một setup pending và một vị thế EA.
- Trade comment vẫn chứa setup, hướng và event Wyckoff.
- Cấu hình mới giảm số lệnh; không nên tăng risk để bù tần suất.

Kết quả toàn history vẫn chứa giai đoạn train và validation. Cần tiếp tục forward-test demo ít nhất 100 lệnh trước khi dùng tiền thật.

## Artifacts

- Preset: `tests/sets/BobH1-AllSetups-Wyckoff.set`
- Report toàn history: `artifacts/reports/BobH1-Matrix-Conservative-MaxHistory.htm`
- Report real ticks: `artifacts/reports/BobH1-Matrix-Conservative-RealTicks-Q3.htm`
- Optimization distance: `artifacts/reports/BobH1-Wyckoff-Distance-Opt-Train.xml`
