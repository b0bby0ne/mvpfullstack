# Checklist QA kế hoạch đầu tư cá nhân

Mỗi mục được ghi `Pass`, `Fail`, `Not applicable` hoặc `Blocked by missing data`, kèm bằng chứng ngắn. `Present` phải đạt mọi mục áp dụng. `Framework` được phép có mục `Blocked by missing data` nếu chính output nêu rõ dữ liệu thiếu, không đưa target cá nhân hóa và không tự nhận là plan hoàn chỉnh. `Escalation` chỉ cần đạt các mục phạm vi, an toàn, nguồn và chuyển tuyến áp dụng.

## Intake và suitability

- [ ] Với `Present`, jurisdiction, currency, goals và horizon rõ; với `Framework`, phần thiếu được liệt kê và chặn cá nhân hóa.
- [ ] Với `Present`, cash flow, emergency reserve, debt, liquidity và dependants đã xét; với `Framework`, phần thiếu được liệt kê và chặn cá nhân hóa.
- [ ] Risk capacity/willingness được tách khỏi required return/funding gap.
- [ ] Holdings/concentration chính đã biết hoặc giới hạn được ghi.
- [ ] Plan chỉ dùng mức cá nhân hóa được planning-suitability và authorization gate cho phép.
- [ ] Advice mode ánh xạ đúng sang plan status theo Authorization Gate.

## Kế hoạch

- [ ] Baseline plan được viết mà không cần astrology.
- [ ] Allocation là khoảng có vai trò/rủi ro, không phải con số thần kỳ.
- [ ] Range coherence đạt: `Σ min ≤ 100% ≤ Σ max`, có candidate tổng 100%, denominator rõ và không double-count holdings/goal buckets.
- [ ] `Present` ghi assumption-set ID/as-of và range-coherence record; `Framework` không có range cá nhân hóa được ghi `Not applicable`.
- [ ] Mục tiêu ngắn hạn thiết yếu không phụ thuộc tài sản biến động cao.
- [ ] Có contribution, rebalancing và review policy.
- [ ] Có stress test và hành động định trước.

## Sản phẩm và nguồn

- [ ] Product facts, fees, liquidity và key risks còn hiện hành.
- [ ] Snapshot/published time, valid-until/refresh triggers và `Freshness status` nhất quán giữa Master Index và file 05.
- [ ] Nguồn chính thức/prospectus được ưu tiên.
- [ ] Tax/legal claim có jurisdiction, ngày hiệu lực và nguồn.
- [ ] Past performance không là lý do duy nhất.

## Astrology

- [ ] Route B/no-astro ghi overlay `None` và mục consent là `Not applicable`; nếu có overlay, người dùng đã chủ động yêu cầu hoặc đồng ý.
- [ ] Nếu overlay dùng natal chart, natal data có consent và độ chính xác; nếu chỉ dùng market-transit scenario hoặc `None`, mục này là `Not applicable`.
- [ ] Overlay là `None`, `Reflective only` hoặc `Scenario monitoring` theo route; không có `Execution`.
- [ ] Astrology không đổi risk profile, allocation, sản phẩm hoặc execution.
- [ ] Astrology không phải căn cứ một phần cho recommendation tài chính.
- [ ] Khi có overlay, independence test đạt; với overlay `None`, ghi `Not applicable — no astrology used`.

## An toàn

- [ ] Không có bảo đảm lợi nhuận hoặc ngôn ngữ chắc chắn.
- [ ] Không có credential/account identifier/private key.
- [ ] Không tự nhận giấy phép/fiduciary status.
- [ ] Không có exact buy/sell amount, share/token count, entry/exit, order type hoặc transaction timing.
- [ ] Không có leverage/margin/derivatives recommendation trong personal plan.
- [ ] Product-specific personalization đã được chuyển ra chuyên gia có giấy phép bên ngoài; AstroTeam không phát hành sau review.
- [ ] Có escalation khi tax/legal/solvency/complex-product risk vượt phạm vi.
