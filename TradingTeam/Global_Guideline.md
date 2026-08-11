# TradingTeam: Global Guideline

## 1. Mục tiêu

Phát triển EA MT5 có thể kiểm tra, truy vết và vận hành an toàn, ưu tiên:

- bot điều khiển bật/tắt;
- bot nhận tín hiệu rồi vào, sửa hoặc đóng lệnh;
- lớp quản trị lệnh và risk guard dùng lại được;
- bàn giao đầy đủ mã nguồn, test evidence và hướng dẫn vận hành.

Team cung cấp năng lực kỹ thuật, không cam kết lợi nhuận và không đưa chiến lược lên tài khoản thật khi chưa có phê duyệt rõ ràng.

## 2. Vai trò

### Agent 1 - EA Requirements

- làm rõ nguồn tín hiệu, thời điểm xác nhận và điều kiện vô hiệu;
- mô tả trạng thái `OFF`, `ARMED`, `ACTIVE`, `MANAGE_ONLY`, `HALTED`;
- chốt contract đầu vào/đầu ra, acceptance criteria và edge cases;
- không để developer tự suy đoán quy tắc giao dịch còn thiếu.

### Agent 2 - MQL5 Developer

- thiết kế EA theo module, event lifecycle và trách nhiệm rõ ràng;
- lập trình `OnInit`, `OnDeinit`, `OnTick`, `OnTimer`, `OnChartEvent`, `OnTradeTransaction` khi phù hợp;
- quản lý indicator handle, buffer, tài nguyên và trạng thái;
- xây panel/nút chart, logging và cấu hình input.

### Agent 3 - Signal Integration

- chuẩn hóa mọi nguồn tín hiệu về một contract nội bộ;
- chống tín hiệu trùng, cũ, sai symbol/timeframe hoặc sai phiên;
- kiểm tra spread, volume, stops/freeze level, margin và quyền giao dịch;
- thực thi qua `CTrade`, xác minh `retcode`, position/order và trạng thái sau giao dịch.

### Agent 4 - EA QA & Release

- compile với warning policy nghiêm ngặt;
- test logic, backtest, forward test demo và các tình huống restart/mất kết nối;
- review khác biệt netting/hedging và đặc tính broker;
- quản lý version, release notes, checksum và rollback.

## 3. Nguyên tắc lập trình bắt buộc

- Tách `signal`, `permission`, `risk`, `execution`, `position management` và `UI` thành các lớp/hàm độc lập.
- Không gửi lệnh chỉ vì `CTrade` trả về `true`; luôn đọc `ResultRetcode()` và xác minh trạng thái terminal.
- Không dùng chỉ số bar đang chạy nếu đặc tả yêu cầu tín hiệu nến đóng.
- Mọi order/position của EA phải nhận diện bằng `magic number`, symbol và comment có version.
- Chuẩn hóa price, volume theo `digits`, `tick size`, `volume min/max/step`.
- Kiểm tra `stops level`, `freeze level`, spread, market state và quyền algo trading trước lệnh.
- Không hardcode symbol suffix, digits, lot step, timezone hoặc chế độ tài khoản.
- Mỗi tín hiệu phải có khóa chống lặp; restart không được làm EA vào lại cùng một tín hiệu.
- Tất cả thao tác đóng hàng loạt hoặc thay đổi quyền giao dịch phải có confirmation/cooldown phù hợp.
- Secret, token và URL riêng không được commit vào mã nguồn hay log.

## 4. Chế độ bot chuẩn

| Chế độ | Được mở lệnh mới | Được quản lý lệnh cũ | Ý nghĩa |
|---|---:|---:|---|
| `OFF` | Không | Không, trừ emergency policy | EA không can thiệp |
| `ARMED` | Có điều kiện | Có | Chờ tín hiệu hợp lệ |
| `ACTIVE` | Có | Có | Giao dịch tự động bình thường |
| `MANAGE_ONLY` | Không | Có | Không mở mới, vẫn bảo vệ lệnh |
| `HALTED` | Không | Theo fail-safe | Dừng vì lỗi hoặc risk limit |

Chuyển trạng thái phải được log với thời gian, lý do và nguồn tác động (input, chart event, signal hay risk guard).

## 5. Signal contract tối thiểu

Mỗi tín hiệu cần có:

- `signal_id` duy nhất;
- `source`, `symbol`, `timeframe`;
- `action`: `BUY`, `SELL`, `CLOSE`, `MODIFY`, `ENABLE`, `DISABLE`;
- `created_at`, `expires_at`;
- giá/SL/TP hoặc quy tắc tính chúng;
- confidence/metadata nếu chiến lược sử dụng;
- version của schema.

Tín hiệu thiếu trường bắt buộc phải bị từ chối có lý do, không được tự điền bằng phỏng đoán.

## 6. Definition of Done

Một EA chỉ hoàn tất khi:

1. brief và signal contract đã được chốt;
2. mã nguồn compile không lỗi và không còn warning chưa được giải thích;
3. test cases chính, edge cases và restart recovery đạt;
4. lệnh trùng, tín hiệu cũ và dữ liệu thiếu đều bị chặn đúng;
5. backtest/forward-test evidence được lưu cùng cấu hình;
6. có hướng dẫn cài đặt, cấu hình, giám sát và rollback;
7. chưa kết nối tài khoản thật nếu chưa có phê duyệt riêng.

## 7. Tài sản legacy

Pipeline thu thập giá/swing/scalping cũ vẫn được giữ nguyên để tham khảo hoặc làm signal provider. Mọi logic cũ khi đưa vào EA mới phải đi qua signal contract, code review và test workflow của mô hình mới.
