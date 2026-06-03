# Knowledge: Market Data Source Map

## Mục tiêu
Xác định nguồn dữ liệu chuẩn cho từng nhóm thị trường mà `TradingTeam` hỗ trợ.

## 1. Chứng khoán Việt Nam
- nhóm thị trường: cổ phiếu niêm yết tại Việt Nam
- nguồn chuẩn: `FireAnt`
- dữ liệu tối thiểu:
  - mã
  - trading date hoặc timestamp
  - OHLC
  - volume nếu có
- workflow hiện tại:
  - `top 50 market cap`
  - poll frequency: `5 phút`
  - data granularity: `1d`

## 2. CFD
- nhóm thị trường: forex CFD, commodity CFD
- nguồn chuẩn: `OANDA`
- dữ liệu tối thiểu:
  - instrument
  - timestamp
  - bid, ask hoặc mid
- workflow hiện tại:
  - `EURUSD`
  - `XAUUSD`
  - `XAGUSD`
  - `USOIL`
  - `USDJPY`
  - `USDCAD`
  - `GBPJPY`
  - `USDCHF`
  - `EURJPY`
- poll frequency: `5 phút`
- data granularity: `pricing_snapshot`
- mapping OANDA:
  - `EURUSD` -> `EUR_USD`
  - `XAUUSD` -> `XAU_USD`
  - `XAGUSD` -> `XAG_USD`
  - `USOIL` -> `BCO_USD`
  - `USDJPY` -> `USD_JPY`
  - `USDCAD` -> `USD_CAD`
  - `GBPJPY` -> `GBP_JPY`
  - `USDCHF` -> `USD_CHF`
  - `EURJPY` -> `EUR_JPY`

## 3. Crypto
- nhóm thị trường: coin/token spot
- nguồn chuẩn: `CoinGecko`
- dữ liệu tối thiểu:
  - symbol hoặc coin id
  - timestamp
  - price
  - market cap
  - volume nếu có
- workflow hiện tại:
  - `top 50 market cap`
  - poll frequency: `5 phút`
  - data granularity: `snapshot`

## Quy tắc chọn nguồn
1. Nếu người dùng đã chỉ rõ nguồn, dùng đúng nguồn đó.
2. Nếu người dùng chỉ nêu thị trường:
   - `cổ phiếu Việt Nam` -> `FireAnt`
   - `CFD` -> `OANDA`
   - `coin` -> `CoinGecko`
3. Không trộn dữ liệu giữa nhiều nguồn trong cùng một run nếu chưa ghi chú rõ lý do.
