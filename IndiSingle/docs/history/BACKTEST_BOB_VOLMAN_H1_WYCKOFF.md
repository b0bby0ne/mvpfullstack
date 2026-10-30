# Bob Volman H1 v1.31 + bộ lọc sự kiện Wyckoff

Ngày kiểm thử: 2026-10-07. Terminal/MetaEditor: `D:\Demo SMMA`. Symbol `XAUUSDm`, H1, vốn 10.000 USD, leverage 1:100, rủi ro 1% equity mỗi lệnh.

## Logic mới

Bảy setup Bob Volman DDB, FB, SB, BB, RB, IRB và ARB vẫn quyết định mẫu hình, trigger, SL và TP. Wyckoff chỉ là lớp xác nhận bối cảnh:

1. EA tìm range của 20 nến H1 đứng trước event.
2. Chỉ đọc nến đã đóng; không dùng nến tương lai.
3. Nhận dạng Spring, Upthrust, Sign of Strength (SOS), Sign of Weakness (SOW), Test, Last Point of Support (LPS) và Last Point of Supply (LPSY).
4. SOS/SOW cần thân nến tối thiểu 40% range nến và tick volume tối thiểu 1,30 lần trung bình 20 nến. Tick volume chỉ là proxy của broker, không phải volume tập trung của thị trường vàng.
5. Event có hiệu lực tối đa 12 nến H1. Setup BUY chỉ được nhận khi bias Wyckoff tăng; setup SELL chỉ được nhận khi bias giảm.
6. Upthrust và LPSY mặc định bị tắt sau kiểm thử; SOW và bearish Test vẫn cho phép SELL. Vì vậy EA không khóa chiều SELL toàn cục.
7. Trade comment và chú thích chart chứa cả setup và event, ví dụ `BVH1_SB_BUY_LPS`.

Chế độ `WY_FILTER_STRICT` có sẵn nhưng không được chọn làm mặc định vì giảm mẫu xuống 61 lệnh mà chỉ đạt win rate 47,54%, Net Profit 567,91 USD.

## So sánh cùng dữ liệu 2023-01-02 đến 2026-09-27

| Cấu hình | Net Profit | PF | RF | Equity DD | Trades | Win rate |
|---|---:|---:|---:|---:|---:|---:|
| v1.20, không Wyckoff | +2.241,41 | 1,13 | 1,32 | 15,10% | 288 | 45,49% |
| Wyckoff bias ban đầu | +2.541,33 | 1,35 | 3,46 | 6,83% | 127 | 48,03% |
| v1.31, cấu hình cuối | **+5.013,38** | **2,40** | **9,63** | **3,52%** | 75 | **61,33%** |

So với v1.20, cấu hình cuối tăng win rate 15,84 điểm phần trăm, tăng Net Profit 2.771,97 USD và giảm equity drawdown 11,58 điểm phần trăm. Số lệnh giảm 73,96%; đây là tác động có chủ ý của bộ lọc.

## Kiểm tra từng năm

| Giai đoạn | Net Profit | PF | RF | Equity DD | Trades | Win rate |
|---|---:|---:|---:|---:|---:|---:|
| 2023 | +1.143,03 | 2,38 | 3,90 | 2,73% | 22 | 63,64% |
| 2024 | +1.331,02 | 2,80 | 3,60 | 3,70% | 17 | 58,82% |
| 2025 | +1.460,64 | 2,38 | 4,69 | 2,73% | 26 | 61,54% |
| 2026 đến 27/09 | +309,82 | 1,78 | 1,17 | 2,57% | 10 | 60,00% |

Cả bốn lát thời gian đều dương, nhưng 2024 và 2026 có ít hơn 20 lệnh nên chưa đủ mạnh để kết luận độc lập.

## Đối chiếu Q3/2026

| Model | Net Profit | PF | RF | Equity DD | Trades | Win rate |
|---|---:|---:|---:|---:|---:|---:|
| M1 OHLC | +165,24 | 2,68 | 1,22 | 1,35% | 3 | 66,67% |
| Real ticks | +173,16 | 2,76 | 1,54 | 1,13% | 3 | 66,67% |

Hai mô hình khớp về số lệnh và win rate; chênh lệch PnL nhỏ. Mẫu ba lệnh chỉ xác nhận hành vi entry, không đủ để chứng minh hiệu suất.

## Đóng góp theo setup trong combo cuối

