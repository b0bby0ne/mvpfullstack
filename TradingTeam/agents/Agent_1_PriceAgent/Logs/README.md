# Logs Guide

Lịch sử lấy dữ liệu của `Agent_1_PriceAgent` được lưu trong thư mục này.

## Cấu trúc bắt buộc
- mỗi market là một thư mục riêng
- mỗi cặp hoặc symbol là một file log riêng

## Quy ước thư mục
- `vn_stock/`
- `cfd/`
- `crypto/`

## Ví dụ
- `Logs/vn_stock/fpt.jsonl`
- `Logs/cfd/xau_usd.jsonl`
- `Logs/crypto/btc.jsonl`
- `Logs/crypto/eth.jsonl`

## Nguyên tắc
- file log dùng định dạng `jsonl`
- mỗi dòng là một snapshot độc lập
- dùng `append` để giữ lịch sử
- không ghi đè lịch sử cũ nếu chưa có lý do vận hành rõ ràng
