# Personal Finance Data Workspace

Workspace này chỉ lưu record tối thiểu cần cho personal-advisory run.

## Cho phép

- intake đã giảm định danh;
- goal/risk/portfolio summary theo khoảng giá trị;
- source records;
- plan version và changelog;
- consent/retention status của natal overlay.

## Cấm lưu

- username/password/OTP;
- seed phrase/private key;
- số tài khoản đầy đủ;
- số định danh, địa chỉ hoặc tài liệu KYC đầy đủ;
- natal data ngoài consent/retention scope;
- raw statement nếu summary đã đủ.

Mỗi record phải có owner/run ID, created/updated time, retention preference và deletion/review trigger. Personal data không được đưa vào `Financial_Market/Data`.
