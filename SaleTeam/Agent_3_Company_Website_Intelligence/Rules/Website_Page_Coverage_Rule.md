# Quy tắc: Coverage và trạng thái trang

## Mục tiêu
Giúp Agent 3 ghi rõ đã quét trang nào, trang nào chưa quét và trang nào là trọng tâm cho account research.

## Các trạng thái coverage
- `Đã quét`
- `Đã quét sơ bộ`
- `Chưa quét`
- `Không áp dụng`

## Nhóm trang cần theo dõi
- homepage
- about
- product / solution
- pricing
- customer / case study
- careers
- blog / newsroom
- contact / locations

## Quy tắc
- Mỗi run nên ghi rõ coverage tối thiểu cho các nhóm trang trên.
- Nếu sitemap có nhóm trang rất lớn, có thể chỉ quét sơ bộ và đánh dấu `Đã quét sơ bộ`.
- Nếu thiếu nhóm trang quan trọng như pricing hoặc product, phải ghi rõ là `Không tìm thấy` hoặc `Chưa quét`.
