# Personalization Authorization Gate

## 1. Mục đích

Suitability nội bộ không tạo quyền pháp lý để cung cấp regulated investment advice. Disclaimer cũng không tự loại bỏ nghĩa vụ pháp lý. Trước khi cá nhân hóa, phải ghi jurisdiction và phân loại advice mode.

## 2. Advice mode

### `Educational framework`

Mặc định khi jurisdiction hoặc hồ sơ chưa đủ. Được phép:

- giải thích nguyên tắc;
- dùng ví dụ/hypothetical ranges;
- đưa checklist và câu hỏi;
- so sánh factual features của sản phẩm.

Không gắn nhãn một sản phẩm/tỷ trọng là phù hợp với cá nhân.

### `Educational personal-planning draft`

Chỉ dùng khi:

- người dùng chủ động yêu cầu self-directed planning;
- personal intake đủ;
- planning-suitability gate đạt;
- jurisdiction check không cho thấy yêu cầu phải dừng;
- phần khuyến nghị cá nhân hóa chỉ ở cấp goal bucket và asset-class target ranges; tên sản phẩm, nếu xuất hiện, chỉ nằm trong factual comparison set trung lập và không được gắn nhãn phù hợp với cá nhân;
- ghi rõ cần licensed review trước quyết định lớn hoặc không thể đảo ngược.

Đây vẫn là công cụ giáo dục/decision support, không phải xác nhận regulatory suitability.

### Decision table

| Intake completeness | Planning suitability | Jurisdiction check | Maximum advice mode |
|---|---|---|---|
| `Đủ để lập plan` | `Đạt` | `No restriction found within draft scope` | `Educational personal-planning draft` |
| `Đủ để lập plan` | `Đạt có giới hạn` | bất kỳ | `Educational framework` |
| `Đủ để lập plan` | `Chưa đánh giá/Không đạt` | bất kỳ | `Educational framework` |
| `Đủ để minh họa` | bất kỳ | bất kỳ | `Educational framework` |
| `Chờ dữ liệu trọng yếu` | bất kỳ | bất kỳ | `Educational framework` |
| bất kỳ | bất kỳ | `Not assessed/Not established` | `Educational framework` |
| bất kỳ | bất kỳ | `Licensed review required` | `Licensed review required` |
| `Ngoài phạm vi` | bất kỳ | bất kỳ | `Outside scope` |

Mode cuối là mức hạn chế nhất trong bảng; không nâng mode bằng disclaimer hoặc user preference.

### Mapping sang plan status

| Advice mode | `05_Personal_Investment_Plan.md` status |
|---|---|
| `Educational personal-planning draft` | `Present` |
| `Educational framework` | `Framework` |
| `Licensed review required` | `Escalation` |
| `Outside scope` | `Escalation` — chỉ ghi lý do từ chối an toàn và kênh hỗ trợ phù hợp, không lập plan |

Mapping này là bắt buộc và không được suy ra lại bằng nhãn tự do.

### `Licensed review required`

Bắt buộc khi yêu cầu:

- product/security-specific personalized recommendation;
- exact buy/sell amount, share/token count, entry/exit, order type hoặc timing;
- leverage, margin, options, futures hoặc structured products;
- individualized tax/legal/estate conclusion;
- discretionary management, custody hoặc execution;
- quyết định phức tạp/không thể đảo ngược mà luật hoặc dữ liệu còn bất định.

Agent có thể chuẩn bị dữ kiện và câu hỏi để mang tới chuyên gia bên ngoài, nhưng `Licensed review required` không mở khóa cho AstroTeam phát hành recommendation hay lệnh sau đó.

### `Outside scope`

Dùng cho guarantee, fraud, credential/private-key request hoặc yêu cầu trái quy tắc an toàn.

## 3. Jurisdiction check

Record phải có:

- quốc gia cư trú và tax residency nếu liên quan;
- loại sản phẩm/thị trường;
- nguồn regulator/văn bản chính thức;
- ngày truy cập/ngày hiệu lực;
- `jurisdiction_check_status` theo canonical enum bên dưới;
- giới hạn của kết luận.

Canonical `jurisdiction_check_status` là:

- `Not assessed`;
- `Not established`;
- `No restriction found within draft scope`;
- `Licensed review required`.

Nếu chưa xác định, dùng `Not assessed` hoặc `Not established` và mặc định advice mode `Educational framework`.

FINRA suitability rules chỉ là ví dụ cho phạm vi Hoa Kỳ, không phải luật toàn cầu: [FINRA Rule 2111](https://www.finra.org/rules-guidance/rulebooks/finra-rules/2111).
