# Skill: Bob Volman Structure Filtering

## Muc tieu
Doc hanh vi gia theo logic price action ngan han kieu Bob Volman va loai bo cac cu swing khong sach.

## Knowledge dependencies
- `Knowledge/Bob_Volman_Principles.md`
- `Knowledge/Bob_Volman_Setup_Catalog.md`
- `Knowledge/Bob_Volman_Execution_Management.md`
- `Knowledge/Bob_Volman_Training_Risk.md`

## Dau vao bat buoc
- asset-level handoff tu `PriceAgent`
- readiness flag cua asset
- market package tu `Agent_2_SwingAgent/Handoff/markets/*.json`
- log goc cua symbol neu can kiem tra chuoi gia

## Dieu kien truoc khi phan tich
- neu `swing_read_mode == hold`, dung va khong phan tich
- neu `swing_read_mode == context_only`, chi duoc doc boi canh lon
- neu `swing_read_mode == full_bob_volman`, moi duoc chay full checklist ben duoi

## Tru cot phan tich
- double pressure va barrier quality
- cau truc dinh day gan nhat
- do doc va nhip cua impulse
- chat luong breakout
- do nong hoac sau cua pullback
- vi tri setup so voi range, block va session context

## Tieu chi swing sach
- co toi thieu 2 nguon pressure cung huong
- co mot leg day ro rang truoc khi pullback
- pullback khong pha hong hoan toan cau truc vua tao
- diem vo hieu nam o noi logic, khong qua xa
- khong vao giua vung nhieu dinh day chong lap

## Tin hieu can loai
- khong co double pressure
- breakout khong co follow-through
- pullback qua sau lam mat uu the cau truc
- nhieu overlap lien tiep tao vung chop
- setup xuat hien ngay truoc vung can gan ma khong con khoang chay

## Checklist thuc thi
1. Doc handoff summary va chon asset du readiness.
2. Xac dinh trang thai: trend, range hay transition.
3. Ve barrier, swing high, swing low, false high, false low va buildup gan nhat.
4. Liet ke cac pressure elements; neu duoi 2 thi dung.
5. Map pattern sang setup family cua Bob Volman.
6. Kiem tra cu break co duoc xac nhan bang nhip tiep dien khong.
7. Danh gia pullback theo do sau, toc do, vi tri va duong chay.
8. Xac dinh vung vao lenh gia dinh, muc vo hieu, obstruction va do tin cay.
9. Loai cac setup khong dap ung logic cau truc.
