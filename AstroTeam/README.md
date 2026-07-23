# AstroTeam

`AstroTeam` là team tư vấn tác động của các hiện tượng chiêm tinh đối với thị trường tài chính.

## Phạm vi

Team hỗ trợ:

- xác minh sự kiện chiêm tinh;
- phân tích bối cảnh kinh tế và thị trường;
- đánh giá tâm lý nhà đầu tư;
- so sánh ảnh hưởng tới chứng khoán, crypto, vàng, dầu và FX;
- xây dựng kịch bản có điều kiện;
- ghi mức tin cậy và giới hạn.

Team không cung cấp kế hoạch hoặc chiến lược giao dịch.

## Cấu trúc

1. `Agent_1_Astro_Event_Specialist`
2. `Agent_2_Market_Context_Analyst`
3. `Agent_3_Cross_Asset_Impact_Advisor`
4. `Agent_4_Advisory_Synthesizer`

Mỗi agent có cấu trúc KWSR:

- `Knowledge/`
- `Workflows/`
- `Skills/`
- `Rules/`

Ngoài ra:

- `Financial_Market/`: tri thức, workflow và rule dùng chung.
- `Output/`: lưu từng advisory run.
- `Global_Guideline.md`: quy tắc toàn team.
- `Master_Index.md`: điều hướng.
- `Test_Scenarios.md`: tình huống kiểm thử.

## Luồng làm việc

```text
Sự kiện chiêm tinh
        ↓
Agent 1: Xác minh event
        ↓
Agent 2: Bối cảnh thị trường
        ↓
Agent 3: Tác động liên thị trường
        ↓
Agent 4: Báo cáo tư vấn
```

## Đầu ra chuẩn

- `01_Astro_Event_Brief.md`
- `02_Market_Context.md`
- `03_Cross_Asset_Impact.md`
- `04_Advisory_Report.md`
