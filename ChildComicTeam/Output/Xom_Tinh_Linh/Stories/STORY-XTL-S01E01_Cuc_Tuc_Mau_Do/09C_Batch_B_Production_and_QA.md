# `STORY-XTL-S01E01` — Batch B Production & QA (`P07–P12`)

## 1. Trạng thái

| Trường | Giá trị |
|---|---|
| Batch | `B — Escalation / P07–P12` |
| Scope | 18 panel theo script (`4 + 3 + 3 + 3 + 3 + 2`) |
| Rough màu | `6/6 trang` |
| Lettering proof | `6/6 trang`, SVG tách lớp |
| QA | `PASS WITH 3 MINOR` |
| Blocker/Major | `0 / 0` |
| Batch C | `CLEARED TO OPEN` |

## 2. Asset register

| Trang | Rough bitmap | Lettering SVG | QA |
|---:|---|---|---|
| P07 | [Rough](./Visual_Assets/ROUGH-P07_BatchB_v1.png) | [Lettered](./Visual_Assets/LETTERED-P07_BatchB_v1.svg) | Overwork/ruler safety pass; `QA-B-MIN-01` |
| P08 | [Rough](./Visual_Assets/ROUGH-P08_BatchB_v1.png) | [Lettered](./Visual_Assets/LETTERED-P08_BatchB_v1.svg) | Shape humour pass; `QA-B-MIN-02` |
| P09 | [Rough](./Visual_Assets/ROUGH-P09_BatchB_v1.png) | [Lettered](./Visual_Assets/LETTERED-P09_BatchB_v1.svg) | Knot setup pass; `QA-B-MIN-02` |
| P10 | [Rough](./Visual_Assets/ROUGH-P10_BatchB_v1.png) | [Lettered](./Visual_Assets/LETTERED-P10_BatchB_v1.svg) | Safe rope grip + single sun pass |
| P11 | [Rough v3](./Visual_Assets/ROUGH-P11_BatchB_v3.png) | [Lettered v3](./Visual_Assets/LETTERED-P11_BatchB_v3.svg) | Choice beat/identity/sun continuity pass |
| P12 | [Rough v2](./Visual_Assets/ROUGH-P12_BatchB_v2.png) | [Lettered v2](./Visual_Assets/LETTERED-P12_BatchB_v2.svg) | Causality pass; `QA-B-MIN-03` |

## 3. Causality audit

| Step | Required reading | Evidence | Result |
|---|---|---|---|
| P09 | Dây mắc sau bảng | Nút và đường dây nhìn thấy; Lam giơ tay cảnh báo | Pass |
| P10 | Bắp biết có nút nhưng vẫn chuẩn bị kéo | Lam chỉ nút; Bắp đặt chân và cầm dây an toàn | Pass |
| P11 | Có lựa chọn thật trước hành động | Lam giữ mép bảng; panel giữa có nhịp do dự; Bắp tự kéo | Pass |
| P12 | Lực kéo gây rách | Tay Bắp → dây căng → nút → đường rách qua sun/board | Pass |
| P12 | Cục Tức không phải nguyên nhân | CT-3 ở nền, không chạm người/dây/bảng | Pass |

## 4. QA findings

| ID | Severity | Pages | Finding | Required correction | Gate status |
|---|---|---|---|---|---|
| `QA-B-MIN-01` | Minor | P07.1 | Bạn nền hỏi “Lệch không?” chưa có silhouette riêng rõ; bubble đang đọc như off-panel. | Thêm silhouette/crop bạn nền ở final rough. | Open — không chặn |
| `QA-B-MIN-02` | Minor | P08–P09 | Các pose liên tiếp của Cục có thể bị đọc thành nhiều Cục hoặc scale jump. | Dùng motion echo/overlap rõ hơn; giữ một khối chính. | Open — không chặn |
| `QA-B-MIN-03` | Minor | P12.1 | Mảnh giấy rơi chưa nổi bật ở khoảng giữa không trung. | Đẩy silhouette mảnh giấy ra khỏi nền ở final line art. | Open — không chặn |

## 5. Correction log

| Version | Change | Result |
|---|---|---|
| `P11-v2` | Khôi phục Lam giữ mép bảng và sun xuyên ba panel | Phát sinh duplicate Bắp ở panel giữa |
| `P11-v3` | Xóa duplicate Bắp; giữ mọi invariants | Pass |
| `P12-v2` | Xóa sun duplicate trên bàn; giữ sun rách trên bảng | Pass |

## 6. Exit criteria

1. 18/18 panel rough và 6/6 lettering proof tồn tại.
2. `0 Blocker / 0 Major`; ba Minor chuyển vào final-line backlog.
3. Rope safety và cause/effect P09–P12 đọc được khi bỏ chữ.
4. Cục Tức không chạm người/đạo cụ và không bị dựng thành nguyên nhân gây rách.
5. Batch C `P13–P18` được phép bắt đầu.

