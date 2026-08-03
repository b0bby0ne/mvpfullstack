# Khung risk, suitability và danh mục

## 1. Ba chiều rủi ro

### Risk capacity — khả năng chịu lỗ

Đánh giá bằng dữ kiện:

- thời hạn từng mục tiêu;
- độ ổn định thu nhập;
- quỹ dự phòng và bảo hiểm;
- nghĩa vụ nợ/người phụ thuộc;
- nhu cầu rút tiền;
- tỷ lệ tài sản đầu tư so với tài sản thiết yếu;
- khả năng phục hồi sau drawdown.

### Risk willingness — mức sẵn lòng

Đánh giá bằng:

- phản ứng thực tế trong các đợt giảm trước;
- mức drawdown khiến người dùng mất ngủ hoặc bán tháo;
- kinh nghiệm và hiểu biết sản phẩm;
- xu hướng FOMO, concentration hoặc overtrading;
- khác biệt giữa câu trả lời giả định và hành vi thật.

### Required return và funding gap

Tính mức lợi nhuận cần thiết từ vốn hiện có, đóng góp, thời hạn và target amount bằng cùng currency/nominal-real convention. Đây là funding calculation, không phải “mức rủi ro cần thiết”. Nếu mức lợi nhuận cần thiết phi thực tế, ưu tiên điều chỉnh mục tiêu, kỳ hạn hoặc đóng góp; không tự động tăng rủi ro.

## 2. Risk ceiling

Risk ceiling bị giới hạn bởi chiều thấp nhất giữa capacity và willingness. Required return không được dùng để nâng risk ceiling. Không lấy trung bình các chiều để che lấp một giới hạn nghiêm trọng.

Kết quả dùng nhãn:

- `Bảo toàn`;
- `Thận trọng`;
- `Cân bằng`;
- `Tăng trưởng`;
- `Tăng trưởng cao`.

Nhãn phải đi kèm loss budget và stress scenario; không chỉ dựa trên tuổi.

## 3. Portfolio architecture

Xây theo mục tiêu và liability:

- `Liquidity`: tiền cho dự phòng và mục tiêu gần;
- `Stability`: tài sản biến động thấp/chất lượng tín dụng phù hợp;
- `Growth`: cổ phiếu/quỹ đa dạng cho mục tiêu dài hạn;
- `Real asset/hedge`: chỉ khi có vai trò rõ;
- `Speculative`: crypto, cổ phiếu tập trung, thematic hoặc tài sản rủi ro rất cao trong một sleeve có trần.

Không có danh mục 60/40 hay tỷ trọng vàng/crypto mặc định cho mọi người.

## 4. Khoảng phân bổ

Đề xuất dưới dạng `target range`, không phải điểm duy nhất, và ghi:

- vai trò của từng asset class;
- expected risk chứ không hứa expected return;
- concentration cap;
- currency exposure;
- liquidity floor;
- speculative cap;
- sai số dữ liệu và giả định.

Nếu dữ liệu đầu vào chưa đủ, chỉ cung cấp ví dụ minh họa, không gắn nhãn là phân bổ phù hợp cá nhân.

## 4A. Phương pháp tạo target range

1. `Funding math`: ghi PV, contribution schedule, target FV, horizon, currency, inflation/tax/fee assumptions; giải required return hoặc funding gap.
2. `Liability matching`: bảo vệ emergency reserve và các dòng tiền mục tiêu gần bằng tài sản phù hợp horizon/liquidity.
3. `Capital-market assumptions`: dùng range hiện hành cho return, volatility, correlation, drawdown và inflation; ghi nguồn/as-of/uncertainty. Không lấy một con số lịch sử làm cam kết tương lai.
4. `Constraints`: áp liquidity floor, concentration cap, currency limits, speculative cap và product restrictions.
5. `Candidate portfolios`: tạo nhiều allocation ranges ở dưới risk ceiling; không tối ưu hóa nếu inputs không đủ bền.
6. `Stress/goal test`: chọn phương án có rủi ro thấp nhất còn hợp lý với goal, hoặc ghi funding gap và điều chỉnh goal/contribution/horizon.
7. `Range width`: mở rộng range khi assumptions bất định; không đưa tỷ trọng điểm giả chính xác.

Mọi range phải truy được về funding math, constraints và assumption set. Nếu thiếu assumption set, output chỉ là educational illustration.

### Range coherence invariant

- mỗi range thỏa `0 ≤ min ≤ max ≤ 100%`;
- với một total-portfolio allocation: `Σ min ≤ 100% ≤ Σ max`;
- phải tồn tại ít nhất một candidate allocation nằm trong mọi range và có tổng đúng `100%`;
- mỗi goal bucket tự cân bằng; bảng consolidated phải hòa giải các bucket theo số vốn, không cộng tỷ lệ bucket trực tiếp;
- look-through holdings để tránh đếm trùng ETF/quỹ và cổ phiếu/tài sản cơ sở;
- concentration, speculative, currency và liquidity constraints phải còn đúng ở candidate allocation;
- không trộn phần trăm trên investable assets với phần trăm trên total net worth mà không ghi denominator.

Với contribution cuối mỗi kỳ và return mỗi kỳ `r`, có thể dùng:

```text
FV = PV × (1 + r)^n + C × ((1 + r)^n - 1) / r
```

Khi `r = 0`, dùng giới hạn `FV = PV + n × C`. Giải `r` bằng numerical root search; với contribution đầu kỳ, nhân phần niên kim với `(1 + r)`. Ghi rõ tần suất, thuế, phí, lạm phát và không làm tròn kết quả thành kỳ vọng chắc chắn.

## 5. Stress test tối thiểu

Kiểm tra plan dưới các kịch bản:

- cổ phiếu giảm sâu và hồi phục chậm;
- lãi suất/lạm phát cao hơn dự kiến;
- mất hoặc giảm thu nhập;
- nội tệ mất giá/tăng giá mạnh so với liability;
- tài sản rủi ro cao mất phần lớn giá trị;
- nhu cầu tiền mặt đến sớm hơn.

Ghi tác động tới mục tiêu, thanh khoản và hành động đã định trước. Không biến stress test thành dự báo.

## 6. Rebalancing

Chọn một policy rõ:

- theo lịch, ví dụ review định kỳ;
- theo band/threshold;
- hoặc kết hợp.

Ưu tiên dùng dòng tiền mới để giảm giao dịch; kiểm tra phí, spread, thuế và giới hạn sản phẩm trước khi bán. Astrology không tạo rebalance trigger.
