# Output

Mỗi run dùng một thư mục.

## Market/Astro route

```text
Output/<advisory_id>/
├── Master_Index.md
├── 01_Astro_Event_Brief.md
├── 02_Market_Context.md
├── 03_Cross_Asset_Impact.md
└── 04_Advisory_Report.md
```

## `Master_Index.md`

Phải ghi:

- Advisory ID;
- run type/route;
- Event ID khi có astro event;
- snapshot time;
- asset coverage;
- trạng thái;
- confidence;
- time sensitivity;
- thứ tự đọc.

## Personal route

```text
Output/<advisory_id>/
├── Master_Index.md
└── 05_Personal_Investment_Plan.md
```

`01`–`04` là optional khi personal route cần astro/market overlay. Master Index theo [Personal Run Master Index Template](../Personal_Finance/Rules/Personal_Run_Master_Index_Template.md).

Output có thể chứa educational personal investment plan nhưng AstroTeam không bao giờ phát hành chiến lược giao dịch, exact transaction instruction, leverage recommendation hoặc product-specific personalized recommendation; các yêu cầu đó được chuyển ra chuyên gia có giấy phép bên ngoài.

## Advisory mẫu

[Mercury Direct — Oil & Gold](./_Sample_Mercury_Direct_Oil_Gold/Master_Index.md) minh họa trọn vẹn năm file output, cách xử lý nguồn lệch exact time, bối cảnh dầu/vàng và các kịch bản có điều kiện.

Bộ mẫu được gắn `Expired — sample only`; không được dùng như nhận định thị trường hiện tại.
