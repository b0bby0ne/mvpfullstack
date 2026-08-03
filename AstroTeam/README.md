# AstroTeam

`AstroTeam` là team phân tích tác động của các hiện tượng chiêm tinh đối với thị trường tài chính và hỗ trợ lập kế hoạch đầu tư cá nhân theo mục tiêu với lớp chiêm tinh được giới hạn rõ.

## Phạm vi

Team hỗ trợ:

- thu thập ephemeris có provenance/hash/replay, quét window và xác minh sự kiện chiêm tinh;
- giải nghiệm ingress, station, aspect, lunation và node crossing; enrichment/house modules chỉ chạy qua gate rõ ràng;
- phân tích bối cảnh kinh tế và thị trường;
- đánh giá tâm lý nhà đầu tư;
- so sánh ảnh hưởng tới chứng khoán, crypto, vàng, dầu và FX;
- xây dựng kịch bản có điều kiện;
- ghi mức tin cậy và giới hạn;
- đánh giá mục tiêu, risk capacity và suitability khi người dùng yêu cầu kế hoạch cá nhân;
- tạo draft Investment Policy Statement, khoảng phân bổ và quy tắc tái cân bằng không phụ thuộc chiêm tinh.

Team không thực thi lệnh hoặc cung cấp chiến lược giao dịch. Personal Finance track chỉ tạo educational planning draft sau planning-suitability và authorization gate, không tự nhận tư cách cố vấn có giấy phép; chiêm tinh không quyết định bất kỳ recommendation tài chính nào.

## Cấu trúc

1. `Agent_1_Astro_Event_Specialist`
2. `Agent_2_Market_Context_Analyst`
3. `Agent_3_Cross_Asset_Impact_Advisor`
4. `Agent_4_Advisory_Synthesizer`
5. `Agent_5_Personal_Investment_Advisor`

Mỗi agent có cấu trúc KWSR:

- `Knowledge/`
- `Workflows/`
- `Skills/`
- `Rules/`

Ngoài ra:

- `Financial_Market/`: tri thức, workflow và rule dùng chung.
- `Personal_Finance/`: intake, suitability, portfolio và lớp astro cá nhân có kiểm soát.
- `Output/`: lưu từng advisory run.
- `Global_Guideline.md`: quy tắc toàn team.
- `Master_Index.md`: điều hướng.
- `Test_Scenarios.md`: tình huống kiểm thử.
- `.agents/skills/astroteam-collect-astro-data/`: skill tái sử dụng để thu thập, solve, enrich và cross-validate dữ liệu chiêm tinh.

## Luồng làm việc

```text
Request router
├─ Market/Astro → Agent 1 → Agent 2 → Agent 3 → Agent 4
├─ Personal, no astrology → Agent 5
└─ Personal + astro overlay → Agent 5 baseline → Agent 1–4 khi cần → Agent 5 QA
```

## Đầu ra theo route

Market/Astro route:

- `Master_Index.md`
- `01_Astro_Event_Brief.md`
- `02_Market_Context.md`
- `03_Cross_Asset_Impact.md`
- `04_Advisory_Report.md`

Personal route:

- `Master_Index.md`
- `05_Personal_Investment_Plan.md`, với plan status `Present`, `Framework` hoặc `Escalation`
- `01`–`04` chỉ khi có astro/market overlay thực sự được chạy
