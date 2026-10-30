//+------------------------------------------------------------------+
//|                                     Combo_3Logic_EA.mq5           |
//|  Gộp 3 EA: Scalp Breakout + Strong Pullback + Swing Breakout      |
//|  - 3 logic độc lập, mỗi logic magic riêng, quản lý lệnh riêng    |
//|  - Master filter: chọn 1 logic tốt nhất khi nhiều logic signal    |
//|  - Cooldown 30 min sau mỗi entry                                  |
//+------------------------------------------------------------------+
#property copyright "Combo 3-Logic EA (Scalp + Pullback + Swing)"
#property version   "1.00"
#property strict

#include <Trade\Trade.mqh>
CTrade trade;

//=== WATERMARK ===
#define EA_WM_NAME       "COMBO_WM"
#define EA_WM_TEXT       "EA by t/me/hieuphammmo"
const string LICENSE_CONTACT     = "@Hieuphammmo";

//=== ENUMS ===
enum ENUM_EMA_PRESET
{
   EMA_9_21   = 0, // EMA nhanh 9 / chậm 21
   EMA_20_50  = 1, // EMA nhanh 20 / chậm 50
   EMA_50_200 = 2, // EMA nhanh 50 / chậm 200
   EMA_200_50 = 3, // EMA nhanh 200 / chậm 50
   EMA_CUSTOM = 4 // Tùy chỉnh chu kỳ EMA bên dưới
};
enum ENUM_SL_MODE { SL_SWING = 0, SL_ATR = 1, SL_FIXED = 2 };

// Inputs: true = bật, false = tắt. Đơn vị point theo mã giao dịch; R = khoảng cách SL ban đầu.

input group "01. CHUNG | Bật/tắt chiến lược"
input bool Inp_EnableL1 = true; // Bật L1: Phá vỡ ngắn hạn (Scalp)
input bool Inp_EnableL2 = true; // Bật L2: Giá hồi theo xu hướng (Pullback)
input bool Inp_EnableL3 = true; // Bật L3: Phá vỡ đỉnh/đáy (Swing)

input group "02. CHUNG | Vốn và khối lượng lệnh"
input bool Inp_UseRiskPercent = true; // Tính lot: true = theo % vốn; false = lot cố định
input double Inp_RiskPercent = 1.0; // Rủi ro mỗi lệnh (% số dư)
input double Inp_LotFixed = 0.05; // Khối lượng cố định (lot)

input group "03. CHUNG | Giới hạn lệnh và thời gian nghỉ"
input int Inp_MaxPositions = 3; // Tổng số vị thế tối đa của EA
input int Inp_CooldownMinutes = 30; // Thời gian nghỉ sau khi vào lệnh (phút)
input double Inp_MinFinalScore = 5.0; // Điểm final tối thiểu để được vào lệnh (0-10). Dưới ngưỡng → SKIP

input group "04. CHUNG | Mã lệnh riêng biệt và backtest"
input ulong Inp_MagicL1 = 20260901; // Mã nhận diện lệnh L1 (Magic)
input ulong Inp_MagicL2 = 20260902; // Mã nhận diện lệnh L2 (Magic)
input ulong Inp_MagicL3 = 20260903; // Mã nhận diện lệnh L3 (Magic)
input bool Inp_FastBacktest = false; // Bật backtest nhanh: ẩn bảng và giảm log

input group "L1 - PHÁ VỠ NGẮN HẠN | 1. EMA và nến vào lệnh"
input ENUM_EMA_PRESET L1_EMAPreset = EMA_CUSTOM; // L1 | Chọn bộ EMA nhanh/chậm
input int L1_EMAFastCustom = 13; // L1 | Chu kỳ EMA nhanh (khi chọn Tùy chỉnh)
input int L1_EMASlowCustom = 50; // L1 | Chu kỳ EMA chậm (khi chọn Tùy chỉnh)
input int L1_BreakoutBars = 19; // L1 | Số nến tìm vùng phá vỡ
input double L1_BodyRatio = 0.67; // L1 | Tỷ lệ thân/toàn nến tối thiểu (0.67 = 67%)
input double L1_MinEMADistPts = 170; // L1 | Khoảng cách 2 EMA tối thiểu (point)
input int L1_MaxSpreadPts = 50555; // L1 | Spread tối đa cho phép (point)

input group "L1 | 2. Biến động ATR"
input int L1_ATRPeriod = 20; // L1 | Chu kỳ ATR
input bool L1_UseATRFilter = false; // L1 | Bật lọc độ dài nến theo ATR
input double L1_ATRMultiplier = 3.0; // L1 | Độ dài nến tối thiểu = ATR x hệ số này
input bool L1_UseATRRegime = true; // L1 | Bật ngưỡng biến động ATR tối thiểu
input double L1_ATRMinPoints = 200; // L1 | ATR tối thiểu (point)

input group "L1 | Lọc sức mạnh xu hướng ADX"
input bool L1_UseADXFilter = true; // L1 | Bật lọc sức mạnh xu hướng bằng ADX
input int L1_ADXPeriod = 14; // L1 | Chu kỳ ADX
input double L1_ADXMinLevel = 28.0; // L1 | ADX tối thiểu để vào lệnh
input bool L1_ADXRequireDI = true; // L1 | Yêu cầu DI+/DI- cùng hướng lệnh

input group "L1 | Lọc hướng MACD"
input bool L1_UseMACDFilter = true; // L1 | Bật lọc hướng bằng MACD
input int L1_MACDFast = 12; // L1 | Chu kỳ EMA nhanh của MACD
input int L1_MACDSlow = 26; // L1 | Chu kỳ EMA chậm của MACD
input int L1_MACDSignal = 9; // L1 | Chu kỳ đường tín hiệu MACD
input bool L1_MACDRequireZero = true; // L1 | Yêu cầu MACD đúng phía mốc 0

input group "L1 | Xác nhận xu hướng M30/H1"
input bool L1_UseM30Filter = true; // L1 | Bật xác nhận xu hướng khung M30
input bool L1_UseH1Filter = true; // L1 | Bật xác nhận xu hướng khung H1
input int L1_MTFEMAFast = 22; // L1 | Chu kỳ EMA nhanh trên M30/H1
input int L1_MTFEMASlow = 80; // L1 | Chu kỳ EMA chậm trên M30/H1

input group "L1 | Cắt lỗ, chốt lời và giới hạn lot"
input double L1_MaxLot = 10.0; // L1 | Lot tối đa khi tính theo % vốn
input int L1_SwingBars = 6; // L1 | Số nến tìm đỉnh/đáy đặt SL
input double L1_SLBufferPoints = 60; // L1 | Khoảng đệm ngoài đỉnh/đáy cho SL (point)
input double L1_MaxSLPoints = 1900; // L1 | Khoảng cách SL tối đa (point)
input double L1_RiskReward = 2.8; // L1 | Mục tiêu TP / khoảng cách SL (R)

input group "L1 | Dời SL hòa vốn"
input bool L1_UseBEMove = true; // L1 | Bật dời SL về vùng hòa vốn
input double L1_BEActivatePts = 500; // L1 | Lãi tối thiểu để dời SL hòa vốn (point)
input double L1_BEOffsetPts = 50; // L1 | Phần lãi giữ lại khi dời SL hòa vốn (point)

input group "L1 | SL bám giá và thoát khi đảo chiều"
input bool L1_UseTrailStop = true; // L1 | Bật dời SL theo giá (Trailing stop)
input double L1_TrailActivatePts = 1500; // L1 | Lãi tối thiểu để bắt đầu trailing (point)
input double L1_TrailDistancePts = 300; // L1 | Khoảng cách SL bám theo giá (point)
input bool L1_CloseOnH1Reverse = true; // L1 | Đóng lệnh khi xu hướng H1 đảo chiều

input group "L1 | Tùy chọn chưa được logic sử dụng"
input ENUM_SL_MODE L1_SLMode = SL_SWING; // L1 | Kiểu SL (chưa có tác dụng; luôn dùng đỉnh/đáy)

input group "L2 - GIÁ HỒI THEO XU HƯỚNG | 1. EMA và vùng phá vỡ"
input int L2_FastEmaLen = 30; // L2 | Chu kỳ EMA nhanh xác định xu hướng
input int L2_SlowEmaLen = 108; // L2 | Chu kỳ EMA chậm xác định xu hướng
input int L2_PullEmaLen = 13; // L2 | Chu kỳ EMA chờ giá hồi về
input int L2_SlopeLookback = 5; // L2 | Số nến đo độ dốc EMA nhanh
input int L2_BreakLookback = 13; // L2 | Số nến tìm vùng phá vỡ ban đầu
input double L2_MinBreakBodyPts = 40; // L2 | Thân nến phá vỡ tối thiểu (point)

input group "L2 | 2. Chờ giá hồi và mẫu nến"
input int L2_MinWaitBars = 1; // L2 | Số nến chờ tối thiểu sau phá vỡ
input int L2_MaxHuntBars = 40; // L2 | Số nến tối đa chờ tín hiệu hồi
input double L2_PullbackTolPts = 210; // L2 | Biên độ cho phép quanh EMA hồi (point)
input bool L2_AcceptPinbar = true; // L2 | Chấp nhận tín hiệu nến Pinbar
input double L2_PinbarWickRatio = 1.6; // L2 | Pinbar: râu chính / thân tối thiểu
input double L2_PinbarWickDom = 3.0; // L2 | Pinbar: râu chính / râu đối diện tối thiểu
input bool L2_AcceptEngulfing = true; // L2 | Chấp nhận tín hiệu nến nhấn chìm (Engulfing)
input bool L2_RequireClose = true; // L2 | Yêu cầu nến tăng khi mua, giảm khi bán
input bool L2_UseCooldown = true; // L2 | Bật thời gian nghỉ riêng cho L2
input int L2_CooldownBars = 18; // L2 | Số nến nghỉ giữa các lệnh L2

input group "L2 | 3. Biến động ATR và động lượng RSI"
input int L2_AtrLen = 14; // L2 | Chu kỳ ATR
input bool L2_UseATRMinFilter = true; // L2 | Bật ngưỡng biến động ATR tối thiểu
input double L2_ATRMinPts = 250; // L2 | ATR tối thiểu (point)
input bool L2_UseRSI = true; // L2 | Bật lọc động lượng bằng RSI
input int L2_RSILen = 14; // L2 | Chu kỳ RSI
input double L2_RSILongMin = 50; // L2 | RSI tối thiểu để mua
input double L2_RSIShortMax = 50; // L2 | RSI tối đa để bán

input group "L2 | Lọc sức mạnh xu hướng ADX"
input bool L2_UseADXFilter = true; // L2 | Bật lọc sức mạnh xu hướng bằng ADX
input int L2_ADXPeriod = 14; // L2 | Chu kỳ ADX
input double L2_ADXMinLevel = 12; // L2 | ADX tối thiểu để vào lệnh
input bool L2_ADXRequireDI = true; // L2 | Yêu cầu DI+/DI- cùng hướng lệnh

input group "L2 | Lọc hướng MACD"
input bool L2_UseMACDFilter = true; // L2 | Bật lọc hướng bằng MACD
input int L2_MACDFast = 12; // L2 | Chu kỳ EMA nhanh của MACD
input int L2_MACDSlow = 26; // L2 | Chu kỳ EMA chậm của MACD
input int L2_MACDSignal = 9; // L2 | Chu kỳ đường tín hiệu MACD
input bool L2_MACDRequireZero = true; // L2 | Yêu cầu MACD đúng phía mốc 0

input group "L2 | Xác nhận xu hướng M30/H1"
input bool L2_UseM30Filter = true; // L2 | Bật xác nhận xu hướng khung M30
input bool L2_UseH1Filter = true; // L2 | Bật xác nhận xu hướng khung H1
input int L2_MTFEmaFastLen = 28; // L2 | Chu kỳ EMA nhanh trên M30/H1
input int L2_MTFEmaSlowLen = 166; // L2 | Chu kỳ EMA chậm trên M30/H1

