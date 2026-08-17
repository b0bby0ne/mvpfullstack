# Knowledge: Bob Volman Setup Catalog

## Muc tieu
Gom nhom setup va trigger quan trong cua Bob Volman de `SwingAgent` co the gan nhan pattern mot cach nhat quan.

## A. Setup cot loi tu `Forex Price Action Scalping`

### 1. Double Doji Break
- Ban chat: compression sau pullback, sau do break theo huong uu the truoc do.
- Boi canh tot:
  - trend ro
  - pullback nong, ngan, khong pha trend
  - cum doji hoac bars nho sat level
- Trigger:
  - pha khoi cum doji theo huong continuation
- Bo qua neu:
  - doji nam giua vung chop
  - barrier doi dien qua gan
  - khong co follow-through sau break

### 2. First Break
- Ban chat: lan break co y nghia dau tien qua mot barrier.
- Boi canh tot:
  - barrier duoc xac nhan ro
  - xu huong va ap luc dang nghieng ve huong break
- Trigger:
  - bar break chat, khong le loet
- Bo qua neu:
  - barrier mo ho
  - break qua som, buildup xau
  - ngay sau break co obstruction gan

### 3. Second Break
- Ban chat: break lan hai sau khi lan mot da mo duong nhung chua chay dep.
- Boi canh tot:
  - barrier da bi cong pha
  - pullback sau break khong pha hong luan diem
  - lan tan cong thu hai co tinh xac nhan
- Trigger:
  - break tiep theo theo huong lan dau
- Day la setup xac nhan lai, thuong chat hon First Break.

### 4. Block Break
- Ban chat: break khoi mot khoi gia bi nen chat.
- Boi canh tot:
  - nhieu bars tao thanh mot block chat
  - block nam sat barrier hoac sat huong uu the
- Trigger:
  - pha khoi block theo huong pressure
- Bo qua neu:
  - block qua rong
  - block nam giua vung vo nghia

### 5. Range Break
- Ban chat: pha khoi range ngang ro rang.
- Boi canh tot:
  - range ro bien
  - da co dau vet uu the truoc khi break
  - co false break o phia doi dien hoac buildup sat bien
- Trigger:
  - break dung bien range
- Day la setup de hinh nhung de false break, nen can context rat chat.

### 6. Inside Range Break
- Ban chat: mot rangepattern ben trong range lon hon, sau do break.
- Boi canh tot:
  - market dang nen them mot lop nua
  - pressure da chon ben kha ro
- Trigger:
  - break khoi pham vi con
- Gia tri cua setup nay den tu su nen tiep dien.

### 7. Advanced Range Break
- Ban chat: break cua mot range phuc tap, thuong sau nhieu lan quet, test, false move.
- Boi canh tot:
  - trader da doc duoc cau truc range va trap cua no
  - da co thong tin ve phe nao dang mat uu the
- Trigger:
  - break cuoi cung co support tu context, khong chi tu hinh dang
- Day la setup kho, khong dung cho market moi quan sat.

## B. Setup families tu `Understanding Price Action`

### 1. Pattern Break
- Trade mot break cua pattern duoc xac lap ro.
- Tuong ung mot phan voi `First Break`, `Range Break`, `Block Break`.

### 2. Pattern Break Pullback
- Sau break, cho pullback xac nhan roi moi vao.
- Tuong ung mot phan voi `Second Break`.

### 3. Pattern Break Combi
- Ket hop nhieu mini-pattern trong qua trinh buildup truoc va ngay sau break.
- Thuong dung khi market khong cho entry "sach sach dep" theo mot ten setup duy nhat.

### 4. Pullback Reversal (PR)
- Một hợp phần cực kỳ quan trọng. Kéo ngược (hồi lại) chạm vùng cản mấu chốt, có tín hiệu đâm ngược hỗ trợ.
- Dùng khi pullback chạm EMA 25 hoặc một level nằm ngang có ý nghĩa và giá bắt đầu quay lại theo hướng ưu thế chính.

### 5. Complex Pullback (CPB - Kéo ngược Phức tạp)
- Khi một cú Pullback không rơi/tăng thẳng một nhịp gọn gàng mà khựng lại, đâm thêm vài nhịp nhỏ tạo thành một Mini-Range hoặc nêm nhỏ (Wedge/Flag).
- CPB phá vỡ nêm này thuận theo xu hướng chính thường mang lại xung lực mạnh do khối lượng phe đánh ngược (counter-trend) bị nhốt lại và dính thanh lý (Stop-hunt).

### 6. False Break (FB - Đảo chiều Phá vỡ Giả)
- Vượt mức hỗ trợ / kháng cự quan trọng rất chớp nhoáng (thường là xuyên qua 1 bar rồi bị kéo ngược đuôi lên, hoặc tạo thân lùn).
- Setup này hoàn thiện khi thanh nến tín hiệu đóng mạnh mẽ quay ngược trở lại và nằm ngoài sự kiềm tỏa của EMA hướng ngược lại.
- FB tạo ra "sự mắc kẹt" tâm lý cực lớn. Bẫy này rất hiệu quả để bắt đầu một dao động lớn ngược hướng breakout vừa thất bại.

### 7. Teaser (T - Setup Phá vỡ Mồi / Phá vỡ Sớm)
- Giá chọc vỡ mức ranh giới nhưng chưa có đoạn nén khí (Buildup) rõ ràng ngay sát mức rào cản đó.
- Teaser thu hút nhóm trader nóng vội đu theo hướng phá vỡ sớm.
- Thường dẫn đến một cú đập nhả về lại EMA (Pullback). Nếu sau cú Teaser và Pullback giá lại tạo Buildup lần nữa, lúc đó cờ mới phất thành Second Break. Hạn chế vào lệnh trực tiếp tại nhịp Teaser đầu tiên.

## C. Mapping giua hai cuon
- Day la mapping van hanh, khong phai mapping chinh thuc tu tac gia.
- `Pattern Break` bao phu `First Break`, `Range Break`, `Block Break`.
- `Pattern Break Pullback` bao phu `Second Break`.
- `Pattern Break Combi` bao phu cac break co buildup phuc hop, gan voi `Inside Range Break` va mot phan `Advanced Range Break`.
- `Pullback Reversal` xuyen suot ca hai cuon.

## D. Tieu chi xep hang setup

### Setup A
- co double pressure ro
- barrier ro
- buildup chat
- duong chay ro
- vo hieu ngan va logic

### Setup B
- context duoc
- setup nhin thay duoc
- nhung con obstruction, momentum hoac buildup chua dep

### Setup C
- hinh dang co ve giong setup
- nhung khong co context, khong co duong chay hoac vo hieu mo ho
- mac dinh loai
