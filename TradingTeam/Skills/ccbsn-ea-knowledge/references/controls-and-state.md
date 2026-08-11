# CCBSN - Controls and State

## New Cycle

- Từ v2.6.1: `New Cycle = true` nghĩa là cho phép mở chu kỳ mới.
- `false` chặn chu kỳ mới, không mặc nhiên nói rằng chuỗi hiện hữu ngừng DCA/management.
- New Cycle không phải Algo Trading toàn terminal.
- Nút chart, Zone Cycle, target và remote command có thể tác động trạng thái này.

## Nút chart

- `New Cycle`.
- `Close Buy`, `Close Sell`, `Close All`.
- `Reset Lots Buy`, `Reset Lots Sell`.
- `Stop Buy`, `Stop Sell`.

## Pending-order mobile commands

| Order | Special price | Action |
|---|---:|---|
| Buy Stop | `999999` | Dừng mọi hoạt động, không mở mới/DCA |
| Buy Stop | `666666` | Cho EA hoạt động lại |
| Buy Stop | `888888` | Tắt New Cycle |
| Sell Limit | `888888` | Bật New Cycle |
| Buy Stop | `555555` | Stop Buy; xóa pending để cho Buy lại |
| Sell Limit | `555555` | Stop Sell; xóa pending để cho Sell lại |

Manual ghi volume bất kỳ, bot tự nhận command, thực thi và xóa pending. Với Stop Buy/Sell, dữ liệu người dùng lại ghi pending không tự xóa và người dùng xóa để resume; phải xác minh v3.0.5 thực tế.

## State model để phân tích/tái tạo

Đây là suy luận kỹ thuật, không phải tên state nội bộ đã xác minh:

- global: `RUNNING` / `STOPPED`;
- permissions: `new_cycle_enabled`, `buy_enabled`, `sell_enabled`;
- active modules: DCA, trim, hedge, hedge-zone, trailing;
- limit states: daily halted, ladder delay, lottery delay.

```text
can_open_first = running
  AND new_cycle_enabled
  AND side_enabled
  AND time_ok
  AND spread_ok
  AND limits_ok
  AND signal_ok
  AND filters_ok
```

Không tái sử dụng gate trên cho DCA/management nếu module được phép chạy ngoài giờ hoặc khi New Cycle tắt.

## Safety

- Magic price có thể bị broker từ chối hoặc thành order thực trên symbol scale khác; chỉ test demo.
- Khi tái tạo mới, ưu tiên authenticated command channel nếu không cần tương thích ngược.
- Scope command theo account/symbol/Magic.
- Debounce chart button, audit old/new state.
- Reconcile state/pending/positions sau restart.