input group "L2 | Chấm điểm tín hiệu (nâng cao)"
input bool L2_OnlyStrong = true; // L2 | Chỉ nhận tín hiệu đủ điểm sức mạnh
input double L2_StrongThr = 6; // L2 | Điểm sức mạnh tối thiểu (0-10)
input double L2_W_HTF = 1.60; // L2 | Trọng số: xu hướng M30/H1
input double L2_W_Session = 1.22; // L2 | Trọng số: phiên (thành phần hiện cố định = 1)
input double L2_W_Trend = 1.70; // L2 | Trọng số: khoảng cách 2 EMA
input double L2_W_Depth = 0.30; // L2 | Trọng số: khoảng cách giá tới EMA hồi
input double L2_W_Momentum = 1.6; // L2 | Trọng số: động lượng RSI
input double L2_W_Volume = 2.6; // L2 | Trọng số: khối lượng tick
input double L2_SepNormPts = 850; // L2 | Khoảng cách EMA đạt điểm tối đa (point)
input double L2_DepthNormPts = 190; // L2 | Khoảng cách giá/EMA hồi đạt điểm tối đa (point)

input group "L2 | Cắt lỗ và giới hạn lot"
input double L2_MaxLot = 5; // L2 | Lot tối đa khi tính theo % vốn
input int L2_SLSwingBars = 5; // L2 | Số nến tìm đỉnh/đáy đặt SL
input double L2_SLBufferPts = 50; // L2 | Khoảng đệm ngoài đỉnh/đáy cho SL (point)
input bool L2_UseMaxSL = true; // L2 | Bật giới hạn khoảng cách SL
input double L2_MaxSLPts = 1300; // L2 | Khoảng cách SL tối đa (point)

input group "L2 | Chốt lời từng phần và bảo vệ lãi"
input double L2_TP1_R = 1.6; // L2 | Mốc chốt lời một phần TP1 (R)
input double L2_TP2_R = 3.1; // L2 | Mốc chốt lời cuối cùng TP2 (R)
input double L2_TP1_ClosePct = 80; // L2 | Khối lượng chốt tại TP1 (% lệnh)
input double L2_BE_AfterTP1_Pts = 100; // L2 | Phần lãi giữ lại khi dời SL sau TP1 (point)

input group "L3 - PHÁ VỠ ĐỈNH/ĐÁY | 1. EMA và nến vào lệnh"
input ENUM_EMA_PRESET L3_EMAPreset = EMA_CUSTOM; // L3 | Chọn bộ EMA nhanh/chậm
input int L3_EMAFastCustom = 12; // L3 | Chu kỳ EMA nhanh (khi chọn Tùy chỉnh)
input int L3_EMASlowCustom = 23; // L3 | Chu kỳ EMA chậm (khi chọn Tùy chỉnh)
input int L3_BreakoutBars = 16; // L3 | Số nến tìm vùng phá vỡ
input double L3_BodyRatio = 0.75; // L3 | Tỷ lệ thân/toàn nến tối thiểu (0.67 = 67%)
input double L3_MinEMADistPts = 140; // L3 | Khoảng cách 2 EMA tối thiểu (point)
input int L3_MaxSpreadPts = 50555; // L3 | Spread tối đa cho phép (point)

input group "L3 | 2. Biến động ATR"
input int L3_ATRPeriod = 20; // L3 | Chu kỳ ATR
input bool L3_UseATRFilter = false; // L3 | Bật lọc độ dài nến theo ATR
input double L3_ATRMultiplier = 3.0; // L3 | Độ dài nến tối thiểu = ATR x hệ số này
input bool L3_UseATRRegime = true; // L3 | Bật ngưỡng biến động ATR tối thiểu
input double L3_ATRMinPoints = 200; // L3 | ATR tối thiểu (point)

input group "L3 | Lọc sức mạnh xu hướng ADX"
input bool L3_UseADXFilter = true; // L3 | Bật lọc sức mạnh xu hướng bằng ADX
input int L3_ADXPeriod = 14; // L3 | Chu kỳ ADX
input double L3_ADXMinLevel = 25.0; // L3 | ADX tối thiểu để vào lệnh
input bool L3_ADXRequireDI = true; // L3 | Yêu cầu DI+/DI- cùng hướng lệnh

input group "L3 | Lọc hướng MACD"
input bool L3_UseMACDFilter = true; // L3 | Bật lọc hướng bằng MACD
input int L3_MACDFast = 12; // L3 | Chu kỳ EMA nhanh của MACD
input int L3_MACDSlow = 26; // L3 | Chu kỳ EMA chậm của MACD
input int L3_MACDSignal = 9; // L3 | Chu kỳ đường tín hiệu MACD
input bool L3_MACDRequireZero = true; // L3 | Yêu cầu MACD đúng phía mốc 0

input group "L3 | Xác nhận xu hướng M30/H1"
input bool L3_UseM30Filter = true; // L3 | Bật xác nhận xu hướng khung M30
input bool L3_UseH1Filter = true; // L3 | Bật xác nhận xu hướng khung H1
input int L3_MTFEMAFast = 34; // L3 | Chu kỳ EMA nhanh trên M30/H1
input int L3_MTFEMASlow = 89; // L3 | Chu kỳ EMA chậm trên M30/H1

input group "L3 | Cắt lỗ, chốt lời và giới hạn lot"
input double L3_MaxLot = 10.0; // L3 | Lot tối đa khi tính theo % vốn
input int L3_SwingBars = 11; // L3 | Số nến tìm đỉnh/đáy đặt SL
input double L3_SLBufferPoints = 60; // L3 | Khoảng đệm ngoài đỉnh/đáy cho SL (point)
input double L3_MaxSLPoints = 2500; // L3 | Khoảng cách SL tối đa (point)
input double L3_RiskReward = 3.1; // L3 | Mục tiêu TP / khoảng cách SL (R)

input group "L3 | Dời SL hòa vốn"
input bool L3_UseBEMove = false; // L3 | Bật dời SL về vùng hòa vốn
input double L3_BEActivatePts = 2000; // L3 | Lãi tối thiểu để dời SL hòa vốn (point)
input double L3_BEOffsetPts = 200; // L3 | Phần lãi giữ lại khi dời SL hòa vốn (point)

input group "L3 | SL bám giá và thoát khi đảo chiều"
input bool L3_UseTrailStop = false; // L3 | Bật dời SL theo giá (Trailing stop)
input double L3_TrailActivatePts = 600; // L3 | Lãi tối thiểu để bắt đầu trailing (point)
input double L3_TrailDistancePts = 500; // L3 | Khoảng cách SL bám theo giá (point)
input bool L3_CloseOnH1Reverse = true; // L3 | Đóng lệnh khi xu hướng H1 đảo chiều

input group "L3 | Tùy chọn chưa được logic sử dụng"
input ENUM_SL_MODE L3_SLMode = SL_SWING; // L3 | Kiểu SL (chưa có tác dụng; luôn dùng đỉnh/đáy)

//================== GLOBAL MASTER STATE ==================
datetime g_lastEntryTime  = 0;
datetime g_cooldownUntil  = 0;
datetime g_lastBarTime    = 0;

// Per-logic stats
int    s_L1_trades = 0, s_L1_wins = 0;
int    s_L2_trades = 0, s_L2_wins = 0;
int    s_L3_trades = 0, s_L3_wins = 0;
double s_L1_net = 0, s_L2_net = 0, s_L3_net = 0;
double s_grossProfit = 0, s_grossLoss = 0;

//================== SHARED UTILS ==================
void CreateWatermark()
{
   if(ObjectFind(0, EA_WM_NAME) < 0) ObjectCreate(0, EA_WM_NAME, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, EA_WM_NAME, OBJPROP_CORNER, CORNER_RIGHT_LOWER);
   ObjectSetInteger(0, EA_WM_NAME, OBJPROP_ANCHOR, ANCHOR_RIGHT_LOWER);
   ObjectSetInteger(0, EA_WM_NAME, OBJPROP_XDISTANCE, 15);
   ObjectSetInteger(0, EA_WM_NAME, OBJPROP_YDISTANCE, 12);
   ObjectSetString(0, EA_WM_NAME, OBJPROP_TEXT, EA_WM_TEXT);
   ObjectSetString(0, EA_WM_NAME, OBJPROP_FONT, "Arial Bold");
   ObjectSetInteger(0, EA_WM_NAME, OBJPROP_FONTSIZE, 10);
   ObjectSetInteger(0, EA_WM_NAME, OBJPROP_COLOR, C'255,200,80');
   ObjectSetInteger(0, EA_WM_NAME, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, EA_WM_NAME, OBJPROP_HIDDEN, true);
}

bool IsNewBar()
{
   datetime t = iTime(_Symbol, PERIOD_M5, 0);
   if(t != g_lastBarTime) { g_lastBarTime = t; return true; }
   return false;
}

double GetBuf(int handle, int shift)
{
   double buf[];
   if(CopyBuffer(handle, 0, shift, 1, buf) != 1) return EMPTY_VALUE;
   return buf[0];
}
double GetBufIdx(int handle, int idx, int shift)
{
   double buf[];
   if(CopyBuffer(handle, idx, shift, 1, buf) != 1) return EMPTY_VALUE;
   return buf[0];
}

int CountPositionsByMagic(ulong magic)
{
   int cnt = 0;
   for(int i=PositionsTotal()-1; i>=0; i--)
   {
      ulong t = PositionGetTicket(i);
      if(!PositionSelectByTicket(t)) continue;
      if(PositionGetString(POSITION_SYMBOL) == _Symbol &&
         PositionGetInteger(POSITION_MAGIC) == (long)magic) cnt++;
   }
   return cnt;
}
int CountAllEAPositions()
{
   return CountPositionsByMagic(Inp_MagicL1) + CountPositionsByMagic(Inp_MagicL2) + CountPositionsByMagic(Inp_MagicL3);
}

double NormalizeLot(double lot)
{
   double step = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   double mn = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double mx = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   if(step <= 0) step = 0.01;
   lot = MathFloor(lot / step) * step;
   if(lot < mn) lot = mn;
   if(lot > mx) lot = mx;
   return NormalizeDouble(lot, 2);
}

double CalcLotByRisk(double slDistPrice, double maxLot)
{
   if(!Inp_UseRiskPercent) return NormalizeLot(Inp_LotFixed);
   if(slDistPrice <= 0) return NormalizeLot(Inp_LotFixed);
   double bal = AccountInfoDouble(ACCOUNT_BALANCE);
   double risk = bal * Inp_RiskPercent / 100.0;
   double tv = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   double ts = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   if(tv <= 0 || ts <= 0) return NormalizeLot(Inp_LotFixed);
   double lossPerLot = (slDistPrice / ts) * tv;
   if(lossPerLot <= 0) return NormalizeLot(Inp_LotFixed);
   double lot = risk / lossPerLot;
   if(lot > maxLot) lot = maxLot;
   return NormalizeLot(lot);
}

//=== CANDLE PATTERNS (shared) ===
bool IsBullPinbar(double o, double h, double l, double c, double wickRatio, double wickDom)
{
   double body = MathAbs(c - o);
   double bH = MathMax(o, c), bL = MathMin(o, c);
   double lw = bL - l, uw = h - bH;
   if(body <= 0) return false;
   return lw >= wickRatio * body && lw > uw * wickDom && c >= (o + l) / 2.0;
}
bool IsBearPinbar(double o, double h, double l, double c, double wickRatio, double wickDom)
{
   double body = MathAbs(c - o);
   double bH = MathMax(o, c), bL = MathMin(o, c);
   double lw = bL - l, uw = h - bH;
   if(body <= 0) return false;
   return uw >= wickRatio * body && uw > lw * wickDom && c <= (o + h) / 2.0;
}
bool IsBullEngulf(double o1, double c1, double o2, double c2)
{
   return c1 > o1 && c2 < o2 && c1 >= o2 && o1 <= c2;
}
bool IsBearEngulf(double o1, double c1, double o2, double c2)
{
   return c1 < o1 && c2 > o2 && c1 <= o2 && o1 >= c2;
}

