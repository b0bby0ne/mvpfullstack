# Kỹ năng chart, houses và condition enrichment

## 1. Gate dữ liệu chart

Muốn tính chart mới phải có:

- UTC instant và nguồn timestamp/timezone;
- geographic latitude/longitude, location precision và elevation policy;
- tropical/sidereal + ayanamsha;
- named house system;
- engine/version và exact settings;
- timestamp/location uncertainty và sensitivity policy.

Date-only, giờ ước tính hoặc location thiếu thì houses/angles là `unsupported` hoặc `not_requested`, không phải `không có`.

## 2. Houses và angles

Script enrichment có thể gán:

- whole-sign house từ Ascendant sign được cung cấp;
- equal house từ Ascendant longitude được cung cấp.

Ascendant, MC và quadrant cusps phải đến từ engine house đã kiểm định. Không tự dựng quadrant houses từ longitude hành tinh. Nếu engine không tính được house system ở vĩ độ cực hoặc tự fallback, phải ghi `requested_system`, `returned_system`, error/warning; cấm silent fallback.

## 3. Doctrine profile

Khóa và xuất lại trong kết quả:

- rulership/exaltation/detriment/fall table;
- traditional/modern outer-planet rulership policy;
- sect convention và day/night input;
- cazimi/combust/under-beams thresholds;
- declination/OOB và parallel orb policy;
- Lot formulas/day-night reversal;
- fixed-star catalog, epoch, frame/precession và orb.

Không suy sect chỉ từ giờ đồng hồ. Không trộn nhiều dignity table trong cùng run.

## 4. Enrichment xác định

[enrich_astro_state.py](../../../.agents/skills/astroteam-collect-astro-data/scripts/enrich_astro_state.py) bổ sung, không sửa, ephemeris gốc:

- essential dignity và dispositor theo profile;
- solar proximity với threshold được công bố;
- declination OOB, parallel/contra-parallel khi có field;
- whole-sign/equal house assignment khi có Ascendant;
- Lots of Fortune/Spirit khi có Ascendant và explicit sect.

Fixed-star contact chỉ được tính từ catalog có frame/epoch và propagation policy tương thích. Script bundled chỉ nhận ecliptic `longitude_deg` đã chuyển đúng state frame/epoch; catalog RA/Dec cần adapter chuẩn hóa bên ngoài. Không so trực tiếp catalog J2000 với longitude-of-date.

## 5. Anchor và quyền riêng tư

Ghi anchor type, nguồn, alternative anchors và uncertainty. Với natal/personal chart, ưu tiên lưu derived state thay vì raw birth data; chỉ giữ dữ liệu được người dùng cho phép.

Condition/house labels là phân loại chiêm tinh, không phải lực vật lý, expected return, risk capacity, suitability hay transaction timing.
