# Sub-agent: PriceAgent

## Mục tiêu
Thu thập và chuẩn hóa dữ liệu giá để các agent sau có thể phân tích cấu trúc một cách nhất quán.

## Phạm vi thị trường hỗ trợ
- chứng khoán Việt Nam
- CFD
- crypto

## Workflow khởi động hiện tại
- `crypto`
  - phạm vi: `top 50` theo vốn hóa
  - chu kỳ: `5 phút`
  - nguồn mặc định: `CoinGecko`
  - granularity hiện tại: `snapshot`
- `CFD`
  - phạm vi: danh sách cặp mặc định do workflow chỉ định
  - chu kỳ: `5 phút`
  - nguồn mặc định: `OANDA`
  - danh sách hiện tại: `EURUSD`, `XAUUSD`, `XAGUSD`, `USOIL`, `USDJPY`, `USDCAD`, `GBPJPY`, `USDCHF`, `EURJPY`
  - granularity hiện tại: `pricing snapshot`
- `VN stock`
  - phạm vi: `top 50` theo vốn hóa
  - chu kỳ: `5 phút`
  - nguồn mặc định: `FireAnt`
  - granularity hiện tại: `daily bar`
  - ghi chú: Agent 1 hiện đang poll mỗi `5 phút`, nhưng bar giá lấy theo `latest daily quote` từ FireAnt REST công khai

## Cấu trúc log lịch sử
- lịch sử lấy dữ liệu được lưu trong `Agent_1_PriceAgent/Logs/`
- mỗi market là một thư mục riêng
- mỗi cặp hoặc symbol là một file log riêng

### Quy ước hiện tại
- `Logs/vn_stock/<symbol>.jsonl`
- `Logs/cfd/<instrument>.jsonl`
- `Logs/crypto/<symbol>.jsonl`

## Nguồn dữ liệu ưu tiên theo thị trường
- `FireAnt` cho giá cổ phiếu chứng khoán Việt
- `OANDA` cho giá thị trường CFD
- `CoinMarketCap` hoặc `CoinGecko` cho giá coin

## Mapping nguồn theo asset class
- `Cổ phiếu Việt Nam`
  - ví dụ: `FPT`, `VCB`, `HPG`
  - nguồn mặc định: `FireAnt`
  - tiêu chí chọn universe hiện tại: `top 50 market cap`
- `CFD`
  - ví dụ: `EURUSD`, `XAUUSD`, `XAGUSD`, `USOIL`, `USDJPY`
  - nguồn mặc định: `OANDA`
  - danh sách workflow hiện tại:
    - `EURUSD`
    - `XAUUSD`
    - `XAGUSD`
    - `USOIL`
    - `USDJPY`
    - `USDCAD`
    - `GBPJPY`
    - `USDCHF`
    - `EURJPY`
- `Crypto`
  - ví dụ: `BTC`, `ETH`, `SOL`
  - nguồn mặc định: `CoinGecko`
  - tiêu chí chọn universe hiện tại: `top 50 market cap`

## Input
- mã giao dịch hoặc sản phẩm
- loại thị trường
- timeframe
- khoảng thời gian cần phân tích
- timezone hoặc phiên giao dịch
- nguồn dữ liệu hoặc file đầu vào

## Output
- `Price_Log.md` hoặc `02_Price_Log.md`
- file log `jsonl` theo từng symbol
- ghi chú bối cảnh cấu trúc cơ bản
- schema chuẩn để handoff:
  - `TradingTeam/Agent_1_PriceAgent/Knowledge/Unified_Price_Record_Schema.md`

## Runner chung
- runner hiện tại:
  - `TradingTeam/scripts/run_price_agent.py`
- runtime status:
  - `TradingTeam/Agent_1_PriceAgent/Runtime/price_agent_status.json`

## Câu hỏi chính
- đây là thị trường nào và nên map sang nguồn nào?
- dữ liệu giá lấy từ đâu?
- có đủ độ phân giải cho timeframe yêu cầu không?
- chuỗi giá có thiếu nến, lệch giờ hoặc trùng dòng không?
- bối cảnh hiện tại là trend, range hay chuyển pha?