//=== SIGNAL RESULT STRUCT (shared for master orchestration) ===
struct SignalResult
{
   bool   valid;
   int    dir;      // 1=buy, -1=sell
   double score;    // 0-10
   double slPrice;
   double lotSize;
};

//===================================================================
//                    LOGIC 1: SCALP BREAKOUT (EMA13/50)
//===================================================================
int L1_hEMAFast = INVALID_HANDLE, L1_hEMASlow = INVALID_HANDLE;
int L1_hATR = INVALID_HANDLE, L1_hADX = INVALID_HANDLE, L1_hMACD = INVALID_HANDLE;
int L1_hM30F = INVALID_HANDLE, L1_hM30S = INVALID_HANDLE;
int L1_hH1F  = INVALID_HANDLE, L1_hH1S  = INVALID_HANDLE;

bool L1_Init()
{
   L1_hEMAFast = iMA(_Symbol, PERIOD_M5, L1_EMAFastCustom, 0, MODE_EMA, PRICE_CLOSE);
   L1_hEMASlow = iMA(_Symbol, PERIOD_M5, L1_EMASlowCustom, 0, MODE_EMA, PRICE_CLOSE);
   L1_hATR     = iATR(_Symbol, PERIOD_M5, L1_ATRPeriod);
   L1_hADX     = iADX(_Symbol, PERIOD_M5, L1_ADXPeriod);
   L1_hMACD    = iMACD(_Symbol, PERIOD_M5, L1_MACDFast, L1_MACDSlow, L1_MACDSignal, PRICE_CLOSE);
   L1_hM30F    = iMA(_Symbol, PERIOD_M30, L1_MTFEMAFast, 0, MODE_EMA, PRICE_CLOSE);
   L1_hM30S    = iMA(_Symbol, PERIOD_M30, L1_MTFEMASlow, 0, MODE_EMA, PRICE_CLOSE);
   L1_hH1F     = iMA(_Symbol, PERIOD_H1,  L1_MTFEMAFast, 0, MODE_EMA, PRICE_CLOSE);
   L1_hH1S     = iMA(_Symbol, PERIOD_H1,  L1_MTFEMASlow, 0, MODE_EMA, PRICE_CLOSE);
   return (L1_hEMAFast != INVALID_HANDLE && L1_hEMASlow != INVALID_HANDLE &&
           L1_hATR != INVALID_HANDLE && L1_hADX != INVALID_HANDLE && L1_hMACD != INVALID_HANDLE &&
           L1_hM30F != INVALID_HANDLE && L1_hM30S != INVALID_HANDLE &&
           L1_hH1F != INVALID_HANDLE && L1_hH1S != INVALID_HANDLE);
}
void L1_Deinit()
{
   if(L1_hEMAFast != INVALID_HANDLE) IndicatorRelease(L1_hEMAFast);
   if(L1_hEMASlow != INVALID_HANDLE) IndicatorRelease(L1_hEMASlow);
   if(L1_hATR != INVALID_HANDLE) IndicatorRelease(L1_hATR);
   if(L1_hADX != INVALID_HANDLE) IndicatorRelease(L1_hADX);
   if(L1_hMACD != INVALID_HANDLE) IndicatorRelease(L1_hMACD);
   if(L1_hM30F != INVALID_HANDLE) IndicatorRelease(L1_hM30F);
   if(L1_hM30S != INVALID_HANDLE) IndicatorRelease(L1_hM30S);
   if(L1_hH1F != INVALID_HANDLE) IndicatorRelease(L1_hH1F);
   if(L1_hH1S != INVALID_HANDLE) IndicatorRelease(L1_hH1S);
}

//=== L1 Filters ===
bool L1_FilterADX(bool isBuy)
{
   if(!L1_UseADXFilter) return true;
   double adx = GetBufIdx(L1_hADX, 0, 1);
   double dip = GetBufIdx(L1_hADX, 1, 1);
   double dim = GetBufIdx(L1_hADX, 2, 1);
   if(adx == EMPTY_VALUE || dip == EMPTY_VALUE || dim == EMPTY_VALUE) return false;
   if(adx < L1_ADXMinLevel) return false;
   if(L1_ADXRequireDI) return isBuy ? (dip > dim) : (dim > dip);
   return true;
}
bool L1_FilterMACD(bool isBuy)
{
   if(!L1_UseMACDFilter) return true;
   double m = GetBufIdx(L1_hMACD, 0, 1);
   double s = GetBufIdx(L1_hMACD, 1, 1);
   if(m == EMPTY_VALUE || s == EMPTY_VALUE) return false;
   bool ok = isBuy ? (m > s) : (m < s);
   if(L1_MACDRequireZero) ok = ok && (isBuy ? (m > 0) : (m < 0));
   return ok;
}
bool L1_FilterATRRegime(double atr1)
{
   if(!L1_UseATRRegime) return true;
   double atrPts = atr1 / _Point;
   return (atrPts >= L1_ATRMinPoints);
}
int L1_GetMTFDir(int hFast, int hSlow, ENUM_TIMEFRAMES tf)
{
   double f = GetBuf(hFast, 1);
   double s = GetBuf(hSlow, 1);
   double c = iClose(_Symbol, tf, 1);
   if(f == EMPTY_VALUE || s == EMPTY_VALUE) return 0;
   if(f > s && c > f) return 1;
   if(f < s && c < f) return -1;
   return 0;
}
bool L1_FilterMTF(bool isBuy)
{
   int need = isBuy ? 1 : -1;
   if(L1_UseM30Filter)
   {
      int d = L1_GetMTFDir(L1_hM30F, L1_hM30S, PERIOD_M30);
      if(d != need) return false;
   }
   if(L1_UseH1Filter)
   {
      int d = L1_GetMTFDir(L1_hH1F, L1_hH1S, PERIOD_H1);
      if(d != need) return false;
   }
   return true;
}

//=== L1 Detect signal ===
SignalResult L1_Detect()
{
   SignalResult r; r.valid=false; r.dir=0; r.score=0; r.slPrice=0; r.lotSize=0;
   if(!Inp_EnableL1) return r;

   double emaF1 = GetBuf(L1_hEMAFast, 1);
   double emaS1 = GetBuf(L1_hEMASlow, 1);
   double atr1  = GetBuf(L1_hATR, 1);
   if(emaF1 == EMPTY_VALUE || emaS1 == EMPTY_VALUE || atr1 == EMPTY_VALUE || atr1 <= 0) return r;

   if(!L1_FilterATRRegime(atr1)) return r;
   if(L1_MinEMADistPts > 0 && MathAbs(emaF1 - emaS1) / _Point < L1_MinEMADistPts) return r;

   if(L1_MaxSpreadPts > 0 && SymbolInfoInteger(_Symbol, SYMBOL_SPREAD) > L1_MaxSpreadPts) return r;

   double o1 = iOpen(_Symbol, PERIOD_M5, 1), c1 = iClose(_Symbol, PERIOD_M5, 1);
   double h1 = iHigh(_Symbol, PERIOD_M5, 1), l1 = iLow (_Symbol, PERIOD_M5, 1);
   double range = h1 - l1;
   if(range <= 0) return r;
   double bodyPct = MathAbs(c1 - o1) / range;
   if(bodyPct < L1_BodyRatio) return r;
   if(L1_UseATRFilter && range < atr1 * L1_ATRMultiplier) return r;

   int hiIdx = iHighest(_Symbol, PERIOD_M5, MODE_HIGH, L1_BreakoutBars, 2);
   int loIdx = iLowest (_Symbol, PERIOD_M5, MODE_LOW,  L1_BreakoutBars, 2);
   if(hiIdx < 0 || loIdx < 0) return r;
   double hh = iHigh(_Symbol, PERIOD_M5, hiIdx);
   double ll = iLow (_Symbol, PERIOD_M5, loIdx);

   bool trendUp = (emaF1 > emaS1) && (c1 > emaF1);
   bool trendDn = (emaF1 < emaS1) && (c1 < emaF1);
   bool breakUp = (c1 > hh);
   bool breakDn = (c1 < ll);

   int dir = 0;
   if(trendUp && breakUp) dir = 1;
   else if(trendDn && breakDn) dir = -1;
   else return r;

   if(!L1_FilterADX(dir == 1) || !L1_FilterMACD(dir == 1) || !L1_FilterMTF(dir == 1)) return r;

   // Compute SL
   double sl;
   if(dir == 1)
   {
      int idx = iLowest(_Symbol, PERIOD_M5, MODE_LOW, L1_SwingBars, 1);
      double swingLow = (idx >= 0) ? iLow(_Symbol, PERIOD_M5, idx) : c1 - L1_MaxSLPoints*_Point;
      sl = swingLow - L1_SLBufferPoints * _Point;
   }
   else
   {
      int idx = iHighest(_Symbol, PERIOD_M5, MODE_HIGH, L1_SwingBars, 1);
      double swingHi = (idx >= 0) ? iHigh(_Symbol, PERIOD_M5, idx) : c1 + L1_MaxSLPoints*_Point;
      sl = swingHi + L1_SLBufferPoints * _Point;
   }
   double px = (dir == 1) ? SymbolInfoDouble(_Symbol, SYMBOL_ASK) : SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double slDist = MathAbs(px - sl);
   if(slDist > L1_MaxSLPoints * _Point) { slDist = L1_MaxSLPoints * _Point; sl = (dir==1) ? px - slDist : px + slDist; }
   if(slDist <= 0) return r;

   double lot = CalcLotByRisk(slDist, L1_MaxLot);
   if(lot <= 0) return r;

   // Score based on ACTUAL indicator strength (chuẩn hoá 0-10)
   double score = 0;
   // MTF (max 3.0): mỗi khung đồng thuận = 1.5
   if(L1_UseM30Filter && L1_GetMTFDir(L1_hM30F, L1_hM30S, PERIOD_M30) == dir) score += 1.5;
   if(L1_UseH1Filter  && L1_GetMTFDir(L1_hH1F,  L1_hH1S,  PERIOD_H1 ) == dir) score += 1.5;
   // ADX strength (max 2.5)
   double _adxV = GetBufIdx(L1_hADX, 0, 1);
   if(_adxV != EMPTY_VALUE)
   {
      if(_adxV >= 40)      score += 2.5;
      else if(_adxV >= 30) score += 2.0;
      else if(_adxV >= 25) score += 1.5;
      else if(_adxV >= 20) score += 1.0;
      else                  score += 0.5;
   }
   // MACD divergence strength (max 2.0)
   double _macd = GetBufIdx(L1_hMACD, 0, 1), _sig = GetBufIdx(L1_hMACD, 1, 1);
   if(_macd != EMPTY_VALUE && _sig != EMPTY_VALUE)
   {
      double divPts = MathAbs(_macd - _sig) / _Point;
      score += MathMin(divPts / 20.0, 2.0);   // 20+ points divergence = full
   }
   // ATR regime (max 1.5)
   if(L1_ATRMinPoints > 0)
   {
      double atrRatio = (atr1 / _Point) / L1_ATRMinPoints;
      if(atrRatio >= 1.5)      score += 1.5;
      else if(atrRatio >= 1.2) score += 1.0;
      else if(atrRatio >= 1.0) score += 0.5;
   }
   // EMA separation (max 1.0)
   if(L1_MinEMADistPts > 0)
   {
      double emaSep = MathAbs(emaF1 - emaS1) / _Point;
      score += MathMin(emaSep / (L1_MinEMADistPts * 2.0), 1.0);
   }
   if(score > 10.0) score = 10.0;

   r.valid = true; r.dir = dir; r.score = score;
   r.slPrice = sl; r.lotSize = lot;
   return r;
}

