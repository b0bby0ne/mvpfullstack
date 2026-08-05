# 18 — Bảng quản lý tiến độ Comic Portfolio

## 1. Thông tin quản trị

| Trường | Giá trị |
|---|---|
| Series | `Xóm Tinh Linh` |
| Series ID | `SERIES-XTL-001` |
| Thời gian kế hoạch | `04/08/2026–02/11/2026` |
| Chu kỳ | `13 tuần / 90 ngày` |
| Mục tiêu | Hoàn thiện nền móng IP, sản xuất và phát hành pilot 1, khởi động pilot 2, ra quyết định go/no-go cho mùa 1 |
| Pilot 1 | `Cục Tức Màu Đỏ` |
| Pilot 2 đề xuất | `Con Suối Mang Rác Từ Đâu` |
| Ngày cập nhật bảng | `05/08/2026` |
| Người cập nhật | `[Điền tên PM/Producer]` |
| Tiến độ tổng | `66% — gói social 24 ảnh đã QA; Facebook/Threads chờ quyền tài khoản để đăng` |

## 2. Quy ước sử dụng

### Trạng thái

| Trạng thái | Ý nghĩa |
|---|---|
| Chưa bắt đầu | Chưa có người thực hiện hoặc chưa tới ngày bắt đầu |
| Sẵn sàng | Đã đủ đầu vào và có thể bắt đầu |
| Đang thực hiện | Đã có sản phẩm dở dang |
| Chờ duyệt | Đã nộp, đang chờ phản hồi |
| Bị chặn | Không thể tiếp tục vì thiếu đầu vào hoặc quyết định |
| Hoàn thành | Đã qua cổng duyệt và lưu đúng thư mục |
| Tạm hoãn | Chủ động rút khỏi chu kỳ hiện tại |

### Vai trò

| Mã | Vai trò | Agent mặc định |
|---|---|---|
| PM | Producer/điều phối tiến độ | `Agent_6_Portfolio_Producer` |
| CL | Creative Lead/chủ sở hữu canon | `Agent_2_Story_Architect` |
| RS | Researcher | `Agent_7_Research_Cultural_Validator` |
| WR | Biên kịch comic/prose | `Agent_3_Comic_Scriptwriter` / `Agent_4_Prose_Story_Writer` |
| SB | Storyboard Artist | `Agent_8_Visual_Storyboard_Producer` |
| ART | Họa sĩ/Colorist/Letterer | `Agent_8_Visual_Storyboard_Producer` điều phối |
| ED | Biên tập | `Agent_5_Child_Safety_Editorial_QA` |
| QA | Child Safety/Education QA | `Agent_5_Child_Safety_Editorial_QA` |
| MD | Motion/Distribution | `Agent_9_Motion_Distribution_Producer` |

Mỗi đầu việc chỉ có **một người chịu trách nhiệm cuối cùng**. Nếu một vai trò có nhiều thành viên, ghi tên cụ thể sau mã, ví dụ `ART — Lan`.

## 3. Dashboard 90 ngày

| Giai đoạn | Thời gian | Mục tiêu | Deliverable bắt buộc | Cổng duyệt | Trạng thái |
|---|---|---|---|---|---|
| 1. Nền móng | 04/08–24/08 | Khóa hệ thống IP và sản xuất | Series Bible v1, cast, visual guide, template research/QA, bốn pilot | Gate A — Canon Ready | Chưa bắt đầu |
| 2. Prototype | 25/08–21/09 | Hoàn thành gói pilot 1 | Comic, truyện chữ, 3 clip prototype, parent/activity card, source note | Gate B — Pilot Ready | Chưa bắt đầu |
| 3. Pilot công khai | 22/09–12/10 | Phát hành và thiết lập baseline | Trang canon, video 4–8 phút, clip khám phá, moderation log, báo cáo phản hồi | Gate C — Release Validated | Chưa bắt đầu |
| 4. Mở rộng | 13/10–02/11 | Khởi động pilot 2 và quyết định mùa 1 | Research/outline pilot 2, retrospective, lịch mùa 1, quyết định go/no-go | Gate D — Scale Decision | Chưa bắt đầu |

## 4. Bảng công việc chi tiết

