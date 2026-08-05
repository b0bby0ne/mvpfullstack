# `STORY-XTL-S01E01` — Batch C Production & QA (`P13–P18`)

## 1. Trạng thái

| Trường | Giá trị |
|---|---|
| Batch | `C — Regulation / P13–P18` |
| Scope | 17 panel theo script (`3 + 3 + 3 + 3 + 2 + 3`) |
| Rough màu | `6/6 trang` |
| Lettering proof | `6/6 trang`, SVG tách lớp |
| QA | `PASS WITH 3 MINOR` |
| Blocker/Major | `0 / 0` |
| Batch D | `CLEARED TO OPEN` |

## 2. Asset register

| Trang | Rough bitmap | Lettering SVG | QA |
|---:|---|---|---|
| P13 | [Rough](./Visual_Assets/ROUGH-P13_BatchC_v1.png) | [Lettered](./Visual_Assets/LETTERED-P13_BatchC_v1.svg) | Hậu quả và rút khỏi tình huống đọc rõ; `QA-C-MIN-01` |
| P14 | [Rough v2](./Visual_Assets/ROUGH-P14_BatchC_v2.png) | [Lettered v2](./Visual_Assets/LETTERED-P14_BatchC_v2.svg) | Cô Sen đúng vai người lớn; lựa chọn và khoảng cách pass |
| P15 | [Rough v2](./Visual_Assets/ROUGH-P15_BatchC_v2.png) | [Lettered v2](./Visual_Assets/LETTERED-P15_BatchC_v2.svg) | Nhận biết tín hiệu cơ thể, nước đặt trong tầm với; `QA-C-MIN-02` |
| P16 | [Rough](./Visual_Assets/ROUGH-P16_BatchC_v1.png) | [Lettered](./Visual_Assets/LETTERED-P16_BatchC_v1.svg) | Hai phía của Cục và ý định nói đọc rõ; `QA-C-MIN-03` |
| P17 | [Rough](./Visual_Assets/ROUGH-P17_BatchC_v1.png) | [Lettered](./Visual_Assets/LETTERED-P17_BatchC_v1.svg) | Gọi tên cơn giận; chỉ vào vật bị đổi, không chỉ vào Lam |
| P18 | [Rough](./Visual_Assets/ROUGH-P18_BatchC_v1.png) | [Lettered](./Visual_Assets/LETTERED-P18_BatchC_v1.svg) | Hai phía nhận phần trách nhiệm; Cục hạ nhưng còn hiện diện |

## 3. Regulation và safety audit

| Beat | Yêu cầu | Bằng chứng hình | Kết quả |
|---|---|---|---|
| P13 | Bắp rời tình huống, không bị đuổi/phạt | Bắp tự quay về bậc hiên; Lam giữ khoảng cách | Pass |
| P14 | Người lớn đưa lựa chọn thật | Cô Sen đứng xa, sau đó ngồi đúng vị trí Bắp chỉ | Pass |
| P15 | Nhận biết cơ thể không bị y khoa hóa | Bắp quan sát bàn tay/má; không gắn nhãn chẩn đoán | Pass |
| P15 | Hỗ trợ không ép buộc | Cô Sen đặt nước trong tầm với, không chạm Bắp | Pass |
| P16–P17 | Trẻ tự chọn nói và gọi tên cảm xúc | Bắp quay về phía Lam, nói “Tớ đang giận” | Pass |
| P17 | Không biến lời nói thành đổ lỗi con người | Bắp chỉ phần mặt trời/bảng bị rách, không chỉ Lam | Pass |
| P18 | Hai phía cùng giữ trách nhiệm | Lam nhận cần hỏi trước; Bắp nhận “không sao” không thật | Pass |
| P13–P18 | Cục Tức phản chiếu, không điều khiển hay biến mất | Cục chia khung, hạ dần và vẫn thấy rõ ở P18 | Pass |

## 4. QA findings

| ID | Severity | Pages | Finding | Required correction | Gate status |
|---|---|---|---|---|---|
| `QA-C-MIN-01` | Minor | P13.3 | Cục đi theo Bắp chưa có motion cue rõ; khối chính vẫn đọc như ở sau bảng. | Thêm overlap/motion echo hướng về bậc hiên ở final line art. | Open — không chặn |
| `QA-C-MIN-02` | Minor | P15.1 | Chuyển động “ngón tay từ từ mở” mới thể hiện một tay mở, tay còn lại siết. | Thêm hai pose nhỏ hoặc motion echo của các ngón ở final line art. | Open — không chặn |
| `QA-C-MIN-03` | Minor | P16.3 | Bắp đã quay đối diện Lam nhưng chuyển động xoay ghế chưa có chỉ báo mạnh. | Thêm đường dịch chân ghế/đổi góc rõ hơn ở final line art. | Open — không chặn |

## 5. Correction log

| Version | Change | Result |
|---|---|---|
| `P14-v2` | Thay Lam ở panel 2–3 bằng Cô Sen đúng model người lớn; giữ khoảng cách và bố cục | Pass |
| `P15-v2` | Thay Lam ở panel 3 bằng Cô Sen đặt nước, không chạm Bắp | Pass |

## 6. Exit criteria

1. 17/17 panel rough và 6/6 lettering proof tồn tại.
2. `0 Blocker / 0 Major`; ba Minor chuyển vào final-line backlog.
3. Safe pause được thể hiện như lựa chọn, không phải trừng phạt hay ép trẻ bình tĩnh.
4. Bắp và Lam đều có agency; lời xin lỗi/nhận trách nhiệm không làm nhục bên nào.
5. Cục Tức hạ dần nhưng không biến mất; Batch D `P19–P24` được phép bắt đầu.
