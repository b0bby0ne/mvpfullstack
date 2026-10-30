# Workflow cải tiến chiến lược IndiSingle

## Selected v2.58: tăng mẫu ENGULFED BUY bằng price failure tại session 16–23

V2.58 giữ nguyên multi-position, risk 1%, SL/TP và toàn bộ lane selected v2.57. ENGULFED BUY được phép thêm `WY_NONE` chỉ khi SELL quét đáy accumulation rồi bị BUY engulf/close-back trong session server 16–23. Không có Wyckoff anchor nên session thanh khoản là điều kiện bổ sung; `SOW/TEST` cũ không bị thay đổi.

So với v2.57, OOS tăng 382 → 385 lệnh, Net 58.498,31 → 59.130,05 USD, PF 2,77 → 2,79 và RF 27,11 → 27,47; DD giữ 6,82%. Riêng 2025 tăng hai winner, Net 19.743,55 → 20.300,62 USD và RF 21,20 → 21,69. Extended và real ticks 2026 tái lập tuyệt đối control. ENGULFED BUY hiện đại tăng 12 → 15 mẫu, toàn portfolio tăng 536 → 539 lệnh trong 46 tháng. Forward test vẫn hoãn. Chi tiết: `docs/ENGULFED_BUY_NOEVENT_SESSION_V258.md`.

Tổng hợp toàn bộ 17 nhánh active, 3 nhánh OFF, logic, số lệnh từng năm và mức ưu tiên tiếp theo nằm tại `docs/SETUP_PERFORMANCE_SUMMARY_V258.md`. Modern đạt 11,72 lệnh/tháng, WR 69,76%, Net +77.419,52 USD và PF 2,94; khoảng 60% Net modern đến từ 2025 nên concentration risk vẫn phải được theo dõi.

Bản đồ context của ba nhánh OFF và các nhánh dưới 0,50 lệnh/tháng nằm tại `docs/OFF_LOW_SAMPLE_CONTEXT_MAP_V258.md`. Hướng cải thiện là thêm lane ngoại lệ độc lập dựa trên external liquidity, volume chronology, POC/VWAP migration và volatility transition; không áp context mới như filter chung lên core selected. Thứ tự ưu tiên: NOENTRY → ARB SELL → inverse EMAENGULF SELL → ARB BUY → IRB SELL.

## Selected v2.57: SB BUY failure-to-progress tại EXTENDED

Theo tiêu chí mới, EA tiếp tục cho phép nhiều vị thế đồng thời và chấp nhận nhiều lệnh âm tạm thời; không dùng directional-risk cap. Kết quả gần nhất 2025–2026 được ưu tiên, còn Extended dùng làm kiểm định logic.

V2.57 chỉ đóng SB BUY sau đúng bốn nến M5 nếu confirmation là full-body tại location H1 `EXTENDED`, MFE vẫn dưới 0,25R và close gần nhất không vượt entry. Rule giảm độ lớn hai loser 2025 mà không loại entry hoặc thay đổi SL/TP/risk. Extended và real ticks 2026 tái lập control; OOS tăng Net 57.399,72 → 58.498,31 USD, PF 2,71 → 2,77 và RF 23,68 → 27,11. Backtest riêng 2025 tăng Net 19.241,24 → 19.743,55 USD và RF 18,39 → 21,20.

Giữ v2.57 làm selected pre-official. Không chia tiếp hai lệnh vừa chọn. Vòng sau bỏ qua portfolio risk cap và chuyển sang lane tăng mẫu độc lập. Forward test vẫn hoãn. Chi tiết: `docs/SB_BUY_FAILURE_TO_PROGRESS_V257.md`.

## Audit v2.34: không mở rộng ARB BUY

V2.34 kiểm tra ba hướng tăng mẫu ARB BUY: kéo dài tuổi sell-side sweep, thay range 12 bằng 8/10/14/16 nến, và ghép alternate range 8 vào core 12. Older sweep bị loại vì lane mới âm OOS và làm Extended giảm; displacement/FVG không sửa được. Range 8 tăng lệnh nhưng ARB OOS chỉ còn WR 41,67%, PF 1,00. Alternate range 8 + Wyckoff active không có mẫu Extended/2026 và làm OOS portfolio giảm nhẹ.

Không có rule mới được nhận. Preset v2.34 khóa toàn bộ detector nghiên cứu OFF và tái tạo chính xác v2.33: Extended +4.123,88; OOS +42.998,56; 2026 +16.197,36 USD. Giữ logic v2.33 làm control, không forward test. Vòng sau chuyển sang inverse `ENGULFED SELL`; không tiếp tục chia nhỏ 17 lệnh ARB hiện tại. Chi tiết: `docs/ARB_RANGE_ACCEPTANCE_AUDIT_V234.md`.

## Candidate v2.33: ENGULFED BUY theo accumulation failure có Wyckoff chọn lọc

V2.33 mô hình hóa entry BUY nghịch đảo bằng trình tự M5 `sell-side sweep → close-back`; detector rộng bị loại vì làm Extended giảm mạnh. Lane selected chỉ nhận snapshot Wyckoff H1 `SOW` hoặc `TEST`: SOW phải thất bại thành bear trap, còn TEST đại diện cho absorption/retest quanh đáy vùng.

Kết quả selected: Extended giữ nguyên +4.123,88 USD/PF 1,29/RF 2,19; OOS tăng lên +42.998,56/PF 2,13/RF 19,51/DD 7,16%; 2026 tăng lên +16.197,36/PF 2,81/RF 17,40/WR 69,14%. ENGULFED BUY modern tăng 7 → 12 lệnh, WR 75,00%; toàn portfolio đạt 588 lệnh/46 tháng = 12,78 lệnh/tháng.

Giữ v2.33 làm control pre-official. Không tinh chỉnh tiếp trên năm entry mới; vòng kế tiếp ưu tiên tăng mẫu `ARB BUY`. Forward test vẫn hoãn. Chi tiết: `docs/ENGULFED_BUY_FAILURE_SEQUENCE_V233.md` và `docs/SETUP_PERFORMANCE_SUMMARY_V233.md`.

## Tổng hợp setup sau v2.30

V2.30 có 15 nhánh hoạt động, đạt 553 lệnh trong 46 tháng hiện đại, tương đương 12,02 lệnh/tháng. SB BUY là nguồn Net lớn nhất; DDB BUY và FB SELL đứng tiếp theo. Bốn nhánh thiếu mẫu nhưng đang có expectancy dương là RB SELL, ARB BUY, BB BUY và inverse ENGULFED BUY.

Giữ v2.30 làm control. Vòng tiếp theo ưu tiên mở rộng RB SELL từng điều kiện một; chỉ chấp nhận khi số mẫu tăng trên ít nhất hai vùng và Net không giảm ở Extended/OOS/2026. Chi tiết: `docs/SETUP_PERFORMANCE_SUMMARY_V230.md`.

## Candidate v2.30: FB SELL không bán đuổi tại đáy range 240H

MAE/MFE xác nhận TP 1R và SL theo nến entry vẫn phù hợp; break-even 0,5R/0,75R làm giảm tính ổn định giữa OOS và 2026. Rule mới chỉ chặn `FB SELL × location EXTENDED × wait0`: entry SELL tức thời khi giá đã nằm trong 20% phía dưới của range 240H.

V2.30 đạt Extended +3.152,81 USD/PF 1,24/RF 1,72/DD 13,85%; OOS +35.089,89/PF 2,09; 2026 +14.626,59/PF 2,81/RF 16,73/DD 4,23%/WR 69,28%. Tổng Net ba vùng tăng 995,07 USD so với v2.29. Rule loại đúng hai loser làm 2023 âm mà không dùng year filter.

Giữ v2.30 làm control. Ba audit EMAENGULF BUY, DDB BUY và FB SELL đã hoàn tất; bước tiếp theo là tăng mẫu có kiểm soát cho RB SELL. Chi tiết: `docs/FB_SELL_MAE_MFE_V230.md`.

## Candidate v2.29: DDB BUY tránh LOW confluence trong volatility bình thường

MAE/MFE xác nhận TP 1R và SL theo nến entry vẫn hợp lý. Break-even 0,5R/0,75R làm mất quá nhiều winner OOS/2026, nên lỗi chính là chất lượng tín hiệu. Rule mới chỉ chặn `DDB BUY × confluence LOW × volatility NORMAL`; không chặn LOW khi volatility contracting/expanding.

V2.29 đạt Extended +2.988,71 USD/PF 1,22/RF 1,64/DD 13,93%; OOS +34.277,10/PF 2,08/RF 18,95; 2026 +14.608,41/PF 2,74/RF 16,11/DD 4,23%/WR 69,05%. Tổng Net ba vùng tăng 1.306,86 USD so với v2.28. DDB BUY chuyển dương trên Extended và tăng PF tại cả ba vùng.

Giữ v2.29 làm control; bước tiếp theo là FB SELL MAE/MFE và structure để phân biệt Extended/2023 khỏi 2024–2026 mà không dùng năm làm filter. Chi tiết: `docs/DDB_BUY_MAE_MFE_V229.md`.

## Candidate v2.28: inverse EMAENGULF BUY tránh BEAR_W5 và LPSY

MAE/MFE xác nhận TP 1R và SL hiện tại phù hợp; break-even 0,5R làm mất nhiều winner hiện đại hơn số loser cứu được. Chỉ hai structure cùng âm trên Extended/OOS và không có mẫu 2026 được chặn: Elliott `BEAR_W5` và Wyckoff `LPSY`.

V2.28 đạt Extended +2.468,00 USD/PF 1,17/RF 1,26/DD 14,79%; OOS +33.798,47/PF 2,03/RF 18,77; 2026 giữ nguyên +14.301,89/PF 2,59/RF 15,93/DD 4,17%/WR 68,00%. Tổng Net ba vùng tăng 937,17 USD và giảm 6 lệnh so với v2.27.

EMAENGULF BUY isolated Extended vẫn âm, nên không tinh chỉnh tiếp trên mẫu nhỏ. Giữ v2.28 làm control; bước kế tiếp là DDB BUY MAE/MFE và structure. Chi tiết: `docs/EMAENGULF_BUY_STRUCTURE_V228.md`.

## Tổng hợp setup sau v2.27

V2.27 có 15 nhánh hoạt động. Tần suất 2023–20/10/2026 đạt 12,52 lệnh/tháng, còn thấp hơn mục tiêu 30. SB BUY là nguồn Net lớn nhất; DDB BUY đứng thứ hai. DDB SELL và IRB BUY đã cải thiện ổn định qua v2.26–v2.27 nên tạm dừng tinh chỉnh.

Ưu tiên mới là inverse EMAENGULF BUY vì Extended -526,95/PF 0,63 nhưng giai đoạn 2023–2026 đạt +3.104,43/PF 5,64. Sau đó audit DDB BUY và FB SELL. Không nới các setup thiếu mẫu hoặc bật setup OFF chỉ để tăng tần suất. Chi tiết: `docs/SETUP_PERFORMANCE_SUMMARY_V227.md`.

## Candidate v2.27: giữ multi-position, lọc IRB BUY thiếu activity

Directional-risk cap bị loại vì không ổn định: cap hai vị thế cải thiện OOS nhưng loại BB/SB SELL thắng trong 2026; các cap một vị thế làm giảm Net mạnh. EA tiếp tục nhận mọi setup hợp lệ và không giới hạn riêng số vị thế BUY/SELL.

MAE/MFE IRB BUY xác nhận TP 0,75R và SL theo nến vẫn phù hợp. Chỉ interaction `IRB BUY × session 08–15 × activity CONTRACTING` âm ở cả Extended/OOS/2026 nên được chặn. V2.27 đạt Extended +2.070,15 USD/PF 1,14; OOS +33.259,15/PF 2,00/RF 18,74; 2026 +14.301,89/PF 2,59/RF 15,93/DD 4,17%/WR 68,00%.

So với v2.26, tổng Net ba vùng tăng 1.330,24 USD và giảm 7 lệnh. Giữ v2.27 làm control; bước tiếp theo là inverse EMAENGULF BUY. Chi tiết: `docs/DIRECTIONAL_RISK_AND_IRB_BUY_V227.md`.

## Candidate v2.26: DDB SELL theo MAE/MFE và structure

MAE/MFE xác định lỗi DDB SELL nằm ở tín hiệu/context, không nằm ở SL/TP: winner median MFE đạt 1,01–1,18R, còn loser median MAE xấp xỉ 1R. Không nới SL, không đổi TP 1R và không bật break-even 0,5R.

Chỉ hai interaction âm ở cả Extended/OOS/2026 được lọc: `Wyckoff NONE × wait=2` và Elliott `BEAR_W5`. V2.26 đạt Extended +1.697,31 USD/PF 1,12/DD 14,94%; OOS +32.386,26/PF 1,95/RF 18,25; 2026 +14.217,38/PF 2,56/RF 15,92/WR 67,80%. Tổng Net ba vùng tăng 2.186,25 USD và giảm 14 lệnh so với v2.25.

Mọi DDB filter tiếp theo phải được kiểm tra cô lập rồi chạy lại multi-position portfolio. Không tinh chỉnh tiếp cùng bucket nhỏ. Bước kế tiếp: directional-risk cap simulation, sau đó IRB BUY và inverse EMAENGULF BUY. Chi tiết: `docs/DDB_SELL_MAE_MFE_V226.md`.

## Tổng hợp setup sau v2.25

Sau mỗi thay đổi accepted, phải phân rã lại đủ `setup × direction`, family, tần suất/tháng, từng năm và đoạn drawdown. Tổng hợp v2.25 xác định `SB BUY` là nguồn Net lớn nhất, BB SELL đã đủ ổn định để dừng tối ưu, còn DDB SELL có PF giảm từ 3,97 năm 2024 xuống 1,32 năm 2026 và là contributor âm lớn nhất trong drawdown 2026.

Drawdown OOS 2025 đến từ cụm nhiều setup BUY cùng thua, không phải một detector duy nhất. Vòng sau ưu tiên DDB SELL isolated MAE/MFE trước, sau đó mô phỏng directional-risk cap; không cắt SB BUY chỉ vì đóng góp drawdown và không bật setup OFF để ép tần suất. Chi tiết: `docs/SETUP_PERFORMANCE_SUMMARY_V225.md`.

## Candidate v2.25: BB TPO SELL loại Wyckoff SOW

Attribution bucket chỉ là giả thuyết; mọi filter phải backtest lại toàn portfolio vì setup thay thế có thể đổi kết quả. Với TPO SELL, SOW âm trên Extended/OOS/2026 và được giải thích là breakout muộn sau khi dấu hiệu weakness/markdown đã xuất hiện. V2.25 chặn riêng interaction `BB SELL × TPO12 × SOW`; không suy rộng sang setup SELL khác.

Wyckoff mask bắt buộc tính theo `1 << enum`: SOW=4 nên mask là 16; mask 32 là TEST. Kết quả từ mask sai phải hủy. Hai kiểu entry chờ signal ở trong value area hoặc chờ first-close breakout đều bị loại vì giảm mẫu và Net mạnh; giữ stop-entry được arm tại VAL trước breakout.

V2.25 đạt Extended +1.125,79 USD/PF 1,08/RF 0,54/DD 16,71%; OOS +31.518,33/PF 1,92/RF 18,16/DD 7,18%; 2026 +13.470,58/PF 2,39/RF 15,51/DD 4,19%/WR 66,48%. So với v2.24, tổng Net ba vùng tăng 1.358,67 USD và giảm 12 lệnh. Trạng thái selected/pre-official; forward test tiếp tục hoãn. Chi tiết: `docs/BB_WYCKOFF_SOW_V225.md`.

