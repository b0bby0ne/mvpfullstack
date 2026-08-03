# Kỹ năng kiểm định chéo engine chiêm tinh

## 1. Mục tiêu

Phân biệt lỗi dữ liệu/parser/configuration với sai khác mô hình ephemeris. Kết quả kiểm định thiên văn không kiểm định khả năng dự báo thị trường.

Script chuẩn: [compare_astro_states.py](../../../.agents/skills/astroteam-collect-astro-data/scripts/compare_astro_states.py).

## 2. Equivalence gate

Chỉ so sánh khi hai record tương đương về:

- instant/timescale;
- observer center/site và topocentric coordinates;
- geometric/astrometric/apparent correction;
- frame/ecliptic/equinox;
- tropical/sidereal và ayanamsha;
- body/point definition, node policy và house system.

Sai convention phải trả `NOT_COMPARABLE_CONVENTION`, không tính delta rồi quy thành lỗi engine.

## 3. Independence gate

Ghi engine/API version, theory/kernel, EOP/Delta-T và correction pipeline. Hai wrapper của cùng library/config không độc lập. Hai engine cùng DE441 có thể kiểm tra parser/config nhưng phải gắn `shared_upstream_lineage`; upstream thiếu hoặc dùng chung không được pass full astronomical-validation gate. Muốn kiểm định ephemeris độc lập cần theory/kernel khác phù hợp.

## 4. Delta và tolerance

- longitude/RA: circular delta;
- latitude/declination/speed/cusps: absolute delta cùng đơn vị;
- exact time: UTC seconds của cùng event/pass;
- categorical labels: chỉ so sau khi numeric primitives pass.

Tolerance phải khóa trước. Mốc vận hành ban đầu:

- planetary longitude `0.01°`;
- Moon longitude `0.02°`;
- latitude/declination `0.02°`;
- exact-event time `900 s`;
- houses/angles `0.1°` khi inputs/system trùng khớp.

Các mốc này là QA policy, không phải tuyên bố sai số phổ quát. Không nới tolerance sau khi thấy outlier.

## 5. Báo cáo và adjudication

Mỗi field ghi primary/secondary value, delta, tolerance, pass/fail, lineage và nguyên nhân nghi vấn. Nhãn chuẩn:

- `PASS`;
- `WARN_MODEL_DIFFERENCE`;
- `NOT_COMPARABLE_CONVENTION`;
- `FAIL_DATA_OR_SOLVER`.

Recompute từ raw artifacts/hash trước khi chọn nguồn ưu tiên. Chỉ gắn `Cross-validated astronomical` khi coverage đủ, equivalence gate pass, engine implementation và upstream ephemeris lineages đều khác, và mọi field bắt buộc trong tolerance.
