# `STORY-XTL-S01E01` — Art, Color & Lettering Prototype

## 1. Gate và trạng thái

| Trường | Giá trị |
|---|---|
| Art Gate | `APPROVED — 04/08/2026` |
| Người duyệt | Người dùng/Creative Lead; visual safety checklist của Agent 5 không có Blocker/Major |
| Production task | `P07 — Art, màu và lettering prototype` |
| Owner | `Agent_8_Visual_Storyboard_Producer` phối hợp `Agent_5_Child_Safety_Editorial_QA` |
| Trạng thái | `Rough production complete — desk preflight done; 3 Major release blockers open` |
| Hoàn thành trong vòng này | Production model sheet v1; 24/24 rough màu; 24/24 SVG lettering; 73/73 panel; typography/color/accessibility spec |
| Chưa hoàn thành | Mobile lettering/panel reader, human read-aloud, font/license lock, trim/bleed, 300-ppi print master và color proof |

## 2. Asset register

| Asset | Vai trò | Trạng thái |
|---|---|---|
| [VD-02 Production Model Sheet](./Visual_Assets/VD-02_Production_Model_Sheet_v1.png) | Turnaround, expression, CT-1–4 và grayscale silhouette | Khóa cho rough production |
| [P04 Lettering Proof](./Visual_Assets/PROOF-P04_Lettering_v1.svg) | Ba câu thoại của trigger scene | Prototype; art nền cần dựng lại đúng panel script |
| [P12 Lettering Proof](./Visual_Assets/PROOF-P12_Lettering_v1.svg) | SFX hậu quả và khoảng lặng | Prototype; art nền cần làm rõ tay kéo/vết rách |
| [P24 Lettering Proof](./Visual_Assets/PROOF-P24_Lettering_v1.svg) | Final line, bảng ngày hội và SFX nhỏ | Prototype đạt hướng |

Lettering được giữ dưới dạng SVG riêng, liên kết tới raster nền. Cách này giữ chữ tiếng Việt chính xác và cho phép thay font/kích thước mà không ghi đè tranh đã duyệt.

## 3. Copy deck đã khóa

| Panel | Speaker/type | Text verbatim | Ưu tiên đọc |
|---|---|---|---:|
| `P04.1` | Bắp | `Ơ… cậu đổi chỗ à?` | 1 |
| `P04.2` | Lam | `Ừ. Chỗ cũ chắn lối.` | 2 |
| `P04.3` | Bắp | `Không sao.` | 3 |
| `P12.1` | SFX | `RẸẸẸT!` | 1 |
| `P12.2` | SFX | `xào` | 2 |
| `P24.1` | Lam | `Mình cùng lo.` | 1 |
| `P24.2` | Sign | `NGÀY HỘI XÓM MÌNH` | 2 |
| `P24.2` | SFX | `ụp` | 3 |

## 4. Typography prototype

- Font stack làm việc: `Noto Sans, Arial, sans-serif`; chưa khóa font final cho tới khi Rights Gate xác nhận file font và license.
- Dialogue: sentence case, weight khoảng 650, tối đa 2 dòng/bóng ở khổ prototype.
- SFX: có stroke tương phản, hình dáng chữ hỗ trợ âm lượng; không dùng màu đỏ là tín hiệu duy nhất.
- Dấu tiếng Việt phải kiểm bằng mắt sau export: `Ơ`, `Ừ`, `Ẹ`, `À`, `Ì`, `ụ`.
- Không rasterize lettering trước preflight; balloon và tail nằm trong safe area.

## 5. Color và kiểm không phụ thuộc màu

| Thành phần | Color role | Tín hiệu phụ bắt buộc |
|---|---|---|
| Bắp | Mustard/teal | Túi dây, tóc và silhouette hành động |
| Lam | Blue/leaf/navy | Bob hair, sổ và bút chì |
| Cô Sen | Cream/mauve/plum | Búi tóc, khăn và posture mở |
| Cục Tức | Coral → burgundy | Diện tích, trọng lượng, nếp gấp, khoảng chiếm khung |
| Board damage | Red/cream craft palette | Đường rách/vá và shape không đều |

`VD-02` có grayscale silhouette dưới từng state của Cục Tức. Kết quả: CT-1/2/3/4 vẫn phân biệt được khi bỏ màu; pass cho model level. Kiểm grayscale toàn trang sẽ lặp lại ở preflight sau khi có rough/final art.

## 6. Production batches 24 trang

| Batch | Trang | Mục tiêu | Điều kiện sang batch sau |
|---|---|---|---|
| A — Hook | P01–P06 | Geography, props, trigger, CT-1 | P04 dialogue order và page-turn đọc đúng |
| B — Escalation | P07–P12 | Overwork, rope continuity, CT-2/3, tear | Nguyên nhân rách là tay Bắp; không ai bị thương |
| C — Regulation | P13–P18 | Safe pause, body cue, naming/listening | Cô Sen không áp đảo; Cục hạ nhưng không biến mất |
| D — Repair | P19–P24 | Nhận lỗi, xin phép, cùng vá, ending | Seam/lối đi/CT-4 và sự kiện xuyên mùa còn rõ |

## 7. QA trước full production

- `P04`: dựng lại Lam và lối đi đúng ba panel; proof hiện tại chỉ khóa style/lettering hierarchy.
- `P12`: dựng action tay Bắp kéo và đường rách xuyên bảng đúng script; giữ Cục không chạm ai.
- `P24`: giữ bảng, đường vá, lối mở và CT-4; kiểm bóng thoại không che hành động tay.
- Thực hiện read-aloud copy deck và kiểm font trên thiết bị trước khi khóa lettering.
- Không mở motion/distribution dựa trên asset prototype chưa preflight.

## 8. Exit criteria của P07

1. Rough 24 trang khớp 73 panel và panel manifest.
2. Color pass đọc được ở grayscale và trên màn hình nhỏ.
3. Lettering tiếng Việt không lỗi dấu, không tràn bóng, đúng thứ tự đọc.
4. Agent 5 không còn Blocker/Major; Creative Lead duyệt proof toàn tập.
5. Font/reference/AI asset provenance sẵn sàng cho Rights Gate.

## 9. Batch production log

| Batch | Trang | Output | QA | Trạng thái |
|---|---|---|---|---|
| A — Hook | P01–P06 | [Batch A Production & QA](./09B_Batch_A_Production_and_QA.md) | 0 Blocker / 0 Major / 2 Minor | Pass; Batch B được mở |
| B — Escalation | P07–P12 | [Batch B Production & QA](./09C_Batch_B_Production_and_QA.md) | 0 Blocker / 0 Major / 3 Minor | Pass; Batch C được mở |
| C — Regulation | P13–P18 | [Batch C Production & QA](./09D_Batch_C_Production_and_QA.md) | 0 Blocker / 0 Major / 3 Minor | Pass; Batch D được mở |
| D — Repair | P19–P24 | [Batch D Production & QA](./09E_Batch_D_Production_and_QA.md) | 0 Blocker / 0 Major / 3 Minor | Pass; rough production complete |