## Candidate v2.24: detector block BB theo hướng

Khi thay định nghĩa block, phải kiểm tra riêng detector broad trước khi ghép context. `OB_FVG_FILL`, `INSIDE_RANGE` và `TPO12` đã được triển khai; broad đều bị loại. TPO không phải volume profile sàn thật mà là proxy 12 nến M5: tick volume được phân bổ theo các price bin để tạo POC và value area 70%.

Selected chỉ dùng TPO12 cho BB SELL, yêu cầu H1 activity `CONTRACTING`, transition khác `NO_FAST_TREND`, đồng thời giữ Elliott W3 alignment và Wyckoff event. BB BUY giữ legacy. `NO_FAST_TREND` âm ở Extended/OOS/2026 nên được loại; RR SELL 2,25 được giữ vì RR 1,50 âm OOS/2026 và RR 2,00 có Net thấp hơn trên dữ liệu mới.

V2.24 đạt Extended Net +1.034,24/PF 1,07/RF 0,54/DD 15,77%; OOS +31.150,69/PF 1,90/RF 18,32/DD 7,18%; 2026 +12.571,10/PF 2,24/RF 14,43/DD 5,21%, 186 lệnh. BB tăng từ 8/17/2 lên 16/41/16 lệnh trên Extended/OOS/2026. Trade-off: OOS PF/WR/DD và DD 2026 kém v2.23, nên trạng thái vẫn pre-official; forward test tiếp tục hoãn. Chi tiết: `docs/BB_BLOCK_DETECTORS_TPO_V224.md`.

## Candidate v2.23: tăng mẫu ARB và inverse ENGULFED

V2.23 chỉ mở rộng setup hiếm khi điều kiện bổ sung vẫn dương trên Extended/OOS/2026. ARB BUY tăng edge-zone 0,25 → 0,45 nhưng giữ false-break, follow-through, wait 1–2 và activity gate. Inverse ENGULFED tăng cửa sổ 2 → 3 nến; SELL được mở cả ba session sau khi tổng hợp từng vùng vẫn dương. BB giữ nguyên vì W5, late-Wyckoff và FVG age 12 đều làm xấu expectancy.

Kết quả selected: Extended +561,04 USD, PF 1,04, 246 lệnh; OOS +31.121,04 USD, PF 2,02, RF 17,70, 388 lệnh; 2026 +10.703,45 USD, PF 2,23, RF 14,08, DD 4,17%, 172 lệnh. Tần suất ba family hiếm tăng 0,89 → 1,42 lệnh/tháng trên OOS và 1,10 → 1,30 trên 2026. Forward test vẫn hoãn; chi tiết tại `docs/LOW_SAMPLE_EXPANSION_V223.md`.

## Candidate v1.85: phục hồi setup yếu và profile balanced

Các nhánh DDB Sell, FB Buy, RB Sell, SB Buy và SB Sell được lọc bằng interaction H1 đã chứng minh âm qua telemetry: long-trend × Elliott corrective/counter, vị trí extended, Wyckoff SOS/SOW/Test, transition range và activity. BB/ARB/IRB vẫn tắt; SL/TP/risk 1% và entry M5 không đổi.

Weak basket chuyển từ OOS -1.793,11 USD, PF 0,89, WR 38,76% sang +3.166,61 USD, PF 1,20, WR 45,80%; real ticks 2026 tăng từ +1.494,16 lên +3.581,00 USD, PF 1,66, WR 55,14%. Khi ghép với core v1.83, profile balanced đạt OOS 2023–2025 Net +9.557,72 USD, PF 1,33, RF 5,36, DD 9,44%, 439 lệnh, WR 54,21%; real ticks 2026 Net +7.358,39 USD, PF 1,80, RF 12,32, DD 4,74%, 185 lệnh, WR 61,08% (~20,9 lệnh/tháng).

Profile balanced dương từng năm 2023–2026 nhưng vẫn YELLOW vì rule được khám phá trên cùng telemetry. RB Sell còn âm OOS với tám mẫu; cần forward-demo, không tinh chỉnh tiếp bằng 2026. Chi tiết: `docs/BACKTEST_H1_CONTEXT_M5_WEAK_SETUP_REHAB_V185.md`.

## Candidate v1.83: core win-rate với impulse và Wyckoff chọn lọc

Profile v1.83 chỉ giữ DDB Buy, FB Sell, RB Buy và inverse ENGULFED Sell v1.81. Elliott chặn FB Sell khi H1 còn `BULL_W3`/`BULL_IMPULSE_COMPLETE`; Wyckoff chặn RB Buy khi có Upthrust đồng thời transition là `NO_FAST_TREND`/`REVERSAL_ALIGNED`. Rule DDB Buy × Upthrust × Extended tiếp tục giữ nguyên; global Wyckoff filter vẫn OFF.

Kết quả OOS 2023–2025: Net +4.304,36 USD, PF 1,48, RF 5,90, equity DD 5,01%, 212 lệnh, WR 62,74%. Kết quả 100% real ticks 2026: Net +2.888,19 USD, PF 2,09, RF 6,49, equity DD 3,71%, 79 lệnh, WR 69,62%. Candidate cải thiện mọi chỉ số chính so với v1.81 core ở cả hai vùng, nhưng 2023 vẫn -62,88 USD và tần suất 2026 chỉ khoảng 8,9 lệnh/tháng. Trạng thái YELLOW/forward-demo only. Chi tiết: `docs/BACKTEST_H1_CONTEXT_M5_CORE_IMPULSE_WYCKOFF_V183.md`.

Vòng sau không tinh chỉnh lại hai gate bằng 2026. Để tăng coverage, chỉ mở lại từng nhánh yếu trong context đã chứng minh qua discovery/validation/holdout; không bật hard filter Wyckoff/Elliott toàn portfolio và không tăng risk quá 1%.

## Candidate v1.76: FB emerging trend không được xác nhận trễ

v1.76 giữ nguyên v1.75 và thêm `Inp_FBBlockEmergingWait1=true`: chặn FB khi transition H1 là `EMERGING_ALIGNED` và entry chỉ xác nhận sau đúng một nến M5. Bucket baseline có 16 trade, win rate 25%, tổng -8R và âm trong từng năm 2023–2026. MFE trung bình chỉ 0,54R so với 0,85R của FB còn lại, xác nhận lỗi follow-through. Wyckoff/Elliott không tham gia rule mới.

100% real ticks 2026 đạt 220 lệnh (~24,8/tháng), Net +4.916,54 USD, PF 1,42, RF 5,70, DD 8,12%, win rate 55,91%. Preset bất biến: `BobH1ContextM5-v176-Selected.set`; báo cáo: `docs/BACKTEST_H1_CONTEXT_M5_FB_EMERGING_WAIT_V176.md`. Candidate vẫn YELLOW vì 2023 âm.

24,8 lệnh/tháng là ngoại lệ nhỏ dưới lower bound 25 do candidate đồng thời cải thiện mọi lát cắt và chỉ loại bốn real-tick trade. Vòng sau không được thêm filter giảm tần suất; phải ưu tiên tăng coverage có expectancy dương hoặc management không giảm entry count.

## Candidate v1.75: DDB BUY × Upthrust × biên trên 240H

v1.75 giữ nguyên v1.74 và thêm duy nhất `Inp_DDBBlockBuyUpthrustExtended=true`. Chỉ DDB BUY bị chặn khi H1 có event `UT` còn hiệu lực và vị trí giá là `EXTENDED` ở 20% phía trên range 240H. Bucket baseline có 32 trade, win rate 37,50%, tổng -8R và âm trong từng năm 2023–2026. MAE/MFE xác nhận đây là thiếu follow-through của tín hiệu, không phải bằng chứng để nới SL hay giảm TP. Elliott không tham gia rule này; Wyckoff không được bật thành hard filter toàn portfolio.

100% real ticks 2026 đạt 224 lệnh (~25,3/tháng), Net +4.586,65 USD, PF 1,39, RF 5,33, DD 8,19%, win rate 55,36%. Preset bất biến: `BobH1ContextM5-v175-Selected.set`; báo cáo: `docs/BACKTEST_H1_CONTEXT_M5_DDB_UPTHRUST_V175.md`. Candidate vẫn YELLOW vì 2023 âm.

Không được mở rộng rule thành “mọi DDB BUY có UT”: bucket không có điều kiện `EXTENDED` không ổn định và dương trong một số lát cắt. Vòng sau phải giữ tần suất real ticks tối thiểu 25 lệnh/tháng.

## Candidate v1.74: Wyckoff–Elliott chọn lọc cho SB

v1.74 giữ nguyên v1.73 và chỉ thêm `Inp_SBUseWyckoffElliottFilter=true`: từ chối SB khi không có Wyckoff event H1 hợp lệ và Elliott alignment là `ALIGNED` hoặc `UNDEFINED`. Rule được giới hạn ở SB vì bucket này có 48 trade, win rate 18,75%, tổng -21R và âm trong từng năm 2023–2026. DDB/FB/BB/RB/ARB không dùng hard filter này; IRB vẫn tắt. Đồng thời detector Wyckoff được tách khỏi filter để mode OFF vẫn xuất telemetry đúng mà không thay đổi xếp hạng setup.

100% real ticks 2026 đạt 231 lệnh (~26,1/tháng), Net +3.879,58 USD, PF 1,31, RF 4,51, DD 8,19%, win rate 54,55%. Preset bất biến: `BobH1ContextM5-v174-Selected.set`; báo cáo: `docs/BACKTEST_H1_CONTEXT_M5_SB_WYCKOFF_ELLIOTT_V174.md`.

Không mở rộng Wyckoff/Elliott sang setup khác bằng suy luận định tính. Một rule mới chỉ được nhận nếu interaction của chính setup đó đủ mẫu, cùng dấu theo các lát cắt thời gian và cải thiện real ticks sau cost. Candidate vẫn YELLOW vì 2023–2024 âm; cần forward-demo và counterfactual log riêng cho SB bị chặn.

## Candidate v1.73: BB theo absolute volatility H1

v1.73 giữ nguyên v1.72 và thêm duy nhất gate chiến lược `Inp_BBMinH1ATRPercent=0.50`: Block Break chỉ được tạo pending khi ATR14 của nến H1 đã đóng gần nhất đạt ít nhất 0,50% giá đóng. Rule hình thành từ discovery 2023–2024, cùng dấu ở validation 2025, rồi mới xác nhận trên 2026. Bản phát hành đồng thời kiểm tra `SymbolInfoSessionTrade` trước `OrderSend` để loại lỗi vận hành `10018 / market closed`; pending vẫn được reset như hành vi cũ. Real ticks 2026 đạt 243 lệnh (~27,4/tháng), Net +3.489,01 USD, PF 1,27, RF 3,58, DD 8,47%, win rate 53,09%. Preset bất biến: `BobH1ContextM5-v173-Selected.set`; báo cáo: `docs/BACKTEST_H1_CONTEXT_M5_BB_VOLATILITY_V173.md`.

Không tinh chỉnh tiếp ngưỡng BB trên bốn mẫu 2026. Efficiency ratio 24/72/240H và gate ATR toàn portfolio đã bị loại vì không ổn định giữa discovery/validation hoặc làm xấu holdout. Candidate vẫn YELLOW vì 2023–2024 âm; vòng sau ưu tiên setup có mẫu lớn, đặc biệt SB, và không được dùng lại 2026 để chọn threshold.

## Candidate v1.72: ma trận độ trễ xác nhận M5

v1.72 thay v1.70 sau khi loại `DDB SELL wait=1` và `FB BUY wait=0`. Preset bất biến là `BobH1ContextM5-v172-Selected.set`. Kết quả 100% real ticks 2026: 244 lệnh, khoảng 27,6 lệnh/tháng, Net +3.363,51 USD, PF 1,25, RF 3,45, DD 8,47%, win rate 52,87%. Discovery 2023/2024 và validation 2025 đều cải thiện cùng hướng so với v1.70, nhưng 2023–2024 vẫn âm nên candidate vẫn YELLOW. Báo cáo: `docs/BACKTEST_H1_CONTEXT_M5_WAIT_MATRIX_V172.md`.

Các thử nghiệm SB break-even 0,50R–1,50R đã bị loại. Không bật lại nếu chưa có giả thuyết mới vì real ticks cho thấy Net/PF giảm. Vòng tiếp theo không được tinh chỉnh thêm wait mask trên các bucket nhỏ; ưu tiên regime gate H1 liên tục và validation theo thời gian.

## Candidate v1.70: H1 context, setup/entry M5, khoảng 30 lệnh/tháng

Nhánh `IndiSingle_BobVolman_H1_M5.mq5` hiện nhận dạng bảy setup trên M5, còn direction/regression/Wyckoff/Elliott giữ ở H1. Preset bất biến `BobH1ContextM5-v170-SessionMatrix.set` đạt 268 lệnh trên 100% real ticks từ 2026-01-01 đến 2026-09-27, khoảng 30,2 lệnh/tháng; Net +3.347,68 USD, PF 1,23, RF 3,10, DD 8,94%. Validation khóa tham số thất bại ở 2023–2024, vì vậy trạng thái YELLOW/regime-specific và không được dùng production. Chi tiết: `docs/BACKTEST_H1_CONTEXT_M5_SETUP_FREQUENCY_2026.md`.

Vòng kế tiếp không được chỉnh session matrix bằng validation cũ. Chỉ được thêm rule context H1 nếu rule được hình thành trên discovery riêng, giữ tần suất mục tiêu 25–35 lệnh/tháng và cải thiện đồng thời PF/RF/DD trên holdout.

## Candidate v1.64: tăng tần suất có kiểm soát

Sau ma trận expiry/session/tolerance trên 2026, chỉ `Inp_FBExpiryBars=2` và `Inp_SBExpiryBars=2` được chấp nhận. Session mask không mở rộng và trigger tolerance đã bị loại khỏi source. Preset `BobH1M5-v164-Selected.set` là bất biến cho validation kế tiếp; xem `docs/BACKTEST_BOB_VOLMAN_H1_M5_FREQUENCY_2026.md`.

## Candidate v1.63: entry M5

Nhánh `IndiSingle_BobVolman_H1_M5.mq5` giữ signal/context H1 nhưng yêu cầu nến M5 đã đóng xác nhận trigger và dùng high/low nến đó cho SL. Preset `BobH1M5-v163-Selected.set` được khóa sau discovery 2026; không được chỉnh lại khi chạy 2023–2025. Candidate đang YELLOW vì chỉ có sáu trade. Báo cáo: `docs/BACKTEST_BOB_VOLMAN_H1_CONTEXT_M5_ENTRY_2026.md`.

## Bổ sung v1.62: context snapshot bắt buộc

Mọi trade forward từ v1.62 phải lưu snapshot tại `signal_time`: regression trend 24/72/240H, transition state, volatility/activity ratio, range location 240H, Wyckoff phase, Elliott phase/alignment và confluence tier. Snapshot chỉ dùng nến đã đóng; Elliott pivot phải đã được xác nhận đủ số nến hai phía. Chi tiết tại `docs/MARKET_CONTEXT_WYCKOFF_ELLIOTT.md`.

Elliott và confluence mặc định là biến chẩn đoán, không phải filter. Ngoại lệ hiện tại duy nhất là interaction SB của v1.74: `Wyckoff=NONE × Elliott∈{ALIGNED,UNDEFINED}`, được chứng minh âm theo từng năm 2023–2026 và xác nhận lại bằng real ticks. Chỉ được chuyển interaction khác thành rule nếu hiệu ứng cùng dấu qua discovery/validation, không suy giảm holdout/extended và còn hiệu quả sau cost. Không chọn rule vì một wave label hoặc một tháng riêng lẻ có win rate cao.

