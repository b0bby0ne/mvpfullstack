# Knowledge: AI Strategy Decision Matrix (RAG vs Fine-tune vs Chain)

Mục tiêu: Giúp Agent 2 đưa ra quyết định kỹ thuật tối ưu nhất dựa trên mục tiêu nghiệp vụ.

## 1. Decision Matrix
| Kỹ thuật | Khi nào nên dùng | Ưu điểm | Nhược điểm |
|----------|-----------------|---------|------------|
| **Prompt Chaining** | Logic phức tạp, nhiều bước. | Linh hoạt, dễ sửa, chi phí thấp. | Tốn thời gian chờ (Latency). |
| **RAG (Vector DB)** | Cần truy xuất tri thức lớn, dữ liệu riêng tư. | Cập nhật dữ liệu real-time, ít ảo giác. | Kết quả phụ thuộc vào Search. |
| **Fine-tuning** | Cần thay đổi tone-of-voice, định dạng output đặc thù. | Phản hồi cực nhanh, chuẩn format. | Đắt, dữ liệu bị "cứng", khó cập nhật. |

## 2. Tiêu chí lựa chọn cho MVP
- Luôn bắt đầu bằng **Prompt Chaining** kết hợp với **Few-shot prompting**.
- Chỉ dùng **RAG** khi dữ liệu đầu vào vượt quá giới hạn Token Window của LLM.
- **Fine-tuning** là lựa chọn cuối cùng khi cần tối ưu tuyệt đối về tốc độ hoặc chi phí token (nén prompt).