//=== L1 Open trade ===
bool L1_OpenTrade(SignalResult &s)
{
   double px = (s.dir == 1) ? SymbolInfoDouble(_Symbol, SYMBOL_ASK) : SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double slDist = MathAbs(px - s.slPrice);
   double tp = (s.dir == 1) ? px + slDist * L1_RiskReward : px - slDist * L1_RiskReward;
   s.slPrice = NormalizeDouble(s.slPrice, _Digits);
   tp = NormalizeDouble(tp, _Digits);

   trade.SetExpertMagicNumber(Inp_MagicL1);
   trade.SetDeviationInPoints(30);
   string cmt = "L1_S" + IntegerToString((int)s.score);

   bool ok;
   if(s.dir == 1) ok = trade.Buy(s.lotSize, _Symbol, px, s.slPrice, tp, cmt);
   else           ok = trade.Sell(s.lotSize, _Symbol, px, s.slPrice, tp, cmt);

   if(ok && !Inp_FastBacktest)
      PrintFormat("[L1-%s] lot=%.2f @%.5f SL=%.5f TP=%.5f score=%.0f",
                  s.dir==1?"BUY":"SELL", s.lotSize, px, s.slPrice, tp, s.score);
   return ok;
}

//=== L1 Manage positions (BE + Trail + H1 reverse close) ===
void L1_Manage()
{
   for(int i = PositionsTotal()-1; i >= 0; i--)
   {
      ulong t = PositionGetTicket(i);
      if(!PositionSelectByTicket(t)) continue;
      if(PositionGetInteger(POSITION_MAGIC) != (long)Inp_MagicL1) continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;

      long type = PositionGetInteger(POSITION_TYPE);
      double entry = PositionGetDouble(POSITION_PRICE_OPEN);
      double curSL = PositionGetDouble(POSITION_SL);
      double curTP = PositionGetDouble(POSITION_TP);

      // BE Move
      if(L1_UseBEMove)
      {
         if(type == POSITION_TYPE_BUY)
         {
            double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
            if((bid - entry)/_Point >= L1_BEActivatePts)
            {
               double newSL = NormalizeDouble(entry + L1_BEOffsetPts * _Point, _Digits);
               if(newSL > curSL) trade.PositionModify(t, newSL, curTP);
            }
         }
         else
         {
            double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
            if((entry - ask)/_Point >= L1_BEActivatePts)
            {
               double newSL = NormalizeDouble(entry - L1_BEOffsetPts * _Point, _Digits);
               if(curSL <= 0 || newSL < curSL) trade.PositionModify(t, newSL, curTP);
            }
         }
      }

      // Trailing Stop
      if(L1_UseTrailStop)
      {
         if(type == POSITION_TYPE_BUY)
         {
            double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
            if((bid - entry)/_Point >= L1_TrailActivatePts)
            {
               double newSL = NormalizeDouble(bid - L1_TrailDistancePts * _Point, _Digits);
               if(newSL > curSL) trade.PositionModify(t, newSL, curTP);
            }
         }
         else
         {
            double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
            if((entry - ask)/_Point >= L1_TrailActivatePts)
            {
               double newSL = NormalizeDouble(ask + L1_TrailDistancePts * _Point, _Digits);
               if(curSL <= 0 || newSL < curSL) trade.PositionModify(t, newSL, curTP);
            }
         }
      }

      // H1 Reversal Close
      if(L1_CloseOnH1Reverse)
      {
         int h1dir = L1_GetMTFDir(L1_hH1F, L1_hH1S, PERIOD_H1);
         if(type == POSITION_TYPE_BUY && h1dir == -1) trade.PositionClose(t);
         else if(type == POSITION_TYPE_SELL && h1dir == 1) trade.PositionClose(t);
      }
   }
}

//===================================================================
//                    LOGIC 2: STRONG PULLBACK (Pinbar/Engulfing)
//===================================================================
int L2_hFast = INVALID_HANDLE, L2_hSlow = INVALID_HANDLE, L2_hPull = INVALID_HANDLE;
int L2_hATR = INVALID_HANDLE, L2_hRSI = INVALID_HANDLE;
int L2_hM30F = INVALID_HANDLE, L2_hM30S = INVALID_HANDLE;
int L2_hH1F  = INVALID_HANDLE, L2_hH1S  = INVALID_HANDLE;
int L2_hMACD = INVALID_HANDLE, L2_hADX = INVALID_HANDLE;

// Armed setup state
bool     L2_armed        = false;
int      L2_adir         = 0;
datetime L2_armTime      = 0;
datetime L2_lastSigTime  = 0;
datetime L2_lastBar      = 0;

bool L2_Init()
{
   L2_hFast = iMA(_Symbol, PERIOD_M5, L2_FastEmaLen, 0, MODE_EMA, PRICE_CLOSE);
   L2_hSlow = iMA(_Symbol, PERIOD_M5, L2_SlowEmaLen, 0, MODE_EMA, PRICE_CLOSE);
   L2_hPull = iMA(_Symbol, PERIOD_M5, L2_PullEmaLen, 0, MODE_EMA, PRICE_CLOSE);
   L2_hATR  = iATR(_Symbol, PERIOD_M5, L2_AtrLen);
   L2_hRSI  = iRSI(_Symbol, PERIOD_M5, L2_RSILen, PRICE_CLOSE);
   L2_hM30F = iMA(_Symbol, PERIOD_M30, L2_MTFEmaFastLen, 0, MODE_EMA, PRICE_CLOSE);
   L2_hM30S = iMA(_Symbol, PERIOD_M30, L2_MTFEmaSlowLen, 0, MODE_EMA, PRICE_CLOSE);
   L2_hH1F  = iMA(_Symbol, PERIOD_H1,  L2_MTFEmaFastLen, 0, MODE_EMA, PRICE_CLOSE);
   L2_hH1S  = iMA(_Symbol, PERIOD_H1,  L2_MTFEmaSlowLen, 0, MODE_EMA, PRICE_CLOSE);
   L2_hMACD = iMACD(_Symbol, PERIOD_M5, L2_MACDFast, L2_MACDSlow, L2_MACDSignal, PRICE_CLOSE);
   L2_hADX  = iADX(_Symbol, PERIOD_M5, L2_ADXPeriod);
   return (L2_hFast!=INVALID_HANDLE && L2_hSlow!=INVALID_HANDLE && L2_hPull!=INVALID_HANDLE &&
           L2_hATR!=INVALID_HANDLE && L2_hRSI!=INVALID_HANDLE &&
           L2_hM30F!=INVALID_HANDLE && L2_hM30S!=INVALID_HANDLE &&
           L2_hH1F!=INVALID_HANDLE && L2_hH1S!=INVALID_HANDLE &&
           L2_hMACD!=INVALID_HANDLE && L2_hADX!=INVALID_HANDLE);
}
void L2_Deinit()
{
   if(L2_hFast!=INVALID_HANDLE) IndicatorRelease(L2_hFast);
   if(L2_hSlow!=INVALID_HANDLE) IndicatorRelease(L2_hSlow);
   if(L2_hPull!=INVALID_HANDLE) IndicatorRelease(L2_hPull);
   if(L2_hATR !=INVALID_HANDLE) IndicatorRelease(L2_hATR);
   if(L2_hRSI !=INVALID_HANDLE) IndicatorRelease(L2_hRSI);
   if(L2_hM30F!=INVALID_HANDLE) IndicatorRelease(L2_hM30F);
   if(L2_hM30S!=INVALID_HANDLE) IndicatorRelease(L2_hM30S);
   if(L2_hH1F !=INVALID_HANDLE) IndicatorRelease(L2_hH1F);
   if(L2_hH1S !=INVALID_HANDLE) IndicatorRelease(L2_hH1S);
   if(L2_hMACD!=INVALID_HANDLE) IndicatorRelease(L2_hMACD);
   if(L2_hADX !=INVALID_HANDLE) IndicatorRelease(L2_hADX);
}

int L2_MTFDir(int hF, int hS, ENUM_TIMEFRAMES tf)
{
   double f = GetBuf(hF, 1), s = GetBuf(hS, 1);
   double c = iClose(_Symbol, tf, 1);
   if(f == EMPTY_VALUE || s == EMPTY_VALUE) return 0;
   if(f > s && c > f) return 1;
   if(f < s && c < f) return -1;
   return 0;
}
bool L2_MTFPass(bool isBuy)
{
   int need = isBuy ? 1 : -1;
   if(L2_UseM30Filter && L2_MTFDir(L2_hM30F, L2_hM30S, PERIOD_M30) != need) return false;
   if(L2_UseH1Filter  && L2_MTFDir(L2_hH1F,  L2_hH1S,  PERIOD_H1 ) != need) return false;
   return true;
}
double L2_MTFScoreFactor(bool isBuy)
{
   int need = isBuy ? 1 : -1;
   int active = 0, passed = 0;
   if(L2_UseM30Filter) { active++; if(L2_MTFDir(L2_hM30F, L2_hM30S, PERIOD_M30) == need) passed++; }
   if(L2_UseH1Filter)  { active++; if(L2_MTFDir(L2_hH1F,  L2_hH1S,  PERIOD_H1)  == need) passed++; }
   if(active == 0) return 0.6;
   return (double)passed / active;
}
bool L2_MACDOK(bool isBuy)
{
   if(!L2_UseMACDFilter) return true;
   double m = GetBufIdx(L2_hMACD, 0, 1), s = GetBufIdx(L2_hMACD, 1, 1);
   if(m == EMPTY_VALUE || s == EMPTY_VALUE) return false;
   bool ok = isBuy ? (m > s) : (m < s);
   if(L2_MACDRequireZero) ok = ok && (isBuy ? (m > 0) : (m < 0));
   return ok;
}
bool L2_ADXOK(bool isBuy)
{
   if(!L2_UseADXFilter) return true;
   double adx = GetBufIdx(L2_hADX, 0, 1);
   double dip = GetBufIdx(L2_hADX, 1, 1);
   double dim = GetBufIdx(L2_hADX, 2, 1);
   if(adx == EMPTY_VALUE) return false;
   if(adx < L2_ADXMinLevel) return false;
   if(L2_ADXRequireDI) return isBuy ? (dip > dim) : (dim > dip);
   return true;
}

double L2_CalcScore(int side, double atr, double fastE, double slowE, double pullE, double rsi)
{
   double mtfF = L2_MTFScoreFactor(side == 1);
   double sesF = 1.0;
   double a = (atr <= 0) ? _Point : atr;
   double sepF = MathMin(MathAbs(fastE - slowE) / (L2_SepNormPts * _Point), 1.0);
   double c1 = iClose(_Symbol, PERIOD_M5, 1);
   double depF = MathMin(MathAbs(c1 - pullE) / (L2_DepthNormPts * _Point), 1.0);
   double momF = (side == 1) ? MathMin(MathMax((rsi-50.0)/30.0, 0.0), 1.0)
                             : MathMin(MathMax((50.0-rsi)/30.0, 0.0), 1.0);
   long volNow = iVolume(_Symbol, PERIOD_M5, 1);
   double volAvg = 0;
   for(int i=1; i<=20; i++) volAvg += iVolume(_Symbol, PERIOD_M5, i);
   volAvg /= 20.0;
   double volF = (volAvg > 0) ? MathMin((double)volNow / volAvg, 1.0) : 0.0;

   double wsum = L2_W_HTF + L2_W_Session + L2_W_Trend + L2_W_Depth + L2_W_Momentum + L2_W_Volume;
   if(wsum <= 0) return 0;
   double raw = (mtfF*L2_W_HTF + sesF*L2_W_Session + sepF*L2_W_Trend
               + depF*L2_W_Depth + momF*L2_W_Momentum + volF*L2_W_Volume) / wsum;
   return MathMin(MathMax(raw * 10.0, 0.0), 10.0);
}