Workflow này là quy trình bắt buộc cho mọi thay đổi đối với `IndiSingle_BobVolman_H1.mq5`. Mục tiêu là tăng Net Profit và win rate nhưng không đánh đổi bằng overfit, drawdown lớn hơn hoặc giảm số lệnh đến mức kết quả không còn ý nghĩa.

## 1. Baseline bất biến

Trước mỗi vòng nghiên cứu, khóa và lưu bốn thành phần:

- source `.mq5`, file compile `.ex5` và số version;
- preset `.set` đang dùng;
- report baseline theo đúng symbol, timeframe, vốn, leverage và mô hình tick;
- kết quả compile, yêu cầu `0 error, 0 warning`.

Baseline logic giao dịch là v1.61; baseline code/telemetry là v1.62 với preset `tests/sets/BobH1-v162-MarketStructure.set`. v1.62 không thay đổi entry, exit hoặc sizing: chỉ đóng băng snapshot structure tại signal. v1.60 và v1.70 được đóng băng tại `checkpoints/`; DDB buffer của v1.70 không được mang trở lại.

## 2. Chẩn đoán trước khi tối ưu

Phân rã kết quả theo `setup × Wyckoff event × hướng lệnh × năm/regime`. Chỉ chọn một giả thuyết thay đổi trong mỗi vòng. Không tối ưu setup có quá ít mẫu; dưới 10 lệnh chỉ được xem là tín hiệu cần theo dõi, không phải bằng chứng để sửa rule.

Các lỗi vận hành phải được loại trừ trước lỗi chiến lược:

- sai timeframe hoặc symbol;
- nhiều pending/position trái quy tắc đơn lệnh;
- lot, SL hoặc 1R không đúng 1% equity;
- invalid stops, requote, market closed, thiếu dữ liệu hoặc spread bất thường;
- cùng một nến phát nhiều tín hiệu hoặc comment sai tên setup/event.

### 2.1. Structure regression trước khi tạo rule mới

Mỗi trade phải được ghép với snapshot chỉ chứa thông tin đã biết tại `signal_time`, theo năm lớp:

1. price structure;
2. flow/liquidity structure;
3. session/event structure;
4. intermarket/macro structure;
5. execution/data structure.

Hồi quy tối thiểu gồm `win`, `exit_r`, `MAE_R`, `MFE_R` và thời gian thoát. Dùng split theo thời gian, purge/embargo và rolling transform fit trên train fold; không random split, không backward-fill dữ liệu daily/weekly và không dùng post-exit path làm feature. Với mẫu trade nhỏ, giới hạn 5–10 predictor đã chọn trước hoặc dùng regularization. Chỉ một hiệu ứng có dấu ổn định qua các fold và tạo lift kinh tế sau cost mới được chuyển thành rule ứng viên. Schema và định nghĩa chi tiết: `docs/STRUCTURE_REGRESSION_FRAMEWORK.md`.

### 2.2. Bảng structure theo tháng

Mỗi tháng được mô tả bằng return/range, realized volatility, ATR/price, trend slope/R², path efficiency, tick-volume activity và phân bổ theo bucket giờ server. Bảng tháng có hai vai trò tách biệt:

- `observed context`: mô tả tháng sau khi tháng kết thúc, chỉ dùng nghiên cứu;
- `tradable context`: dùng nhãn tháng đã hoàn tất trước đó, tránh look-ahead.

Kết quả v1.60 trên 45 tháng 2023-01–2026-09 cho thấy mọi filter toàn cục hoặc setup-specific kiểu `skip/half risk` dựa trên context tháng trước đều thất bại discovery 2023–2024 hoặc validation 2025. Do đó không tích hợp filter tháng vào EA. Bảng tháng chỉ giữ vai trò regime map. Rolling H1 tại `signal_time` sau đó xác định được một candidate bền: bỏ SB ngược trend hồi quy 72H mạnh. Candidate vượt validation và được phát hành thành v1.61; xem `docs/BACKTEST_BOB_VOLMAN_H1_ROLLING_CONTEXT.md`.

## 3. Phân vùng dữ liệu

Mỗi ứng viên phải đi theo thứ tự sau:

1. **Discovery:** 2023–2024 để hình thành giả thuyết.
2. **Validation:** 2025 để chọn tham số ổn định, không chọn đỉnh đơn lẻ.
3. **OOS khóa:** sau 2026-09-27; giai đoạn 2026 đến ngày này đã được dùng trực tiếp ở vòng tối ưu v1.70.
4. **Combo:** bật đủ bảy setup để đo cạnh tranh tín hiệu.
5. **Extended:** 2010–hiện tại với tham số đã khóa, không tối ưu lại.
6. **Execution:** kiểm tra một đoạn bằng real ticks và điều kiện spread/slippage xấu hơn.

Nếu nguồn dữ liệu dài có history quality dưới 90%, kết quả chỉ được dùng để phát hiện regime risk, không được dùng làm bằng chứng duy nhất để thêm hoặc bỏ rule.

## 4. Cổng chấp nhận thay đổi

Một ứng viên chỉ được đưa vào mặc định khi đạt toàn bộ điều kiện bắt buộc:

- compile sạch và không có lỗi vận hành trong tester log;
- OOS không xấu đi rõ rệt so với baseline;
- combo đầy đủ setup cải thiện, không chỉ riêng setup cô lập;
- Net Profit, PF, RF, equity DD, win rate và số lệnh đều được báo cáo;
- kết quả không phụ thuộc duy nhất vào một năm hoặc một Wyckoff event;
- extended test vẫn có Net Profit dương, PF tối thiểu 1,20 và DD không cao hơn baseline;
- số lệnh combo của vùng hiện tại tối thiểu 50; setup thay đổi nên có tối thiểu 10 lệnh trước khi kết luận.

Ưu tiên Pareto theo thứ tự: `Net Profit → Recovery Factor → Win rate → Drawdown → số lệnh`. Không chấp nhận tăng win rate nếu Net Profit/RF giảm đáng kể, hoặc giảm hơn 40% số lệnh mà không có cải thiện đủ lớn về PF/RF.

Quy ước trạng thái:

- **GREEN:** đủ điều kiện phát hành.
- **YELLOW:** có triển vọng nhưng thiếu mẫu hoặc chất lượng dữ liệu; chỉ forward demo.
- **RED:** thất bại OOS/combo/extended; hoàn nguyên baseline.

## 5. Kiểm thử độ bền

Sau khi vượt cổng chiến lược, chạy thêm:

- spread `+25%` và `+50%`;
- slippage/execution delay nếu tester hỗ trợ;
- từng năm riêng biệt và walk-forward theo thứ tự thời gian;
- Monte Carlo thứ tự lệnh hoặc bootstrap chuỗi trade;
- real ticks trên ít nhất một giai đoạn có đủ lệnh;
- forward demo tối thiểu 30 lệnh cho setup vừa thay đổi hoặc 100 lệnh toàn EA.

Trong forward demo giữ risk 0,5–1,0%; không tăng risk để bù cho việc giảm tần suất.

## 6. Phát hành và rollback

Khi ứng viên đạt GREEN:

1. tăng version trong source;
2. compile lại trên `D:\Demo SMMA`;
3. cập nhật preset chuẩn;
4. lưu report current, yearly, OOS, extended và real ticks trong `artifacts/reports`;
5. cập nhật tài liệu kết quả và ghi rõ limitation;
6. giữ lại baseline trước đó để rollback.

## Trạng thái baseline và checkpoint tại ngày 2026-10-14

Baseline active v1.62 đã được compile `0 error, 0 warning` và tái tạo chính xác kết quả giao dịch v1.61 trên Demo SMMA:

| Vùng | Net Profit | PF | RF | Equity DD | Win rate | Trades |
|---|---:|---:|---:|---:|---:|---:|
| 2023–09/2026, quality 98% | +7.397,16 | 4,76 | 12,52 | 3,51% | 76,67% | 60 |
| 2026, quality 99% | +506,19 | 3,54 | 3,06 | 1,65% | 75,00% | 8 |
| 2010–2026, quality 77% | +3.163,97 | 1,54 | 1,30 | 24,28% | 50,39% | 127 |

Hồi quy sơ bộ từ 135 trade cho thấy hiệu suất thay đổi mạnh theo giai đoạn nhưng setup/event/direction/hour chưa dự báo được walk-forward tốt hơn baseline naive. Đây là bằng chứng cần bổ sung feature structure, không phải bằng chứng để thêm ngay một time filter.

| Gate | Kết quả | Trạng thái |
|---|---|---|
| 2023–09/2026, quality 98% | Net +7.547,62; PF 5,12; RF 19,97; DD 2,63%; WR 77,97%; 59 lệnh | GREEN |
| Real ticks Q3/2026 | 2/2 lệnh thắng; mẫu quá nhỏ | YELLOW |
| Extended 2010–2026, quality 77% | Net +2.871,07; PF 1,46; RF 1,07; DD 26,96%; WR 49,25% | YELLOW |
| BB v1.50 | Tốt hơn baseline trên current và extended | GREEN |
| SB v1.60 | Xác nhận breakout thêm 0,025 ATR; loại 3 lệnh thua current và 6 lệnh thua extended | GREEN |
| Rolling context v1.61 | Bỏ SB ngược strong trend 72H; tăng Net/PF/RF/WR và giảm extended DD | GREEN |
| DDB v1.70 | Xác nhận breakout thêm 0,05 ATR; cải thiện 2026, 2023–2025 và extended | GREEN |
| IRB mở rộng | Giảm combo extended và xấu đi OOS 2026 | RED, đã loại |

Kết luận vận hành: v1.62 là baseline code/forward telemetry, còn v1.61 là baseline logic giao dịch tương đương. v1.70 là checkpoint DDB độc lập, không được gộp tự động. Vì 2026 đã trở thành in-sample và extended quality chỉ 77%, chưa đủ bằng chứng để coi bất kỳ cấu hình nào là production ổn định qua mọi regime.

## Hướng cải thiện ưu tiên

### P0 — nâng chất lượng dữ liệu dài hạn

Thu thập lại XAUUSD H1/M1 hoặc real ticks 2010–2022 từ broker/nguồn khác, mục tiêu history quality tối thiểu 90%. Đây là bước có giá trị cao nhất vì DD gần 30% hiện có thể là tổ hợp của regime thật và dữ liệu 77%.

### P1 — bộ lọc regime cấp portfolio

Thử một bộ phân loại 2–3 trạng thái dựa hoàn toàn trên nến đã đóng: percentile của `ATR/price`, độ dốc EMA chậm và/hoặc ADX. Bộ lọc phải được dùng chung trước bước chọn setup, với mục tiêu giảm giao dịch ở regime lịch sử bất lợi. Chỉ thử ít biến thể và đánh giá bằng walk-forward; không tạo rule riêng cho từng năm.

### P2 — kiểm soát setup yếu, vẫn giữ đủ bảy setup

- **ARB:** ưu tiên xác định regime gây đảo chiều hiệu suất trước khi đổi event mask; extended đang âm và có dấu hiệu đổi hành vi giữa giai đoạn cũ/mới.
- **IRB:** giữ logic v1.50, không mở rộng tín hiệu; cân nhắc hệ số risk 0,25–0,50R cho đến khi có ít nhất 30 lệnh forward/quality cao.
- **SB:** vẫn tạo Net Profit lớn nhất nhưng win rate dài hạn thấp; nghiên cứu lọc regime/quality của breakout thay vì siết TP hoặc thêm break-even.
- **RB:** tỷ lệ thắng cao nhưng chỉ có bốn lệnh extended; không tối ưu vì thiếu mẫu.
- **BB:** giữ cấu trúc v1.50 và dùng làm control, không tiếp tục tinh chỉnh ngay.

### P3 — phân tích đường đi của lệnh

Đã triển khai ở v1.60: xuất MAE/MFE và shadow path 12 nến theo setup/event. Kết quả cho thấy nới SL làm xấu hiệu suất; thay đổi được chấp nhận là xác nhận breakout SB thêm 0,025 ATR. Xem `docs/BACKTEST_BOB_VOLMAN_H1_MAE_MFE.md`. Tiếp tục thu thập telemetry trong forward demo; chỉ thay exit khi mẫu mới ổn định qua validation và OOS.

### Thứ tự vòng cải tiến kế tiếp

1. Giữ logic v1.61 bất biến trong v1.62 và thu thập forward telemetry Wyckoff–Elliott–structure cho các context reject/accept.
2. Bổ sung DXY, GC futures/OI, real yield và event calendar theo schema trong `docs/STRUCTURE_REGRESSION_FRAMEWORK.md`; options để giai đoạn hai.
3. Chạy hồi quy chẩn đoán và walk-forward có purge/embargo; không tinh chỉnh lại threshold 72H trên 2026.
4. Chỉ chuyển thêm một hiệu ứng ổn định thành rule ứng viên rồi kiểm tra OOS/combo/extended.
5. Kết thúc bằng stress cost, real ticks và forward demo; v1.60/v1.70 là mốc so sánh.

## Phụ lục 2026-10-16 — kiểm thử setup nghịch đảo

Đã bổ sung chế độ shadow/inverse trong v1.79 để kiểm tra setup chính thất bại mà không mở lệnh chính. Kết quả tốt nhất riêng 2026 đạt đúng vùng tần suất yêu cầu trên real ticks: 92 lệnh, khoảng 10,4 lệnh/tháng, Net +254,43 USD, PF 1,07, RF 0,32, win rate 57,61% và equity DD 7,90%.

Ứng viên không vượt cổng OOS: 2023, 2024 và 2025 đều âm; gộp 2023–09/2026 Net -2.555,57 USD, PF 0,76, RF -0,68 và DD 36,37%. Vì vậy chế độ inverse phải giữ mặc định OFF, không được cộng vào kết quả hoặc vị thế của v1.76. Chỉ preset nghiên cứu được phép bật. Chi tiết: `docs/BACKTEST_H1_CONTEXT_M5_INVERSE_FAILURE_V179.md`.

### Nhánh inverse độc lập

Sau phép thử shadow-failure, một EA độc lập đã được tạo tại `IndiSingle_BobVolman_Inverse_M5.mq5`. Nó không chờ setup chính thất bại mà giao dịch ba sự kiện riêng trên accumulation M5: không có entry thuận hướng rồi phá biên đối diện, nến entry bị nhấn chìm, hoặc nến ngược hướng xuyên EMA25 M5.

Mốc v1.02 Quality năm 2026: Net +1.861,55 USD, PF 1,26, RF 1,59, equity DD 9,48%, 150 lệnh. Do tần suất 16,9 lệnh/tháng và chưa kiểm tra OOS/real ticks, trạng thái vẫn YELLOW. Không gộp PnL hoặc vị thế với EA chính trước khi vượt đủ cổng validation.

### v1.80 — gộp có chọn lọc, ưu tiên win rate

Nhánh inverse độc lập đã được gộp vào `IndiSingle_BobVolman_H1_M5.mq5` nhưng không thay đổi logic v1.76 khi tắt. Inverse được quyền ưu tiên nếu cùng xác nhận trên một nến M5; EA vẫn chỉ giữ một vị thế. Legacy inverse v1.79 và independent inverse không được bật đồng thời.

Preset selected chỉ giữ `EMAENGULF SELL` 00–07h và `ENGULFED SELL` 08–15h. Real ticks 2026: 244 lệnh, Net +6.394,11 USD, PF 1,48, RF 7,41, equity DD 8,11%, WR 57,38%; inverse riêng đạt 19/26 thắng, WR 73,08%. M1 OHLC 2026: Net +7.301,54, PF 1,54, RF 9,64, DD 5,79%, WR 57,32%, 246 lệnh.