| ID | Công việc | Chủ trì | Bắt đầu | Deadline | Phụ thuộc | Deliverable/tiêu chí hoàn thành | Tiến độ | Trạng thái |
|---|---|---|---|---|---|---|---:|---|
| F01 | Xác nhận phạm vi portfolio và bốn pilot | CL | 04/08 | 05/08 | — | Biên bản quyết định; không thay mùa 1 bằng trend story | 100% | Hoàn thành |
| F02 | Phân công nhân sự và lịch check-in | PM | 04/08 | 06/08 | F01 | Agent routing và cadence Thứ Ba/Thứ Sáu đã khóa | 100% | Hoàn thành |
| F03 | Khóa dàn nhân vật chính | CL | 05/08 | 10/08 | F01 | Bắp, Lam và Cô Sen khóa cho pilot; hai ensemble slot còn lại ngoài scope pilot | 100% | Hoàn thành |
| F04 | Hoàn thiện Series Bible v1 | CL | 06/08 | 14/08 | F03 | Series Bible v1 khóa thế giới, magic rule, event, continuity và age band | 100% | Hoàn thành |
| F05 | Hoàn thiện visual guide | ART | 08/08 | 17/08 | F03 | Writing/storyboard guide khóa shape, expression, palette, location và accessibility; model sheet chi tiết ở Art Gate | 100% | Hoàn thành |
| F06 | Tạo Research Packet và Source Note template | RS | 06/08 | 12/08 | F01 | Template đã tích hợp trong Agent 7 và project template | 100% | Hoàn thành |
| F07 | Tạo checklist biên tập và child-safety | QA | 08/08 | 14/08 | F06 | Checklist, severity và quyền chặn của Agent 5 đã khóa | 100% | Hoàn thành |
| F08 | Chốt Definition of Done cho một tập | PM | 15/08 | 18/08 | F04–F07 | DoD và Gate A/B/C/D đã tích hợp trong Global Guideline/workflow | 100% | Hoàn thành |
| F09 | Thiết lập cấu trúc owned library/playlist | MD | 15/08 | 21/08 | F04 | Owned library routes, playlist, metadata và release dependency đã khóa | 100% | Hoàn thành |
| F10 | Gate A — Canon Ready | CL | 22/08 | 24/08 | F02–F09 | Gate A passed cho pilot writing/storyboard; Art Gate vẫn tách riêng | 100% | Hoàn thành |
| P01 | Research Packet: Cục Tức Màu Đỏ | RS | 04/08 | 28/08 | F10 | Conditional pass cho story development; reviewer còn mở trước Release Gate | 85% | Đang thực hiện |
| P02 | Story Bible và outline pilot 1 | WR | 04/08 | 31/08 | F10, P01 | Canon v1.0 và outline tám beat đã khóa | 100% | Hoàn thành |
| P03 | Duyệt outline và safety sớm | ED | 01/09 | 03/09 | P02 | Story package QA không còn Blocker/Major | 100% | Hoàn thành |
| P04 | Viết comic script | WR | 04/09 | 08/09 | P03 | Comic script 24 trang/73 panel hoàn thành và QA pass | 100% | Hoàn thành |
| P05 | Viết prose story | WR | 04/09 | 09/09 | P03 | Prose 1.482 từ, cùng final choice/outcome và alignment đầy đủ | 100% | Hoàn thành |
| P06 | Thumbnail và storyboard | SB | 06/09 | 11/09 | P04 | Styleboard, thumbnail plan 24 trang và 3 sample page được duyệt Art Gate | 100% | Hoàn thành |
| P07 | Art, màu và lettering prototype | ART | 10/09 | 16/09 | P06 | 24 rough/73 panel pass; social JPEG raster hóa chữ đúng; print preflight vẫn mở | 98% | Social pass; print chờ |
| P08 | Parent card, activity card và source note | QA | 10/09 | 16/09 | P01, P04 | Câu hỏi mở; hoạt động ngoại tuyến, an toàn, không thu dữ liệu trẻ | 0% | Chưa bắt đầu |
| P09 | Ba clip ngắn prototype | MD | 12/09 | 18/09 | P06 | Ngoài release boundary mới; chỉ Facebook comic + Threads comic | 0% | Tạm hoãn |
| P10 | Đọc thử có kiểm soát | QA | 17/09 | 19/09 | P05, P07, P08 | Session sheet, 24-page copy deck và 7 câu hỏi hiểu đã sẵn sàng; session người thật chưa chạy | 15% | Đang thực hiện |
| P11 | Sửa pilot theo kết quả test | CL | 19/09 | 21/09 | P10 | Sửa lỗi hiểu sai, continuity và safety; khóa version phát hành | 0% | Chưa bắt đầu |
| P12 | Gate B — Pilot Ready | CL | 21/09 | 21/09 | P01–P11 | Comic, prose, cards, nguồn và clip đều được duyệt | 0% | Chưa bắt đầu |
| R01 | Dựng motion comic/video 4–8 phút | MD | 22/09 | 28/09 | P12 | Ngoài release boundary mới | 0% | Tạm hoãn |
| R02 | Hoàn thiện trang canon và metadata | MD | 22/09 | 29/09 | P12, F09 | Ngoài release boundary mới; Facebook album là nơi đọc trọn social pilot | 0% | Tạm hoãn |
| R03 | QA trước phát hành | QA | 05/08 | 05/08 | Social export | 24 JPEG, checksum, caption, alt text, thứ tự 24 trang và contact sheet đạt | 90% | Chờ live-device QA |
| R04 | Phát hành pilot 1 | PM | 05/08 | 05/08 | R03 | Facebook một album 24 ảnh; Threads ba bài 8 ảnh; có URL public | 75% | Chờ quyền tài khoản |
| R05 | Theo dõi moderation và lỗi phát hành | MD | 02/10 | 09/10 | R04 | Nhật ký phản hồi, lỗi, correction và tình huống nhạy cảm | 0% | Chưa bắt đầu |
| R06 | Báo cáo baseline pilot 1 | PM | 10/10 | 12/10 | R05 | Báo cáo completion, dẫn đọc, hiểu nội dung và phản hồi người lớn | 0% | Chưa bắt đầu |
| R07 | Gate C — Release Validated | CL | 12/10 | 12/10 | R06 | Quyết định giữ/sửa/bỏ từng format dựa trên baseline | 0% | Chưa bắt đầu |
| S01 | Research Packet: Con Suối Mang Rác Từ Đâu | RS | 13/10 | 18/10 | R07 | Bối cảnh địa phương, dòng chảy/rác, nguồn và reviewer phù hợp | 0% | Chưa bắt đầu |
| S02 | Outline và storyboard thô pilot 2 | WR | 17/10 | 24/10 | S01 | Trẻ điều tra nguyên nhân; không đơn giản hóa vấn đề thành “nhặt rác” | 0% | Chưa bắt đầu |
| S03 | Retrospective quy trình pilot 1 | PM | 13/10 | 19/10 | R07 | Bài học về thời gian, chi phí, chất lượng và phối hợp | 0% | Chưa bắt đầu |
| S04 | Khóa format lặp lại cho mùa 1 | CL | 20/10 | 26/10 | S03 | Danh sách asset bắt buộc/tùy chọn và effort estimate | 0% | Chưa bắt đầu |
| S05 | Xây lịch sản xuất bảy tập còn lại | PM | 24/10 | 30/10 | S02, S04 | Owner, sequence, capacity và dependency được chốt | 0% | Chưa bắt đầu |
| S06 | Gate D — Go/no-go mùa 1 | CL | 31/10 | 02/11 | S01–S05 | Quyết định có lý do; backlog và ngân sách nguồn lực được cập nhật | 0% | Chưa bắt đầu |

