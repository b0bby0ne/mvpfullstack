# AstroTeam shared astro-data workspace

Thư mục này là vị trí runtime dùng chung cho dữ liệu thu thập/tính toán. Nội dung runtime bị `.gitignore` để tránh commit nhầm raw API response, location hoặc natal data.

```text
Astro_Data/
├─ raw/          # response nguyên trạng, chỉ khi retention được bật
├─ manifests/    # collection request/source manifest và SHA-256
├─ states/       # astro_state/snapshot
├─ windows/      # sampled ephemeris windows
├─ events/       # exact-event calendars
├─ enrichment/   # doctrine/house/condition outputs
├─ validation/   # cross-engine reports
├─ anchors/      # dữ liệu anchor đã được phép lưu
└─ cache/        # cache có lineage + expiry
```

## Quy tắc lưu trữ

- Mặc định chỉ giữ hash/provenance trong output; raw retention cần được bật rõ.
- Raw response là immutable; replay phải xác minh SHA-256 trước khi parse.
- Cache key gồm canonical request hash, engine/version, kernel/theory, frame, timescale và observer.
- Không lưu secret trong URL/manifest.
- Natal/birthplace và location topocentric là dữ liệu nhạy cảm: chỉ lưu tối thiểu theo consent/retention policy; ưu tiên derived state đã giảm nhận diện.
- Xóa/expire artifact theo retention policy của run; không dùng lại anchor cá nhân cho mục đích khác.

Các script không tự tạo dữ liệu mẫu tại đây. Người chạy chọn `--output`/`--raw-dir` khi thực sự muốn lưu artifact.