Gate OOS không đạt: 2023–2025 cho Net -117,02, PF 1,00 và WR 46,81%; EMA inverse riêng âm -620,25. Vì thế `Inp_EnableIndependentInverse=false` vẫn là mặc định. Chỉ profile 2026/forward demo được bật; không dùng lịch năm hay mức giá hard-code làm regime filter. Báo cáo đầy đủ: `docs/BACKTEST_H1_CONTEXT_M5_INDEPENDENT_INVERSE_V180.md`.

## Phụ lục 2026-10-19 — quy trình kiểm thử imbalance v1.86

Imbalance/FVG phải được kiểm thử theo ma trận `setup × direction`, không được bật toàn cục chỉ vì win rate của một giai đoạn tăng. Thứ tự chuẩn:

1. Chạy control `OFF` với cùng universe setup.
2. Chạy riêng `M5_ALIGNED`, `H1_ALIGNED` và `EITHER_ALIGNED` trên OOS 2023–2025 và real ticks 2026.
3. Tách attribution theo setup và BUY/SELL; loại các kết quả có mẫu quá nhỏ hoặc đảo dấu giữa hai vùng.
4. Tạo preset kết hợp chỉ từ hiệu ứng lặp lại ở cả hai vùng, rồi backtest lại toàn portfolio vì one-position constraint và compounding làm tổng kết quả không bằng phép cộng từng setup.
5. Chấp nhận khi PF, RF, WR và DD cải thiện nhất quán, đồng thời mức giảm Net nằm trong ngân sách đã nêu; mọi candidate vẫn cần forward sample độc lập.

Kết quả v1.86 là nghiên cứu đối chứng và đã bị thay thế vì còn dùng H1 imbalance. Chi tiết lịch sử: `docs/BACKTEST_H1_CONTEXT_M5_IMBALANCE_V186.md`.

## Phụ lục 2026-10-21 — context chọn lọc v1.87

Quy tắc vận hành mới:

1. Imbalance chỉ được tính tại timeframe entry M5; không dùng FVG H1 hoặc phép `M5 OR H1`.
2. Mỗi filter phải có scope `setup × direction`; mặc định OFF và chỉ bật sau attribution OOS/2026.
3. Nếu hiệu quả thay đổi theo Wyckoff event, tách event trước khi chấp nhận. Không áp filter lên toàn setup khi chỉ một event có lợi.
4. Wyckoff global filter và setup-event matrix giữ OFF. Elliott/impulse không được dùng global; chỉ các gate setup-specific đã validation mới được bật.
5. Sau khi ghép các filter, luôn backtest lại portfolio hoàn chỉnh do one-position constraint và compounding.

Kết quả được chấp nhận: active bullish FVG M5 chỉ xác nhận `SB BUY` khi Wyckoff H1 là `SOS`. DDB BUY M5, SB BUY mọi event, Spring-only và tổ hợp DDB+SB đều bị loại. Báo cáo: `docs/BACKTEST_H1_CONTEXT_M5_SELECTIVE_CONTEXT_V187.md`.

## Phụ lục 2026-10-22 — same-snapshot A/B và v1.96

Trước mọi quyết định accept/reject, baseline và candidate phải được chạy lại trên cùng snapshot history. Nếu report cũ kết thúc trước ngày `ToDate` vì broker chưa đồng bộ đủ ticks, không được dùng nó làm đối chứng. Vòng v1.96 phát hiện report cũ dừng ở 28/09 dù config đến 20/10; 12 lệnh tháng 10 mới làm thay đổi đáng kể Net/PF/DD 2026.

V1.96 nhận filter entry-quality cho `RB BUY`: loại nến xác nhận M5 có body/range từ 0.50 đến dưới 0.75. Trên baseline refresh cùng dữ liệu, OOS Net giảm 1.03% nhưng PF/RF/WR tăng và DD giảm; 2026 Net/DD giữ nguyên, PF/WR tăng. Telemetry được mở rộng để ghi thứ tự các milestone MFE và lần quay lại entry. Phân tích SB SELL cho thấy close-back đảo dấu giữa OOS và 2026, vì vậy không thêm BE/time-stop.

Khi đánh giá EA một vị thế, luôn kiểm tra lại toàn portfolio: chặn một setup có thể giải phóng slot cho setup khác. Không được chấp nhận rule chỉ dựa vào PF của nhánh mục tiêu. Báo cáo: `docs/SETUP_PERFORMANCE_SUMMARY_V196.md`.

## Phụ lục 2026-10-22 — multi-position v1.97 và context v1.98

EA hiện hỗ trợ nhiều vị thế trên tài khoản hedging. Preset selected dùng `Inp_AllowMultiplePositions=true`, `Inp_MaxOpenPositions=0`, `Inp_CooldownBars=0`; mỗi nến M5 vẫn chỉ nhận setup có score cao nhất để không nhân bản cùng một market event. Nếu account là netting, EA phải dừng khởi tạo thay vì để MT5 gộp lệnh. Export MAE/MFE đơn lệnh không được bật cùng multi-position.

Khi đánh giá rule mới trong multi-position, không dùng parser giả định một trade đang hoạt động. Dùng `tools/Analyze-MT5Portfolio.ps1`, báo cáo peak concurrency, kết quả overlap và attribution theo setup/direction. Luôn so với baseline multi cùng snapshot trước khi so với release single cũ.

V1.98 nhận rule setup-specific: chặn `FB BUY` chỉ khi H1 activity `EXPANDING` đồng thời trend regression 72H là `DOWN`. Broad activity filter bị loại vì đảo dấu năm 2024. Candidate selected đạt OOS Net 20.252,26, PF 1,78, RF 10,11, DD 7,35%, 358 lệnh; 2026 real ticks Net 7.514,88, PF 1,81, RF 6,25, DD 6,42%, 180 lệnh. Forward test tiếp tục hoãn đến khi duyệt official. Chi tiết: `docs/MULTI_POSITION_AND_FB_BUY_CONTEXT_V198.md`.

## Phụ lục 2026-10-22 — BB tại FVG M5 trong impulse W3, v1.99

Với BB, active FVG M5 được dùng như một vùng hỗ trợ/kháng cự có bề rộng, không phải mức retest tuyệt đối. Mọi BB context phải được kiểm tra trước khi đưa vào `ConsiderCandidate()`; một BB bị loại không được phép chiếm best-slot rồi làm mất setup khác trên cùng nến.

Ma trận riêng BB đã loại FVG-only, W5 và Wyckoff phase D/E vì âm hoặc đảo dấu giữa OOS và 2026. Candidate selected chỉ giữ `BB BUY`: bullish FVG cách block không quá 0,35 ATR, tuổi tối đa 8 nến M5, H1 `BULL_W3`, session 16–23. Wyckoff late phase không được bật cho BB.

Portfolio v1.99 đạt OOS Net 21.931,55, PF 1,79, RF 10,74, DD 7,35%, 367 lệnh, WR 59,67%; 2026 real ticks Net 7.774,97, PF 1,81, RF 6,38, DD 6,41%, 182 lệnh, WR 61,54%. Extended 2010–2022 quality 67% không vượt baseline: Net -2.002,94 so với -1.936,70; riêng BB chỉ có 4 lệnh, PF 0,72. Vì vậy v1.99 chỉ là research candidate, baseline hiện hành vẫn là v1.98. Mẫu BB 2026 chỉ có hai lệnh và không được tinh chỉnh tiếp trên cùng mẫu. Chi tiết: `docs/BB_IMBALANCE_IMPULSE_V199.md`.

## Phụ lục 2026-10-22 — BB activation v2.00

V2.00 thêm đúng một interaction đã lặp lại qua extended, OOS và 2026: BB W3 không có Wyckoff event là bucket 0/3 và bị loại. Rule chỉ yêu cầu một event H1 còn hiệu lực; không giới hạn phase D/E và global Wyckoff filter vẫn OFF.

BB isolated chuyển thành dương ở cả ba vùng. Portfolio đạt OOS Net 22.223,82, PF 1,80, RF 10,79, DD 7,35%, 366 lệnh; 2026 Net 7.972,01, PF 1,85, RF 6,48, DD 6,41%, 181 lệnh. Extended quality 67% vẫn âm do baseline cũ, nhưng contribution BB mới dương +9,29 thay vì âm. BB được bật trong preset selected v2.00 nhưng candidate vẫn chưa official và không dùng ba lệnh extended/một lệnh 2026 để tinh chỉnh tiếp. Chi tiết: `docs/BB_ACTIVATION_V200.md`.

## Phụ lục 2026-10-22 — IRB activation v2.02

IRB phải được audit từ detector broad trước khi ghép portfolio. SELL bị loại vì âm rõ ở OOS. BUY chỉ được giữ khi event H1 là `NONE/LPS`, confirmation M5 xảy ra sau 1–2 nến và trend hồi quy 240H không phải `DOWN`. Mọi IRB context gate phải chạy trước `ConsiderCandidate()` để tín hiệu bị loại không chiếm best-slot của setup khác.

Quy trình xác nhận gồm: broad attribution → event/session audit → telemetry MAE/MFE và structure → isolated extended/OOS/2026 → portfolio extended/OOS/2026. Không chấp nhận kết quả chỉ đẹp ở 2023–2026. Rule `wait=1–2` sửa false breakout tức thời; rule 240H loại breakout BUY ngược cấu trúc dài hạn. Elliott/volatility/activity không được thêm vì không lặp dấu ổn định sau hai gate này.

V2.02 selected đạt OOS Net 24.023,43, PF 1,76, RF 10,30, DD 7,57%, WR 60,61%, 396 lệnh; 2026 real ticks Net 8.147,12, PF 1,82, RF 6,56, DD 6,41%, WR 61,90%, 189 lệnh. IRB riêng trong portfolio có PF 1,93 / 1,31 / 1,79 trên extended / OOS / 2026. Forward test tiếp tục hoãn đến khi duyệt official. Chi tiết: `docs/IRB_ACTIVATION_V202.md`.

## Phụ lục 2026-10-22 — đưa setup OFF vào preset chung v2.05

Một setup đang OFF chỉ được bật sau chuỗi kiểm tra: broad telemetry → context có giải thích cấu trúc → isolated Extended/OOS/2026 → portfolio hoàn chỉnh. Kết quả isolated dương chưa đủ; nhánh phải thực sự tạo lệnh và đóng góp dương sau cạnh tranh score với các setup khác.

V2.05 nhận hai hướng. `ARB BUY` phải chờ 1–2 nến xác nhận và loại H1 activity `EXPANDING`. `BB SELL` phải nằm tại bearish FVG M5 còn hiệu lực, tuổi tối đa 8 nến, trong `BEAR_W3` H1 và có Wyckoff event còn hiệu lực. Cả hai filter chạy trước `ConsiderCandidate()`.

`NOENTRY` vẫn OFF vì Extended Net -5.162,39, PF 0,55 trên 277 giao dịch của nhánh. `IRB SELL` reversal-counter dù isolated dương nhưng chỉ có 3/5/1 lệnh và tạo 0 lệnh trong portfolio; `ARB SELL` không có context dương ổn định qua ba vùng. Không được bật các nhánh này chỉ vì 2026 đẹp hoặc vì cần tăng tần suất.

Portfolio selected đạt Extended Net -1.480,47, PF 0,90, RF -0,53, DD 25,14%; OOS Net +26.357,81, PF 1,79, RF 13,72, DD 7,33%; 2026 real ticks Net +9.562,04, PF 1,90, RF 7,11, DD 6,43%, WR 62,56% với 195 lệnh. Forward test vẫn hoãn đến khi duyệt official. Chi tiết và ma trận ON/OFF: `docs/OFF_SETUP_ACTIVATION_V205.md`.

## Phụ lục 2026-10-23 — inverse direction selective v2.09

Khi mở hướng inverse đối diện, session mask phải tách theo `setup × direction`. Không được đổi mask chung vì sẽ vô tình nới cả hướng đang active và làm A/B sai attribution. Context H1 được snapshot khi accumulation M5 hình thành và gắn vào comment trade để audit theo trend/activity/volatility/transition.

`ENGULFED BUY` được nhận duy nhất khi transition H1 là `CONTINUATION_COUNTER`: isolated dương trên Extended/OOS/2026 và khi ghép portfolio làm Net/PF/RF/WR tăng ở cả ba vùng. Selected v2.09 đạt OOS Net +26.659,89, PF 1,80, RF 13,79, DD 7,33%; 2026 Net +9.924,43, PF 1,93, RF 7,28, DD 6,40%, WR 62,94% với 197 lệnh.

`EMAENGULF SELL` vẫn OFF. Volatility contracting cho Extended -2,19 USD/PF 1,00; reversal-counter chỉ +0,04 USD/PF 1,00 và khi ghép làm Extended Net giảm, DD tăng. Với report có overlap, không dùng parser tuần tự một-active-trade; quyết định bắt buộc dựa trên `Analyze-MT5Portfolio.ps1`. Forward test vẫn hoãn. Chi tiết: `docs/INVERSE_OFF_DIRECTION_ACTIVATION_V209.md`.

## Phụ lục 2026-10-23 — DDB SELL weak confirmation v2.11

Khi audit multi-position, DDB SELL dùng compact trade-comment telemetry thay cho single-position MAE/MFE exporter. Comment diagnostic mã hóa trend 24/72/240H, transition, volatility, activity, location, Elliott alignment, wait, body bucket và Wyckoff event; phải tái lập chính xác control trước khi dùng để chọn rule.

DDB SELL có regime shift lớn: Extended 31 lệnh, Net -1.254,50/PF 0,40; OOS 37 lệnh, Net +1.639,08/PF 1,57; 2026 37 lệnh, Net +349,38/PF 1,13. Session, trend, Wyckoff, Elliott và wait đều đảo dấu nên không được dùng làm hard filter. Bucket nến xác nhận M5 có body/range 0,25–0,50 là bucket đơn giản duy nhất âm trên cả Extended, OOS và 2026, vì vậy v2.11 chặn riêng bucket này.

Portfolio selected v2.11 đạt Extended Net -1.055,24, PF 0,93, DD 24,37%; OOS Net +27.508,24, PF 1,84, RF 13,77, DD 7,33%; 2026 Net +9.973,31, PF 2,06, RF 8,57, DD 5,51%, WR 64,09% với 181 lệnh. Forward test vẫn hoãn. Chi tiết: `docs/DDB_SELL_WEAK_BODY_V211.md`.

## Phụ lục 2026-10-23 — RB SELL context v2.15

RB SELL phải được audit từ detector broad trước khi chọn hard filter. Broad RB SELL âm trên Extended, OOS và gần hòa vốn âm ở 2026, vì vậy không được mở rộng session hoặc dùng Wyckoff/Elliott/volatility toàn cục. Context gate phải chạy trước `ConsiderCandidate()` để tín hiệu không hợp lệ không chiếm best-slot.

Hai rule `volatility=NORMAL` và `transition=NO_FAST_TREND` đã bị loại. Dù no-fast-trend cho nhánh RB win rate 100% trên mẫu 1/2/2, portfolio 2026 mất 617,27 USD và Extended mất 184,09 USD. Đây là ví dụ bắt buộc phải đánh giá chi phí cơ hội giữa các setup, không chọn filter chỉ từ attribution của nhánh mục tiêu.

