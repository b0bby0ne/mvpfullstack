# ChildComicTeam — Portfolio Agent Routing

## 1. Ma trận vai trò

| Vai trò trong tracker | Agent chịu trách nhiệm | Phạm vi |
|---|---|---|
| PM | `Agent_6_Portfolio_Producer` | Tiến độ, owner, dependency, Gate A/B/C/D, baseline và go/no-go |
| CL | `Agent_2_Story_Architect` | Creative direction, canon, character, outline và lựa chọn cuối của truyện |
| RS | `Agent_7_Research_Cultural_Validator` | Research Packet, kiểm chứng, bối cảnh Việt Nam, source note và rights nguồn |
| WR — Comic | `Agent_3_Comic_Scriptwriter` | Comic script, page/panel/dialogue và illustration handoff |
| WR — Prose | `Agent_4_Prose_Story_Writer` | Truyện chữ và comic–prose alignment |
| SB/ART | `Agent_8_Visual_Storyboard_Producer` | Thumbnail, storyboard, visual pack, art production và preflight |
| ED/QA | `Agent_5_Child_Safety_Editorial_QA` | Editorial, age-fit, continuity, safety và release gate |
| Audience | `Agent_1_Child_Audience_Specialist` | Age band, readability, emotional intensity và accessibility brief |
| MD | `Agent_9_Motion_Distribution_Producer` | Motion comic, clip, owned library, metadata, moderation và metrics |

## 2. Routing theo task của kế hoạch 90 ngày

| Task/nhóm task | Agent chính | Agent review/hỗ trợ |
|---|---|---|
| F01–F02 — Scope, owner và lịch | Agent 6 | Agent 2, Agent 5 |
| F03–F04 — Cast và Series Bible | Agent 2 | Agent 1, Agent 5 |
| F05 — Visual guide | Agent 8 | Agent 2, Agent 5 |
| F06 — Research/Source templates | Agent 7 | Agent 5 |
| F07 — Editorial và child-safety checklist | Agent 5 | Agent 1, Agent 7 |
| F08 — Definition of Done | Agent 6 | Agent 2, Agent 5 |
| F09 — Owned library/playlist | Agent 9 | Agent 6 |
| F10 — Gate A | Agent 6 điều phối | Agent 2 và Agent 5 duyệt |
| P01 — Research pilot | Agent 7 | Agent 1, Agent 5 |
| P02 — Story Bible/outline | Agent 2 | Agent 1, Agent 7, Agent 5 |
| P03 — Outline/safety review | Agent 5 | Agent 2, Agent 7 |
| P04 — Comic script | Agent 3 | Agent 2, Agent 5 |
| P05 — Prose story | Agent 4 | Agent 2, Agent 5 |
| P06–P07 — Storyboard và art | Agent 8 | Agent 2, Agent 3, Agent 5 |
| P08 — Parent/activity/source note | Agent 7 + Agent 5 | Agent 1 |
| P09 — Clip prototype | Agent 9 | Agent 2, Agent 5, Agent 8 |
| P10 — Đọc thử | Agent 1 + Agent 5 | Agent 6 |
| P11 — Revision | Agent 2 điều phối | Agent 3, 4, 7, 8 theo lỗi |
| P12 — Gate B | Agent 6 điều phối | Agent 2 và Agent 5 duyệt |
| R01–R02 — Motion và trang canon | Agent 9 | Agent 8, Agent 6 |
| R03 — Release QA | Agent 5 | Agent 7, Agent 8, Agent 9 |
| R04–R06 — Release, moderation, baseline | Agent 9 | Agent 6, Agent 5 |
| R07 — Gate C | Agent 6 điều phối | Agent 2 và Agent 5 duyệt |
| S01 — Research pilot 2 | Agent 7 | Agent 5 |
| S02 — Outline/storyboard thô | Agent 2 + Agent 8 | Agent 5 |
| S03–S06 — Retrospective và scale decision | Agent 6 | Tất cả Agent liên quan |

## 3. Chuỗi thực thi một tập

`Agent 6 mở task`  
`→ Agent 7 research + Agent 1 audience brief`  
`→ Agent 2 khóa Story Bible/Outline`  
`→ Agent 3 và Agent 4 viết song song`  
`→ Agent 5 editorial/safety QA`  
`→ Agent 8 storyboard và visual production`  
`→ Agent 5 Art/Release QA`  
`→ Agent 9 motion, distribution và metrics`  
`→ Agent 6 retrospective và cập nhật portfolio`

## 4. Quy tắc routing

- Một task có một Agent chính dù có nhiều Agent review.
- Agent 6 sở hữu tiến độ nhưng không sở hữu canon hoặc safety verdict.
- Agent 2 không khóa outline khi Agent 7 còn blocker rủi ro cao.
- Agent 8 không mở final-art batch trước khi thumbnail và sample page được duyệt.
- Agent 9 không phát hành clip trước khi nội dung canon/landing page sẵn sàng.
- Agent 5 có quyền chặn ở bất kỳ bước nào vì safety, age-fit hoặc rights.
- Bất đồng không giải quyết được phải được ghi trong decision log, kèm owner và deadline.

## 5. Nhịp vận hành mặc định

- Thứ Ba `09:00 ICT`: Agent 6 cập nhật tiến độ, owner, dependency và ba ưu tiên tuần.
- Thứ Sáu `16:00 ICT`: review risk, blocker, canon/safety change và gate readiness.
- Task bị chặn quá 48 giờ được đưa vào phiên gần nhất.
- Đây là cadence mặc định; người vận hành có thể đổi giờ nhưng phải ghi trong tracker.