## 5. Theo dõi tám tập mùa 1

| Tập | Tên | Ưu tiên | Research | Outline | Script | Storyboard | Art | QA | Phái sinh | Trạng thái tổng | Deadline dự kiến |
|---:|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Cục Tức Màu Đỏ | P0 — Pilot 1 | Conditional pass | Hoàn thành | Hoàn thành | Hoàn thành | 24/24 rough pass | Social package QA pass | Facebook + Threads ready | Chờ quyền đăng/URL live | 05/08/2026 |
| 2 | Lời Nói Dối Có Cái Đuôi | P1 | Chưa bắt đầu | Chưa bắt đầu | Chưa bắt đầu | Chưa bắt đầu | Chưa bắt đầu | Chưa bắt đầu | Chưa bắt đầu | Backlog | Sau Gate D |
| 3 | Bạn Mới Nói Chậm Hơn | P1 | Chưa bắt đầu | Chưa bắt đầu | Chưa bắt đầu | Chưa bắt đầu | Chưa bắt đầu | Chưa bắt đầu | Chưa bắt đầu | Backlog | Sau Gate D |
| 4 | Cây Cầu Chỉ Xây Từ Hai Phía | P1 | Chưa bắt đầu | Chưa bắt đầu | Chưa bắt đầu | Chưa bắt đầu | Chưa bắt đầu | Chưa bắt đầu | Chưa bắt đầu | Backlog | Sau Gate D |
| 5 | Con Suối Mang Rác Từ Đâu | P0 — Pilot 2 | Chưa bắt đầu | Chưa bắt đầu | Chưa bắt đầu | Chưa bắt đầu | Chưa bắt đầu | Chưa bắt đầu | Chưa bắt đầu | Chờ pilot 1 | 24/10/2026 cho outline |
| 6 | Tin Nhắn Chạy Nhanh Hơn Sự Thật | P0 — Pilot tiếp theo | Chưa bắt đầu | Chưa bắt đầu | Chưa bắt đầu | Chưa bắt đầu | Chưa bắt đầu | Chưa bắt đầu | Chưa bắt đầu | Backlog ưu tiên | Sau Gate D |
| 7 | Ngày Mây Không Muốn Vui | P0 — Pilot tiếp theo | Chưa bắt đầu | Chưa bắt đầu | Chưa bắt đầu | Chưa bắt đầu | Chưa bắt đầu | Chưa bắt đầu | Chưa bắt đầu | Backlog ưu tiên | Sau Gate D |
| 8 | Chiếc Cúp Của Cả Đội | P1 — Finale | Chưa bắt đầu | Chưa bắt đầu | Chưa bắt đầu | Chưa bắt đầu | Chưa bắt đầu | Chưa bắt đầu | Chưa bắt đầu | Backlog | Sau Gate D |