V2.15 chỉ chặn RB SELL khi transition là `CONTINUATION_ALIGNED`, trend hồi quy 240H là `UP` và location 240H là `MID`. OOS tăng 760,49 USD, PF/RF/WR tăng và DD giảm 0,80 điểm phần trăm; 2026 không đổi. Extended giảm 66,57 USD do mất một lệnh thắng. Tổng Net ba vùng tăng 693,92 USD với ít hơn ba lệnh, nên rule được nhận vào selected research candidate nhưng chưa phải official. Forward test tiếp tục hoãn. Chi tiết: `docs/RB_SELL_CONTEXT_V215.md`.

## Phụ lục 2026-10-23 — EMAENGULF BUY context v2.16

Đối với inverse EMAENGULF BUY, `CONTINUATION_COUNTER` biểu thị trend hồi quy 24H và 72H cùng giảm so với hướng BUY. Entry M5 lúc này là đảo chiều sớm chống lại hai lớp cấu trúc H1. Bucket này âm trên tổng Extended/OOS/2026 và có WR chỉ 37,50% ở Extended, 33,33% ở 2026.

V2.16 chặn riêng bucket đó. Extended cải thiện 227,14 USD và DD giảm 1,60 điểm phần trăm; 2026 tăng 179,55 USD, PF/RF/WR/DD đều tốt hơn. OOS giảm 359,16 USD nhưng PF/DD giữ nguyên, WR chỉ giảm 0,04 điểm phần trăm; 2023 không đổi, 2024 giảm 171,47 USD, 2025 gần như giữ Net và PF/WR tăng. Tổng Net ba vùng tăng 47,53 USD, số lệnh giảm 14 và win rate gộp tăng khoảng 0,23 điểm phần trăm.

Rule được nhận vào selected research candidate vì cải thiện out-of-era Extended và 2026 mà không tạo năm OOS âm. Không thêm Wyckoff/Elliott/imbalance cho nhánh này khi chưa có bằng chứng. Forward test tiếp tục hoãn; Extended còn âm nên chưa phải official. Chi tiết: `docs/EMAENGULF_BUY_CONTEXT_V216.md`.

## Phụ lục 2026-10-23 — RB BUY confirmation wait v2.17

RB BUY được bổ sung compact telemetry trước khi chọn rule. Telemetry-only control phải tái lập chính xác selected trước đó; nếu comment diagnostic làm thay đổi PnL/trade count thì dữ liệu không được dùng. Session, Wyckoff, Elliott, activity, volatility và trend dài hạn tiếp tục đảo dấu nên không được áp làm hard filter mới.

Bucket `wait=1` có WR 27,27%/57,89%/50,00% trên Extended/OOS/2026, thấp hơn phần RB BUY còn lại ở cả ba vùng. V2.17 đổi `Inp_RBBuyWaitMask=5`, chỉ giữ confirmation wait 0 và 2. Portfolio Extended tăng 556,27 USD và DD giảm 1,99 điểm phần trăm; OOS giảm 91,13 USD nhưng PF/RF/WR/DD đều tốt hơn; 2026 tăng nhẹ Net/PF/WR và giữ RF/DD. Tổng Net ba vùng tăng 470,72 USD, giảm 31 lệnh.

Yearly A/B cho thấy 2023 cải thiện rõ, 2024 giảm 391,62 USD và 2025 giảm 168,29 USD nhưng PF/RF/DD năm 2025 tốt hơn. Rule được nhận theo ưu tiên win rate/recovery factor; không được che giấu trade-off năm 2024 khi đánh giá official. Forward test tiếp tục hoãn. Chi tiết: `docs/RB_BUY_WAIT_V217.md`.

## Phụ lục 2026-10-23 — DDB SELL × Wyckoff TEST v2.18

Wyckoff chỉ được dùng theo interaction `setup × direction × event` đã có bằng chứng, không bật global filter. Với DDB SELL, event TEST cho 0/2 thắng ở Extended, 1/2 ở OOS và 1/2 ở 2026; Net tương ứng -204,08, -211,87 và +24,58 USD. Logic là tránh bán DDB khi thị trường đang kiểm tra cung sau dấu hiệu hấp thụ/cầu.

Gate phải chạy trước `ConsiderCandidate()` để DDB bị loại không chiếm best-slot. Portfolio v2.18 tăng Extended 162,31 USD; OOS giảm 62,68 USD nhưng PF/RF/WR tăng; 2026 giảm 43,52 USD nhưng WR tăng và PF/DD giữ nguyên. Tổng Net ba vùng tăng 56,11 USD. Năm 2024 xấu hơn 153,80 USD, năm 2025 tốt hơn 201,04 USD, năm 2023 không đổi.

Rule được nhận ở mức selected research vì phù hợp mục tiêu win rate/RF và đưa Extended sát hòa vốn. Tuy nhiên chỉ có hai trade TEST mỗi vùng; không được tinh chỉnh tiếp trên cùng bucket và chưa đủ bằng chứng cho official. Forward test tiếp tục hoãn. Chi tiết: `docs/DDB_SELL_WYCKOFF_TEST_V218.md`.

## Phụ lục 2026-10-23 — FB SELL × Wyckoff TEST v2.20

FB SELL phải được audit bằng compact telemetry riêng và telemetry-only control phải tái lập selected trước đó. Các bucket trend, Elliott, body và confirmation wait đảo dấu hoặc loại nhiều lệnh thắng 2026. Wyckoff TEST là interaction âm ở Extended (7 lệnh, PF 0,69) và OOS (10 lệnh, PF 0,73), đồng thời không phát sinh trong 2026.

V2.20 chặn riêng `FB SELL × WY_TEST` trước `ConsiderCandidate()`. Extended tăng 83,64 USD và DD giảm 1,43 điểm phần trăm. OOS tăng 106,99 USD, PF/RF/WR tăng; 2026 không đổi. Yearly OOS cho thấy 2023 giảm 127,14 USD, 2024 gần như không đổi nhưng quality metrics tăng và 2025 tăng 190,53 USD với DD giảm.

Rule được nhận vào selected research. Wyckoff global filter vẫn OFF; không được suy rộng TEST sang mọi setup. Forward test tiếp tục hoãn và Extended vẫn âm nhẹ nên chưa phải official. Chi tiết: `docs/FB_SELL_WYCKOFF_TEST_V220.md`.

## Phụ lục 2026-10-23 — drawdown portfolio và SB SELL v2.22

Khi Extended đã gần hòa vốn, vòng cải thiện phải bắt đầu từ đoạn drawdown lớn nhất thay vì tiếp tục chọn bucket đơn lẻ theo tổng Net. Với v2.20, trade-level max drawdown khoảng 2.319,35 USD nằm trong 09/2020–02/2022; peak concurrency chỉ 2. SB SELL là nhánh đóng góp âm lớn nhất trong đoạn này (-554,45 USD).

Telemetry SB SELL xác định TEST và UPTHRUST đều âm trên Extended, OOS và 2026. Phải kiểm thử riêng TEST, riêng UPTHRUST và combo trước khi chọn. Combo cho kết quả cân bằng nhất: Extended +339,38/PF 1,03, OOS +28.318,85/PF 2,01, 2026 +10.339,18/PF 2,20; RF và DD 2026 cải thiện mạnh. Tổng Net ba vùng tăng 1.112,19 USD và giảm 15 lệnh.

V2.22 là candidate đầu tiên dương trên cả ba vùng và được nâng lên trạng thái pre-official. Tuy nhiên 2023 giảm 205,90 USD, chưa có forward test và chưa được người dùng phê duyệt official, nên không được tự động phát hành. Wyckoff filter vẫn setup-specific; không suy rộng Upthrust sang mọi SELL. Chi tiết: `docs/SB_SELL_DRAWDOWN_WYCKOFF_V222.md`.

## Phụ lục 2026-10-25 — structure lane và BB BUY TPO v2.31

Khi tăng mẫu cho setup thiếu dữ liệu, không nới detector Bob Volman trực tiếp. Candidate phải đi qua một `structure lane` độc lập: Wyckoff active, spatial imbalance M5, hoặc tổ hợp được chỉ định theo setup × direction. Structure gate phải chạy trước `ConsiderCandidate()` và mặc định OFF; chỉ lane chứng minh được trên Extended/OOS/2026 mới được bật trong preset chung.

V2.31 thử mở rộng `RB SELL`, `ARB BUY`, `BB BUY` và inverse `ENGULFED BUY`. RB SELL chỉ thêm một lệnh modern; ARB BUY wait=0 thêm bảy lệnh OOS nhưng WR 28,57% và Net -488,52; ENGULFED BUY tăng 2026 nhưng làm Extended xấu đi. Ba lane này giữ OFF.

BB BUY được chấp nhận bằng detector `LEGACY_OR_TPO12`. Lane TPO dùng value area 12 nến M5 làm block, chỉ nhận H1 `BULL_W3`, transition `CONTINUATION_ALIGNED`, trend 240H `RANGE` và Wyckoff event còn hiệu lực. `WY_TEST` bị chặn vì broad sample 6 lệnh chỉ WR 16,67%, Net -714,43, PF 0,43. Không suy rộng filter TEST sang setup khác.

Portfolio selected đạt Extended Net +3.987,49/PF 1,28/RF 2,07; OOS +41.743,46/PF 2,14/RF 19,52; 2026 +15.799,72/PF 2,83/RF 17,26. BB BUY modern tăng từ 9 lên 28 lệnh, đạt 0,61 lệnh/tháng, WR 60,71%, Net +4.559,00. Tổng portfolio hiện đại đạt 12,43 lệnh/tháng, vẫn thấp hơn mục tiêu dài hạn 30.

Không tiếp tục cắt bucket TPO theo wait/body/volatility trên cùng mẫu. Vòng sau phải mô hình hóa liquidity state có thứ tự thời gian (`sweep → reclaim → displacement → retest`) cho RB SELL hoặc inverse ENGULFED, rồi kiểm thử isolated trước portfolio. Forward test tiếp tục hoãn đến khi người dùng duyệt official. Chi tiết: `docs/PRIORITY_SAMPLE_EXPANSION_V231.md`.

## Phụ lục 2026-10-26 — RB SELL liquidity sequence v2.32

Đối với setup thiếu mẫu, liquidity state phải được phát hiện theo trình tự thời gian, không thay bằng phép kiểm tra một FVG/event đang active. RB SELL expansion có ba mức audit: sweep–reclaim, thêm displacement, và thêm retest. Sweep đơn thuần làm loãng Extended/OOS; displacement cải thiện OOS; retest bắt buộc làm Net giảm trên cả ba vùng nên không được chọn.

Phân rã displacement theo H1 trend 72H cho thấy chỉ bucket `DOWN` dương trên Extended/OOS/2026. Bản selected vì vậy mở session 08–15 khi có `buy-side sweep → reclaim → bearish displacement` và H1 72H đã down. Không bắt buộc FVG vì displacement body/break đã là bằng chứng initiative supply; không chặn Wyckoff SOS/Spring từ một vài mẫu đơn lẻ.

Portfolio v2.32 đạt Extended Net +4.123,88/PF 1,29/RF 2,19/DD 13,85%; OOS +42.028,38/PF 2,13/RF 19,49/DD 7,19%; 2026 +15.953,31/PF 2,79/RF 17,37/DD 4,27%. RB SELL modern đạt 25 lệnh/46 tháng = 0,54 lệnh/tháng, WR 72,00%, Net +1.313,24 và PF 1,75.

PF/RF/DD OOS và PF/WR 2026 có trade-off nhỏ; không được mô tả v2.32 như cải thiện mọi metric. Candidate được nhận ở mức pre-official vì tăng Net cả ba vùng, đạt chuẩn mẫu và giữ DD ổn định. Không tinh chỉnh tiếp RB SELL trên 11 lệnh liquidity modern. Vòng sau chuyển sang inverse ENGULFED BUY với failure-state tuần tự. Forward test tiếp tục hoãn. Chi tiết: `docs/RB_SELL_LIQUIDITY_SEQUENCE_V232.md`.

## Phụ lục 2026-10-26 — ENGULFED SELL delayed failure v2.35

Mở rộng ENGULFED SELL phải giữ nguyên cửa sổ core ba nến và chỉ xét entry trễ bằng một chuỗi có thứ tự: bullish breakout quét đỉnh accumulation, bearish engulf, rồi close-back vào range. Cấp lọc cao hơn có thể yêu cầu bearish displacement và active bearish M5 imbalance gần failed-break level. Không nới session vì ENGULFED SELL selected đã chạy cả ba session.

Ma trận window 4–8 cho thấy window 4 không thêm mẫu; window 5 thêm một thắng OOS nhưng đồng thời một thua Extended; window 6–8 sweep-only tạo 4–9 lệnh OOS nhưng WR 44,44–50% và Net âm. H1 bull trend stack phục hồi OOS ở window 8 lên 5 lệnh, WR 60%, Net +508,61, nhưng vẫn thêm một loser -123,23 trong Extended và làm RF OOS giảm 19,51 xuống 17,51.

Không được tinh chỉnh body, giờ hoặc Wyckoff event trên nhóm chỉ 1–6 lệnh này. Lane giữ OFF trong selected preset; control v2.35 phải khớp v2.34 ở cả Extended/OOS/2026. Vòng sau muốn tăng mẫu phải thay đổi universe trước entry bằng detector accumulation/block độc lập, rồi giữ failure sequence làm xác nhận. Forward test tiếp tục hoãn. Chi tiết: `docs/ENGULFED_SELL_DELAYED_FAILURE_AUDIT_V235.md`.

## Phụ lục 2026-10-26 — ENGULFED SELL OB/FVG accumulation v2.36

Alternate accumulation phải có state/cooldown riêng và chạy song song với core. Không dùng chung state: một alternate đang chờ không được phép chặn detector core. Nếu hai lane xác nhận cùng nến, core ưu tiên và alternate reset để tránh double-entry. Final phải chứng minh non-alternate trade count giữ đúng control trước khi xét PnL.

Lane selected dùng bullish M5 FVG/displacement, bearish order candle, fill không invalid và bullish reclaim. Reclaim là failed BUY entry; SELL chỉ mở khi trong ba nến tiếp theo có bearish engulf/close-back, bearish displacement đóng dưới đáy failed BUY và active bearish FVG gần block. SL bảo vệ cả block high và failed-entry high; TP riêng 1,10R.

Inside-range bị loại dù dương OOS vì WR chỉ 40% ở 2026 và 0/3 trên Extended. OB/full tại 1R gần hòa 2026; ma trận 1,05/1,10/1,25 xác định 1,10R cải thiện cả ba vùng, còn 1,25R làm mất hai winner OOS. Không suy rộng RR 1,10 sang core hoặc setup khác.

Selected v2.36 đạt Extended +4.801,82/PF 1,32/RF 2,55; OOS +43.750,77/PF 2,12/RF 19,67; 2026 +16.243,69/PF 2,74/RF 17,45. Modern ENGULFED SELL tăng lên 34 lệnh/46 tháng. PF/WR OOS và 2026 giảm nhẹ nên candidate vẫn pre-official; forward test tiếp tục hoãn. Chi tiết: `docs/ENGULFED_SELL_ALT_ACCUM_V236.md`.

## Phụ lục 2026-10-26 — MAE/MFE và session lane v2.37

MAE/MFE của lane độc lập phải được đo ở single-position mode, nhưng quyết định cuối phải kiểm lại trên portfolio multi-position. V2.37 tái tạo đúng 12/9/4 mẫu OB/FVG. Trong 10 loser, median MFE chỉ 0,254R, 5 lệnh không vượt 0,25R và không lệnh nào đạt 1R; lỗi chính nằm ở chất lượng tín hiệu. Không thêm break-even 0,50R vì 8/15 winner từng hồi về entry sau ngưỡng này, trong khi chỉ ba loser đạt ngưỡng.

