# `STORY-XTL-S01E01` — Batch A Production & QA (`P01–P06`)

## 1. Trạng thái

| Trường | Giá trị |
|---|---|
| Batch | `A — Hook / P01–P06` |
| Scope | 19 panel theo script (`3 + 3 + 4 + 3 + 3 + 3`) |
| Rough màu | `6/6 trang` |
| Lettering proof | `6/6 trang`, SVG tách lớp |
| QA | `PASS WITH 2 MINOR — Major resolved in v2` |
| Batch B | `CLEARED TO OPEN` |

## 2. Asset register

| Trang | Rough bitmap | Lettering SVG | QA |
|---:|---|---|---|
| P01 | [Rough v3](./Visual_Assets/ROUGH-P01_BatchA_v3.png) | [Lettered v3](./Visual_Assets/LETTERED-P01_BatchA_v3.svg) | Pass — bảng chưa gắn mặt trời; canvas normalized |
| P02 | [Rough v2](./Visual_Assets/ROUGH-P02_BatchA_v2.png) | [Lettered v2](./Visual_Assets/LETTERED-P02_BatchA_v2.svg) | Pass — chỉ một mặt trời trong tay Bắp |
| P03 | [Rough v3](./Visual_Assets/ROUGH-P03_BatchA_v3.png) | [Lettered v3](./Visual_Assets/LETTERED-P03_BatchA_v3.svg) | Major resolved; canvas normalized; giữ `QA-A-MIN-01` |
| P04 | [Rough v2](./Visual_Assets/ROUGH-P04_BatchA_v2.png) | [Lettered v2](./Visual_Assets/LETTERED-P04_BatchA_v2.svg) | Trigger logic và prop continuity pass |
| P05 | [Rough v2](./Visual_Assets/ROUGH-P05_BatchA_v2.png) | [Lettered v2](./Visual_Assets/LETTERED-P05_BatchA_v2.svg) | CT-1/prop pass; giữ `QA-A-MIN-02` |
| P06 | [Rough v2](./Visual_Assets/ROUGH-P06_BatchA_v2.png) | [Lettered v2](./Visual_Assets/LETTERED-P06_BatchA_v2.svg) | CT-1 scale và prop continuity pass |

## 3. QA findings

| ID | Severity | Pages | Finding | Required correction | Gate status |
|---|---|---|---|---|---|
| `QA-A-MAJ-01` | Major | P01–P06 | v1 có biểu tượng mặt trời đỏ lặp trên bảng và trong tay/trên bàn. | v2 đã xóa bản gắn trùng; mỗi trang chỉ còn một `PROP-XTL-E01-SUN`. | **Resolved** |
| `QA-A-MIN-01` | Minor | P03.2 | Người nhận keo dễ bị đọc thành Lam thay vì một bàn tay bạn nền. | Chỉnh crop/silhouette ở final rough/line art. | Open — không chặn Batch B |
| `QA-A-MIN-02` | Minor | P05.3 | Bạn nền có silhouette hơi gần Lam. | Đổi tóc/trang phục nền ở final rough/line art; không thêm nhân vật canon. | Open — không chặn Batch B |

## 4. Pass checks

- P04 có đúng ba panel, Cục Tức **chưa xuất hiện**, Lam chỉ giải thích lối mở và không bị dựng thành phản diện.
- Mặt trời/bảng chưa có đường rách; hậu quả vẫn được giữ cho P12.
- P05 giới thiệu CT-1 sau page-turn; khối không có mặt/chi, không chạm người hoặc đạo cụ.
- P06 chuyển scale viên bi → quả chanh bằng silhouette và kích thước; Lam chưa nhìn thấy Cục.
- Chữ Việt được giữ ở SVG, không ghi đè bitmap; balloon order bám script.

## 5. Exit criteria để mở Batch B

1. ~~Sửa `QA-A-MAJ-01` trên rough continuity master P01–P06.~~ Hoàn thành.
2. P03.2 và silhouette bạn nền P05.3 được hạ về Minor backlog; không ảnh hưởng canon/action.
3. ~~Re-link lettering SVG sang rough v2.~~ Hoàn thành 6/6.
4. Agent 5 recheck: `0 Blocker / 0 Major / 2 Minor` — Batch B được mở.

## 6. Correction log

| Version | Date | Change | Verification |
|---|---|---|---|
| `BatchA-v2` | 04/08/2026 | Xóa sun duplicate trên bảng P01–P06; giữ sun thật trong tay/trên bàn; tạo lettering v2 | 6 rough + 6 SVG hợp lệ; panel count không đổi; CT-1 không đổi |
| `P01/P03-v3` | 04/08/2026 | Chuẩn hóa canvas `1007×1562` thành `1024×1536`; không đổi nội dung đã duyệt | Raster/SVG đúng manifest; panel và copy không đổi |
