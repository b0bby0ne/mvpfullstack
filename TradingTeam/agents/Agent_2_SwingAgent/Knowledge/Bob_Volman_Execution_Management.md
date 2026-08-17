# Knowledge: Bob Volman Execution and Management

## 1. Nguyen tac entry
- Khong du doan som hon chart.
- Break dep thi vao theo break.
- Pullback dep thi vao khi market cho thay da quay lai huong uu the.
- Limit order khong phai trong tam cua cach tiep can nay; trong tam la xac nhan gia.
- Bar signal phai co chat luong, khong duoc nua vay nua mo.

## 2. Stop placement
- Stop phai dua tren diem vo hieu cau truc.
- Diem vo hieu thuong nam o ben kia:
  - signal bar
  - cluster
  - swing mini
  - muc support/resistance ma trade dang dua vao
- Khong doi stop rong hon de "mong" trade quay lai.

## 3. Target philosophy
- Triet ly chung la uu tien muc tieu vua phai, lap lai duoc.
- Trong public summaries cua `Forex Price Action Scalping`, muc tieu co tinh chuan hoa thuong duoc mo ta la nho va co tinh scalping.
- Voi repo nay, SwingAgent khong duoc mac dinh tham lam theo "runner" neu chart chua cho phep.

## 4. Tipping point technique
- Day la ky thuat quan ly lenh trung tam trong sach dau.
- Operational reading:
  - luc trade van chay dung ky vong, giu stop cau truc
  - khi trade co dau hieu stall hoac cau truc moi sinh ra, diem tipping point co the duoc cap nhat
  - stop chi duoc keo theo huong giam rui ro, khong duoc mo rong lai
- Dinh nghia van hanh cho repo nay:
  - tipping point = muc gia ma neu bi xuyen, luan diem trade hien tai khong con dung nua
  - day la mot level ky thuat, khong phai muc cam xuc

## 5. Manual exits

### News report exit
- Neu co su kien tin tuc lam thay doi hanh vi gia dot ngot, can uu tien thoat hon la co chap giu mot luan diem cu.

### Resistance exit
- Khi trade gap barrier gan va chart khong cho thay kha nang xuyen qua dep, thoat la hop ly.

### Reversal exit
- Khi gia in ra thong tin nguoc huong co y nghia, dac biet sau mot false break hoac reversal bar ro, can thoat chu dong.

## 6. Skipping trades
- Bo qua trade la mot ky nang cot loi, khong phai hanh vi thu dong.
- Cac ly do skip kinh dien:
  - chop
  - flat EMA va context mo ho
  - break dam vao obstruction gan
  - buildup khong chat
  - false break sai huong nhung khong tao du pressure nguoc
  - setup dep nhung nam giua range

## 7. Failure trading
- "Trade for failure" khong dong nghia cu thay break hong la vao nguoc.
- Chi giao dich huong nguoc khi:
  - break that bai o diem nhay cam
  - co phan ung ro cua phe doi dien
  - co them it nhat mot nguon pressure khac hoi tu

## 8. Dieu kien de SwingAgent xuat setup
- Phai chi ra:
  - setup family
  - direction
  - barrier lien quan
  - double pressure elements
  - invalidation point
  - obstruction gan nhat
- Neu thieu bat ky thanh phan nao, uu tien xep vao watchlist hoac loai.