Phân rã phiên cho thấy 16–23 có 9 mẫu, WR 33,33%, Net -270,09 và PF 0,55; 00–07 và 08–15 đều dương. Session filter phải tách riêng theo lane. Không được dùng `Inp_IndInvEngulfSellSessionMask` chung vì sẽ vô tình thay đổi cả core ENGULFED SELL. V2.37 thêm `Inp_IndInvEngulfSellAltSessionMask=3`; control mask 7 tái tạo chính xác v2.36 trên 2026.

Selected đạt Extended +4.909,82/PF 1,34/RF 2,78/DD 12,98%; OOS +43.618,93/PF 2,12/RF 19,61/DD 7,17%; 2026 +16.740,95/PF 2,86/RF 17,66/DD 4,27%/WR 69,49%. OOS giảm 131,84 USD nên đây vẫn là pre-official. Không tinh chỉnh thêm Wyckoff/Elliott/SL/TP trên 16 lệnh còn lại; forward test tiếp tục hoãn. Chi tiết: `docs/ENGULFED_SELL_OB_MAE_MFE_V237.md`.

## Phụ lục 2026-10-26 — SB BUY first-attempt quality v2.38

SB BUY phải được audit bằng MAE/MFE trước khi cắt theo win rate. TP 2R vẫn cho expectancy cao nhất ở Extended/OOS/2026; break-even 1R ảnh hưởng nhiều winner hồi về entry hơn số loser được cứu. Không nới SL. Các bucket slope/R², volatility/activity, Wyckoff và Elliott đảo dấu theo regime nên không được dùng làm filter mới.

Thay đổi hợp lệ nằm trong price structure của Second Break: nến bullish first attempt có body/range dưới 0,10 gần doji và không chứng minh initiative demand. Input mới `Inp_SBBuyMinAttemptBodyRatio` phải tách riêng BUY để không thay đổi SB SELL. Ngưỡng 0,10 vượt 0,20/0,25/0,50 trên cân bằng Net–WR và được xác nhận lại trên portfolio multi-position.

V2.38 đạt Extended +5.366,96/PF 1,37/RF 3,53/DD 11,09%; OOS +44.828,40/PF 2,14/RF 19,72/DD 7,17%; 2026 +16.960,04/PF 2,89/RF 17,76/DD 4,23%/WR 69,89%. Tổng Net ba vùng tăng 1.885,70 USD; SB BUY giảm 3/2/1 lệnh nhưng WR/PF/Net đều tăng ở từng vùng. Forward test tiếp tục hoãn. Chi tiết: `docs/SB_BUY_ATTEMPT_BODY_MAE_MFE_V238.md`.

## Phụ lục 2026-10-26 — BB SELL fresh breakout v2.39

MAE/MFE của BB SELL phải được đo single-position nhưng quyết định phải xác nhận lại trên portfolio multi-position. Loser có median MFE 0,013R/0,267R/0,111R trên Extended/OOS/2026, trong khi winner có median MFE trên 2,25R. Vì vậy không hạ TP 2,25R, không nới SL và không thêm break-even; lỗi nằm ở breakout không có follow-through.

TPO 10 nến tạo quá nhiều nhiễu, TPO 16 nến quá chậm, profile max 2,50 ATR phá hỏng OOS và body 0,40 làm giảm mạnh 2026. TPO12 hiện tại được giữ. Quy luật lặp lại qua ba vùng là confirmation trễ: BB SELL `wait=1/2` làm suy giảm expectancy tổng thể. Selected dùng `Inp_BBSellWaitMask=1`, chỉ nhận confirmation đầu tiên. Đây là filter riêng cho BB SELL; không suy rộng sang BB BUY hoặc setup khác.

V2.39 đạt Extended +5.667,53/PF 1,40/RF 3,67/DD 11,14%; OOS +46.758,03/PF 2,28/RF 20,02/DD 6,82%; 2026 +16.148,71/PF 2,85/RF 17,41/DD 4,28%/WR 69,94%. Tổng Net ba vùng tăng 1.418,87 USD nhưng Net 2026 giảm 811,33 USD; candidate vì vậy vẫn pre-official. Modern còn 12,57 lệnh/tháng và BB SELL còn 0,52 lệnh/tháng. Forward test tiếp tục hoãn. Chi tiết: `docs/BB_SELL_FRESH_BREAK_V239.md`.

## Phụ lục 2026-10-26 — SB SELL weak confirmation body v2.40

SB SELL có nhiều loser từng đạt 0,5–1R, nhưng break-even 0,50R làm tổng R OOS giảm 15R xuống 7R do triệt tiêu tám winner. First-attempt body 0,10/0,20 cải thiện Extended/OOS nhưng làm xấu 2026; close-zone 0,20 cải thiện mẫu hiện đại nhưng làm Extended âm. Các biến thể này phải giữ OFF.

Compact telemetry toàn portfolio xác định bucket confirmation body/range `[0,25;0,50)` âm ở cả Extended và OOS: mỗi vùng bốn lệnh, WR 25%, Net lần lượt -78,50 và -313,29; năm 2026 không có mẫu. V2.40 thêm `Inp_SBSellBlockWeakBodyConfirm=true` riêng cho SB SELL. Không chặn body dưới 0,25 vì đó có thể là compression, và không suy rộng sang SB BUY hoặc setup khác.

V2.40 đạt Extended +5.816,91/PF 1,42/RF 3,42/DD 12,13%; OOS +47.354,73/PF 2,31/RF 20,12/DD 6,82%; 2026 không đổi +16.148,71/PF 2,85/RF 17,41/DD 4,28%. Tổng Net tăng 746,08 USD; RF/DD Extended là trade-off phải công bố. SB SELL hiện đại còn 1,11 lệnh/tháng, toàn portfolio 12,48 lệnh/tháng. Forward test tiếp tục hoãn. Chi tiết: `docs/SB_SELL_WEAK_BODY_MAE_MFE_V240.md`.

## Phụ lục 2026-10-26 — FB SELL full-body không có Wyckoff v2.41

FB SELL không được lọc bằng một nhãn context đơn vì full-body, Spring/SOW, volatility NORMAL và wait đều đảo dấu giữa Extended và dữ liệu hiện đại. Interaction được phép phải có giải thích price structure và âm lặp lại qua ba vùng.

`Full-body confirmation ≥0,75 × WY_NONE` có 3/1/5 lệnh trên Extended/OOS/2026, Net tương ứng -173,02/-534,17/-49,73 USD. Đây là bán đuổi momentum khi không có event Wyckoff chứng minh absorption/distribution. V2.41 thêm `Inp_FBSellBlockFullBodyNoWyckoff=true` riêng cho FB SELL; full-body có Wyckoff context vẫn được giữ.

V2.41 đạt Extended +5.983,68/PF 1,44/RF 3,83/DD 11,25%; OOS +47.941,40/PF 2,34/RF 20,37/DD 6,82%; 2026 +16.282,15/PF 2,93/RF 17,49/DD 4,19%/WR 70,83%. Tổng Net tăng 886,88 USD và mọi vùng đều cải thiện Net/PF/RF/WR. FB SELL hiện đại còn 0,98 lệnh/tháng; portfolio còn 12,35 lệnh/tháng. Forward test tiếp tục hoãn. Chi tiết: `docs/FB_SELL_FULLBODY_NOWYCKOFF_V241.md`.

## Phụ lục 2026-10-27 — DDB SELL pullback trong long trend v2.42

DDB SELL không được lọc theo một nhãn context đơn vì trend, Wyckoff, Elliott, body và wait đều đảo dấu qua regime. Interaction được phép phải vừa lặp lại trên ba vùng vừa có diễn giải cấu trúc. V2.42 chọn `trend 72H DOWN × trend 240H UP`: một nhịp giảm trung hạn vẫn nằm trong xu hướng tăng dài hạn, nên DDB SELL có rủi ro bán cuối pullback. Sáu lệnh telemetry thuộc bucket này có Net tổng -620,91 USD.

Rule `Inp_DDBSellBlockTrend72DownLongUp` chỉ áp dụng cho DDB SELL và không thay thế bộ lọc Elliott corrective-long-up cũ. Kết quả portfolio selected: Extended +6.346,91/PF 1,47/RF 4,05/DD 11,19%; OOS +47.932,07/PF 2,37/RF 20,54/DD 6,82%; 2026 +16.309,11/PF 2,97/RF 17,52/DD 4,19%/WR 71,08%. Tổng Net ba vùng tăng 380,86 USD; OOS mất 9,33 USD Net nhưng quality metrics tăng.

Không được kết luận DDB SELL đã ổn định: riêng nhánh này trên Extended còn 12 lệnh, WR 41,67%, Net -356,20 và PF 0,63. Không tinh chỉnh tiếp trên sáu mẫu interaction. Candidate vẫn pre-official, forward test tiếp tục hoãn. Chi tiết: `docs/DDB_SELL_T72_PULLBACK_LONGUP_V242.md`.

## Phụ lục 2026-10-27 — RB BUY thiếu Wyckoff và Elliott structure v2.43

RB BUY loser có MFE thấp trong audit trước, nên tiếp tục sửa chất lượng tín hiệu thay vì nới SL hoặc hạ TP 2R. Không dùng nhãn context đơn vì chúng đảo dấu qua regime. Interaction được chọn là `Elliott alignment UNDEFINED × Wyckoff NONE`: breakout BUY thiếu cả impulse wave được xác nhận lẫn sự kiện accumulation/absorption. Bucket telemetry có 4 lệnh Extended/Net -99,83 và 6 lệnh OOS/Net -64,15; không có mẫu năm 2026.

V2.43 thêm `Inp_RBBuyBlockNoEventUndefinedElliott` riêng cho RB BUY. Portfolio selected đạt Extended +6.540,21/PF 1,49/RF 4,14/DD 11,24%; OOS +49.064,41/PF 2,42/RF 20,89/DD 6,81%; 2026 giữ nguyên +16.309,11/PF 2,97/RF 17,52/DD 4,19%/WR 71,08%. Tổng Net ba vùng tăng 1.325,64 USD. Trade-off phải công bố là DD Extended tăng 0,05 điểm phần trăm.

RB BUY Extended vẫn âm -81,76/PF 0,88 và interaction chưa có mẫu 2026, nên không tinh chỉnh tiếp trên bucket 10 lệnh. Candidate giữ trạng thái pre-official; forward test tiếp tục hoãn. Chi tiết: `docs/RB_BUY_NO_EVENT_UNDEFINED_ELLIOTT_V243.md`.

## Phụ lục 2026-10-27 — DDB BUY xác nhận tức thời thân yếu v2.44

Trước khi lọc, telemetry-only control phải tái lập chính xác v2.43. V2.44 thêm compact telemetry cho DDB BUY và control đã khớp tuyệt đối trên Extended/OOS/2026. Không thay SL nến entry, TP 1R hoặc thêm break-even vì MAE/MFE v2.29 đã xác định vấn đề chính nằm ở chất lượng tín hiệu.

Interaction hai biến duy nhất âm trên cả ba vùng là `wait=0 × body/range [0,25;0,50)`: 1/4/4 lệnh, WR 0%/25%/25%, Net -108,03/-343,62/-384,30 USD. Đây là breakout tức thời chưa có displacement đủ mạnh. V2.44 thêm `Inp_DDBBuyBlockImmediateWeakBody` riêng cho DDB BUY; không chặn body dưới 0,25, confirmation sau retest hoặc setup khác.

Portfolio selected đạt Extended +6.673,64/PF 1,50/RF 4,20/DD 11,20%; OOS +50.285,45/PF 2,45/RF 20,86/DD 6,81%; 2026 +16.972,90/PF 3,16/RF 17,77/DD 4,26%/WR 72,22%. Tổng Net tăng 2.018,26 USD. Trade-off là RF OOS giảm 0,03 và DD 2026 tăng 0,07 điểm phần trăm.

Không tinh chỉnh tiếp trên chín mẫu interaction. Candidate vẫn pre-official, forward test tiếp tục hoãn. Chi tiết: `docs/DDB_BUY_IMMEDIATE_WEAK_BODY_V244.md`.

## Phụ lục 2026-10-27 — FB BUY mid-body trong long-term range v2.45

SB BUY không được tinh chỉnh tiếp vì audit v2.38 đã khóa không cắt context trên cùng mẫu. Vòng v2.45 chuyển sang FB BUY và thêm compact telemetry riêng. Telemetry-only control tái lập chính xác v2.44 trên Extended/OOS/2026.

Không có nhãn đơn âm trên cả ba vùng. Interaction `trend 240H RANGE × confirmation body/range [0,50;0,75)` có 3/3/1 lệnh, WR 33,33%/33,33%/0% và Net -151,09/-642,33/-110,07 USD. First Break BUY trong long-term range thiếu directional support; body trung bình chưa chứng minh initiative demand sau pullback. V2.45 thêm `Inp_FBBuyBlockMidBodyLongRange` riêng cho FB BUY.

Portfolio selected đạt Extended +6.845,00/PF 1,53/RF 4,31/DD 11,20%; OOS +50.933,83/PF 2,51/RF 21,13/DD 6,81%; 2026 +17.072,31/PF 3,18/RF 17,78/DD 4,26%/WR 72,67%. Tổng Net tăng 919,15 USD; DD không tăng ở vùng nào. Không tinh chỉnh tiếp trên bảy mẫu interaction. Candidate vẫn pre-official, forward test tiếp tục hoãn. Chi tiết: `docs/FB_BUY_MIDBODY_LONGRANGE_V245.md`.

## Phụ lục 2026-10-27 — SB SELL continuation trong long-term range v2.46

V2.46 giữ nguyên TP 2R, SL nến entry, break-even OFF, first-attempt body và close-zone theo kết luận MAE/MFE v2.40. Compact telemetry hiện tại được phân tích bằng parser multi-position để không bỏ sót lệnh chồng vị thế.

Không có nhãn đơn âm trên cả ba vùng. Interaction `trend 240H RANGE × transition CONTINUATION_ALIGNED` có 4/6/2 lệnh, WR 0%/33,33%/0% và Net -549,29/-122,15/-463,80 USD. Transition giảm ngắn hạn bên trong long-term range dễ là markdown đã cạn lực và mean-revert. V2.46 thêm `Inp_SBSellBlockContinuationLongRange` riêng cho SB SELL.

Portfolio selected đạt Extended +7.542,21/PF 1,60/RF 5,09/DD 10,34%; OOS +50.907,00/PF 2,54/RF 21,12/DD 6,81%; 2026 +17.641,29/PF 3,38/RF 19,36/DD 4,21%/WR 73,58%. Tổng Net tăng 1.239,36 USD. OOS giảm 26,83 USD Net và RF giảm 0,01 nhưng PF/WR tăng. Không tinh chỉnh tiếp trên 12 mẫu interaction. Candidate vẫn pre-official, forward test tiếp tục hoãn. Chi tiết: `docs/SB_SELL_CONTINUATION_LONGRANGE_V246.md`.

## Phụ lục 2026-10-27 — IRB BUY context audit v2.47

IRB BUY phải được audit bằng telemetry-only trước khi thêm filter. V2.47 thêm `Inp_IRBBuyCompactTelemetry`; khi bật input này, control phải tái lập chính xác v2.46 trên Extended/OOS/2026. Telemetry chỉ thay đổi comment lệnh, không được thay đổi điều kiện entry, SL, TP, sizing hay quản lý vị thế.

