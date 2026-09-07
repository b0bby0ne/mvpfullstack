# Test Matrix

| ID | Trường hợp | Kết quả mong đợi | Trạng thái |
|---|---|---|---|
| LITE-001 | Compile MetaEditor | 0 errors, 0 warnings | PASS |
| LITE-002 | Visual Only mặc định | Không có trade request | Chưa chạy |
| LITE-003 | Entry ratio trong band 2 nến | OFF -> ARMING -> ACTIVE | Truth table PASS |
| LITE-004 | Entry candidate mất | ARMING -> OFF | Truth table PASS |
| LITE-005 | Hold ratio chạm biên entry nhưng trong hold | Zone tiếp tục | Truth table PASS |
| LITE-006 | Soft exit trước minimum bars | Không OFF | Truth table PASS |
| LITE-007 | Soft exit đủ confirm sau minimum bars | ACTIVE -> OFF | Truth table PASS |
| LITE-008 | Bear shock | ACTIVE -> RISK_LOCK ngay | Truth table PASS |
| LITE-009 | Recovery sau lock | Chỉ ACTIVE khi đủ recovery confirm | Chưa chạy |
| LITE-010 | Session qua nửa đêm | 23:59 và 02:59 được phép | Static PASS |
| LITE-011 | Ngoài session | 03:00–05:59 bị block | Static PASS |
| LITE-012 | Spread/ATR vượt ngưỡng | Entry block; active OFF | Chưa chạy |
| LITE-013 | Tick stale | Entry block; active OFF | Chưa chạy |
| LITE-014 | Controller cũ giữ mutex | Lite control init fail | Chưa chạy demo |
| LITE-015 | Fast CCBSN ACK | Ticket/history được reconcile | Chưa chạy demo |
| LITE-016 | Pending command timeout | Xóa có kiểm tra, control ERROR | Chưa chạy demo |
| LITE-017 | Command bị fill | Fatal control error/alert | Chưa chạy demo |
| LITE-018 | Restart khi pending | Recover đúng một order | Chưa chạy demo |
| LITE-019 | Hai pending controller orders | Fail closed | Chưa chạy demo |
| LITE-020 | Backtest profile comparison | Có risk metrics và zone metrics | Chưa chạy |
| PINE-001 | TradingView compiler | Pine v6 không có compile error | PASS — 0 warnings |
| PINE-002 | Chart không phải M5 | Cảnh báo và không cập nhật state | Static PASS |
| PINE-003 | Balanced defaults | Khớp MT5 Lite | Static PASS |
| PINE-004 | Continuous session | Quyết định tại close, không cắt 12:00/18:00 | Static PASS |
| PINE-005 | Visual only | Không strategy/request/webhook/control | Static PASS |
| PINE-006 | Zone/Risk history quota | Không vượt input object limits | Static PASS |
| PINE-007 | Feed comparison | Ghi nhận sai khác TV/broker MT5 | Chưa chạy |
| V3M5-001 | TradingView compiler | Pine v6 không có compile error/warning | PASS — 0 warnings |
| V3M5-002 | M5 closed-bar gate | Chart khác M5 không cập nhật state | Static PASS |
| V3M5-003 | Ver3 core | ATR20, EMA23, D và dual policy đúng contract | Static PASS |
| V3M5-004 | M5 price scale | Mặc định 0.50; 1.00 phục hồi ngưỡng giá Ver3 | Static PASS |
| V3M5-005 | Event priority | Session > Bear Drop > Soft OFF > Risk/Active/Entry | Static PASS |
| V3M5-006 | Soft OFF priority | BearTwo > D-EMA > LowATR > Deny > Fall > Reverse > Pattern > Red | Static PASS |
| V3M5-007 | Continuous session | Không có điểm cắt 12:00/18:00 | Static PASS |
| V3M5-008 | Visual only | Không strategy/request/alert()/MT5 command | Static PASS |
| V3M5-009 | Scale comparison | So sánh 0.40/0.50/0.60/1.00 trên cùng dữ liệu | Chưa chạy thủ công |
| MT5V3M5-001 | MetaEditor compile | 0 errors, 0 warnings | PASS |
| MT5V3M5-002 | Pine/MT5 base parity | 12 Ver3 M5 defaults khớp | Static PASS |
| MT5V3M5-003 | M5 scaled gates | 10 raw-price gates đều qua `InpM5PriceScale` | Static PASS |
| MT5V3M5-004 | New Cycle transport | Khớp audited transport hash của Ver3 | Static PASS |
| MT5V3M5-005 | Controller mutex | Chung Account/Symbol/CCBSN Magic với controller cũ | Static PASS |
| MT5V3M5-006 | Fast ACK / restart | Ticket authority, persist và reconcile đúng contract | Static PASS |
| MT5V3M5-007 | Position drift | OFF phát hiện chain mới và reassert | Static PASS |
| MT5V3M5-008 | Manual handover | Dọn ownership/command trước khi chuyển controller | Static PASS |
| MT5V3M5-009 | Dashboard | Cycle, ACK, policy, checklist, session, performance | Static PASS |
| MT5V3M5-010 | Event Checklist | Đủ 17 market/event/sync rows | Static PASS |
| MT5V3M5-011 | Visual Only default | Không gửi command khi attach lần đầu | Static PASS |
| MT5V3M5-012 | Demo command consumption | CCBSN xóa đúng ON/OFF command tại 888888 | Runtime PASS |
| MT5V3M5-013 | Restart with pending | Phục hồi đúng ticket/history thực tế | Chưa chạy demo |
| MT5V3M5-014 | OFF drift with live chain | Alert, theo dõi chain đến flat và OFF reassert | Runtime PASS |
| MT5V3M5-015 | Command contract identity | Owner/magic/symbol/type/price/volume/comment đều phải khớp | Static PASS |
| MT5V3M5-016 | Duplicate/untracked command | Fail closed khi có hơn một command hoặc ticket lệch | Static PASS |
| MT5V3M5-017 | Stale ACK | Không nhận ACK cũ làm current; resync desired mới | Model PASS |
| MT5V3M5-018 | Timeout resync | Persist qua restart, tối đa 3 retry rồi ERROR | Model PASS |
| MT5V3M5-019 | Cycle consistency visibility | Dashboard/checklist/CSV/monitor cùng phản ánh state | Static PASS |
| MT5V3M5-020 | Release integrity | Source/EX5 khớp canonical build và SHA-256 manifest | PASS |
| MT5V3M5-021 | Actual OFF handshake | Buy Stop 888888 được CCBSN tiêu thụ và ACK đúng ticket | Runtime PASS |
| MT5V3M5-022 | Actual ON handshake | Sell Limit 888888 được CCBSN tiêu thụ và ACK đúng ticket | Runtime PASS |
| MT5V3M5-023 | Cleanup final state | Chain flat, OFF reassert ACK, terminal/profile restored | Runtime PASS |
| MT5V3M5-024 | Unattended restart | Không để first Buy lọt trước startup OFF ACK | FAIL — manual OFF bootstrap required |
