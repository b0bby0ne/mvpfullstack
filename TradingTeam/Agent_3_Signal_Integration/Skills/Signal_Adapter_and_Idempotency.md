# Skill: Signal Adapter and Idempotency

## Mục tiêu

Biến mọi nguồn tín hiệu thành event nhất quán và bảo đảm một tín hiệu chỉ gây side effect tối đa một lần theo policy.

## Pipeline

```text
Read -> Parse -> Validate schema -> Normalize -> Check expiry
     -> Deduplicate -> Permission gate -> Risk gate -> Execute -> Persist result
```

## Dedup key

Ưu tiên `signal_id` từ upstream. Nếu không có, tạo deterministic key từ:

- source/version;
- normalized symbol/timeframe;
- action;
- event/bar time;
- strategy-specific discriminator.

Không dùng duy nhất thời gian EA nhận message vì retry sẽ tạo ID khác.

## State lưu tối thiểu

- signal ID và status: received/rejected/executing/succeeded/failed/expired;
- source event time và receive time;
- terminal request/deal/order identifier khi có;
- retry count và lỗi cuối;
- EA/version/schema version.

## Retry policy

- Chỉ retry lỗi được phân loại là tạm thời.
- Trước retry phải query terminal để tránh gửi lại request đã thành công nhưng mất acknowledgement.
- Retry có giới hạn, backoff và signal expiry.
- Lỗi validation không được retry.