Các trường được phép kiểm tra trong vòng này gồm trend hồi quy 24/72/240H, transition, volatility, activity, long-range location, số nến chờ xác nhận và body/range M5. Không khai phá lại Wyckoff/Elliott hoặc SL/TP vì audit v2.27 đã khóa các hướng đó trên mẫu IRB BUY nhỏ.

Kết quả 58 giao dịch IRB BUY trên ba vùng không tạo ra nhãn đơn hoặc interaction hai biến nào âm ổn định ở cả Extended, OOS và 2026. Không được đào interaction ba biến trên cùng mẫu vì bucket sẽ quá nhỏ và tăng nguy cơ overfit. V2.47 vì vậy là audit release: không nhận rule giao dịch mới và giữ nguyên selected v2.46.

Selected-control đạt Extended +7.542,21/PF 1,60/RF 5,09/DD 10,34%; OOS +50.907,00/PF 2,54/RF 21,12/DD 6,81%; 2026 +17.641,29/PF 3,38/RF 19,36/DD 4,21%/WR 73,58%, khớp tuyệt đối v2.46. Vòng kế tiếp phải chuyển sang setup khác hoặc mở rộng universe phát hiện tín hiệu trước khi quay lại IRB BUY. Candidate vẫn pre-official, forward test tiếp tục hoãn. Chi tiết: `docs/IRB_BUY_CONTEXT_AUDIT_V247.md`.

## Phụ lục 2026-10-27 — FB SELL reversal thiếu volatility expansion v2.48

FB SELL được chọn vì có 58 lệnh trên ba vùng nhưng vẫn âm trên Extended. TP 1R, SL theo nến entry và các rule cũ phải giữ nguyên. Source với filter mới mặc định OFF phải tái lập control trước khi nhận candidate; control 2026 đã khớp tuyệt đối v2.47.

Không chặn volatility `NORMAL` độc lập vì nhãn này dương mạnh ở dữ liệu hiện đại. Chỉ chặn interaction `REVERSAL_ALIGNED × NORMAL`: trend nhanh 24H vừa đảo theo hướng SELL trong khi trend 72H còn ngược hướng, nhưng volatility H1 chưa expansion để xác nhận chuyển pha. Bucket có 1/3/2 lệnh, WR 0%/33,33%/50% và Net -135,83/-311,16/-6,39 trên Extended/OOS/2026.

V2.48 thêm `Inp_FBSellBlockReversalNormalVolatility` riêng cho FB SELL. Selected đạt Extended +7.722,59/PF 1,61/RF 5,69/DD 9,47%; OOS +51.526,62/PF 2,58/RF 23,23/DD 6,81%; 2026 +17.649,32/PF 3,42/RF 19,37/DD 4,21%/WR 73,89%. Tổng Net tăng 808,03 USD; Net/PF/RF/WR tăng ở cả ba vùng và DD không tăng.

FB SELL Extended vẫn âm -87,42/PF 0,90 trên 12 lệnh nên không được xem là hoàn toàn ổn định. Không chia nhỏ tiếp mẫu này trong cùng vòng. Candidate vẫn pre-official; forward test tiếp tục hoãn. Chi tiết: `docs/FB_SELL_REVERSAL_NORMAL_VOL_V248.md`.

## Phụ lục 2026-10-27 — EMAENGULF SELL structure audit v2.49

Setup OFF chỉ được kích hoạt qua một lane cấu trúc độc lập; không bật broad chỉ để tăng tần suất. V2.49 thêm `Inp_IndInvEMASellStructureMode` để yêu cầu accumulation high gần bearish Wyckoff resistance, active bearish M5 imbalance, EITHER hoặc BOTH. Control mode OFF phải giữ nguyên selected v2.48.

Broad EMAENGULF SELL âm Extended/OOS dù dương 2026. Wyckoff và EITHER dương Extended nhưng âm OOS -1.069,71 USD. Imbalance 0,50 ATR/8 nến chỉ tạo hai winner Extended và không có mẫu hiện đại. Phép nhạy cảm 1,00 ATR/12 nến tạo 6/6/1 lệnh nhưng Net -270,46/-388,97/+178,60 trên Extended/OOS/2026. BOTH-wide chỉ tạo hai loser OOS. Không mode nào có edge lặp lại qua ba vùng.

Selected v2.49 giữ `Inp_IndInvEMAAllowSell=false` và structure mode OFF. Portfolio khớp tuyệt đối v2.48: Extended +7.722,59/PF 1,61/RF 5,69/DD 9,47%; OOS +51.526,62/PF 2,58/RF 23,23/DD 6,81%; 2026 +17.649,32/PF 3,42/RF 19,37/DD 4,21%/WR 73,89%. Không tinh chỉnh thêm mask, session hoặc threshold trên bucket nhỏ. Candidate vẫn pre-official; forward test tiếp tục hoãn. Chi tiết: `docs/EMAENGULF_SELL_STRUCTURE_AUDIT_V249.md`.

## Phụ lục 2026-10-27 — IRB SELL structure audit v2.50

IRB SELL không được bật broad để tăng tần suất. Broad có 109/110/83 lệnh và Net -1.320,65/-6.396,62/-1.608,30 trên Extended/OOS/2026. `REVERSAL_COUNTER` đúng logic pullback trong xu hướng giảm nhưng branch OOS vẫn âm -282,95 USD và làm PF/RF portfolio giảm.

RC + bearish imbalance là nhóm sạch nhất với 2/1/1 winner trên ba vùng. Tuy nhiên lệnh OOS chỉ tái phân loại một RB SELL có cùng PnL, nên toàn lịch sử chỉ thêm ba lệnh thực. Không được nhận win rate 100% từ mẫu này hoặc chia tiếp theo wait/body/session. Wyckoff-only và BOTH tạo nhiều mẫu hơn nhưng làm giảm Net Extended/OOS hoặc cả ba vùng.

V2.50 chỉ thêm `Inp_IRBSellCompactTelemetry`, mặc định OFF. Selected giữ `Inp_IRBAllowSell=false` và khớp tuyệt đối v2.49: Extended +7.722,59/PF 1,61/RF 5,69/DD 9,47%; OOS +51.526,62/PF 2,58/RF 23,23/DD 6,81%; 2026 +17.649,32/PF 3,42/RF 19,37/DD 4,21%/WR 73,89%. Chỉ xét lại IRB SELL khi RC+imbalance có thêm dữ liệu độc lập. Candidate vẫn pre-official; forward test tiếp tục hoãn. Chi tiết: `docs/IRB_SELL_STRUCTURE_AUDIT_V250.md`.

## Phụ lục 2026-10-27 — ARB SELL false-break audit v2.51

ARB SELL phải được đánh giá như một setup false-break độc lập, không được bật broad chỉ để tăng mẫu. V2.51 thêm compact telemetry riêng và Wyckoff event mask riêng cho SELL; cả hai mặc định không tác động đến control. Broad đạt 15/22/9 lệnh trên Extended/OOS/2026 nhưng WR chỉ 53,33%/27,27%/33,33%; OOS và 2026 đều âm.

Bearish imbalance M5 là lane duy nhất dương trên 2026. Interaction `bearish imbalance × WY_NONE` đạt 3/4 winner, branch Net +858,46 và nâng portfolio 2026 lên +18.603,10 USD. Tuy nhiên OOS thua 0/5, branch Net -1.008,96 USD và portfolio giảm còn +48.655,98 USD. Đây là regime effect, không phải edge có thể nhận. Broad telemetry cũng không có session, transition, volatility, activity, location, Elliott, body hoặc Wyckoff bucket nào ổn định qua cả ba vùng; không đào interaction ba biến trên 46 mẫu.

V2.51 giữ `Inp_ARBAllowSell=false`. Selected-control khớp tuyệt đối v2.50: Extended +7.722,59/PF 1,61/RF 5,69/DD 9,47%; OOS +51.526,62/PF 2,58/RF 23,23/DD 6,81%; 2026 +17.649,32/PF 3,42/RF 19,37/DD 4,21%/WR 73,89%. Không hạ ngưỡng imbalance hoặc chọn session từ mẫu 2026. Candidate vẫn pre-official; forward test tiếp tục hoãn. Chi tiết: `docs/ARB_SELL_IMBALANCE_AUDIT_V251.md`.

## Phụ lục 2026-10-27 — NOENTRY strict wait=4 v2.52

NOENTRY phải chạy bằng state machine accumulation dedicated để không nới detector dùng chung của ENGULFED/EMAENGULF. V2.52 giữ detector strict sáu nến, overlap 0,60, body trung bình 0,30–0,50, ba pressure closes và nến phá biên ngược body tối thiểu 0,80. Risk vẫn 1%, TP 0,75R và SL bảo vệ accumulation/signal.

Wyckoff và M5 imbalance không cải thiện 2026: Wyckoff/BOTH không có mẫu, imbalance/EITHER chỉ chọn một loser. Broad strict có regime split lớn: Extended 21 lệnh, WR 42,86%, Net -712,89; OOS 21 lệnh, WR 80,95%, Net +1.766,58; 2026 ba lệnh, WR 66,67%, Net +47,19. Không bật broad.

Timing `wait=4` là bucket duy nhất dương lặp lại: 3/4 thắng Extended, 7/7 OOS và 1/1 năm 2026. Logic là một nến grace xác nhận breakout thuận hướng không xuất hiện, trong khi accumulation chưa stale như wait 5–6. Selected bật BUY/SELL, mọi session, state dedicated strict và `Inp_IndNoEntryExactWaitBars=4`; structure mode OFF.

Selected v2.52 đạt Extended +7.909,06/PF 1,62/RF 5,34/DD 10,22%/WR 57,21%; OOS +55.223,25/PF 2,63/RF 23,66/DD 6,83%/WR 66,75%; 2026 +17.830,35/PF 3,43/RF 19,42/DD 4,22%/WR 74,05%. Net tăng ở cả ba vùng, tổng +4.064,13 USD. Attribution multi-position xác nhận 13 lệnh mới, 12 thắng; không có setup khác bị đổi nhãn.

Trade-off bắt buộc theo dõi là Extended DD tăng 0,75 điểm phần trăm và RF giảm 0,35. Không chia nhỏ tiếp 13 mẫu theo session/Wyckoff/Elliott và không nới detector để ép tần suất. Candidate vẫn pre-official; forward test tiếp tục hoãn. Chi tiết: `docs/NOENTRY_STRICT_WAIT4_V252.md`.

## Phụ lục 2026-10-27 — RB BUY context/imbalance audit v2.53

RB BUY được chọn vì là setup active có PF thấp nhất trên Extended của selected v2.52: 11 lệnh, WR 54,55%, Net -89,90 và PF 0,87. Tuy nhiên cùng setup đạt 24 lệnh/PF 3,67 ở OOS và 10 lệnh/PF 10,62 ở 2026. MAE/MFE trước đó cho thấy loser có MFE thấp và sai gần ngay sau entry, nên đây là bài toán tín hiệu/context, không phải lý do để nới SL hoặc hạ TP.

Telemetry xác nhận các bucket thua ở Extended đều đổi dấu trong dữ liệu hiện đại. `NORMAL`, `MID`, full-body và trend 240H `RANGE` đều dương mạnh ở OOS/2026. Không có nhãn đơn hoặc interaction hai biến nào âm xuyên cả ba vùng; không khai phá interaction ba biến trên 45 mẫu. Các rule RB BUY hiện có được giữ nguyên.

Thử nghiệm bắt buộc bullish imbalance M5 làm 2026 giảm từ +17.830,35 xuống +17.527,58 USD, PF 3,43 xuống 3,41, RF 19,42 xuống 19,24 và WR 74,05% xuống 73,72%. Riêng RB BUY giảm từ 10 lệnh/Net +1.030,68/PF 10,62 còn 8 lệnh/Net +780,17/PF 8,28. Filter đã loại hai giao dịch có đóng góp dương nên bị bác bỏ, không mở rộng tối ưu sang vùng khác.

V2.53 là audit release, không đổi logic giao dịch. Selected-control khớp tuyệt đối v2.52: Extended +7.909,06/PF 1,62/RF 5,34/DD 10,22%; OOS +55.223,25/PF 2,63/RF 23,66/DD 6,83%; 2026 +17.830,35/PF 3,43/RF 19,42/DD 4,22%/WR 74,05%. Portfolio hiện đại đạt 546 lệnh/46 tháng = 11,87 lệnh/tháng. Candidate vẫn pre-official; forward test tiếp tục hoãn. Chi tiết: `docs/RB_BUY_CONTEXT_AUDIT_V253.md`.

## Phụ lục 2026-10-28 — SB BUY continuation-contracting v2.54

SB BUY được chọn vì có 139 mẫu trên ba vùng và WR thấp lặp lại 40,48%/46,15%/57,89%. MAE/MFE v2.38 đã xác nhận TP 2R có expectancy tốt nhất, break-even 1R không hiệu quả và loser thường sai tín hiệu thay vì thiếu khoảng SL. Vì vậy vòng này không đổi SL/TP.

Compact telemetry BUY tái lập tuyệt đối v2.53. Không có bucket đơn hoặc interaction hai biến nào âm đồng thời trên cả ba vùng; không khai phá interaction ba biến. Candidate duy nhất được kiểm thử là `CONTINUATION_ALIGNED × volatility CONTRACTING`: hướng ngắn hạn thuận BUY nhưng H1 đang co biên, thiếu expansion cho Second Break theo tới 2R. Nhóm telemetry đạt 0/4 Extended, 1/3 và gần hòa vốn OOS, 0/1 năm 2026.

V2.54 thêm `Inp_SBBuyBlockContinuationContracting`, mặc định OFF và selected bật ON. Portfolio đạt Extended +8.636,55/PF 1,70/RF 7,08/DD 8,42%/WR 58,26%; OOS +55.253,69/PF 2,64/RF 23,52/DD 6,84%/WR 67,01%; 2026 +18.194,05/PF 3,54/RF 19,36/DD 4,27%/WR 74,52%. Net/PF/WR tăng ở cả ba vùng, tổng Net tăng 1.121,63 USD và chỉ giảm tám lệnh. Trade-off phải theo dõi là OOS RF -0,14/DD +0,01 điểm phần trăm và 2026 RF -0,06/DD +0,05 điểm phần trăm.

SB BUY mới đạt 38/75/18 lệnh với WR 44,74%/46,67%/61,11% và PF 1,47/1,86/3,11. Portfolio hiện đại còn 542 lệnh/46 tháng = 11,78 lệnh/tháng. Khóa SB BUY sau vòng này; không chia tiếp theo Wyckoff/Elliott/session. Candidate vẫn pre-official; forward test tiếp tục hoãn. Chi tiết: `docs/SB_BUY_CONTINUATION_CONTRACTING_V254.md`.

## Phụ lục 2026-10-28 — SB SELL aligned full-body v2.55

Sau khi khóa SB BUY, vòng v2.55 chọn SB SELL vì PF 2026 chỉ 1,75. MAE/MFE v2.40 vẫn giữ nguyên kết luận: không dùng break-even, không đổi TP 2R và không nới SL. Compact telemetry xác định interaction hiện đại yếu `Elliott ALIGNED × confirmation body >= 0,75`: OOS 0/3, 2026 1/3; Extended lại 2/4 và dương. Logic là nến displacement M5 quá rõ khi impulse H1 đã aligned thường tạo entry bán muộn.

V2.55 thêm `Inp_SBSellBlockAlignedFullBody`, mặc định OFF và selected bật ON. Portfolio đạt Extended +8.250,70/PF 1,68/RF 7,59/DD 7,50%/WR 58,41%; OOS +57.399,72/PF 2,71/RF 23,68/DD 6,82%/WR 67,54%; 2026 +18.289,47/PF 3,71/RF 19,46/DD 4,29%/WR 75,32%. Tổng Net ba vùng tăng 1.855,60 USD. Trade-off: Extended mất 385,85 USD Net/PF -0,02 nhưng RF +0,51 và DD giảm 0,92 điểm phần trăm.