## 6. Cổng duyệt một tập

| Gate | Câu hỏi bắt buộc | Người duyệt | Kết quả |
|---|---|---|---|
| Idea Gate | Vấn đề có thật với trẻ Việt Nam, trẻ có agency và có visual metaphor không? | CL + ED | Chưa đánh giá |
| Research Gate | Dữ kiện/văn hóa/an toàn có nguồn và reviewer phù hợp chưa? | RS + QA | Chưa đánh giá |
| Outline Gate | Giá trị xuất hiện qua lựa chọn, hậu quả và sửa chữa hay chỉ qua lời nói? | CL + ED | Chưa đánh giá |
| Art Gate | Hình ảnh kể được hành động, dễ đọc và không phụ thuộc duy nhất vào màu không? | CL + ART | Đạt — người dùng duyệt 04/08/2026; visual safety không có Blocker/Major |
| Safety Gate | Không fearbait, làm nhục, thu dữ liệu trẻ hoặc ép trẻ tiết lộ trải nghiệm nhạy cảm? | QA | Chưa đánh giá |
| Rights Gate | Hình, âm thanh, font, nguồn và asset AI có provenance/quyền sử dụng rõ? | PM + QA | Chưa đánh giá |
| Release Gate | Canon, metadata, card, source note, link và moderation plan đã sẵn sàng? | CL + PM | Chưa đánh giá |

## 7. Chỉ số báo cáo tuần

Không đặt benchmark số học trước khi có baseline. Mỗi tuần cập nhật các trường sau:

| Tuần | Hoàn thành | Trễ hạn | Bị chặn | Quyết định cần CL | Rủi ro mới | Hành động tuần tới |
|---|---:|---:|---:|---|---|---|
| W01 — 04/08–10/08 | F01–F10; P02–P06; Art Gate; VD-02; 24/24 rough; desk preflight/session kit | 0 | 3 Major preflight; 11 Minor visual | Chọn mobile mode, font final và trim/bleed | Phone no-zoom fail; rough chỉ ~171 ppi ở 6×9; Noto Sans chưa khóa | Human session; quyết định mobile/font/trim; final-line pass |
| W02 — 11/08–17/08 |  |  |  |  |  |  |
| W03 — 18/08–24/08 |  |  |  |  |  |  |
| W04 — 25/08–31/08 |  |  |  |  |  |  |
| W05 — 01/09–07/09 |  |  |  |  |  |  |
| W06 — 08/09–14/09 |  |  |  |  |  |  |
| W07 — 15/09–21/09 |  |  |  |  |  |  |
| W08 — 22/09–28/09 |  |  |  |  |  |  |
| W09 — 29/09–05/10 |  |  |  |  |  |  |
| W10 — 06/10–12/10 |  |  |  |  |  |  |
| W11 — 13/10–19/10 |  |  |  |  |  |  |
| W12 — 20/10–26/10 |  |  |  |  |  |  |
| W13 — 27/10–02/11 |  |  |  |  |  |  |

## 8. Quy tắc cập nhật

1. PM cập nhật bảng ít nhất hai lần mỗi tuần.
2. Task trễ hạn phải có nguyên nhân, ngày mới và người ra quyết định.
3. Task `Bị chặn` quá 48 giờ phải được đưa vào check-in gần nhất.
4. Không chuyển sang bước kế tiếp khi cổng duyệt bắt buộc chưa đạt.
5. Thay đổi canon phải cập nhật Series Bible trước khi chuyển thể video.
6. Tiến độ tập được tính theo trọng số: Research 10%, Outline 10%, Script 15%, Storyboard 15%, Art/Lettering 25%, QA 15%, phái sinh 10%.
7. View và follower không thay thế chỉ số hiểu nội dung, dẫn đọc, an toàn và ý định đọc tiếp.

