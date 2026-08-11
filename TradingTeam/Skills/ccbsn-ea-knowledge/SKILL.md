---
name: ccbsn-ea-knowledge
description: Tra cứu và áp dụng tri thức về EA Can Cu Bu Sieng Nang (CCBSN) trên MT5, lấy manual chính thức v3.0.3 làm nền và bổ sung thay đổi đến v3.0.5 từ kênh tác giả. Sử dụng khi cần giải thích input, dựng hoặc review set file, phân tích DCA/martingale/tỉa lệnh/hedging/cân lots/trailing, thiết kế CCBSN chỉ Buy kết hợp bot điều khiển bật/tắt theo điều kiện thị trường, mô hình hóa New Cycle và điều khiển từ xa, đối chiếu tín hiệu/bộ lọc, viết yêu cầu tái tạo hoặc mở rộng CCBSN, hay đánh giá rủi ro vận hành.
---

# CCBSN EA Knowledge

## Quy trình sử dụng

1. Đọc [overview-and-provenance.md](references/overview-and-provenance.md) để xác định version và mức tin cậy.
2. Chọn reference đúng nhu cầu:
   - Input và công thức: [input-catalog-v3.0.5.md](references/input-catalog-v3.0.5.md).
   - Tín hiệu và filter: [signals-and-filters.md](references/signals-and-filters.md).
   - Luồng entry/DCA/exit: [operation-flow.md](references/operation-flow.md).
   - Nút, New Cycle và lệnh chờ: [controls-and-state.md](references/controls-and-state.md).
   - Review rủi ro/kỹ thuật: [risk-and-engineering-notes.md](references/risk-and-engineering-notes.md).
   - Dữ liệu máy đọc: [structured-knowledge-v3.0.5.json](references/structured-knowledge-v3.0.5.json).
   - Dấu vết manual đã nạp: [manual-source-record.json](references/manual-source-record.json).
   - Bản đồ coverage: [manual-coverage.md](references/manual-coverage.md).
   - Chiến lược CCBSN Only Buy + Controller: [only-buy-controller-strategy.md](references/only-buy-controller-strategy.md).
   - Khung điều kiện thị trường: [market-regime-gates.md](references/market-regime-gates.md).
   - Hợp đồng tích hợp bot điều khiển: [controller-integration-contract.md](references/controller-integration-contract.md).
   - State, event và hiển thị Trading Zone: [trading-zone-state-and-events.md](references/trading-zone-state-and-events.md).
   - Blueprint code Bot 2 MQL5: [bot2-implementation-blueprint.md](references/bot2-implementation-blueprint.md).
   - Policy Bot 2 M15 ATR20 + EMA23: [bot2-m15-atr20-ema23-policy.md](references/bot2-m15-atr20-ema23-policy.md).
   - Policy JSON M15 bước 2, MinATR mặc định 3.0: [controller-policy.m15-atr20-ema23.v0.3.json](references/controller-policy.m15-atr20-ema23.v0.3.json).
   - Test plan hai bot: [only-buy-controller-test-plan.md](references/only-buy-controller-test-plan.md).
   - Policy JSON mẫu: [controller-policy.example.json](references/controller-policy.example.json).
3. Phân biệt `manual v3.0.3`, `version delta v3.0.4-v3.0.5`, `default người dùng cung cấp` và `suy luận kỹ thuật`.
4. Hỏi symbol, broker properties, account currency/cent, account mode và vốn trước khi tính pip, lot hoặc money target.
5. Nêu tác động lên tổng lots, margin, drawdown, khả năng thoát chuỗi và behavior khi EA/VPS dừng.

## Nguyên tắc

- Không cam kết lợi nhuận, độ an toàn hoặc khả năng chống cháy.
- Coi DCA/martingale/hedging nhiều lớp là chiến lược có tail risk cao.
- Không coi trailing ảo là bảo vệ phía broker.
- Không coi quy đổi pip XAU/BTC là chuẩn MT5 phổ quát; kiểm tra symbol properties.
- Không lưu hoặc lặp lại credential/passview tài khoản.
- Không hướng dẫn mua lại CCBSN; tác giả công bố bot miễn phí.
- Gắn cảnh báo: mô tả kỹ thuật và hỗ trợ kiểm thử, không phải lời khuyên đầu tư.

## Khi tái tạo hoặc mở rộng

- Viết requirement và state table trước khi code.
- Đóng băng baseline Bot 1, sau đó code Bot 2 theo thứ tự `VISUAL_ONLY -> SHADOW_CONTROL -> DEMO_CONTROL -> LIVE_CONTROL`.
- Chỉ coi Trading Zone đang hoạt động sau khi New Cycle ON được xác nhận; kết thúc sau khi OFF được xác nhận.
- Tách signal, New Cycle/permission, DCA sizing, trimming, hedge, close targets và UI/remote commands.
- Định nghĩa scope Magic-Symbol cho mọi phép đếm, profit và close action.
- Tạo regression tests cho tương tác giữa tỉa, hedge, DCA, trailing và daily target.
- Không suy ngược mã nguồn/thuật toán chưa được manual mô tả từ binary `.ex5`.
