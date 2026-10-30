# 07 — EUR/USD macro + D1/H4/H1 playbook

## Quy trình ra quyết định

Mỗi setup phải đi qua bốn lớp theo đúng thứ tự:

1. **Macro regime:** relative 2Y impulse, central-bank surprises, risk và energy.
2. **D1 bias:** macro state đồng thuận với vị trí so SMA200.
3. **H4 location:** hỗ trợ/kháng cự, liquidity, acceptance/rejection; không vào giữa range.
4. **H1 trigger:** displacement + break/reclaim cấu trúc + retest, với invalidation cụ thể.

Nếu lớp trên không rõ, lớp dưới không có quyền tạo conviction.

## Ma trận bias D1 đã backtest

| Macro state | Giá vs SMA200 | Hành động |
|---|---|---|
| z > +0.5 / macro long | Trên SMA200 | Chỉ tìm long |
| z < -0.5 / macro short | Dưới SMA200 | Chỉ tìm short |
| Macro và trend bất đồng | Bất kỳ | Flat / giảm size |
| `|z| < 0.25` | Bất kỳ | Macro neutral; thoát bias |

Đây là logic đã backtest trên D1. H4/H1 dưới đây là framework thực thi chưa được backtest trong run này.

## Snapshot 22/09/2026

| Biến | Giá trị | Diễn giải |
|---|---:|---|
| EUR/USD | 1.1463 | Sát đáy 20D |
| SMA50 | 1.15381 | Kháng cự động gần |
| SMA200 | 1.16266 | D1 trend bearish |
| 20D low/high | 1.1460 / 1.1669 | Giá ở đáy range |
| 60D low/high | 1.1367 / 1.1699 | Reference tiếp theo |
| EUR 2Y − US 2Y | -161.24 bp | USD front-end advantage |
| 20D spread impulse | -19.28 bp | Spread xấu đi cho EUR |
| Robust macro z | -1.721 | Macro short state |
| VIX / trailing 75th | 14.87 / 19.08 | Normal-VIX regime |
| DFR − EFFR | -138 bp | Carry prior nghiêng USD |

Bias nền: **bearish EUR/USD**. Vị trí: **không chase short ngay trên 1.1460**.

## Kịch bản A — continuation short được xác nhận

Điều kiện bắt buộc:

- D1 hoặc ít nhất H4 đóng và chấp nhận dưới `1.1460`;
- nhịp retest từ dưới thất bại;
- H1 tạo bearish displacement, phá swing low rồi retest vùng supply/FVG vừa hình thành;
- relative 2Y impulse không hồi mạnh vào neutral.

Thực thi:

- entry sau H1 confirmation, không sell cây breakout mở rộng;
- stop trên H1 swing/retest high, cộng buffer theo spread/ATR;
- objective đầu quanh `1.1367`; chỉ trail sâu hơn nếu H4 tiếp tục tạo lower high/lower low;
- bỏ lệnh nếu breakout quay lại và H4 reclaim `1.1460` nhanh.

## Kịch bản B — pullback short, ưu tiên hơn chase

Vùng theo dõi:

- `1.1538` quanh SMA50;
- `1.1627` quanh SMA200;
- `1.1669–1.1699` là cụm high 20D/60D nếu squeeze sâu.

Trigger hợp lệ:

- H4 sweep buy-side liquidity/reject vùng;
- H1 chuyển từ higher-high/higher-low sang lower-high/lower-low;
- bearish displacement có follow-through và retest;
- yield spread không xác nhận cú hồi EUR.

Targets: `1.1460`, sau đó `1.1367`. Không đặt stop chỉ vì một con số tròn; đặt tại điểm thesis H1/H4 sai.

## Kịch bản C — false break / đứng ngoài

Nếu giá quét dưới `1.1460` rồi H4 đóng trở lại trên và H1 reclaim mạnh, không tiếp tục short. Đây có thể là Wyckoff-style spring/liquidity sweep nhưng chưa đủ để long theo hệ thống vì D1 và macro vẫn bearish.

Hành động: flat, đợi retest. Countertrend long nếu có chỉ là setup riêng, size nhỏ hơn và phải chốt trước resistance; không được ghi nhận như lệnh theo model.

## Kịch bản D — đảo sang long có hệ thống

Chỉ nâng thành long bias khi cả hai xảy ra:

1. macro z đi vào neutral rồi vượt `+0.5`; và
2. D1 đóng, giữ trên SMA200 hiện quanh `1.1627`.

Xác nhận chất lượng cao hơn nếu giá reclaim `1.1669–1.1699`, sau đó H4 giữ higher low. Nếu chỉ giá vượt SMA200 nhưng rate impulse vẫn âm, đó là bất đồng → flat, không long full size.

## Invalidation ở ba cấp

- **Trade invalidation:** H1/H4 swing làm thesis entry sai; dùng cho stop.
- **Tactical invalidation:** H4/D1 reclaim vùng breakout hoặc thất bại giữ location; dừng tìm setup cùng hướng.
- **Regime invalidation:** `|z| < 0.25` hoặc macro/trend bất đồng; model về flat.

Không dùng SMA200 làm stop H1 nếu khoảng cách quá lớn. Stop và model-exit là hai khái niệm khác nhau.

## Position sizing

```text
risk_cash = account_equity × risk_percent
lot_size  = risk_cash / (stop_pips × pip_value_per_lot)
```

Khung bảo thủ để forward-test:

- risk `0.25–0.50%` equity mỗi setup;
- tổng risk cùng thesis EUR/USD không vượt giới hạn ngày/tuần đã định trước;
- giảm size trước CPI/NFP/FOMC/ECB hoặc khi spread broker nới;
- không tăng lot để bù lệnh thua;
- chỉ nhận lệnh khi reward đến objective hợp lý ít nhất tương xứng risk sau chi phí.

## Checklist trước lệnh

- [ ] Snapshot macro có timestamp và ngày quan sát cuối?
- [ ] Surprise được đo so với consensus/pricing, không chỉ actual?
- [ ] EUR–US 2Y impulse cùng hướng với lệnh?
- [ ] D1 cùng phía SMA200?
- [ ] Giá ở location H4 rõ, không ở giữa range?
- [ ] H1 có displacement, structure break và retest?
- [ ] Entry, stop, target, invalidation và risk_cash đã ghi trước?
- [ ] Có event trong thời gian giữ dự kiến?
- [ ] Spread/slippage hiện tại có làm hỏng R:R?

## Nhật ký bắt buộc

Ghi model version, macro z, 2Y spread/impulse, D1 SMA state, VIX regime, event risk, H4 zone, H1 trigger, screenshot trước/sau, planned R, realized R, MAE/MFE và lý do exit. Tách kết quả:

- setup đúng playbook;
- discretionary override;
- event trade;
- countertrend trade.

Nếu trộn các loại lệnh, không thể biết model có thực sự tạo edge live hay không.

## Lưu ý bằng chứng

Các level trên được tính từ daily ECB reference fix, không phải giá live của broker. Cần cập nhật SMA/range/yield data trước phiên giao dịch. Framework này phục vụ nghiên cứu và quản trị quyết định; không phải khuyến nghị đầu tư cá nhân hay bảo đảm lợi nhuận.