SB SELL mới đạt 11/19/18 lệnh với PF 2,66/3,87/2,02. Portfolio hiện đại có 536 lệnh/46 tháng = 11,65 lệnh/tháng, WR 69,78% và PF 2,88. Có 17 nhánh active; IRB SELL, ARB SELL và inverse EMAENGULF SELL tiếp tục OFF. Ưu tiên kế tiếp là RB SELL vì PF hiện đại 1,73 trên 25 lệnh; sau đó mới nghiên cứu lane độc lập tăng mẫu. Khóa SB SELL, không chia thêm biến thứ ba. Candidate vẫn pre-official; forward test tiếp tục hoãn. Chi tiết: `docs/SB_SELL_ALIGNED_FULLBODY_V255.md` và `docs/SETUP_PERFORMANCE_SUMMARY_V255.md`.

## Phụ lục 2026-10-28 — RB SELL liquidity/FVG audit v2.56

RB SELL gồm legacy và liquidity expansion. Cả hai lane đều dương ở Extended/OOS/2026. Liquidity lane đạt PF 1,94/1,50/1,30; thấp hơn legacy trong 2026 nhưng vẫn đóng góp Net dương và giữ tần suất RB SELL hiện đại trên 0,50 lệnh/tháng. Không được tắt lane chỉ vì PF hiện đại thấp hơn.

Candidate yêu cầu bearish FVG do displacement M5 tạo ra. Trên 2026, candidate loại một liquidity winner nhưng giữ hai giao dịch có tổng Net -134,52 USD. Portfolio giảm từ +18.289,47 xuống +18.070,72 USD, PF 3,71 xuống 3,68, RF 19,46 xuống 19,22; RB SELL giảm từ 11 lệnh/Net +790,69/PF 2,94 còn 10 lệnh/Net +574,14/PF 2,41. Candidate bị bác bỏ và không chạy tối ưu tiếp OOS/Extended.

V2.56 là audit release, không đổi logic. Control khớp tuyệt đối v2.55 trên cả ba vùng. Không yêu cầu FVG/retest và không thêm filter volatility/Wyckoff cho RB SELL. Chỉ quay lại khi có failure-sequence mới hoặc dữ liệu độc lập; vòng sau chuyển sang lane tăng mẫu độc lập, ưu tiên ARB BUY hoặc inverse ENGULFED BUY. Candidate vẫn pre-official; forward test tiếp tục hoãn. Chi tiết: `docs/RB_SELL_FVG_AUDIT_V256.md`.

## Phụ lục 2026-10-28 — ARB SELL stateful liquidity lane v2.59

Không bật lại ARB SELL broad. V2.59 tạo state riêng theo chuỗi external-high sweep → bearish displacement → failed retest, sau đó chỉ nhận context `trend72=DOWN OR activity=EXPANDING`. Session 08–15, SL ngoài nến entry M5, TP 1,5R và risk 1% giữ nguyên; nhiều vị thế đồng thời vẫn được phép.

2025 reset riêng đạt 17 lệnh/WR 58,82%/branch +1.560,79; 2026 M1 đạt 19 lệnh/WR 68,42%/branch +2.260,09. 2026 real ticks đạt 13 lệnh/WR 84,62%/branch +2.676,71 và nâng portfolio lên +22.550,64/PF 3,89/RF 21,49/DD 4,25%. OOS tổng dương nhưng 2023–2024 yếu; Extended branch -195,20. Vì vậy đây là recent-regime lane theo ưu tiên 2025–2026, không phải edge xuyên chu kỳ.

NOENTRYCTX wait-3/wait-5 chỉ có ba lệnh 2025 và không có lệnh 2026; filter TPO/volume chọn sai mẫu nên giữ OFF. Preset selected là `tests/sets/BobH1ContextM5-v259-Selected-ARBSell-Liquidity.set`. Forward test tiếp tục hoãn. Chi tiết: `docs/ARB_SELL_LIQUIDITY_STATE_V259.md`.

## Phụ lục 2026-10-29 — EMAENGULF SELL ordered exhaustion v2.60

Không bật lại EMAENGULF SELL broad. V2.60 dùng state độc lập theo chuỗi external-high sweep → bearish displacement xuyên EMA25 M5 → failed retest. SL theo nến retest/entry, không theo đỉnh sweep; TP 1R, risk 1% và nhiều vị thế đồng thời vẫn được giữ.

Sàng lọc 2025–2026 bác bỏ loose và strong-volume. Context selected là `activity=NORMAL × transition=NO_FAST_TREND`: 2025 đạt 9 lệnh/WR 66,67%/Net +905,99; 2026 đạt 8 lệnh/WR 75%/Net +702,50. Real ticks 2026 xác nhận 8 lệnh/WR 75%/PF 2,61. OOS 2023–2025 đạt 21 lệnh/WR 71,43%/PF 2,77.

Extended chỉ có 6 lệnh, WR 33,33% và Net -360,05; portfolio Extended giảm 372,94 USD. Lane được nhận theo ưu tiên dữ liệu gần nhưng phải giữ nhãn recent-regime/pre-official. Không nới filter để ép mục tiêu 30 lệnh/tháng; forward test tiếp tục hoãn. Preset selected là `tests/sets/BobH1ContextM5-v260-Selected-EMAExhaust-NormalNF.set`. Chi tiết: `docs/EMAENGULF_SELL_EXHAUSTION_V260.md`.

## Phụ lục 2026-10-29 — IRB SELL break–retest state v2.61

Không bật IRB SELL broad. V2.61 tạo state độc lập theo compression ở đáy range → bearish displacement đóng dưới range → retest support cũ từ phía dưới → bearish rejection. Selected chỉ nhận transition H1 `EMERGING_ALIGNED/CONTINUATION_ALIGNED` và breakout phải tạo bearish FVG M5. SL theo nến retest, TP 0,75R và risk 1%.

Selected tạo 2/2 winner năm 2025 và 5/5 winner năm 2026. Real ticks 2026 đạt Net +25.123,19/PF 3,91/RF 22,64/DD 4,27%/WR 76,67%. OOS branch đạt 3/5 thắng và dương +867,08; Extended branch 2/4 và âm -113,52. Lane được nhận theo ưu tiên recent regime, vẫn pre-official và không tinh chỉnh thêm trên bảy mẫu hiện đại.

Vòng này cũng sửa `tools/Analyze-MT5Report.ps1`: attribution branch nay ghép đúng entry/close order qua hướng, volume và SL/TP trước khi cộng PnL deal. Parser cũ không an toàn khi nhiều vị thế đồng thời. Preset selected: `tests/sets/BobH1ContextM5-v261-Selected-IRBSellRetest-AlignedFVG.set`. Chi tiết: `docs/IRB_SELL_BREAK_RETEST_V261.md`.

## Phụ lục 2026-10-29 — IRB SELL FVG gap audit v2.62

V2.62 tách ngưỡng gap riêng `Inp_IRBSellRetestMinFVGATR` để thử tăng mẫu IRB-RT mà không thay đổi imbalance của setup khác. Nới từ 0,05 xuống 0,03 chỉ thêm một lệnh SELL thua ngày 10/06/2026: nhánh 2026 đổi từ 5/5, +784,80 thành 5/6, +573,97 và Net portfolio giảm 308,03 USD. Mức 0,02 làm 2025 giảm từ 2/2 xuống 2/3; mức 0,00 chỉ đạt 2/3 năm 2025 và 6/8 năm 2026. Các candidate bỏ yêu cầu FVG rồi tăng breakout body lên 0,50/0,65/0,80 ATR chỉ đạt WR 50–61,29%, xác nhận body lớn không thay thế được bearish imbalance.

Selected giữ ngưỡng 0,05 ATR và khớp tuyệt đối v2.61: 2025 +24.322,14/PF 2,99 với IRB-RT 2/2; 2026 +25.515,82/PF 3,46 với IRB-RT 5/5; real ticks 2026 +25.123,19/PF 3,91; OOS +67.295,64/PF 2,59; Extended +8.056,80/PF 1,52. Đây là audit release, không tăng trade. Không tinh chỉnh tiếp gap/body trên bảy mẫu hiện đại; vòng tăng mẫu kế tiếp phải dùng sequence cấu trúc độc lập và được đo như lane riêng. Preset: `tests/sets/BobH1ContextM5-v262-Selected-IRBSellRetest-FVG005.set`. Chi tiết: `docs/IRB_SELL_FVG_GAP_AUDIT_V262.md`.

## Phụ lục 2026-10-29 — IRB SELL liquidity-retest v2.63

V2.63 thêm lane stateful độc lập: range M5 hợp lệ → quét biên trên và đóng lại trong range → bearish displacement đóng dưới biên thấp → retest support cũ từ dưới và bearish rejection. Entry dùng SL ngoài nến retest, TP 0,75R và risk 1%. Lane có comment `BVCTXM5_IRBLQ_S`, không trùng timestamp với IRB-RT/ARB-LQ trong selected 2026.

Broad đạt 7/10 winner năm 2025 và 21/28 năm 2026. Context `ALIGNED` âm 2025; `NORMAL` mạnh 2026 nhưng gần hòa vốn 2025; các context còn lại giảm mẫu quá mạnh, nên selected để context broad. Session 00–15 loại bucket 16–23 PF thấp. Buffer sweep 0 ATR được chọn: vẫn bắt buộc high vượt rangeHigh nhưng không yêu cầu vượt thêm 0,05 ATR. Bearish FVG chỉ còn 5/7 lệnh năm 2025/2026 và không được dùng.

Selected đạt 2025 +25.353,52/PF 3,00 với IRB-LQ 7/9; 2026 +28.908,98/PF 3,24 với IRB-LQ 23/31; real ticks 2026 +28.536,51/PF 3,78 với branch 20/26 và +2.643,74; OOS +70.792,52/PF 2,57 với branch 18/27 và +1.491,35. Extended branch 13/27, -568,25 và portfolio giảm còn +7.240,05/PF 1,42, nên lane mang nhãn recent-regime/pre-official.

Trade-off được chấp nhận để tăng mẫu: 2026 M1 DD tăng 4,88% → 5,83% và RF giảm 14,24 → 12,20, trong khi Net tăng +3.393,16 USD. Real ticks RF lại tăng 22,64 → 24,25. Tần suất portfolio 2025–20/10/2026 đạt khoảng 20,7 lệnh/tháng; modern 2023–2026 đạt 15,52 lệnh/tháng, vẫn dưới mục tiêu 30. Không nới tiếp lane này; vòng sau chuyển sang sequence/setup độc lập khác. Preset: `tests/sets/BobH1ContextM5-v263-Selected-IRBSellLiquidity-Sessions12.set`. Chi tiết: `docs/IRB_SELL_LIQUIDITY_RETEST_V263.md`.

## Phụ lục 2026-10-29 — IRB BUY liquidity-retest audit v2.64

V2.64 xây lane BUY đối xứng: range M5 → quét biên dưới và đóng lại trong range → bullish displacement trên biên cao → retest kháng cự cũ từ trên và bullish rejection. Lane có state/comment riêng `BVCTXM5_IRBLQ_B`, SL ngoài nến retest và risk 1%.

Broad tạo 29 lệnh/PF 1,04/+87,35 USD năm 2025 nhưng 14 lệnh/PF 0,78/-333,23 USD năm 2026. `NORMAL` chỉ dương rất mỏng; `ALIGNED`, `24H UP`, `NO_FAST_TREND` và `REVERSAL_COUNTER` không ổn định hoặc thiếu mẫu. Không session đơn/cặp nào dương cả hai năm. Bullish FVG làm branch âm; sweep buffer 0 ATR tăng mẫu nhưng PF chỉ 0,93/0,58 trên 2025/2026. Không khai phá interaction ba biến.

Selected giữ `Inp_IRBBuyUseLiquidityRetestState=false`. Control khớp tuyệt đối v2.63: 2025 +25.353,52/PF 3,00; 2026 +28.908,98/PF 3,24; real ticks 2026 +28.536,51/PF 3,78; OOS +70.792,52/PF 2,57; Extended +7.240,05/PF 1,42. Đây là audit release, không tăng trade. Preset: `tests/sets/BobH1ContextM5-v264-Selected-Control-IRBBuyLiquidityAudit.set`. Chi tiết: `docs/IRB_BUY_LIQUIDITY_RETEST_AUDIT_V264.md`.

## Phụ lục 2026-10-29 — ARB BUY spring-retest audit v2.65

V2.65 thử lane ARB BUY độc lập theo external-low spring → bullish displacement → demand retest. Broad tạo 164 lệnh/WR 35,98%/PF 0,79 năm 2025 và 137 lệnh/WR 30,66%/PF 0,67 năm 2026. Mẫu lớn và âm rõ nên đây là logic bị bác bỏ, không phải thiếu mẫu.

Các context `72H UP`, `EXPANDING`, `either` và `no value/corrective` không dương ở cả hai năm. Bullish FVG chỉ có 5 lệnh dương năm 2025 và không có mẫu 2026. Yêu cầu retest đóng vượt hoàn toàn demand zone vẫn chỉ đạt PF 0,81/0,67. Không tiếp tục ghép session/context/FVG hoặc hạ body để tránh overfit.

Selected giữ `Inp_ARBBuyUseLiquiditySequence=false`; control khớp v2.64/v2.63: 2025 +25.353,52/PF 3,00; 2026 +28.908,98/PF 3,24; real ticks +28.536,51/PF 3,78; OOS +70.792,52/PF 2,57; Extended +7.240,05/PF 1,42. Preset: `tests/sets/BobH1ContextM5-v265-Selected-Control-ARBBuyLiquidityAudit.set`. Chi tiết: `docs/ARB_BUY_SPRING_RETEST_AUDIT_V265.md`.

## Phụ lục 2026-10-29 — EMAENGULF BUY ordered exhaustion v2.66

V2.66 thêm state độc lập `EMAEXHBUY`: trend H1 giảm → M5 quét external low → bullish displacement xuyên EMA25 và vượt đỉnh nến sweep → retest EMA/demand → BUY. SL ngoài nến retest, TP 1R, risk 1%. Lane có comment riêng và không trùng timestamp với EMAENGULF BUY legacy trong selected 2026.

Base 08–23 dương 2025 nhưng âm 2026. `NORMAL`, `NO_FAST_TREND`, kết hợp hai context, FVG và retest midpoint đều không ổn định. Session 08–15 đạt PF 2,32 năm 2025 nhưng chỉ 0,24 năm 2026. Session 16–23 là candidate duy nhất dương hai năm: 8 lệnh/PF 1,41/+247,59 năm 2025 và 11 lệnh/PF 2,02/+602,75 năm 2026. Không thêm context H1 vì làm 2025 xấu đi hoặc còn quá ít mẫu.

Selected đạt 2025 +25.287,09/PF 2,93; 2026 +30.240,59/PF 3,18; real ticks 2026 +30.414,33/PF 3,70/RF 30,24/DD 3,32%; OOS +71.020,73/PF 2,53. Extended branch âm và portfolio còn +6.899,82/PF 1,39, nên lane là recent-regime/pre-official. Tần suất gần nhất tăng lên khoảng 21,55 lệnh/tháng; modern đạt 16,07 lệnh/tháng. Preset: `tests/sets/BobH1ContextM5-v266-Selected-EMABuyExhaust-Session3.set`. Chi tiết: `docs/EMAENGULF_BUY_EXHAUSTION_V266.md`.
