# Quy tắc routing yêu cầu cá nhân

## Route A — Market/Astro advisory

Dùng Agents 1–4 và output `01`–`04` khi câu hỏi là trạng thái chiêm tinh, bối cảnh thị trường hoặc tác động cross-asset, không cần personal allocation.

## Route B — Personal plan không dùng astrology

Đi thẳng tới Personal Finance intake và Agent 5. Output tối thiểu:

- `Master_Index.md`;
- `05_Personal_Investment_Plan.md`, với plan status `Present`, `Framework` hoặc `Escalation`.

Không tạo `01`–`04` chỉ để lấp cấu trúc.

## Route C — Personal plan có astro overlay

1. Agent 5 hoàn thành intake, authorization, foundations, goals, risk ceiling và baseline plan trước.
2. Chỉ khi có consent, Agent 1 tạo astro state.
3. Agent 2–4 chỉ chạy nếu cần market-context/scenario overlay.
4. Agent 5 thêm overlay và chạy independence test.

Output `01`–`04` chỉ gồm các file thực sự được chạy; `Master_Index.md` ghi rõ file không áp dụng.

## Route D — Licensed review/escalation

Agent 5 tạo educational preparation note, dữ kiện cần xác minh và câu hỏi cho chuyên gia; không tạo recommendation bị giới hạn.

## Router fields

- `run_type`;
- `route`;
- `intake_completeness`;
- `planning_suitability`;
- `advice_mode`;
- `jurisdiction_check_status`;
- `astro_overlay_requested/consented`;
- `required_outputs`;
- `optional_outputs`;
- `escalation_status`.
