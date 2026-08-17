# Runbook: Telegram Signal Alerts

## Muc tieu
Tu dong hoa viec gui tin nhan canh bao (signals) tu Agent 2 den Telegram moi 4 gio hoac theo yeu cau.

## Bot Token hien tai
- `8245864273:AAE9xuMtXpzDllI8QxGhH-POJ8SdS620SUU`

## Huong dan lay Chat ID
Neu ban chua co Chat ID, hay thuc hien cac buoc sau:
1. Gui mot tin nhan bat ky den bot Telegram cua ban.
2. Chay lenh sau de xem Chat ID cua ban:
   ```powershell
   C:\Users\Admin\AppData\Local\Programs\Python\Python314\python.exe TradingTeam\tools\get_telegram_chat_id.py "8245864273:AAE9xuMtXpzDllI8QxGhH-POJ8SdS620SUU"
   ```

## Lenh chay chu ky tu dong (Moi 4h)
Lenh nay se chay toan bo quy trinh: Lay gia -> Quet Swing -> Gui Telegram.
```powershell
C:\Users\Admin\AppData\Local\Programs\Python\Python314\python.exe TradingTeam\tools\run_automated_scans.py --telegram-token "8245864273:AAE9xuMtXpzDllI8QxGhH-POJ8SdS620SUU" --telegram-chat-id <YOUR_CHAT_ID> --loop
```

## Lenh chay tuc thi (On-demand)
```powershell
C:\Users\Admin\AppData\Local\Programs\Python\Python314\python.exe TradingTeam\tools\run_automated_scans.py --telegram-token "8245864273:AAE9xuMtXpzDllI8QxGhH-POJ8SdS620SUU" --telegram-chat-id <YOUR_CHAT_ID>
```

## Cau truc tin nhan
Tin nhan Telegram bao gom:
- Symbol & Timeframe
- Direction (LONG/SHORT)
- Setup Family & Variant
- Score & Tier (A/B/C)
- Trigger & Invalidation Levels
- Notes

## Ghi chu van hanh
- Trang thai cac tin nhan da gui duoc luu tai: `TradingTeam/agents/Agent_2_SwingAgent/Runtime/sent_alerts.json`.
- Xoa file nay neu ban muon gui lai tat ca cac tin nhan cu.
- Toi thieu `score` mac dinh la `3` de gui canh bao. Co the thay doi bang `--min-score`.