SignalResult L2_Detect()
{
   SignalResult r; r.valid=false; r.dir=0; r.score=0; r.slPrice=0; r.lotSize=0;
   if(!Inp_EnableL2) return r;

   double fastE = GetBuf(L2_hFast, 1);
   double slowE = GetBuf(L2_hSlow, 1);
   double pullE = GetBuf(L2_hPull, 1);
   double fastEslope = GetBuf(L2_hFast, 1 + L2_SlopeLookback);
   double atr = GetBuf(L2_hATR, 1);
   double rsi = GetBuf(L2_hRSI, 1);
   double c1 = iClose(_Symbol, PERIOD_M5, 1);
   double o1 = iOpen (_Symbol, PERIOD_M5, 1);
   double h1 = iHigh (_Symbol, PERIOD_M5, 1);
   double l1 = iLow  (_Symbol, PERIOD_M5, 1);
   double o2 = iOpen (_Symbol, PERIOD_M5, 2);
   double c2 = iClose(_Symbol, PERIOD_M5, 2);

   if(fastE == EMPTY_VALUE || slowE == EMPTY_VALUE || pullE == EMPTY_VALUE ||
      atr == EMPTY_VALUE || atr <= 0) return r;

   // ATR min filter
   if(L2_UseATRMinFilter && atr/_Point < L2_ATRMinPts) return r;

   bool bullTrend = (fastE > slowE) && (c1 > slowE) && (fastE > fastEslope);
   bool bearTrend = (fastE < slowE) && (c1 < slowE) && (fastE < fastEslope);

   // === Armed check ===
   if(L2_armed)
   {
      int ageBars = (int)((iTime(_Symbol, PERIOD_M5, 1) - L2_armTime) / PeriodSeconds(PERIOD_M5));
      bool expired = ageBars > L2_MaxHuntBars;
      bool flipped = (L2_adir==1 && !bullTrend) || (L2_adir==-1 && !bearTrend);
      if(expired || flipped) { L2_armed = false; L2_adir = 0; }
      else if(ageBars >= L2_MinWaitBars)
      {
         // Pullback check
         double tol = L2_PullbackTolPts * _Point;
         bool pullbackOK;
         if(L2_adir == 1)
            pullbackOK = (l1 <= pullE + tol) && (c1 >= pullE - tol);
         else
            pullbackOK = (h1 >= pullE - tol) && (c1 <= pullE + tol);

         if(pullbackOK)
         {
            bool candleOK = false;
            if(L2_adir == 1)
            {
               if(L2_AcceptPinbar && IsBullPinbar(o1, h1, l1, c1, L2_PinbarWickRatio, L2_PinbarWickDom)) candleOK = true;
               if(L2_AcceptEngulfing && IsBullEngulf(o1, c1, o2, c2)) candleOK = true;
            }
            else
            {
               if(L2_AcceptPinbar && IsBearPinbar(o1, h1, l1, c1, L2_PinbarWickRatio, L2_PinbarWickDom)) candleOK = true;
               if(L2_AcceptEngulfing && IsBearEngulf(o1, c1, o2, c2)) candleOK = true;
            }

            if(candleOK)
            {
               bool mtfOk = L2_MTFPass(L2_adir == 1);
               bool rsiOk = !L2_UseRSI || (L2_adir==1 ? rsi >= L2_RSILongMin : rsi <= L2_RSIShortMax);
               bool trendOk = (L2_adir==1) ? (c1 > slowE) : (c1 < slowE);
               bool closeOk = !L2_RequireClose || (L2_adir==1 ? c1 > o1 : c1 < o1);
               bool macdOk = L2_MACDOK(L2_adir == 1);
               bool adxOk  = L2_ADXOK(L2_adir == 1);

               if(mtfOk && rsiOk && trendOk && closeOk && macdOk && adxOk)
               {
                  double score = L2_CalcScore(L2_adir, atr, fastE, slowE, pullE, rsi);
                  if(!L2_OnlyStrong || score >= L2_StrongThr)
                  {
                     // Compute SL
                     double sl, px;
                     if(L2_adir == 1)
                     {
                        px = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
                        int idx = iLowest(_Symbol, PERIOD_M5, MODE_LOW, L2_SLSwingBars, 1);
                        double sw = (idx>=0) ? iLow(_Symbol, PERIOD_M5, idx) : px - L2_MaxSLPts*_Point;
                        sl = sw - L2_SLBufferPts * _Point;
                     }
                     else
                     {
                        px = SymbolInfoDouble(_Symbol, SYMBOL_BID);
                        int idx = iHighest(_Symbol, PERIOD_M5, MODE_HIGH, L2_SLSwingBars, 1);
                        double sw = (idx>=0) ? iHigh(_Symbol, PERIOD_M5, idx) : px + L2_MaxSLPts*_Point;
                        sl = sw + L2_SLBufferPts * _Point;
                     }
                     double slDist = MathAbs(px - sl);
                     if(L2_UseMaxSL && slDist > L2_MaxSLPts * _Point)
                     {
                        slDist = L2_MaxSLPts * _Point;
                        sl = (L2_adir==1) ? px - slDist : px + slDist;
                     }
                     if(slDist > 0)
                     {
                        double lot = CalcLotByRisk(slDist, L2_MaxLot);
                        if(lot > 0)
                        {
                           r.valid = true; r.dir = L2_adir; r.score = score;
                           r.slPrice = sl; r.lotSize = lot;
                           // Sẽ reset armed sau khi open trade (thực hiện ngoài)
                           return r;
                        }
                     }
                  }
               }
            }
         }
      }
   }

   // === Detect new breakout to arm ===
   if(!L2_armed)
   {
      double hiBefore = 0, loBefore = DBL_MAX;
      for(int i=2; i<=L2_BreakLookback+1; i++)
      {
         hiBefore = MathMax(hiBefore, iHigh(_Symbol, PERIOD_M5, i));
         loBefore = MathMin(loBefore, iLow (_Symbol, PERIOD_M5, i));
      }
      double body = MathAbs(c1 - o1);
      bool bodyOk = body >= L2_MinBreakBodyPts * _Point;
      bool bullBrk = bullTrend && c1 > hiBefore && c1 > o1 && bodyOk;
      bool bearBrk = bearTrend && c1 < loBefore && c1 < o1 && bodyOk;
      bool cooldownOk = !L2_UseCooldown || L2_lastSigTime==0 ||
                        ((iTime(_Symbol,PERIOD_M5,1) - L2_lastSigTime) / PeriodSeconds(PERIOD_M5) >= L2_CooldownBars);
      if(bullBrk && cooldownOk) { L2_armed = true; L2_adir = 1; L2_armTime = iTime(_Symbol,PERIOD_M5,1); }
      else if(bearBrk && cooldownOk) { L2_armed = true; L2_adir = -1; L2_armTime = iTime(_Symbol,PERIOD_M5,1); }
   }
   return r;
}

bool L2_OpenTrade(SignalResult &s)
{
   double px = (s.dir == 1) ? SymbolInfoDouble(_Symbol, SYMBOL_ASK) : SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double slDist = MathAbs(px - s.slPrice);
   double tp2 = (s.dir == 1) ? px + slDist * L2_TP2_R : px - slDist * L2_TP2_R;
   double tp1 = (s.dir == 1) ? px + slDist * L2_TP1_R : px - slDist * L2_TP1_R;
   s.slPrice = NormalizeDouble(s.slPrice, _Digits);
   tp2 = NormalizeDouble(tp2, _Digits);
   tp1 = NormalizeDouble(tp1, _Digits);

   trade.SetExpertMagicNumber(Inp_MagicL2);
   trade.SetDeviationInPoints(30);
   string cmt = "L2_S" + IntegerToString((int)MathRound(s.score*10));

   bool ok;
   if(s.dir == 1) ok = trade.Buy(s.lotSize, _Symbol, px, s.slPrice, tp2, cmt);
   else           ok = trade.Sell(s.lotSize, _Symbol, px, s.slPrice, tp2, cmt);

   if(ok)
   {
      ulong ticket = trade.ResultOrder();
      if(ticket > 0)
      {
         GlobalVariableSet("L2_TP1_" + IntegerToString(ticket), tp1);
         GlobalVariableSet("L2_TP2_" + IntegerToString(ticket), tp2);
      }
      L2_lastSigTime = iTime(_Symbol,PERIOD_M5,1);
      L2_armed = false; L2_adir = 0;
      if(!Inp_FastBacktest)
         PrintFormat("[L2-%s] lot=%.2f @%.5f SL=%.5f TP1=%.5f TP2=%.5f score=%.1f",
                     s.dir==1?"BUY":"SELL", s.lotSize, px, s.slPrice, tp1, tp2, s.score);
   }
   return ok;
}

// L2 Manage: TP1 partial 80% + BE+100pt, then TP2 close all (broker auto)
void L2_Manage()
{
   for(int i = PositionsTotal()-1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(!PositionSelectByTicket(ticket)) continue;
      if(PositionGetInteger(POSITION_MAGIC) != (long)Inp_MagicL2) continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;

      long type = PositionGetInteger(POSITION_TYPE);
      double entry = PositionGetDouble(POSITION_PRICE_OPEN);
      double curSL = PositionGetDouble(POSITION_SL);
      double curTP = PositionGetDouble(POSITION_TP);
      double curVol = PositionGetDouble(POSITION_VOLUME);

      string sT = IntegerToString(ticket);
      if(!GlobalVariableCheck("L2_TP1_" + sT)) continue;
      if(!GlobalVariableCheck("L2_INITVOL_" + sT)) continue;
      double tp1 = GlobalVariableGet("L2_TP1_" + sT);
      double initVol = GlobalVariableGet("L2_INITVOL_" + sT);
      bool tp1Done = GlobalVariableCheck("L2_TP1DONE_" + sT) && GlobalVariableGet("L2_TP1DONE_" + sT) > 0;
      if(tp1Done) continue;

      if(type == POSITION_TYPE_BUY)
      {
         double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
         if(bid >= tp1)
         {
            double closeVol = NormalizeLot(initVol * L2_TP1_ClosePct / 100.0);
            if(closeVol > 0 && closeVol < curVol && trade.PositionClosePartial(ticket, closeVol))
            {
               GlobalVariableSet("L2_TP1DONE_" + sT, 1);
               double newSL = NormalizeDouble(entry + L2_BE_AfterTP1_Pts * _Point, _Digits);
               trade.PositionModify(ticket, newSL, curTP);
            }
            else GlobalVariableSet("L2_TP1DONE_" + sT, 1);
         }
      }
      else
      {
         double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
         if(ask <= tp1)
         {
            double closeVol = NormalizeLot(initVol * L2_TP1_ClosePct / 100.0);
            if(closeVol > 0 && closeVol < curVol && trade.PositionClosePartial(ticket, closeVol))
            {
               GlobalVariableSet("L2_TP1DONE_" + sT, 1);
               double newSL = NormalizeDouble(entry - L2_BE_AfterTP1_Pts * _Point, _Digits);
               trade.PositionModify(ticket, newSL, curTP);
            }
            else GlobalVariableSet("L2_TP1DONE_" + sT, 1);
         }
      }
   }
}

