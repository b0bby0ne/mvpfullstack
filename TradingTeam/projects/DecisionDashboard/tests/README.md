# Test Evidence

Thư mục lưu test code, fixtures và evidence cho:

- symbol/timezone/session normalization;
- golden-chart pattern detection;
- look-ahead bias và repainting;
- macro data provenance;
- API/UI contracts;
- paper-validation và release regression.

Dữ liệu tài khoản thật, credential và journal nhạy cảm không được commit.

`server/goldMacroOps.test.mjs` kiểm tra ngày nghiệp vụ UTC+7, lịch 06:05 và allowlist provenance của registry nguồn XAU hằng ngày.
