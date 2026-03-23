# UI/UX Design Specs: PageSprint AI (The Kinetic Ether)

## 1. Chiến lược thiết kế (Design Strategy)
- **Concept**: "The Kinetic Ether" - Một giao diện không trọng lực, sử dụng các khối dữ liệu lơ lửng trong không gian kỹ thuật số sâu thẳm.
- **Phong cách**: Dark mode, Glassmorphism, Modern & Premium.
- **Màu sắc chủ đạo**: Electric Purple (#cc97ff) trên nền Deep Void (#060e20).
- **Typography**: Manrope (Headlines) & Inter (Body).

## 2. Các màn hình thiết kế (User Flow Screens)
Đã hoàn thành thiết kế trọn bộ 4 màn hình đáp ứng hành trình người dùng (User Flow) trong SRS:

1.  **Dashboard (The Command Line)**: Nơi người dùng nhập Product Prompt.
    - [Giao diện Dashboard](https://lh3.googleusercontent.com/aida/ADBb0ujIhXZuJlFOgZWllTCNLgWD2gK9bEOaInNmCvVeEProxCidXIGbSXjtOZ4R3hrThVqzhns_X6WEZQemHt_Z6YmcMkIJquZy8JNQBGbBYfvtYTODM-21PTdtOUZRXhJV16KMUFFZ-9cfvdIcmeAfrJPUIZOXt2xmgw7F42JX57FiizGdLwbqP7SuBk1VumFyRhJR34GGnPFoIwzGQA-XMNaM3V4tkvkPj0MmMm3hW5JagmlqmsEVWs3rG2o)
2.  **Results Preview (Angle Choice)**: Hiển thị 3 phương án chiến lược.
    - [Giao diện Results Selection](https://lh3.googleusercontent.com/aida/ADBb0ugN2I-XgQRB1Fqd57Htqfo6H6cd2j8D1-rplWRTKIPK-YzK6lmde1QOY6z-_9cylFxImJD9meYHor68F9Hjg7NLZ0cYVrD8KRLrHPVlA7btz8Gf0tpnjTQ_fguspOrUSryvT6zvhPdbpAJlx37DJY91AezLRc_fBwSibXYa6dFmwuwJXy725M4DC-V2EnNHR-foJcpV-9DYaOZ0QMSTGKm2_hMw9Z-NroHgrf4d_GzIn-XLJGQlk0cOqqk)
3.  **Editor/Preview (Interaction)**: Chỉnh sửa nội dung trực tiếp trên bản Preview.
    - [Giao diện Editor](https://lh3.googleusercontent.com/aida/ADBb0uhBimm8SFHhb2Qf0qOu92eEoBo4PxavLXs8vBPzCZy-sBJW65MRTQQP9Ba3x2dbf4kS3Gj_FAgjaSSsSLJKWTiAGME9ghiiGhLLPs3or37rnbJPoPc-o7B9OgTOiP_uGCtjQn48NVCgcnPgzF7KK2XeevaZzhXIpr3em7yPF-nm6pOMjny4SlJY7I9Y7HlOZ4J8Nh96-pqQP-KhwT73Gm_vPsoZ8GBZ8EsNGkORznitkHD6L6NkgKwKvqHa)
4.  **Export Success (Completion)**: Màn hình xác nhận và nút tải ZIP.
    - [Giao diện Success](https://lh3.googleusercontent.com/aida/ADBb0ujprOiDXfmony5lcUrwdVXPrWwiuL_g31mUzeho-BsEsZcE1M83zXFmIZfdVadrwGKXTPCXlyysKeY-MR3pHLunvali2lL1_3V2WJtplUONKosF9nb__6hGR6UzVT4icoi4v_dKD1jf_MIpNJ1eYVN16jX2E3b7czsE6JWlU5utCmef6O0BRvLDjdAZfmx9hYZoD5vOt5SLCQF7c18zR7LwsLWfmXOmu1NkaVHRLRQsS0MG9zRx6wvuE3Vw)

## 3. Các thành phần UI chính (Core Components)
---
### 3.1 Dashboard (The Command Line)

## 3. Link & Tài nguyên Stitch
- **Project ID**: `10061146242740640161`
- **Live Preview Link**: [Open PageSprint AI on Stitch](https://stitch.withgoogle.com/projects/10061146242740640161)
- **Thumbnail**: [View Dashboard Preview](https://lh3.googleusercontent.com/aida/ADBb0ujIhXZuJlFOgZWllTCNLgWD2gK9bEOaInNmCvVeEProxCidXIGbSXjtOZ4R3hrThVqzhns_X6WEZQemHt_Z6YmcMkIJquZy8JNQBGbBYfvtYTODM-21PTdtOUZRXhJV16KMUFFZ-9cfvdIcmeAfrJPUIZOXt2xmgw7F42JX57FiizGdLwbqP7SuBk1VumFyRhJR34GGnPFoIwzGQA-XMNaM3V4tkvkPj0MmMm3hW5JagmlqmsEVWs3rG2o)

## 4. Ghi chú bàn giao (Agent 4 to Dev)
- Sử dụng Tailwind CSS với các Utility Classes cho glassmorphism (`backdrop-blur-xl`).
- Không sử dụng Border-solid 1px cho các khối module chính.
- Ưu tiên các hiệu ứng chuyển cảnh mượt mà khi người dùng hover vào các Angle Cards.