//===================================================================
//                    LOGIC 3: SWING BREAKOUT (EMA12/23)
//===================================================================
int L3_hEMAFast = INVALID_HANDLE, L3_hEMASlow = INVALID_HANDLE;
int L3_hATR = INVALID_HANDLE, L3_hADX = INVALID_HANDLE, L3_hMACD = INVALID_HANDLE;
int L3_hM30F = INVALID_HANDLE, L3_hM30S = INVALID_HANDLE;
int L3_hH1F  = INVALID_HANDLE, L3_hH1S  = INVALID_HANDLE;

bool L3_Init()
{
   L3_hEMAFast = iMA(_Symbol, PERIOD_M5, L3_EMAFastCustom, 0, MODE_EMA, PRICE_CLOSE);
   L3_hEMASlow = iMA(_Symbol, PERIOD_M5, L3_EMASlowCustom, 0, MODE_EMA, PRICE_CLOSE);
   L3_hATR     = iATR(_Symbol, PERIOD_M5, L3_ATRPeriod);
   L3_hADX     = iADX(_Symbol, PERIOD_M5, L3_ADXPeriod);
   L3_hMACD    = iMACD(_Symbol, PERIOD_M5, L3_MACDFast, L3_MACDSlow, L3_MACDSignal, PRICE_CLOSE);
   L3_hM30F    = iMA(_Symbol, PERIOD_M30, L3_MTFEMAFast, 0, MODE_EMA, PRICE_CLOSE);
   L3_hM30S    = iMA(_Symbol, PERIOD_M30, L3_MTFEMASlow, 0, MODE_EMA, PRICE_CLOSE);
   L3_hH1F     = iMA(_Symbol, PERIOD_H1,  L3_MTFEMAFast, 0, MODE_EMA, PRICE_CLOSE);
   L3_hH1S     = iMA(_Symbol, PERIOD_H1,  L3_MTFEMASlow, 0, MODE_EMA, PRICE_CLOSE);
   return (L3_hEMAFast!=INVALID_HANDLE && L3_hEMASlow!=INVALID_HANDLE &&
           L3_hATR!=INVALID_HANDLE && L3_hADX!=INVALID_HANDLE && L3_hMACD!=INVALID_HANDLE &&
           L3_hM30F!=INVALID_HANDLE && L3_hM30S!=INVALID_HANDLE &&
           L3_hH1F!=INVALID_HANDLE && L3_hH1S!=INVALID_HANDLE);
}
void L3_Deinit()
{
   if(L3_hEMAFast!=INVALID_HANDLE) IndicatorRelease(L3_hEMAFast);
   if(L3_hEMASlow!=INVALID_HANDLE) IndicatorRelease(L3_hEMASlow);
   if(L3_hATR!=INVALID_HANDLE) IndicatorRelease(L3_hATR);
   if(L3_hADX!=INVALID_HANDLE) IndicatorRelease(L3_hADX);
   if(L3_hMACD!=INVALID_HANDLE) IndicatorRelease(L3_hMACD);
   if(L3_hM30F!=INVALID_HANDLE) IndicatorRelease(L3_hM30F);
   if(L3_hM30S!=INVALID_HANDLE) IndicatorRelease(L3_hM30S);
   if(L3_hH1F!=INVALID_HANDLE) IndicatorRelease(L3_hH1F);
   if(L3_hH1S!=INVALID_HANDLE) IndicatorRelease(L3_hH1S);
}

bool L3_FilterADX(bool isBuy)
{
   if(!L3_UseADXFilter) return true;
   double adx = GetBufIdx(L3_hADX, 0, 1);
   double dip = GetBufIdx(L3_hADX, 1, 1);
   double dim = GetBufIdx(L3_hADX, 2, 1);
   if(adx == EMPTY_VALUE) return false;
   if(adx < L3_ADXMinLevel) return false;
   if(L3_ADXRequireDI) return isBuy ? (dip > dim) : (dim > dip);
   return true;
}
bool L3_FilterMACD(bool isBuy)
{
   if(!L3_UseMACDFilter) return true;
   double m = GetBufIdx(L3_hMACD, 0, 1), s = GetBufIdx(L3_hMACD, 1, 1);
   if(m == EMPTY_VALUE || s == EMPTY_VALUE) return false;
   bool ok = isBuy ? (m > s) : (m < s);
   if(L3_MACDRequireZero) ok = ok && (isBuy ? (m > 0) : (m < 0));
   return ok;
}
int L3_MTFDir(int hF, int hS, ENUM_TIMEFRAMES tf)
{
   double f = GetBuf(hF, 1), s = GetBuf(hS, 1);
   double c = iClose(_Symbol, tf, 1);
   if(f == EMPTY_VALUE || s == EMPTY_VALUE) return 0;
   if(f > s && c > f) return 1;
   if(f < s && c < f) return -1;
   return 0;
}
bool L3_FilterMTF(bool isBuy)
{
   int need = isBuy ? 1 : -1;
   if(L3_UseM30Filter && L3_MTFDir(L3_hM30F, L3_hM30S, PERIOD_M30) != need) return false;
   if(L3_UseH1Filter  && L3_MTFDir(L3_hH1F,  L3_hH1S,  PERIOD_H1 ) != need) return false;
   return true;
}

SignalResult L3_Detect()
{
   SignalResult r; r.valid=false; r.dir=0; r.score=0; r.slPrice=0; r.lotSize=0;
   if(!Inp_EnableL3) return r;

   double emaF1 = GetBuf(L3_hEMAFast, 1);
   double emaS1 = GetBuf(L3_hEMASlow, 1);
   double atr1  = GetBuf(L3_hATR, 1);
   if(emaF1 == EMPTY_VALUE || emaS1 == EMPTY_VALUE || atr1 == EMPTY_VALUE || atr1 <= 0) return r;

   // ATR regime
   if(L3_UseATRRegime && atr1 / _Point < L3_ATRMinPoints) return r;
   if(L3_MinEMADistPts > 0 && MathAbs(emaF1 - emaS1) / _Point < L3_MinEMADistPts) return r;
   if(L3_MaxSpreadPts > 0 && SymbolInfoInteger(_Symbol, SYMBOL_SPREAD) > L3_MaxSpreadPts) return r;

   double o1 = iOpen(_Symbol, PERIOD_M5, 1), c1 = iClose(_Symbol, PERIOD_M5, 1);
   double h1 = iHigh(_Symbol, PERIOD_M5, 1), l1 = iLow (_Symbol, PERIOD_M5, 1);
   double range = h1 - l1;
   if(range <= 0) return r;
   double bodyPct = MathAbs(c1 - o1) / range;
   if(bodyPct < L3_BodyRatio) return r;
   if(L3_UseATRFilter && range < atr1 * L3_ATRMultiplier) return r;

   int hiIdx = iHighest(_Symbol, PERIOD_M5, MODE_HIGH, L3_BreakoutBars, 2);
   int loIdx = iLowest (_Symbol, PERIOD_M5, MODE_LOW,  L3_BreakoutBars, 2);
   if(hiIdx < 0 || loIdx < 0) return r;
   double hh = iHigh(_Symbol, PERIOD_M5, hiIdx);
   double ll = iLow (_Symbol, PERIOD_M5, loIdx);

   bool trendUp = (emaF1 > emaS1) && (c1 > emaF1);
   bool trendDn = (emaF1 < emaS1) && (c1 < emaF1);
   bool breakUp = (c1 > hh);
   bool breakDn = (c1 < ll);

   int dir = 0;
   if(trendUp && breakUp) dir = 1;
   else if(trendDn && breakDn) dir = -1;
   else return r;

   if(!L3_FilterADX(dir==1) || !L3_FilterMACD(dir==1) || !L3_FilterMTF(dir==1)) return r;

   double sl;
   if(dir == 1)
   {
      int idx = iLowest(_Symbol, PERIOD_M5, MODE_LOW, L3_SwingBars, 1);
      double sw = (idx>=0) ? iLow(_Symbol, PERIOD_M5, idx) : c1 - L3_MaxSLPoints*_Point;
      sl = sw - L3_SLBufferPoints * _Point;
   }
   else
   {
      int idx = iHighest(_Symbol, PERIOD_M5, MODE_HIGH, L3_SwingBars, 1);
      double sw = (idx>=0) ? iHigh(_Symbol, PERIOD_M5, idx) : c1 + L3_MaxSLPoints*_Point;
      sl = sw + L3_SLBufferPoints * _Point;
   }
   double px = (dir == 1) ? SymbolInfoDouble(_Symbol, SYMBOL_ASK) : SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double slDist = MathAbs(px - sl);
   if(slDist > L3_MaxSLPoints * _Point) { slDist = L3_MaxSLPoints * _Point; sl = (dir==1) ? px - slDist : px + slDist; }
   if(slDist <= 0) return r;

   double lot = CalcLotByRisk(slDist, L3_MaxLot);
   if(lot <= 0) return r;

   double score = 0;
   if(L3_UseM30Filter && L3_MTFDir(L3_hM30F, L3_hM30S, PERIOD_M30) == dir) score += 1.5;
   if(L3_UseH1Filter  && L3_MTFDir(L3_hH1F,  L3_hH1S,  PERIOD_H1 ) == dir) score += 1.5;
   double _adxV = GetBufIdx(L3_hADX, 0, 1);
   if(_adxV != EMPTY_VALUE)
   {
      if(_adxV >= 40)      score += 2.5;
      else if(_adxV >= 30) score += 2.0;
      else if(_adxV >= 25) score += 1.5;
      else if(_adxV >= 20) score += 1.0;
      else                  score += 0.5;
   }
   double _macd = GetBufIdx(L3_hMACD, 0, 1), _sig = GetBufIdx(L3_hMACD, 1, 1);
   if(_macd != EMPTY_VALUE && _sig != EMPTY_VALUE)
   {
      double divPts = MathAbs(_macd - _sig) / _Point;
      score += MathMin(divPts / 20.0, 2.0);
   }
   if(L3_ATRMinPoints > 0)
   {
      double atrRatio = (atr1 / _Point) / L3_ATRMinPoints;
      if(atrRatio >= 1.5)      score += 1.5;
      else if(atrRatio >= 1.2) score += 1.0;
      else if(atrRatio >= 1.0) score += 0.5;
   }
   if(L3_MinEMADistPts > 0)
   {
      double emaSep = MathAbs(emaF1 - emaS1) / _Point;
      score += MathMin(emaSep / (L3_MinEMADistPts * 2.0), 1.0);
   }
   if(score > 10.0) score = 10.0;

   r.valid = true; r.dir = dir; r.score = score;
   r.slPrice = sl; r.lotSize = lot;
   return r;
}

bool L3_OpenTrade(SignalResult &s)
{
   double px = (s.dir == 1) ? SymbolInfoDouble(_Symbol, SYMBOL_ASK) : SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double slDist = MathAbs(px - s.slPrice);
   double tp = (s.dir == 1) ? px + slDist * L3_RiskReward : px - slDist * L3_RiskReward;
   s.slPrice = NormalizeDouble(s.slPrice, _Digits);
   tp = NormalizeDouble(tp, _Digits);

   trade.SetExpertMagicNumber(Inp_MagicL3);
   trade.SetDeviationInPoints(30);
   string cmt = "L3_S" + IntegerToString((int)s.score);

   bool ok;
   if(s.dir == 1) ok = trade.Buy(s.lotSize, _Symbol, px, s.slPrice, tp, cmt);
   else           ok = trade.Sell(s.lotSize, _Symbol, px, s.slPrice, tp, cmt);

   if(ok && !Inp_FastBacktest)
      PrintFormat("[L3-%s] lot=%.2f @%.5f SL=%.5f TP=%.5f score=%.0f",
                  s.dir==1?"BUY":"SELL", s.lotSize, px, s.slPrice, tp, s.score);
   return ok;
}