| Setup | Net Profit | Trades | Win rate |
|---|---:|---:|---:|
| SB | +3.267,57 | 29 | 65,52% |
| BB | +597,53 | 15 | 40,00% |
| DDB | +555,03 | 12 | 66,67% |
| FB | +515,28 | 5 | 100,00% |
| ARB | +313,99 | 10 | 50,00% |
| RB | +249,73 | 3 | 100,00% |
| IRB | -121,35 | 1 | 0,00% |

Tất cả bảy setup đều phát sinh lệnh trong combo. IRB chỉ có một lệnh nên kết quả riêng không có ý nghĩa thống kê; giữ lại để đáp ứng thiết kế đủ setup và tiếp tục thu thập forward data.

## Đóng góp theo event Wyckoff

| Event | Net Profit | Trades | Win rate |
|---|---:|---:|---:|
| SOS | +2.147,15 | 26 | 65,38% |
| LPS | +1.903,31 | 19 | 68,42% |
| Spring | +667,64 | 17 | 52,94% |
| Test | +369,71 | 6 | 66,67% |
| SOW | +289,97 | 7 | 42,86% |

Ở vòng trước, Upthrust thắng 1/5 và LPSY thắng 0/1, tổng Net Profit -466,33 USD. Hai event này bị tắt; không loại toàn bộ SELL vì SOW và bearish Test vẫn có đóng góp dương.

## Các trường hợp thua lỗ còn lại

- **BB:** 9/15 lệnh thua. Block ngắn có thể phá giả ngay cả khi bias Wyckoff đúng. TP 2,25R làm win rate thấp nhưng tổng setup vẫn lãi 597,53 USD.
- **SB:** 10/29 lệnh thua, chủ yếu khi lần break thứ hai xuất hiện muộn sau SOS/LPS và động lượng đã cạn. TP 2R giúp setup vẫn là nguồn lợi nhuận lớn nhất.
- **Spring:** 8/17 lệnh thua. Việc giá đóng lại trong range không bảo đảm đã kết thúc markdown; có trường hợp chỉ là nhịp hồi trước khi phá đáy tiếp.
- **SOW:** 4/7 lệnh thua. Vàng có thể hồi mạnh sau breakdown có volume, đặc biệt khi breakdown xuất hiện gần cuối nhịp giảm.
- **ARB:** 5/10 lệnh thua. False break được xác nhận nhưng giá không đi hết range tới trigger/target đối diện hoặc đảo chiều sau breakout.
- **DDB:** 4/12 lệnh thua do vùng doji nhỏ dễ bị quét cả hai phía trong biến động H1.
- **IRB:** một lệnh duy nhất thua; chưa đủ mẫu để điều chỉnh thêm mà không tạo overfit.

SL vẫn nằm ngoài nến tín hiệu và volume được tính để 1R bằng 1% equity. Vì vậy một lệnh thua bình thường xấp xỉ 1% tại thời điểm entry; gap, spread và swap có thể làm kết quả thực tế lệch nhẹ.

## Kiểm tra vận hành

- Compile bằng MetaEditor: 0 lỗi, 0 cảnh báo.
- Không thấy array-out-of-range, zero-divide, lỗi indicator handle hoặc vị thế treo trong các lượt xác nhận.
- Tester có một số `TRADE_RETCODE_MARKET_CLOSED` tại giờ nghỉ giao dịch của broker. EA ghi log và xóa pending ngay sau reject, không retry liên tục và không giữ tín hiệu cũ qua phiên sau.
- Bộ lọc session của setup vẫn được kiểm tra tại lúc breakout/entry.

## Giới hạn

Các ngưỡng Wyckoff được chọn từ hai vòng, tổng 162 tổ hợp trên chính history 2023–2026. Kết quả từng năm ổn định hơn baseline nhưng vẫn là in-sample. Cần forward-test demo tối thiểu 100 lệnh; không tăng risk trên 1% chỉ vì backtest hiện tại có drawdown thấp.

## Artifacts

- Preset cuối: `tests/sets/BobH1-AllSetups-Wyckoff.set`
- Report toàn history: `artifacts/reports/BobH1-AllSetups-Wyckoff-Final-MaxHistory.htm`
- Report real ticks Q3: `artifacts/reports/BobH1-AllSetups-Wyckoff-Final-RealTicks-Q3.htm`
- Optimization: `artifacts/reports/BobH1-AllSetups-Wyckoff-Opt.xml` và `BobH1-AllSetups-Wyckoff-Refine-Opt.xml`