## 9. Nhật ký quyết định

| Ngày | Quyết định | Người quyết định | Lý do | Tài liệu bị ảnh hưởng |
|---|---|---|---|---|
| 04/08/2026 | Dùng một IP thống nhất; ưu tiên pilot `Cục Tức Màu Đỏ` | Theo strategic baseline v1.0 | Giữ canon và kiểm tra visual hook/cảm xúc trước khi mở rộng | Portfolio, roadmap mùa 1 |
| 04/08/2026 | Mở `STORY-XTL-S01E01` ở trạng thái development draft | Agent 6/Agent 2 | Cho phép research và outline sớm nhưng giữ dependency Gate A | Pilot 1, tracker |
| 04/08/2026 | Giữ tên Bắp, Lam, Cô Sen; khóa Cục Tức chỉ phản chiếu và không biến mất ở ending | Người dùng + Agent 2 | Tránh biến cơn giận thành kẻ xấu hoặc phép thuật chịu trách nhiệm thay trẻ | Series/Story Bible v1, outline, visual guide |
| 04/08/2026 | Khóa `Ngày Hội Xóm Mình` là sự kiện xuyên mùa, payoff ở tập 8 | Người dùng + Agent 2 | Tạo continuity và mục tiêu cộng đồng cho mùa 1 | Series Bible v1, roadmap, pilot 1 |
| 04/08/2026 | Dùng styleboard và ba sample P04/P12/P24 làm bộ kiểm Art Gate; prototype chưa phải final art | Agent 8 | Kiểm model, magic rule, cao trào và ending trước khi đầu tư full art | Visual Production Pack, tracker pilot 1 |
| 04/08/2026 | Duyệt Art Gate và mở P07; giữ lettering ở lớp SVG riêng | Người dùng + Agent 8 | Khóa hướng hình ảnh, bảo toàn chữ Việt và cho phép sửa không phá raster nền | VD-02, lettering proof, tracker P06/P07 |
| 04/08/2026 | Chặn mở Batch B cho tới khi sửa lỗi lặp mặt trời đỏ trong Batch A | Agent 5/Agent 8 | Bảo toàn continuity của `PROP-XTL-E01-SUN`; không đẩy lỗi prop sang 18 trang sau | Batch A QA, P07 tracker |
| 04/08/2026 | Đóng `QA-A-MAJ-01`; mở Batch B với 2 Minor không chặn | Agent 5/Agent 8 | BatchA-v2 chỉ còn một sun prop; panel/action/CT-1 giữ nguyên | Batch A QA, rough/lettering v2, tracker |
| 04/08/2026 | Pass Batch B và mở Batch C; khóa causality tay–dây–nút–vết rách | Agent 5/Agent 8 | Tránh quy nguyên nhân tai nạn cho Cục Tức; giữ agency/hậu quả của Bắp | Batch B QA, P07 tracker |
| 04/08/2026 | Pass Batch C và mở Batch D; khóa safe pause, adult choice, naming/listening | Agent 5/Agent 8 | Giữ điều tiết cảm xúc không cưỡng ép; Cục Tức hạ nhưng không biến mất | Batch C QA, P07 tracker |
| 04/08/2026 | Pass Batch D; khóa rough production 24 trang/73 panel và mở read-aloud/preflight | Agent 5/Agent 8 | Ending giữ seam, lối đi, agency và CT-4; chưa bỏ qua Rights/Release Gate | Batch D QA, P07 tracker |
| 04/08/2026 | Desk preflight pass copy nhưng không mở release; ghi 3 Major mobile/print/font | Agent 5/Agent 8 | Điện thoại co toàn trang làm thoại còn ~10–11 px; print rough chưa 300 ppi/bleed; font final chưa có/license chưa lưu | Preflight report, P07/P10 tracker |
| 05/08/2026 | Đổi release boundary: dừng khi truyện đã đăng Facebook và Threads | Người dùng + Agent 6/9 | Ưu tiên social pilot; tạm hoãn motion, owned site và print; giữ human read là follow-up | P09, R01–R04, distribution plan, release report |
| 05/08/2026 | Khóa Facebook 24 ảnh và Threads ba phần 8 ảnh | Agent 9/5 | Giữ trọn canon, chia ở các beat tự nhiên và giảm rủi ro giới hạn carousel giữa client | Social manifest, caption, alt text, runbook |