void L3_Manage()
{
   for(int i = PositionsTotal()-1; i >= 0; i--)
   {
      ulong t = PositionGetTicket(i);
      if(!PositionSelectByTicket(t)) continue;
      if(PositionGetInteger(POSITION_MAGIC) != (long)Inp_MagicL3) continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;

      long type = PositionGetInteger(POSITION_TYPE);
      double entry = PositionGetDouble(POSITION_PRICE_OPEN);
      double curSL = PositionGetDouble(POSITION_SL);
      double curTP = PositionGetDouble(POSITION_TP);

      if(L3_UseBEMove)
      {
         if(type == POSITION_TYPE_BUY)
         {
            double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
            if((bid - entry)/_Point >= L3_BEActivatePts)
            {
               double newSL = NormalizeDouble(entry + L3_BEOffsetPts * _Point, _Digits);
               if(newSL > curSL) trade.PositionModify(t, newSL, curTP);
            }
         }
         else
         {
            double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
            if((entry - ask)/_Point >= L3_BEActivatePts)
            {
               double newSL = NormalizeDouble(entry - L3_BEOffsetPts * _Point, _Digits);
               if(curSL <= 0 || newSL < curSL) trade.PositionModify(t, newSL, curTP);
            }
         }
      }
      if(L3_UseTrailStop)
      {
         if(type == POSITION_TYPE_BUY)
         {
            double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
            if((bid - entry)/_Point >= L3_TrailActivatePts)
            {
               double newSL = NormalizeDouble(bid - L3_TrailDistancePts * _Point, _Digits);
               if(newSL > curSL) trade.PositionModify(t, newSL, curTP);
            }
         }
         else
         {
            double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
            if((entry - ask)/_Point >= L3_TrailActivatePts)
            {
               double newSL = NormalizeDouble(ask + L3_TrailDistancePts * _Point, _Digits);
               if(curSL <= 0 || newSL < curSL) trade.PositionModify(t, newSL, curTP);
            }
         }
      }
      if(L3_CloseOnH1Reverse)
      {
         int h1d = L3_MTFDir(L3_hH1F, L3_hH1S, PERIOD_H1);
         if(type == POSITION_TYPE_BUY && h1d == -1) trade.PositionClose(t);
         else if(type == POSITION_TYPE_SELL && h1d == 1) trade.PositionClose(t);
      }
   }
}


//===================================================================
//                    MARKET REGIME EVALUATOR
//===================================================================
// Đánh giá thị trường hiện tại → chấm điểm 0-10 mức phù hợp cho từng logic
// Master orchestrate = signal_score × market_fit / 10 = final ranking

int h_MR_ADX  = INVALID_HANDLE;   // ADX 14 M5
int h_MR_ATR  = INVALID_HANDLE;   // ATR 20 M5
int h_MR_EMAF = INVALID_HANDLE;   // EMA 20 M5 (generic fast)
int h_MR_EMAS = INVALID_HANDLE;   // EMA 50 M5 (generic slow)
int h_MR_M30F = INVALID_HANDLE;   // M30 EMA 34
int h_MR_M30S = INVALID_HANDLE;   // M30 EMA 89
int h_MR_H1F  = INVALID_HANDLE;   // H1 EMA 34
int h_MR_H1S  = INVALID_HANDLE;   // H1 EMA 89

struct MarketRegime
{
   double adx;         // ADX value M5
   double atrPts;      // ATR M5 (points)
   double atrRatio;    // ATR now / ATR 50-bar avg (>1 = expanding)
   int    mtfAlign;    // 0/1/2 khung MTF đồng thuận (M30+H1)
   int    mtfDir;      // 1=bull, -1=bear, 0=neutral
   double emaSepATR;   // EMA fast-slow separation tính theo ATR
   double pullDistATR; // Khoảng cách giá đến EMA21 (L2's pullback zone) tính theo ATR
};

// Global cache for panel display
MarketRegime g_regime;
double g_fit1 = 0, g_fit2 = 0, g_fit3 = 0;
double g_final1 = 0, g_final2 = 0, g_final3 = 0;
int    g_lastPickedLogic = 0;
datetime g_lastPickedTime = 0;

bool MR_Init()
{
   h_MR_ADX  = iADX(_Symbol, PERIOD_M5, 14);
   h_MR_ATR  = iATR(_Symbol, PERIOD_M5, 20);
   h_MR_EMAF = iMA (_Symbol, PERIOD_M5, 20, 0, MODE_EMA, PRICE_CLOSE);
   h_MR_EMAS = iMA (_Symbol, PERIOD_M5, 50, 0, MODE_EMA, PRICE_CLOSE);
   h_MR_M30F = iMA (_Symbol, PERIOD_M30, 34, 0, MODE_EMA, PRICE_CLOSE);
   h_MR_M30S = iMA (_Symbol, PERIOD_M30, 89, 0, MODE_EMA, PRICE_CLOSE);
   h_MR_H1F  = iMA (_Symbol, PERIOD_H1,  34, 0, MODE_EMA, PRICE_CLOSE);
   h_MR_H1S  = iMA (_Symbol, PERIOD_H1,  89, 0, MODE_EMA, PRICE_CLOSE);
   return h_MR_ADX!=INVALID_HANDLE && h_MR_ATR!=INVALID_HANDLE &&
          h_MR_EMAF!=INVALID_HANDLE && h_MR_EMAS!=INVALID_HANDLE &&
          h_MR_M30F!=INVALID_HANDLE && h_MR_M30S!=INVALID_HANDLE &&
          h_MR_H1F!=INVALID_HANDLE && h_MR_H1S!=INVALID_HANDLE;
}
void MR_Deinit()
{
   if(h_MR_ADX !=INVALID_HANDLE) IndicatorRelease(h_MR_ADX);
   if(h_MR_ATR !=INVALID_HANDLE) IndicatorRelease(h_MR_ATR);
   if(h_MR_EMAF!=INVALID_HANDLE) IndicatorRelease(h_MR_EMAF);
   if(h_MR_EMAS!=INVALID_HANDLE) IndicatorRelease(h_MR_EMAS);
   if(h_MR_M30F!=INVALID_HANDLE) IndicatorRelease(h_MR_M30F);
   if(h_MR_M30S!=INVALID_HANDLE) IndicatorRelease(h_MR_M30S);
   if(h_MR_H1F !=INVALID_HANDLE) IndicatorRelease(h_MR_H1F);
   if(h_MR_H1S !=INVALID_HANDLE) IndicatorRelease(h_MR_H1S);
}

int MR_MTFDir(int hF, int hS, ENUM_TIMEFRAMES tf)
{
   double f = GetBuf(hF, 1), s = GetBuf(hS, 1);
   double c = iClose(_Symbol, tf, 1);
   if(f == EMPTY_VALUE || s == EMPTY_VALUE) return 0;
   if(f > s && c > f) return 1;
   if(f < s && c < f) return -1;
   return 0;
}

MarketRegime GetMarketRegime()
{
   MarketRegime r;
   r.adx = GetBufIdx(h_MR_ADX, 0, 1);
   double atrNow = GetBuf(h_MR_ATR, 1);
   r.atrPts = (atrNow != EMPTY_VALUE) ? atrNow / _Point : 0;

   // ATR expansion vs 50-bar avg
   double atrSum = 0; int cnt = 0;
   for(int i=1; i<=50; i++)
   {
      double a = GetBuf(h_MR_ATR, i);
      if(a != EMPTY_VALUE && a > 0) { atrSum += a; cnt++; }
   }
   double atrAvg = (cnt > 0) ? atrSum / cnt : atrNow;
   r.atrRatio = (atrAvg > 0 && atrNow != EMPTY_VALUE) ? atrNow / atrAvg : 1.0;

   // EMA separation in ATR
   double f = GetBuf(h_MR_EMAF, 1), s = GetBuf(h_MR_EMAS, 1);
   r.emaSepATR = (atrNow > 0 && f != EMPTY_VALUE && s != EMPTY_VALUE) ? MathAbs(f - s) / atrNow : 0;

   // MTF alignment
   int m30 = MR_MTFDir(h_MR_M30F, h_MR_M30S, PERIOD_M30);
   int h1  = MR_MTFDir(h_MR_H1F,  h_MR_H1S,  PERIOD_H1);
   if(m30 != 0 && m30 == h1)      { r.mtfAlign = 2; r.mtfDir = m30; }
   else if(m30 != 0 && h1 == 0)   { r.mtfAlign = 1; r.mtfDir = m30; }
   else if(h1  != 0 && m30 == 0)  { r.mtfAlign = 1; r.mtfDir = h1;  }
   else if(m30 != 0 && h1 != 0 && m30 != h1) { r.mtfAlign = 0; r.mtfDir = 0; }
   else                            { r.mtfAlign = 0; r.mtfDir = 0; }

   // Pullback distance (dùng L2's pullEma nếu đang chạy, không thì skip)
   if(L2_hPull != INVALID_HANDLE)
   {
      double pE = GetBuf(L2_hPull, 1);
      double c1 = iClose(_Symbol, PERIOD_M5, 1);
      r.pullDistATR = (atrNow > 0 && pE != EMPTY_VALUE) ? MathAbs(c1 - pE) / atrNow : 99;
   }
   else r.pullDistATR = 99;

   return r;
}

//=== MARKET FIT SCORING (0-10 per logic) ===

// L1 Scalp: ADX cao (25-45 sweet), MTF cả 2 khung, ATR mở rộng vừa phải
double MarketFit_L1(MarketRegime &r)
{
   double fit = 0;
   // ADX band (max 4 pts)
   if(r.adx >= 25 && r.adx <= 45) fit += 4;
   else if(r.adx > 45)             fit += 3;
   else if(r.adx >= 20)            fit += 2;
   else if(r.adx >= 15)            fit += 1;
   // MTF alignment (max 3 pts)
   fit += r.mtfAlign * 1.5;
   // ATR expansion vừa phải (max 2 pts)
   if(r.atrRatio >= 0.9 && r.atrRatio <= 1.4) fit += 2;
   else if(r.atrRatio > 1.4 && r.atrRatio <= 1.8) fit += 1;
   // EMA sep vừa (max 1 pt)
   if(r.emaSepATR >= 0.5 && r.emaSepATR <= 2.5) fit += 1;
   return MathMin(fit, 10);
}

// L2 Pullback: ADX trung bình (20-32), giá đang gần EMA21, MTF còn giữ
double MarketFit_L2(MarketRegime &r)
{
   double fit = 0;
   // ADX moderate (max 4 pts) — quá mạnh thì không có pullback
   if(r.adx >= 20 && r.adx <= 32)       fit += 4;
   else if(r.adx >= 18 && r.adx <= 40)  fit += 2;
   else if(r.adx >= 15)                 fit += 1;
   // MTF (max 3 pts)
   fit += r.mtfAlign * 1.5;
   // Pullback zone: gần EMA21 (max 2 pts)
   if(r.pullDistATR <= 0.8)        fit += 2;
   else if(r.pullDistATR <= 1.5)   fit += 1;
   // ATR không quá bùng nổ (max 1 pt) — quá bùng nổ = không có pullback sạch
   if(r.atrRatio <= 1.3) fit += 1;
   return MathMin(fit, 10);
}

// L3 Swing: ADX cao (30+), EMA sep rộng, ATR đang mở rộng — cần "phòng" cho RR 3.1
double MarketFit_L3(MarketRegime &r)
{
   double fit = 0;
   // ADX high (max 4 pts)
   if(r.adx >= 30)      fit += 4;
   else if(r.adx >= 25) fit += 2;
   else if(r.adx >= 20) fit += 1;
   // MTF critical (max 3 pts)
   if(r.mtfAlign == 2)      fit += 3;
   else if(r.mtfAlign == 1) fit += 1;
   // EMA sep wide (max 2 pts)
   if(r.emaSepATR >= 1.5)      fit += 2;
   else if(r.emaSepATR >= 0.8) fit += 1;
   // ATR expanding (max 1 pt) — cần space cho RR 3.1
   if(r.atrRatio >= 1.1) fit += 1;
   return MathMin(fit, 10);
}

