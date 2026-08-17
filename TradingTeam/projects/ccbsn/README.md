# CCBSN Controller Project

Project quản lý Bot 2 điều khiển New Cycle của CCBSN và bản TradingView dùng để kiểm chứng Trading Zone.

## Điều hướng

- `CURRENT.md`: phiên bản đang được khuyến nghị.
- `src/`: mã nguồn chuẩn; không chứa binary hoặc compile log.
- `tests/`: release gates, test matrices và báo cáo.
- `docs/`: kiến trúc và hướng dẫn vận hành.
- `build/`: binary/log sinh ra khi compile; không commit.
- `releases/`: gói phát hành bất biến gồm source, binary, release note và checksum.
- `archive/`: visualizer, release note, checksum và test report lịch sử.

## Kiểm thử nhanh

```powershell
.\tests\Test-ControlHandshake.ps1
.\tests\Test-MT5V3Delivery.ps1
```

Không chạy đồng thời Controller v2 và v3 trên cùng Symbol/Magic.
