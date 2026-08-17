# TradingTeam - EA MT5 Development Support

`TradingTeam` hiện là đội hỗ trợ phân tích, lập trình, tích hợp, kiểm thử và phát hành Expert Advisor cho MetaTrader 5.

## Cấu trúc thư mục

- `agents/`: vai trò, tri thức, workflow và runtime của từng agent.
- `projects/`: source, test, tài liệu và release theo từng sản phẩm.
- `skills/`: tri thức dùng chung có cấu trúc.
- `templates/`: brief, contract và manifest mẫu.
- `tools/`: collector, scanner và automation scripts.
- `output/runs/`: kết quả trading/research theo từng lần chạy.

`projects/ccbsn` là project chuẩn đầu tiên áp dụng cấu trúc mới.

## Mô hình vận hành mặc định

1. `agents/Agent_1_EA_Requirements`: chuyển ý tưởng giao dịch thành đặc tả tín hiệu và máy trạng thái có thể lập trình.
2. `agents/Agent_2_MQL5_Developer`: xây kiến trúc EA, lập trình MQL5, indicator adapter và bảng điều khiển trên chart.
3. `agents/Agent_3_Signal_Integration`: nhận tín hiệu, chống lặp, kiểm tra rủi ro và thực thi lệnh an toàn.
4. `agents/Agent_4_EA_QA_Release`: review mã nguồn, backtest, forward test và đóng gói bản phát hành.

Các thư mục `Agent_1_PriceAgent`, `Agent_2_SwingAgent`, `Agent_3_ScalpingAgent` cùng các script quét thị trường được giữ lại làm tài sản legacy. Chúng không còn là pipeline mặc định, nhưng có thể cung cấp tín hiệu hoặc logic tham khảo cho dự án EA.

## Tri thức EA đã nạp

- [CCBSN EA Knowledge](./skills/ccbsn-ea-knowledge/SKILL.md): manual CCBSN v3.0.3 được chuẩn hóa và overlay thay đổi đến v3.0.5 từ kênh tác giả/dữ liệu người dùng.
- [CCBSN Controller Project](./projects/ccbsn/README.md): source MT5/Pine, kiểm thử, tài liệu, build và release được quản lý riêng.

## Hai nhóm bot ưu tiên

### Bot điều khiển bật/tắt

- bật hoặc tắt quyền vào lệnh tự động;
- bật riêng chiều Buy/Sell;
- tạm dừng theo symbol, phiên hoặc điều kiện rủi ro;
- nút đóng lệnh, hủy pending hoặc chuyển sang chế độ chỉ quản lý lệnh;
- lưu và khôi phục trạng thái an toàn sau khi EA/terminal khởi động lại.

### Bot vào lệnh theo tín hiệu

- tín hiệu từ indicator qua `iCustom` và `CopyBuffer`;
- tín hiệu từ nến/giá trực tiếp trong EA;
- tín hiệu thủ công qua nút chart;
- tín hiệu ngoài qua file, `WebRequest` hoặc cầu nối đã được phê duyệt;
- chống vào lệnh trùng bằng `signal_id`, thời gian bar và trạng thái đã xử lý.

## Chuẩn đầu ra mỗi dự án

- brief và signal contract;
- mã nguồn `.mq5`/`.mqh`, không chỉ có `.ex5`;
- cấu hình input và giả định broker;
- test matrix, báo cáo compile/backtest và known limitations;
- hướng dẫn cài đặt, rollback và version.

## Bắt đầu nhanh

1. Điền [EA Development Brief](./templates/EA_Development_Brief.md) và chốt [Signal Contract mẫu](./templates/Signal_Contract.example.json).
2. Agent 1 chuẩn hóa tín hiệu và acceptance criteria.
3. Agent 2 thiết kế module rồi viết MQL5.
4. Agent 3 nối nguồn tín hiệu với execution engine và risk guards.
5. Agent 4 compile, kiểm thử và chỉ phát hành khi đạt Definition of Done.

Xem [Global Guideline](./Global_Guideline.md) và [Master Index](./Master_Index.md) để điều hướng đầy đủ.