//===================================================================
//                    MASTER ORCHESTRATION
//===================================================================
// Trên mỗi nến M5 mới:
// 1. Nếu đang trong cooldown → skip toàn bộ (mọi logic không được vào lệnh)
// 2. Query cả 3 logic → thu thập signals valid
// 3. Nếu >= 2 signals → chọn cái có score cao nhất (tie → L1 > L2 > L3)
// 4. Open trade → set cooldown g_cooldownUntil = TimeCurrent() + 30 min

void MasterOrchestrate()
{
   // Update regime cache mỗi bar (cho panel + scoring)
   g_regime = GetMarketRegime();
   g_fit1 = MarketFit_L1(g_regime);
   g_fit2 = MarketFit_L2(g_regime);
   g_fit3 = MarketFit_L3(g_regime);

   // Cap max positions
   if(CountAllEAPositions() >= Inp_MaxPositions) return;
   // Cooldown
   if(g_cooldownUntil > 0 && TimeCurrent() < g_cooldownUntil) return;

   // Query all 3 logics
   SignalResult r1 = L1_Detect();
   SignalResult r2 = L2_Detect();
   SignalResult r3 = L3_Detect();

   // Final score = signal quality × market fit / 10  (đồng bộ hoá 0-10)
   g_final1 = r1.valid ? (r1.score * g_fit1 / 10.0) : 0;
   g_final2 = r2.valid ? (r2.score * g_fit2 / 10.0) : 0;
   g_final3 = r3.valid ? (r3.score * g_fit3 / 10.0) : 0;

   int    bestLogic = 0;
   double bestFinal = -1;
   if(r1.valid && g_final1 > bestFinal) { bestFinal = g_final1; bestLogic = 1; }
   if(r2.valid && g_final2 > bestFinal) { bestFinal = g_final2; bestLogic = 2; }
   if(r3.valid && g_final3 > bestFinal) { bestFinal = g_final3; bestLogic = 3; }
   if(bestLogic == 0) return;

   // MIN THRESHOLD GATE: nếu điểm final tốt nhất vẫn dưới ngưỡng → SKIP
   if(bestFinal < Inp_MinFinalScore)
   {
      if(!Inp_FastBacktest)
         PrintFormat("[SKIP-WEAK] L%d best final=%.2f < ngưỡng %.2f → không vào lệnh",
                     bestLogic, bestFinal, Inp_MinFinalScore);
      return;
   }

   bool ok = false;
   if(bestLogic == 1)      ok = L1_OpenTrade(r1);
   else if(bestLogic == 2) ok = L2_OpenTrade(r2);
   else if(bestLogic == 3) ok = L3_OpenTrade(r3);

   if(ok)
   {
      g_lastEntryTime   = TimeCurrent();
      g_cooldownUntil   = TimeCurrent() + Inp_CooldownMinutes * 60;
      g_lastPickedLogic = bestLogic;
      g_lastPickedTime  = TimeCurrent();
      if(!Inp_FastBacktest)
         PrintFormat("[MASTER] L%d picked | final=%.2f (sig=%.1f × fit=%.1f/10) | ADX=%.1f MTF=%d/2 ATR%%=%.2f",
                     bestLogic, bestFinal,
                     (bestLogic==1?r1.score:bestLogic==2?r2.score:r3.score),
                     (bestLogic==1?g_fit1:bestLogic==2?g_fit2:g_fit3),
                     g_regime.adx, g_regime.mtfAlign, g_regime.atrRatio);
   }
}

//===================================================================
//                    ON INIT / DEINIT / TICK
//===================================================================
int OnInit()
{
   if(_Period != PERIOD_M5)
   {
      Alert("EA CHỈ chạy ở khung M5. Liên hệ ", LICENSE_CONTACT);
      return INIT_FAILED;
   }

   if(!MR_Init()) { Print("[INIT] Market Regime FAIL"); return INIT_FAILED; }
   if(Inp_EnableL1 && !L1_Init()) { Print("[INIT] L1 FAIL"); return INIT_FAILED; }
   if(Inp_EnableL2 && !L2_Init()) { Print("[INIT] L2 FAIL"); return INIT_FAILED; }
   if(Inp_EnableL3 && !L3_Init()) { Print("[INIT] L3 FAIL"); return INIT_FAILED; }

   CreateWatermark();
   EventSetTimer(1);
   PrintFormat("[INIT] Combo 3-Logic EA | L1=%s L2=%s L3=%s | Cooldown=%dmin",
               Inp_EnableL1?"ON":"OFF", Inp_EnableL2?"ON":"OFF", Inp_EnableL3?"ON":"OFF",
               Inp_CooldownMinutes);
   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
   EventKillTimer();
   Comment("");
   ObjectDelete(0, EA_WM_NAME);
   MR_Deinit(); L1_Deinit(); L2_Deinit(); L3_Deinit();
}

void OnTick()
{
   if(_Period != PERIOD_M5) return;

   // Each logic manages its own positions
   if(Inp_EnableL1) L1_Manage();
   if(Inp_EnableL2) L2_Manage();
   if(Inp_EnableL3) L3_Manage();

   // Only orchestrate on new M5 bar
   if(!IsNewBar()) { UpdatePanel(); return; }

   MasterOrchestrate();
   UpdatePanel();
}

//=== OnTradeTransaction: track stats per logic ===
void OnTradeTransaction(const MqlTradeTransaction &trans, const MqlTradeRequest &req, const MqlTradeResult &res)
{
   if(trans.type != TRADE_TRANSACTION_DEAL_ADD) return;
   if(!HistoryDealSelect(trans.deal)) return;
   long magic = HistoryDealGetInteger(trans.deal, DEAL_MAGIC);
   if(HistoryDealGetString(trans.deal, DEAL_SYMBOL) != _Symbol) return;
   if(magic != (long)Inp_MagicL1 && magic != (long)Inp_MagicL2 && magic != (long)Inp_MagicL3) return;

   ENUM_DEAL_ENTRY entry = (ENUM_DEAL_ENTRY)HistoryDealGetInteger(trans.deal, DEAL_ENTRY);
   ulong posId = (ulong)HistoryDealGetInteger(trans.deal, DEAL_POSITION_ID);

   if(entry == DEAL_ENTRY_IN)
   {
      double vol = HistoryDealGetDouble(trans.deal, DEAL_VOLUME);
      if(magic == (long)Inp_MagicL2)
         GlobalVariableSet("L2_INITVOL_" + IntegerToString(posId), vol);
      return;
   }
   if(entry != DEAL_ENTRY_OUT && entry != DEAL_ENTRY_INOUT) return;

   double pnl = HistoryDealGetDouble(trans.deal, DEAL_PROFIT)
              + HistoryDealGetDouble(trans.deal, DEAL_SWAP)
              + HistoryDealGetDouble(trans.deal, DEAL_COMMISSION);

   if(pnl > 0) s_grossProfit += pnl; else s_grossLoss += -pnl;

   if(magic == (long)Inp_MagicL1) { s_L1_trades++; s_L1_net += pnl; if(pnl > 0) s_L1_wins++; }
   else if(magic == (long)Inp_MagicL2) { s_L2_trades++; s_L2_net += pnl; if(pnl > 0) s_L2_wins++; }
   else if(magic == (long)Inp_MagicL3) { s_L3_trades++; s_L3_net += pnl; if(pnl > 0) s_L3_wins++; }

   if(!PositionSelectByTicket(posId) && magic == (long)Inp_MagicL2)
   {
      string sT = IntegerToString(posId);
      GlobalVariableDel("L2_INITVOL_" + sT);
      GlobalVariableDel("L2_TP1_"     + sT);
      GlobalVariableDel("L2_TP2_"     + sT);
      GlobalVariableDel("L2_TP1DONE_" + sT);
   }
}

//=== Panel + Timer ===
void UpdatePanel()
{
   if(Inp_FastBacktest) { Comment(""); return; }

   double wr1 = s_L1_trades > 0 ? (double)s_L1_wins / s_L1_trades * 100.0 : 0;
   double wr2 = s_L2_trades > 0 ? (double)s_L2_wins / s_L2_trades * 100.0 : 0;
   double wr3 = s_L3_trades > 0 ? (double)s_L3_wins / s_L3_trades * 100.0 : 0;
   double netAll = s_grossProfit - s_grossLoss;
   double pf = s_grossLoss > 0 ? s_grossProfit / s_grossLoss : 0;

   string cdStatus;
   if(g_cooldownUntil > TimeCurrent())
   {
      int secLeft = (int)(g_cooldownUntil - TimeCurrent());
      cdStatus = StringFormat("COOLDOWN còn %d:%02d", secLeft/60, secLeft%60);
   }
   else cdStatus = "SẴN SÀNG";

   string mtfTxt = (g_regime.mtfDir == 1) ? "BULL" : (g_regime.mtfDir == -1) ? "BEAR" : "MIX";
   string lastPick = (g_lastPickedLogic > 0) ?
      StringFormat("L%d @ %s", g_lastPickedLogic, TimeToString(g_lastPickedTime, TIME_MINUTES)) : "—";

   string txt = "═══ COMBO 3-LOGIC EA + MARKET REGIME ═══\n";
   txt += StringFormat("Regime: ADX=%.1f | ATR=%.0fpt (ratio %.2f) | MTF=%d/2 %s | EMAsep=%.1fATR\n",
                       g_regime.adx, g_regime.atrPts, g_regime.atrRatio,
                       g_regime.mtfAlign, mtfTxt, g_regime.emaSepATR);
   txt += StringFormat("Fit scores: L1=%.1f  L2=%.1f  L3=%.1f  (0-10, cao=phù hợp)\n",
                       g_fit1, g_fit2, g_fit3);
   double _bestF = MathMax(g_final1, MathMax(g_final2, g_final3));
   string _passTxt = (_bestF >= Inp_MinFinalScore) ? "✓ PASS" : "✗ dưới ngưỡng";
   txt += StringFormat("Final rank: L1=%.2f  L2=%.2f  L3=%.2f  (sig × fit / 10)\n",
                       g_final1, g_final2, g_final3);
   txt += StringFormat("Ngưỡng tối thiểu: %.2f  |  Best hiện tại: %.2f  %s\n",
                       Inp_MinFinalScore, _bestF, _passTxt);
   txt += StringFormat("Cooldown: %s (%d min) | Last pick: %s\n",
                       cdStatus, Inp_CooldownMinutes, lastPick);
   txt += "─────\n";
   txt += StringFormat("L1 Scalp   %s: %d lệnh, WR %.1f%%, Net %+.2f\n",
                       Inp_EnableL1?"[ON]":"[OFF]", s_L1_trades, wr1, s_L1_net);
   txt += StringFormat("L2 Pullback%s: %d lệnh, WR %.1f%%, Net %+.2f\n",
                       Inp_EnableL2?"[ON]":"[OFF]", s_L2_trades, wr2, s_L2_net);
   txt += StringFormat("L3 Swing   %s: %d lệnh, WR %.1f%%, Net %+.2f\n",
                       Inp_EnableL3?"[ON]":"[OFF]", s_L3_trades, wr3, s_L3_net);
   txt += StringFormat("Tổng: Net %+.2f  |  PF %.2f  |  Vị thế mở: %d/%d",
                       netAll, pf, CountAllEAPositions(), Inp_MaxPositions);
   Comment(txt);
}

void OnTimer()
{
   if(ObjectFind(0, EA_WM_NAME) < 0) CreateWatermark();
   UpdatePanel();
}

void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
{
   if(id == CHARTEVENT_OBJECT_DELETE && sparam == EA_WM_NAME) CreateWatermark();
}
//+------------------------------------------------------------------+
