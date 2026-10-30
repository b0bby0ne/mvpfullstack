# SMC Controller test matrix

| ID | Test | Expected |
|---|---|---|
| SMC-001 | MetaEditor compile | 0 errors, 0 warnings |
| SMC-002 | Current bar thay đổi | Không phát business event trước close |
| SMC-003 | H1 HH+HL + M15 HL/break/FVG | Tạo `WAIT_RETEST`, chưa ON |
| SMC-004 | FVG touch nhưng không reclaim | Giữ `WAIT_RETEST` |
| SMC-005 | FVG touch + reclaim | `ENTRY_WINDOW`, ON intent đúng một lần |
| SMC-006 | First CCBSN position | Token consumed, desired OFF |
| SMC-007 | Causal low bị phá | OFF + Risk Lock |
| SMC-008 | Bearish displacement break | OFF + Risk Lock |
| SMC-009 | BSL sweep rejection | OFF theo input |
| SMC-010 | Target đạt trước/sau ON | Setup/window kết thúc |
| SMC-011 | Setup/entry timeout | OFF, không reuse setup |
| SMC-012 | Spread/session/data block | Fail closed |
| SMC-013 | Restart trong mọi state | Không phục hồi setup; bootstrap OFF |
| SMC-014 | Hai controller cùng scope | Controller thứ hai bị mutex chặn |
| SMC-015 | ON pending rồi bearish OFF | ON được supersede, sau đó gửi OFF |
| SMC-016 | Command bị execute | Control ERROR + alert |
| SMC-017 | Visual-only | Không tạo trade request |
| SMC-018 | Zone visual control mode | Start/End theo ON/OFF ACK |
| SMC-019 | H1 chuyển bearish khi đang ENTRY_WINDOW | OFF ngay + Risk Lock |
| SMC-020 | ON checklist thiếu bất kỳ gate nào | Không cấp quyền ON |
| SMC-021 | Dashboard gate telemetry | Hiển thị PASS/BLOCK và OFF/-- đúng snapshot |
| SMC-022 | Khởi tạo với 4.500 nến M15 | Zone lịch sử được tái dựng từ cũ đến mới |
| SMC-023 | Historical H1/M15 swing | Chỉ dùng swing đã confirmed tại decision time |
| SMC-024 | Quá 100 closed zones | Xóa rectangle cũ nhất, giữ chart bounded |
| SMC-025 | Historical replay | Không ghi CSV, không gửi command, không dùng current positions |
| SMC-026 | SMC historical event map | Hiển thị liquidity/structure/FVG/lifecycle, giữ tối đa N marker |
| SMC-027 | Setup reference levels | Causal low, FVG 50% và target kết thúc cùng setup box |
| SMC-028 | Structure checklist PASS nhưng chưa reclaim event | Không ON |
| SMC-029 | Reclaim event nhưng Structure checklist BLOCK | Ghi trigger blocked, không ON |
| SMC-030 | Reclaim event + hai checklist PASS | Phát đúng một `BULLISH_ON_TRIGGER` và vào ENTRY_WINDOW |

Golden-chart gate tối thiểu: 8 positive, 8 negative/near-miss, 6 ambiguous,
4 news shocks và 4 low-liquidity cases. Không dùng outcome để sửa lại setup.
