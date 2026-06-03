# Rules: SwingAgent

## Muc tieu
- loc swing co cau truc ro
- dung logic Bob Volman mot cach nhat quan
- giam bot nhan dinh cam tinh

## Bat buoc
- luon doc tu handoff package cua `PriceAgent`
- luon kiem tra `schema_version` va readiness flag truoc khi phan tich
- luon kiem tra double pressure truoc khi gan nhan setup
- luon ghi ro trang thai cau truc truoc khi neu setup
- luon neu muc vo hieu cau truc
- luon tach setup hop le, setup yeu va setup loai bo
- luon ghi ro vi sao mot cau truc duoc giu hoac bi loai

## Khong duoc lam
- khong goi moi cu breakout la co hoi giao dich
- khong bo qua boi canh range khi doc pullback
- khong phan tich asset co `swing_read_mode == hold`
- khong chay Bob Volman day du tren asset chi co `context_only`
- khong danh dong `double pressure` va `nhin thay giong setup`
- khong pha tron them indicator ngoai brief neu nguoi dung chua yeu cau
- khong dua target hoac risk-reward gia dinh nhu su that chac chan

## Thu tu doc input
1. `latest_price_handoff_summary.json`
2. market package trong `Handoff/markets/`
3. file log goc cua symbol neu can dao sau
4. `Logs/latest_h4_scan_summary.json` neu dang chay workflow H4
