# Knowledge: FireAnt FPT Page Footprint

## Nguon local
- `fireant_fpt.html`

## Dau vet xac nhan duoc
- page title: `FPT - CTCP FPT`
- query symbol: `FPT`
- script chart: `tradingView_v27/charting_library.standalone.js`
- chart options cua current user:
  - `period = months`
  - `periodCount = 3`
  - `candlestick = true`
  - `volume = true`
  - `ma = [10, 50]`
  - `rsi = false`
  - `bollingerBands = false`

## Noi dung khac co trong snapshot
- du lieu co ban doanh nghiep
- feed cong dong
- thong tin giao dien FireAnt

## Ket luan van hanh
- file nay khong chua strategy giao dich hoan chinh
- file nay khong chua luong OHLC intraday sach de vao lenh scalping
- file nay co gia tri de:
  - nhan dien symbol va context chart
  - tai su dung `MA10/MA50` lam filter huong
  - xac nhan FireAnt dang dung charting stack TradingView

## Rule su dung
- dung file nay lam `context only`
- khong dung file nay lam feed vao lenh cho EA
