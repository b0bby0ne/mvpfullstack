//+------------------------------------------------------------------+
//|                   IndiSingle_BobVolman_H1_M5.mq5                 |
//|  H1 market context with Bob Volman-inspired M5 price action:     |
//|  DDB, FB, SB, BB, RB, IRB and ARB.                               |
//|  Wyckoff, Elliott and trend regime remain anchored to H1.        |
//|                                                                  |
//|  IMPORTANT                                                       |
//|  - This is a deterministic adaptation, not a verbatim copy of    |
//|    Bob Volman's discretionary methodology.                       |
//|  - One ranked pending signal; multiple EA positions are allowed. |
//|  - Initial SL is always outside the signal candle.               |
//|  - 1R defaults to 1% of account equity through position sizing.  |
//+------------------------------------------------------------------+
#property copyright "IndiSingle - H1 context / Bob Volman M5"
#property version   "2.02"
#property strict

#include <Trade\Trade.mqh>

CTrade trade;

enum ENUM_BV_SETUP
{
   BV_NONE = 0,
   BV_DDB  = 1, // Double Doji Break
   BV_FB   = 2, // First Break
   BV_SB   = 3, // Second Break
   BV_BB   = 4, // Block Break
   BV_RB   = 5, // Range Break
   BV_IRB  = 6, // Inside Range Break
   BV_ARB  = 7  // Advanced Range Break
};

enum ENUM_WYCKOFF_FILTER_MODE
{
   WY_FILTER_OFF    = 0, // Khong loc Wyckoff
   WY_FILTER_BIAS   = 1, // Event gan nhat phai dong thuan huong lenh
   WY_FILTER_STRICT = 2  // Chi nhan event phu hop voi nhom setup
};

enum ENUM_WYCKOFF_EVENT
{
   WY_NONE      = 0,
   WY_SPRING    = 1,
   WY_UPTHRUST  = 2,
   WY_SOS       = 3,
   WY_SOW       = 4,
   WY_TEST      = 5,
   WY_LPS       = 6,
   WY_LPSY      = 7
};

enum ENUM_INVERSE_FAILURE_TRIGGER
{
   INVERSE_AT_MAIN_SL       = 0, // Control: virtual main trade reaches its full SL
   INVERSE_ON_M5_CLOSE_BACK = 1  // Early failure: M5 closes back through the breakout trigger
};

enum ENUM_INDEPENDENT_INVERSE_SETUP
{
   IND_INV_NONE       = 0,
   IND_INV_NO_ENTRY   = 1,
   IND_INV_ENGULFED   = 2,
   IND_INV_EMA_ENGULF = 3
};

enum ENUM_IMBALANCE_FILTER_MODE
{
   IMB_FILTER_OFF         = 0,
   IMB_REQUIRE_M5_ALIGNED = 1
};

enum ENUM_BB_STRUCTURE_MODE
{
   BB_STRUCTURE_OFF                       = 0,
   BB_STRUCTURE_IMBALANCE_ONLY            = 1,
   BB_STRUCTURE_IMBALANCE_IMPULSE         = 2,
   BB_STRUCTURE_IMBALANCE_LATE_WYCKOFF    = 3,
   BB_STRUCTURE_IMBALANCE_IMPULSE_OR_WY   = 4
};

struct WyckoffContext
{
   bool                 valid;
   ENUM_WYCKOFF_EVENT   event;
   ENUM_WYCKOFF_EVENT   primary_event;
   int                  bias;
   datetime             event_time;
   int                  age_bars;
   double               level;
   double               score;
};

// Snapshot is frozen when a setup is detected.  It is diagnostic context,
// not a discretionary Elliott-wave trading signal.
struct MarketContextSnapshot
{
   bool   valid;
   string trend_24;
   string trend_72;
   string trend_240;
   double slope_24_atr;
   double r2_24;
   double slope_72_atr;
   double r2_72;
   double slope_240_atr;
   double r2_240;
   string transition_state;
   string volatility_state;
   double volatility_ratio;
   string activity_state;
   double activity_ratio;
   double range_position_240;
   string location_state;
   string wyckoff_phase;
   string elliott_phase;
   string elliott_alignment;
   int    confluence_score;
   string confluence_tier;
};

struct SetupCandidate
{
   bool          valid;
   ENUM_BV_SETUP type;
   int           direction;   // 1 = BUY, -1 = SELL
   datetime      signal_time;
   double        trigger;
   double        stop_loss;
   double        score;
   string        reason;
   ENUM_WYCKOFF_EVENT wyckoff_event;
   MarketContextSnapshot context;
   datetime      m5_signal_time;
   double        m5_signal_open;
   double        m5_signal_high;
   double        m5_signal_low;
   double        m5_signal_close;
   double        m5_atr;
   double        m5_body_ratio;
   int           m5_wait_bars;
};

//--- General execution
input group "01. CHUNG | H1 context, M5 setup và rủi ro"
input ulong  Inp_MagicNumber           = 20261008; // Magic riêng của EA H1-context/M5-setup
input bool   Inp_AllowBuy              = true;     // Cho phép BUY
input bool   Inp_AllowSell             = true;     // Cho phép SELL
input double Inp_RiskPercent           = 1.0;      // 1R = % equity mất nếu chạm SL
input double Inp_TargetRR              = 2.25;     // TP = số R; tối ưu Net Profit trên history 2023-2026
input int    Inp_EntryExpiryBars       = 3;        // Hủy setup nếu chưa khớp sau N nến M5
input int    Inp_CooldownBars          = 0;        // Số nến M5 nghỉ sau entry; 0 = nhận setup hợp lệ kế tiếp
input bool   Inp_AllowMultiplePositions = true;    // Giữ nhiều vị thế khi có setup mới hợp lệ
input int    Inp_MaxOpenPositions       = 0;        // Giới hạn vị thế EA; 0 = không giới hạn
input int    Inp_MaxSpreadPoints       = 500;      // Spread tuyệt đối tối đa; 0 = tắt
input double Inp_MaxSpreadToRiskPct    = 15.0;     // Spread tối đa theo % khoảng Entry-SL
input bool   Inp_DrawAnnotations       = true;     // Ghi setup và entry lên chart
input bool   Inp_ShowStatusPanel       = true;     // Hiện trạng thái bằng Comment()

input group "01B. INVERSE RESEARCH | Vào ngược sau khi setup chính chạm SL ảo"
input bool   Inp_EnableInverseFailureMode = false; // false giữ nguyên hành vi release v1.76
input double Inp_InverseTargetRR          = 1.00;  // TP của lệnh inverse theo risk từ failure-entry đến main-entry
input bool   Inp_InverseAllowBuy          = true;  // Cho phép lệnh inverse BUY (nguồn là setup SELL thất bại)
input bool   Inp_InverseAllowSell         = true;  // Cho phép lệnh inverse SELL (nguồn là setup BUY thất bại)
input bool   Inp_InverseRejectSpring      = false; // Tránh inverse BUY muộn khi H1 Spring đã phản ánh nhịp tăng
input ENUM_INVERSE_FAILURE_TRIGGER Inp_InverseFailureTrigger = INVERSE_ON_M5_CLOSE_BACK;
input int    Inp_InverseFailureBars       = 3;     // Số M5 bars cho phép xác nhận failed breakout sớm
input double Inp_InverseCloseBufferATR    = 0.00;  // Close-back tối thiểu qua H1 trigger
input bool   Inp_InverseRequireReversalBody = true;// Failed BUY cần nến giảm; failed SELL cần nến tăng
input double Inp_InverseSLBufferATR       = 0.05;  // SL ngoài cực trị confirmation/failure candle

input group "01C. INVERSE ĐỘC LẬP | Accumulation failure M5"
input bool   Inp_EnableIndependentInverse = false; // Chạy song song, không cần setup chính hoặc virtual SL
input double Inp_IndependentRiskPercent   = 1.00;
input bool   Inp_IndInvEnableNoEntry      = false; // Giữ trong code; OFF vì edge discovery âm
input bool   Inp_IndInvEnableEngulfed     = true;
input bool   Inp_IndInvEnableEMAEngulf    = true;  // v1.94: EMAENGULF BUY 08-23 có edge lặp lại OOS/2026
input bool   Inp_IndInvNoEntryAllowBuy    = false;
input bool   Inp_IndInvNoEntryAllowSell   = false;
input bool   Inp_IndInvEngulfAllowBuy     = false; // Strict 2026: BUY WR 50%; SELL được giữ
input bool   Inp_IndInvEngulfAllowSell    = true;
input bool   Inp_IndInvEMAAllowBuy        = true;
input bool   Inp_IndInvEMAAllowSell       = false;
input double Inp_IndInvNoEntryTargetRR    = 0.75;
input double Inp_IndInvEngulfTargetRR     = 1.00;
input double Inp_IndInvEMATargetRR        = 1.00;
input int    Inp_IndInvAccumBars          = 6;
input double Inp_IndInvAccumMinATR        = 0.40;
input double Inp_IndInvAccumMaxATR        = 1.50;
input double Inp_IndInvMinOverlap         = 0.60;
input double Inp_IndInvMinAvgBody         = 0.30; // Loại accumulation doji/noise, cần pressure có thân thực
input double Inp_IndInvMaxAvgBody         = 0.50;
input int    Inp_IndInvMinPressureCloses  = 3;    // Cần cả 3 close gần nhất ép về biên thuận hướng
input double Inp_IndInvPressureZonePct    = 0.40;
input double Inp_IndInvBreakoutBufferATR  = 0.05;
input int    Inp_IndInvNoEntryWaitBars    = 3;
input double Inp_IndInvNoEntryMinBody     = 0.80;
input int    Inp_IndInvEngulfWindowBars   = 2;
input double Inp_IndInvEngulfToleranceATR = 0.05;
input int    Inp_IndInvM5EMAPeriod        = 25;
input double Inp_IndInvEMAMinBody         = 0.50;
input int    Inp_IndInvH1SlopeBars        = 4;
input double Inp_IndInvStopBufferATR      = 0.10;
input double Inp_IndInvMinRiskATR         = 0.50;
input double Inp_IndInvMaxRiskATR         = 3.00;
input int    Inp_IndInvCooldownBars       = 6;
input int    Inp_IndInvNoEntrySessionMask = 2; // 08-15; disabled by default
input int    Inp_IndInvEngulfSessionMask  = 2; // 08-15; real-tick 2026 WR 64.7%
input int    Inp_IndInvEMASessionMask     = 6; // 08-23; BUY only, robust trên OOS 2023-2025 và 2026

//--- Price-action context
input group "02. BỐI CẢNH | EMA, ATR và buffer"
input int    Inp_EMAPeriod             = 25;       // EMA H1 xác định hướng context
input int    Inp_EMASlopeBars          = 4;        // Số nến H1 đo độ dốc EMA
input int    Inp_ATRPeriod             = 14;       // ATR cùng timeframe của context/setup
input double Inp_EntryBufferPoints     = 20;       // Buffer ngoài mức phá vỡ
input double Inp_SLBufferPoints        = 20;       // Buffer ngoài nến tín hiệu
input double Inp_SLBufferATR           = 0.05;     // Buffer SL tối thiểu theo ATR
input double Inp_MaxSignalRangeATR     = 1.25;     // Lọc chặt nến tín hiệu quá lớn

//--- Enable individual setup families
input group "03. SETUP | Bật/tắt từng mô hình"
input bool Inp_EnableDDB = true; // DDB: Double Doji Break
input bool Inp_EnableFB  = true; // FB: First Break
input bool Inp_EnableSB  = true; // SB: Second Break
input bool Inp_EnableBB  = true; // BB: Block Break
input bool Inp_EnableRB  = true; // RB: Range Break
input bool Inp_EnableIRB = false;// IRB mặc định OFF; preset v2.02 bật BUY với context đã validation
input bool Inp_EnableARB = true; // ARB: Advanced Range Break

//--- Pattern thresholds
input group "04. SETUP | Ngưỡng nhận dạng"
input double Inp_DojiBodyRatio         = 0.25; // Thân/range tối đa của doji
input double Inp_MinOverlapRatio       = 0.50; // Overlap tối thiểu của DDB/Block
input double Inp_DDBMinOverlapRatio    = 0.70; // DDB: overlap riêng
input double Inp_BBMinOverlapRatio     = 0.80; // BB: overlap riêng
input int    Inp_MinPullbackBars       = 4;    // FB: số nến pullback tối thiểu
input int    Inp_MaxPullbackBars       = 8;    // FB: số nến pullback tối đa
input int    Inp_BlockBars             = 6;    // BB: số nến tạo block
input double Inp_BlockMaxATR           = 1.00; // BB: chiều cao block tối đa theo ATR
input int    Inp_RangeBars             = 12;   // RB/IRB/ARB: số nến tạo range
input double Inp_RangeMinATR           = 0.80; // Chiều cao range tối thiểu theo ATR
input double Inp_RangeMaxATR           = 2.75; // Chiều cao range tối đa theo ATR
input int    Inp_MinRangeTouches       = 3;    // Lọc range: tối thiểu ba lần chạm mỗi biên
input double Inp_EdgeZonePct           = 0.25; // Vùng áp lực ở mép range
input int    Inp_ARBRangeBars          = 12;   // ARB: range bars riêng
input double Inp_ARBRangeMinATR        = 1.00; // ARB: range tối thiểu riêng
input double Inp_ARBRangeMaxATR        = 3.00; // ARB: range tối đa riêng
input int    Inp_ARBMinRangeTouches    = 2;    // ARB: số lần chạm biên riêng
input double Inp_ARBEdgeZonePct        = 0.20; // ARB: edge zone riêng

input group "04B. SETUP | BB va IRB rieng"
input int    Inp_BBMinPressureBars     = 2;    // BB: directional closes near edge; 0 = off
input double Inp_BBPressureZonePct     = 0.45; // BB: edge zone used to count pressure bars
input double Inp_BBMinSignalBodyRatio  = 0.00; // BB: minimum body/range of latest block bar
input double Inp_SBExtraSLBufferATR    = 0.00; // SB: extra SL room outside signal candle
input double Inp_BBExtraSLBufferATR    = 0.00; // BB: extra SL room outside signal candle
input double Inp_DDBEntryBufferATR     = 0.00; // DDB: v1.60 research baseline; buffer remains testable
input double Inp_SBEntryBufferATR      = 0.025;// SB: MAE/MFE filter for shallow false breakouts
input double Inp_SBMinAttemptBodyRatio = 0.00; // SB: minimum body/range of first break attempt
input double Inp_SBMinSignalCloseZone  = 0.00; // SB: reject pullback close too near adverse edge
input int    Inp_IRBRangeBars          = 12;   // IRB: independent prior-range length
input double Inp_IRBRangeMinATR        = 0.80; // IRB: minimum prior-range height
input double Inp_IRBRangeMaxATR        = 2.75; // IRB: maximum prior-range height
input int    Inp_IRBMinRangeTouches    = 3;    // IRB: touches required at both edges
input double Inp_IRBEdgeZonePct        = 0.25; // IRB: pressure zone at range edge
input double Inp_IRBMaxCandleATR       = 0.90; // IRB: maximum range of either inside bar

//--- Per-setup exits. A value <= 0 falls back to Inp_TargetRR.
input group "05. THOÁT LỆNH | TP riêng theo setup"
input double Inp_DDBTargetRR = 1.00; // DDB TP theo R; ưu tiên win rate
input double Inp_FBTargetRR  = 1.00; // FB TP theo R; ưu tiên win rate
input double Inp_SBTargetRR  = 2.00; // SB TP theo R; 0 = dùng TP chung
input double Inp_BBTargetRR  = 2.25; // BB: cùng win rate, chọn Net Profit cao hơn
input double Inp_RBTargetRR  = 0.75; // RB TP theo R; ưu tiên win rate
input double Inp_IRBTargetRR = 0.75; // IRB TP theo R; mẫu nhỏ
input double Inp_ARBTargetRR = 1.50; // ARB TP theo R; ưu tiên win rate

//--- Setup-specific filters avoid forcing one setup's optimum on all others.
//--- Session mask: 1=00-07, 2=08-15, 4=16-23, 7=all server hours.
input group "06. BỘ LỌC RIÊNG | Expiry, EMA, range nến, hướng và phiên"
input int    Inp_DDBExpiryBars=3; input int Inp_DDBEMASlopeBars=6; input double Inp_DDBMaxSignalATR=0.75; input bool Inp_DDBAllowBuy=true; input bool Inp_DDBAllowSell=true; input int Inp_DDBSessionMask=7;
input int    Inp_FBExpiryBars =3; input int Inp_FBEMASlopeBars =2; input double Inp_FBMaxSignalATR =0.75; input bool Inp_FBAllowBuy =true; input bool Inp_FBAllowSell =true; input int Inp_FBSessionMask =7;
input int    Inp_SBExpiryBars =3; input int Inp_SBEMASlopeBars =2; input double Inp_SBMaxSignalATR =0.75; input bool Inp_SBAllowBuy =true; input bool Inp_SBAllowSell =true; input int Inp_SBSessionMask =7;
input int    Inp_BBExpiryBars =3; input int Inp_BBEMASlopeBars =6; input double Inp_BBMaxSignalATR =1.25; input bool Inp_BBAllowBuy =true; input bool Inp_BBAllowSell =true; input int Inp_BBSessionMask =7;
input int    Inp_RBExpiryBars =3; input int Inp_RBEMASlopeBars =4; input double Inp_RBMaxSignalATR =1.25; input bool Inp_RBAllowBuy =true; input bool Inp_RBAllowSell =true; input int Inp_RBSessionMask =7;
input int    Inp_IRBExpiryBars=3; input int Inp_IRBEMASlopeBars=4; input double Inp_IRBMaxSignalATR=1.25; input bool Inp_IRBAllowBuy=false; input bool Inp_IRBAllowSell=false; input int Inp_IRBSessionMask=7;
input int    Inp_ARBExpiryBars=3; input int Inp_ARBEMASlopeBars=6; input double Inp_ARBMaxSignalATR=1.50; input bool Inp_ARBAllowBuy=true; input bool Inp_ARBAllowSell=true; input int Inp_ARBSessionMask=7;

//--- Optional M5 session matrix per setup and direction.
input group "06B. M5 SESSION | Ma trận riêng BUY/SELL"
input bool Inp_UseDirectionalSessionMasks = true;
input int Inp_DDBBuySessionMask=1; input int Inp_DDBSellSessionMask=3;
input int Inp_FBBuySessionMask =1; input int Inp_FBSellSessionMask =1;
input int Inp_SBBuySessionMask =2; input int Inp_SBSellSessionMask =4;
input int Inp_BBBuySessionMask =7; input int Inp_BBSellSessionMask =7;
input int Inp_RBBuySessionMask =7; input int Inp_RBSellSessionMask =1;
input int Inp_IRBBuySessionMask=0; input int Inp_IRBSellSessionMask=0;
input int Inp_ARBBuySessionMask=2; input int Inp_ARBSellSessionMask=2;

//--- Deterministic Wyckoff context. Tick volume is only a broker-volume proxy.
input group "07. WYCKOFF | Event filter H1"
input ENUM_WYCKOFF_FILTER_MODE Inp_WyckoffFilterMode = WY_FILTER_OFF; // Global filter off; detector vẫn chạy cho telemetry/rule riêng
input int    Inp_WyckoffLookback         = 20;   // Prior range used by Spring/UT/SOS/SOW
input int    Inp_WyckoffValidBars        = 12;   // Event remains valid for N closed H1 bars
input double Inp_WyckoffPenetrationATR   = 0.00; // Minimum Spring/UT excursion beyond range
input double Inp_WyckoffBreakoutATR      = 0.05; // Minimum SOS/SOW close beyond range
input double Inp_WyckoffMinBodyRatio     = 0.40; // SOS/SOW body/range minimum
input double Inp_WyckoffVolumeFactor     = 1.30; // SOS/SOW tick volume versus prior average
input double Inp_WyckoffTestVolumeFactor = 0.85; // Test/LPS volume versus primary event
input double Inp_WyckoffRetestZoneATR    = 0.25; // Retest distance around event level
input bool   Inp_WyckoffAllowSpring       = true; // Permit Spring context
input bool   Inp_WyckoffAllowUpthrust     = false;// Disabled after 2023-2026 validation
input bool   Inp_WyckoffAllowSOS          = true; // Permit Sign of Strength
input bool   Inp_WyckoffAllowSOW          = true; // Permit Sign of Weakness
input bool   Inp_WyckoffAllowTest         = true; // Permit secondary Test
input bool   Inp_WyckoffAllowLPS          = true; // Permit Last Point of Support
input bool   Inp_WyckoffAllowLPSY         = false;// Disabled after 2023-2026 validation
input bool   Inp_DrawWyckoffAnnotations  = true; // Draw latest detected event

//--- Event bit mask uses (1 << ENUM_WYCKOFF_EVENT): Spring=2, UT=4,
//--- SOS=8, SOW=16, Test=32, LPS=64, LPSY=128.
input group "08. WYCKOFF | Matrix theo setup"
input bool   Inp_UseSetupEventMatrix = false;// Event matrix vẫn khả dụng khi bật Wyckoff filter
input int    Inp_DDBWyckoffMask = 120; // SOS + SOW + Test + LPS; exclude Spring
input int    Inp_FBWyckoffMask  = 122; // All globally enabled matching events
input int    Inp_SBWyckoffMask  = 122; // All globally enabled matching events
input int    Inp_BBWyckoffMask  = 120; // Exclude Spring
input int    Inp_RBWyckoffMask  = 122; // Preserve small-sample event coverage
input int    Inp_IRBWyckoffMask = 122; // Spring + SOS + SOW + Test + LPS
input int    Inp_ARBWyckoffMask = 114; // Exclude SOS
input int    Inp_DDBWyckoffMaxAge=12;input double Inp_DDBWyckoffMaxDistanceATR=0.0;
input int    Inp_FBWyckoffMaxAge =12;input double Inp_FBWyckoffMaxDistanceATR =0.0;
input int    Inp_SBWyckoffMaxAge =12;input double Inp_SBWyckoffMaxDistanceATR =0.0;
input int    Inp_BBWyckoffMaxAge =12;input double Inp_BBWyckoffMaxDistanceATR =0.0;
input int    Inp_RBWyckoffMaxAge =12;input double Inp_RBWyckoffMaxDistanceATR =0.0;
input int    Inp_IRBWyckoffMaxAge=12;input double Inp_IRBWyckoffMaxDistanceATR=0.0;
input int    Inp_ARBWyckoffMaxAge=12;input double Inp_ARBWyckoffMaxDistanceATR=0.0;

input group "09. QUAN LY LENH | Hoa von theo setup"
input bool   Inp_SBUseBreakEven       = false; // Disabled: 1.00R/1.25R reduced real-tick Net/PF
input double Inp_SBBreakEvenTriggerR = 1.00;  // SB profit in R before stop modification
input double Inp_SBBreakEvenOffsetR  = 0.00;  // New SB stop = entry + offset R
input bool   Inp_BBUseBreakEven       = false; // Move BB stop after reaching configured R
input double Inp_BBBreakEvenTriggerR = 1.00;  // BB profit in R before stop modification
input double Inp_BBBreakEvenOffsetR  = 0.00;  // New BB stop = entry + offset R

input group "09B. STRUCTURE | Rolling context tai signal"
input bool   Inp_SBBlockCounterTrend72 = true;  // Reject SB against a strong 72H trend
input int    Inp_ContextTrendBars       = 72;    // Closed H1 bars used by rolling price regression
input double Inp_ContextMinTrendR2      = 0.25;  // Minimum regression R-squared for a directional state
input double Inp_ContextMinSlopeATR     = 0.03;  // Minimum absolute slope per bar, normalized by ATR
input int    Inp_ContextFastTrendBars   = 24;    // Fast structure window for transition detection
input int    Inp_ContextLongTrendBars   = 240;   // Long structure window for regime/location
input double Inp_ContextFastMinTrendR2  = 0.20;  // Fast trend minimum R-squared
input double Inp_ContextFastMinSlopeATR = 0.04;  // Fast trend minimum slope in ATR/bar
input double Inp_ContextLongMinTrendR2  = 0.25;  // Long trend minimum R-squared
input double Inp_ContextLongMinSlopeATR = 0.012; // Long trend minimum slope in ATR/bar
input int    Inp_ElliottPivotSpan       = 3;     // Bars on each side needed to confirm a swing
input int    Inp_ElliottLookback        = 160;   // Closed H1 bars searched for alternating pivots
input double Inp_BBMinH1ATRPercent      = 0.50;  // BB only when closed-H1 ATR14/close is at least this %; 0 = off
input bool   Inp_SBUseWyckoffElliottFilter = true;  // Rule riêng đã validation; không áp sang setup khác
input bool   Inp_DDBBlockBuyUpthrustExtended = true; // Reject DDB BUY into H1 UT at upper 240H range edge
input bool   Inp_FBBlockEmergingWait1 = true; // Reject delayed FB while 24H trend is only emerging against 72H range
input bool   Inp_FBBlockBullImpulseSell = true; // Reject FB SELL while confirmed H1 pivots still form a bullish impulse
input bool   Inp_RBBlockBuyUpthrustWeakTransition = true; // Reject RB BUY into UT unless fast H1 structure is established
input bool   Inp_RBBuyBlockLongDown = false; // v1.90 A: reject RB BUY while the 240H regression trend is down
input bool   Inp_RBBuyBlockSOSMid = false; // v1.90 B: reject weak SOS classified in the middle of the 240H range
input bool   Inp_RBBuyBlockNoEventExpanding = false; // v1.90 C: reject eventless RB BUY during expanding H1 activity
input bool   Inp_DDBSellBlockCorrectiveLongUp = false; // Research: reject DDB SELL during Elliott correction inside 240H uptrend
input bool   Inp_DDBSellBlockEarlyEmergingWait0 = false; // v1.88 A: reject 00-07 DDB SELL emerging trend with immediate M5 confirmation
input bool   Inp_DDBSellBlockFullBodyConfirm = false; // v1.93: reject DDB SELL confirmation candles with body >= 75% of range
input bool   Inp_RBBuyBlockMidBodyConfirm = false; // v1.96: reject ambiguous 50-75% body RB BUY confirmations
input bool   Inp_DDBSellBlockMidNoFastContracting = false; // v1.88 B: reject 08-15 DDB SELL with no fast trend and contracting volatility
input bool   Inp_DDBSellBlockMidContinuationNonContracting = false; // v1.88 C: reject 08-15 DDB SELL continuation unless volatility is contracting
input bool   Inp_FBBuyBlockLateBullContext = false; // Research: reject FB BUY after SOS or Bull W3 at extended 240H location
input bool   Inp_RBSellRequireActiveContext = false; // Research: reject RB SELL with no Wyckoff event and normal activity
input bool   Inp_SBBuyBlockBullW4LongUp = false; // Research: reject SB BUY during Bull W4 inside 240H uptrend
input bool   Inp_SBBuyBlockUpthrustExtendedAbnormalVol = false; // v1.89 A: reject UT at extended 240H location outside normal volatility
input bool   Inp_SBBuyBlockSpringEmergingCounter = false; // v1.89 B: reject premature Spring BUY while fast H1 structure is counter
input bool   Inp_SBSellBlockRangeOrDistributionTest = false; // Research: reject weak range/test SB SELL contexts
input bool   Inp_FBBuyBlockCorrectiveNormalActivity = false; // Research: reject FB BUY in corrective wave without activity expansion
input bool   Inp_FBBuyBlockExpandingLongDown = false; // v1.98: reject FB BUY against a falling 72H structure while activity expands
input bool   Inp_SBBuyBlockCounterFastUp = false; // Research: reject SB BUY when bearish impulse conflicts with fast uptrend
input bool   Inp_SBSellBlockSOWLongUp = false; // Research: reject SOW-based SB SELL against 240H uptrend

input group "09C. ENTRY M5 | M5 setup và xác nhận breakout"
input bool   Inp_M5RequireDirectionalCandle = true; // BUY bullish / SELL bearish confirmation candle
input double Inp_M5MinBodyRatio             = 0.00; // Disabled after 2026 comparison; direction remains required
input double Inp_M5MaxCandleATR             = 0.00; // 0 = off; strict cap removed two winning trades
input double Inp_M5MaxChaseATR              = 0.00; // 0 = off; H1 expiry/session still prevent stale chasing
input double Inp_M5SLBufferATR              = 0.10; // Stop buffer beyond M5 confirmation candle
input double Inp_M5MinRiskATR               = 0.50; // Minimum Entry-SL distance in M5 ATR

//--- Confirmation wait mask: bit 1=first eligible candle (wait 0),
//--- bit 2=wait 1, bit 4=wait 2 or later. 7 allows every wait bucket.
input group "09D. ENTRY M5 | Ma trận độ trễ xác nhận"
input bool Inp_UseConfirmWaitMatrix = true;
input int Inp_DDBBuyWaitMask=7; input int Inp_DDBSellWaitMask=5;
input int Inp_FBBuyWaitMask =6; input int Inp_FBSellWaitMask =7;
input int Inp_SBBuyWaitMask =7; input int Inp_SBSellWaitMask =7;
input int Inp_BBBuyWaitMask =7; input int Inp_BBSellWaitMask =7;
input int Inp_RBBuyWaitMask =7; input int Inp_RBSellWaitMask =7;
input int Inp_IRBBuyWaitMask=7; input int Inp_IRBSellWaitMask=7;
input int Inp_ARBBuyWaitMask=7; input int Inp_ARBSellWaitMask=7;

input group "09E. ENTRY M5 IMBALANCE | Active three-candle FVG"
input ENUM_IMBALANCE_FILTER_MODE Inp_DDBBuyImbalanceMode  = IMB_FILTER_OFF;
input ENUM_IMBALANCE_FILTER_MODE Inp_DDBSellImbalanceMode = IMB_FILTER_OFF;
input ENUM_IMBALANCE_FILTER_MODE Inp_FBBuyImbalanceMode   = IMB_FILTER_OFF;
input ENUM_IMBALANCE_FILTER_MODE Inp_FBSellImbalanceMode  = IMB_FILTER_OFF;
input ENUM_IMBALANCE_FILTER_MODE Inp_SBBuyImbalanceMode   = IMB_FILTER_OFF;
input ENUM_IMBALANCE_FILTER_MODE Inp_SBSellImbalanceMode  = IMB_FILTER_OFF;
input ENUM_IMBALANCE_FILTER_MODE Inp_BBBuyImbalanceMode   = IMB_FILTER_OFF;
input ENUM_IMBALANCE_FILTER_MODE Inp_BBSellImbalanceMode  = IMB_FILTER_OFF;
input ENUM_IMBALANCE_FILTER_MODE Inp_RBBuyImbalanceMode   = IMB_FILTER_OFF;
input ENUM_IMBALANCE_FILTER_MODE Inp_RBSellImbalanceMode  = IMB_FILTER_OFF;
input ENUM_IMBALANCE_FILTER_MODE Inp_IRBBuyImbalanceMode  = IMB_FILTER_OFF;
input ENUM_IMBALANCE_FILTER_MODE Inp_IRBSellImbalanceMode = IMB_FILTER_OFF;
input ENUM_IMBALANCE_FILTER_MODE Inp_ARBBuyImbalanceMode  = IMB_FILTER_OFF;
input ENUM_IMBALANCE_FILTER_MODE Inp_ARBSellImbalanceMode = IMB_FILTER_OFF;
input int    Inp_M5ImbalanceLookback = 12;
input double Inp_ImbalanceMinGapATR  = 0.05;
input double Inp_ImbalanceMinBody    = 0.60;
input int    Inp_SBBuyImbalanceWyckoffMask = 8; // SOS only; 0 applies to every event

input group "09F. BB STRUCTURE | Imbalance S/R + impulse/Wyckoff"
input ENUM_BB_STRUCTURE_MODE Inp_BBStructureMode = BB_STRUCTURE_OFF;
input double Inp_BBImbalanceMaxDistanceATR = 0.35; // Block edge to active M5 FVG support/resistance
input int    Inp_BBImbalanceMaxAge = 8;             // Selected: active FVG formed within eight closed M5 bars
input int    Inp_BBImpulsePhaseMask = 1;             // Bit 1=W3, bit 2=W5; selected BB uses W3 only
input bool   Inp_BBRequireWyckoffEvent = false;       // Optional confluence: require any active H1 Wyckoff event
input int    Inp_BBLateWyckoffMaxAge = 8;          // H1 bars since SOS/LPS or SOW/LPSY

input group "09G. IRB STRUCTURE | Directional range context"
input int    Inp_IRBContextEventMask = 0;           // 0=off; bit 1=NONE, 2=Spring ... 64=LPS, 128=LPSY
input bool   Inp_IRBBlockBuyLongDown = false;        // Reject BUY range breaks against a falling 240H structure

input group "10. TESTER | Tieu chi toi uu"
input int    Inp_TesterMinTrades      = 20;    // Minimum trades before OnTester returns win rate

input group "11. DIAGNOSTICS | MAE, MFE va shadow path"
input bool   Inp_ExportExcursions     = false; // Export one CSV row per closed trade
input string Inp_ExcursionFileName    = "BobH1ContextM5-v177-MAE-MFE.csv"; // Written to tester agent MQL5/Files
input int    Inp_PostExitBars         = 144;   // Observe price for N M5 bars after exit

struct ExcursionTracker
{
   bool                 active;
   ENUM_BV_SETUP        setup;
   ENUM_WYCKOFF_EVENT   wyckoff_event;
   int                  direction;
   datetime             signal_time;
   datetime             entry_time;
   double               entry_price;
   double               initial_stop;
   double               initial_risk;
   double               target_rr;
   double               max_favorable_r;
   double               max_adverse_r;
   datetime             first_mfe_025_time;
   datetime             first_mfe_050_time;
   datetime             first_mfe_075_time;
   datetime             first_mfe_100_time;
   datetime             first_return_entry_after_050_time;
   datetime             first_return_entry_after_075_time;
   datetime             first_return_entry_after_100_time;
   MarketContextSnapshot context;
   datetime             m5_signal_time;
   double               m5_signal_open;
   double               m5_signal_high;
   double               m5_signal_low;
   double               m5_signal_close;
   double               m5_atr;
   double               m5_body_ratio;
   int                  m5_wait_bars;
};

struct ExcursionRecord
{
   ENUM_BV_SETUP        setup;
   ENUM_WYCKOFF_EVENT   wyckoff_event;
   int                  direction;
   datetime             signal_time;
   datetime             entry_time;
   datetime             exit_time;
   double               entry_price;
   double               exit_price;
   double               initial_stop;
   double               initial_risk;
   double               target_rr;
   double               max_favorable_r;
   double               max_adverse_r;
   datetime             first_mfe_025_time;
   datetime             first_mfe_050_time;
   datetime             first_mfe_075_time;
   datetime             first_mfe_100_time;
   datetime             first_return_entry_after_050_time;
   datetime             first_return_entry_after_075_time;
   datetime             first_return_entry_after_100_time;
   double               exit_r;
   double               net_profit;
   string               exit_reason;
   double               post_best_r;
   double               post_worst_r;
   int                  post_bars_observed;
   MarketContextSnapshot context;
   datetime             m5_signal_time;
   double               m5_signal_open;
   double               m5_signal_high;
   double               m5_signal_low;
   double               m5_signal_close;
   double               m5_atr;
   double               m5_body_ratio;
   int                  m5_wait_bars;
};

struct InverseShadowState
{
   bool           active;
   SetupCandidate source;
   datetime       open_time;
   double         main_entry;
   double         main_stop;
   double         main_target;
   datetime       last_m5_bar_time;
   int            bars_elapsed;
   bool           main_sl_seen;
};

struct IndependentInverseState
{
   bool       active;
   datetime   detected_time;
   int        main_direction;
   double     high;
   double     low;
   double     atr;
   int        wait_bars;
   bool       entry_candle_seen;
   MqlRates   entry_candle;
   int        bars_after_entry;
};

int       g_emaHandle = INVALID_HANDLE;
int       g_atrHandle = INVALID_HANDLE;
int       g_m5AtrHandle = INVALID_HANDLE;
int       g_indInvM5EmaHandle = INVALID_HANDLE;
datetime  g_lastM5BarTime = 0;
datetime  g_lastEntryBarTime = 0;
SetupCandidate g_pending;
WyckoffContext g_wyckoff;
datetime  g_lastWyckoffAnnotationTime = 0;
ExcursionTracker g_excursion;
ExcursionRecord  g_postExitRecords[];
int       g_excursionFile = INVALID_HANDLE;
InverseShadowState g_inverseShadow;
IndependentInverseState g_independentInverse;
datetime  g_indInvLastStateEndBar=0;

//+------------------------------------------------------------------+
//| Utility                                                          |
//+------------------------------------------------------------------+
string SetupCode(const ENUM_BV_SETUP type)
{
   switch(type)
   {
      case BV_DDB: return "DDB";
      case BV_FB:  return "FB";
      case BV_SB:  return "SB";
      case BV_BB:  return "BB";
      case BV_RB:  return "RB";
      case BV_IRB: return "IRB";
      case BV_ARB: return "ARB";
      default:     return "NONE";
   }
}

string SetupFullName(const ENUM_BV_SETUP type)
{
   switch(type)
   {
      case BV_DDB: return "Double Doji Break";
      case BV_FB:  return "First Break";
      case BV_SB:  return "Second Break";
      case BV_BB:  return "Block Break";
      case BV_RB:  return "Range Break";
      case BV_IRB: return "Inside Range Break";
      case BV_ARB: return "Advanced Range Break";
      default:     return "None";
   }
}

string EnabledSetupsText()
{
   string enabled="";
   if(Inp_EnableDDB) enabled += " DDB";
   if(Inp_EnableFB)  enabled += " FB";
   if(Inp_EnableSB)  enabled += " SB";
   if(Inp_EnableBB)  enabled += " BB";
   if(Inp_EnableRB)  enabled += " RB";
   if(Inp_EnableIRB) enabled += " IRB";
   if(Inp_EnableARB) enabled += " ARB";
   if(enabled=="")
      return "NONE";
   return StringSubstr(enabled,1);
}

string DirectionText(const int direction)
{
   return (direction > 0 ? "BUY" : "SELL");
}

string WyckoffEventCode(const ENUM_WYCKOFF_EVENT event)
{
   switch(event)
   {
      case WY_SPRING:   return "SPRING";
      case WY_UPTHRUST: return "UT";
      case WY_SOS:      return "SOS";
      case WY_SOW:      return "SOW";
      case WY_TEST:     return "TEST";
      case WY_LPS:      return "LPS";
      case WY_LPSY:     return "LPSY";
      default:          return "NONE";
   }
}

void ResetMarketContext(MarketContextSnapshot &context)
{
   context.valid=false;
   context.trend_24="RANGE";
   context.trend_72="RANGE";
   context.trend_240="RANGE";
   context.slope_24_atr=0.0;
   context.r2_24=0.0;
   context.slope_72_atr=0.0;
   context.r2_72=0.0;
   context.slope_240_atr=0.0;
   context.r2_240=0.0;
   context.transition_state="UNDEFINED";
   context.volatility_state="NORMAL";
   context.volatility_ratio=1.0;
   context.activity_state="NORMAL";
   context.activity_ratio=1.0;
   context.range_position_240=0.5;
   context.location_state="MID";
   context.wyckoff_phase="NO_EVENT";
   context.elliott_phase="UNDEFINED";
   context.elliott_alignment="UNDEFINED";
   context.confluence_score=0;
   context.confluence_tier="LOW";
}

void ResetExcursionTracker()
{
   g_excursion.active=false;
   g_excursion.setup=BV_NONE;
   g_excursion.wyckoff_event=WY_NONE;
   g_excursion.direction=0;
   g_excursion.signal_time=0;
   g_excursion.entry_time=0;
   g_excursion.entry_price=0.0;
   g_excursion.initial_stop=0.0;
   g_excursion.initial_risk=0.0;
   g_excursion.target_rr=0.0;
   g_excursion.max_favorable_r=0.0;
   g_excursion.max_adverse_r=0.0;
   g_excursion.first_mfe_025_time=0;
   g_excursion.first_mfe_050_time=0;
   g_excursion.first_mfe_075_time=0;
   g_excursion.first_mfe_100_time=0;
   g_excursion.first_return_entry_after_050_time=0;
   g_excursion.first_return_entry_after_075_time=0;
   g_excursion.first_return_entry_after_100_time=0;
   ResetMarketContext(g_excursion.context);
   g_excursion.m5_signal_time=0;
   g_excursion.m5_signal_open=0.0;
   g_excursion.m5_signal_high=0.0;
   g_excursion.m5_signal_low=0.0;
   g_excursion.m5_signal_close=0.0;
   g_excursion.m5_atr=0.0;
   g_excursion.m5_body_ratio=0.0;
   g_excursion.m5_wait_bars=0;
}

void ResetInverseShadow()
{
   g_inverseShadow.active=false;
   ResetCandidate(g_inverseShadow.source);
   g_inverseShadow.open_time=0;
   g_inverseShadow.main_entry=0.0;
   g_inverseShadow.main_stop=0.0;
   g_inverseShadow.main_target=0.0;
   g_inverseShadow.last_m5_bar_time=0;
   g_inverseShadow.bars_elapsed=0;
   g_inverseShadow.main_sl_seen=false;
}

void ResetIndependentInverse(const bool completed=false)
{
   g_independentInverse.active=false;
   g_independentInverse.detected_time=0;
   g_independentInverse.main_direction=0;
   g_independentInverse.high=0.0;
   g_independentInverse.low=0.0;
   g_independentInverse.atr=0.0;
   g_independentInverse.wait_bars=0;
   g_independentInverse.entry_candle_seen=false;
   ZeroMemory(g_independentInverse.entry_candle);
   g_independentInverse.bars_after_entry=0;
   if(completed)
      g_indInvLastStateEndBar=iTime(_Symbol,PERIOD_M5,0);
}

ENUM_WYCKOFF_EVENT WyckoffFromPositionComment(const string comment)
{
   if(StringFind(comment,"_SPRING")>=0) return WY_SPRING;
   if(StringFind(comment,"_UT")>=0)     return WY_UPTHRUST;
   if(StringFind(comment,"_SOS")>=0)    return WY_SOS;
   if(StringFind(comment,"_SOW")>=0)    return WY_SOW;
   if(StringFind(comment,"_TEST")>=0)   return WY_TEST;
   if(StringFind(comment,"_LPSY")>=0)   return WY_LPSY;
   if(StringFind(comment,"_LPS")>=0)    return WY_LPS;
   return WY_NONE;
}

bool OpenExcursionFile()
{
   if(!Inp_ExportExcursions)
      return true;
   g_excursionFile=FileOpen(Inp_ExcursionFileName,
                            FILE_WRITE|FILE_CSV|FILE_ANSI|FILE_SHARE_READ,
                            ';');
   if(g_excursionFile==INVALID_HANDLE)
   {
      PrintFormat("[BV-H1][MAE-MFE] Cannot open %s. error=%d",Inp_ExcursionFileName,GetLastError());
      return false;
   }
   FileWrite(g_excursionFile,
             "setup","wyckoff_event","direction","signal_time","entry_time","exit_time",
             "entry_price","exit_price","initial_stop","initial_risk","target_rr",
             "mfe_r","mae_r","exit_r","net_profit","exit_reason",
             "first_mfe_025_time","first_mfe_050_time","first_mfe_075_time","first_mfe_100_time",
             "first_return_entry_after_050_time","first_return_entry_after_075_time","first_return_entry_after_100_time",
             "post_best_r","post_worst_r","post_bars_observed",
             "trend_24","slope_24_atr","r2_24","trend_72","slope_72_atr","r2_72",
             "trend_240","slope_240_atr","r2_240","transition_state",
             "volatility_state","volatility_ratio","activity_state","activity_ratio",
             "range_position_240","location_state","wyckoff_phase",
             "elliott_phase","elliott_alignment","confluence_score","confluence_tier",
             "m5_signal_time","m5_open","m5_high","m5_low","m5_close",
             "m5_atr","m5_body_ratio","m5_wait_bars");
   FileFlush(g_excursionFile);
   return true;
}

void StartExcursionTracker(const SetupCandidate &candidate,const double fill)
{
   if(!Inp_ExportExcursions)
      return;
   ResetExcursionTracker();
   g_excursion.active=true;
   g_excursion.setup=candidate.type;
   g_excursion.wyckoff_event=candidate.wyckoff_event;
   g_excursion.direction=candidate.direction;
   g_excursion.signal_time=candidate.signal_time;
   g_excursion.entry_time=TimeCurrent();
   g_excursion.entry_price=fill;
   g_excursion.initial_stop=candidate.stop_loss;
   g_excursion.initial_risk=MathAbs(fill-candidate.stop_loss);
   g_excursion.target_rr=TargetRRForSetup(candidate.type);
   g_excursion.context=candidate.context;
   g_excursion.m5_signal_time=candidate.m5_signal_time;
   g_excursion.m5_signal_open=candidate.m5_signal_open;
   g_excursion.m5_signal_high=candidate.m5_signal_high;
   g_excursion.m5_signal_low=candidate.m5_signal_low;
   g_excursion.m5_signal_close=candidate.m5_signal_close;
   g_excursion.m5_atr=candidate.m5_atr;
   g_excursion.m5_body_ratio=candidate.m5_body_ratio;
   g_excursion.m5_wait_bars=candidate.m5_wait_bars;
}

void UpdateExcursionPrice(const double closeablePrice)
{
   if(!g_excursion.active || g_excursion.initial_risk<=0.0 || closeablePrice<=0.0)
      return;
   const double moveR=g_excursion.direction*(closeablePrice-g_excursion.entry_price)/g_excursion.initial_risk;
   const datetime now=TimeCurrent();
   if(g_excursion.first_mfe_025_time==0 && moveR>=0.25) g_excursion.first_mfe_025_time=now;
   if(g_excursion.first_mfe_050_time==0 && moveR>=0.50) g_excursion.first_mfe_050_time=now;
   if(g_excursion.first_mfe_075_time==0 && moveR>=0.75) g_excursion.first_mfe_075_time=now;
   if(g_excursion.first_mfe_100_time==0 && moveR>=1.00) g_excursion.first_mfe_100_time=now;
   if(moveR<=0.0)
   {
      if(g_excursion.first_mfe_050_time>0 && g_excursion.first_return_entry_after_050_time==0)
         g_excursion.first_return_entry_after_050_time=now;
      if(g_excursion.first_mfe_075_time>0 && g_excursion.first_return_entry_after_075_time==0)
         g_excursion.first_return_entry_after_075_time=now;
      if(g_excursion.first_mfe_100_time>0 && g_excursion.first_return_entry_after_100_time==0)
         g_excursion.first_return_entry_after_100_time=now;
   }
   g_excursion.max_favorable_r=MathMax(g_excursion.max_favorable_r,moveR);
   g_excursion.max_adverse_r=MathMax(g_excursion.max_adverse_r,-moveR);
}

void WriteExcursionRecord(const ExcursionRecord &record)
{
   if(g_excursionFile==INVALID_HANDLE)
      return;
   FileWrite(g_excursionFile,
             SetupCode(record.setup),WyckoffEventCode(record.wyckoff_event),DirectionText(record.direction),
             TimeToString(record.signal_time,TIME_DATE|TIME_MINUTES),
             TimeToString(record.entry_time,TIME_DATE|TIME_MINUTES|TIME_SECONDS),
             TimeToString(record.exit_time,TIME_DATE|TIME_MINUTES|TIME_SECONDS),
             DoubleToString(record.entry_price,_Digits),DoubleToString(record.exit_price,_Digits),
             DoubleToString(record.initial_stop,_Digits),DoubleToString(record.initial_risk,_Digits),
             DoubleToString(record.target_rr,2),DoubleToString(record.max_favorable_r,4),
             DoubleToString(record.max_adverse_r,4),DoubleToString(record.exit_r,4),
             DoubleToString(record.net_profit,2),record.exit_reason,
             TimeToString(record.first_mfe_025_time,TIME_DATE|TIME_MINUTES|TIME_SECONDS),
             TimeToString(record.first_mfe_050_time,TIME_DATE|TIME_MINUTES|TIME_SECONDS),
             TimeToString(record.first_mfe_075_time,TIME_DATE|TIME_MINUTES|TIME_SECONDS),
             TimeToString(record.first_mfe_100_time,TIME_DATE|TIME_MINUTES|TIME_SECONDS),
             TimeToString(record.first_return_entry_after_050_time,TIME_DATE|TIME_MINUTES|TIME_SECONDS),
             TimeToString(record.first_return_entry_after_075_time,TIME_DATE|TIME_MINUTES|TIME_SECONDS),
             TimeToString(record.first_return_entry_after_100_time,TIME_DATE|TIME_MINUTES|TIME_SECONDS),
             DoubleToString(record.post_best_r,4),DoubleToString(record.post_worst_r,4),
             record.post_bars_observed,
             record.context.trend_24,DoubleToString(record.context.slope_24_atr,6),DoubleToString(record.context.r2_24,6),
             record.context.trend_72,DoubleToString(record.context.slope_72_atr,6),DoubleToString(record.context.r2_72,6),
             record.context.trend_240,DoubleToString(record.context.slope_240_atr,6),DoubleToString(record.context.r2_240,6),
             record.context.transition_state,
             record.context.volatility_state,DoubleToString(record.context.volatility_ratio,6),
             record.context.activity_state,DoubleToString(record.context.activity_ratio,6),
             DoubleToString(record.context.range_position_240,6),record.context.location_state,
             record.context.wyckoff_phase,record.context.elliott_phase,record.context.elliott_alignment,
             record.context.confluence_score,record.context.confluence_tier,
             TimeToString(record.m5_signal_time,TIME_DATE|TIME_MINUTES),
             DoubleToString(record.m5_signal_open,_Digits),DoubleToString(record.m5_signal_high,_Digits),
             DoubleToString(record.m5_signal_low,_Digits),DoubleToString(record.m5_signal_close,_Digits),
             DoubleToString(record.m5_atr,_Digits),DoubleToString(record.m5_body_ratio,4),
             record.m5_wait_bars);
   FileFlush(g_excursionFile);
}

void RemovePostExitRecord(const int index)
{
   const int count=ArraySize(g_postExitRecords);
   if(index<0 || index>=count)
      return;
   for(int i=index;i<count-1;i++)
      g_postExitRecords[i]=g_postExitRecords[i+1];
   ArrayResize(g_postExitRecords,count-1);
}

void UpdatePostExitRecords(const MqlTick &tick)
{
   if(!Inp_ExportExcursions)
      return;
   for(int i=ArraySize(g_postExitRecords)-1;i>=0;i--)
   {
      ExcursionRecord record=g_postExitRecords[i];
      const double closeablePrice=(record.direction>0 ? tick.bid : tick.ask);
      if(record.initial_risk>0.0 && closeablePrice>0.0)
      {
         const double moveR=record.direction*(closeablePrice-record.entry_price)/record.initial_risk;
         record.post_best_r=MathMax(record.post_best_r,moveR);
         record.post_worst_r=MathMax(record.post_worst_r,-moveR);
      }
      const int barsSinceExit=iBarShift(_Symbol,PERIOD_M5,record.exit_time,false);
      record.post_bars_observed=MathMax(record.post_bars_observed,barsSinceExit);
      g_postExitRecords[i]=record;
      if(Inp_PostExitBars<=0 || barsSinceExit>=Inp_PostExitBars)
      {
         WriteExcursionRecord(record);
         RemovePostExitRecord(i);
      }
   }
}

double PositionNetProfit(const ulong positionId)
{
   if(positionId==0 || !HistorySelectByPosition(positionId))
      return 0.0;
   double net=0.0;
   const int deals=HistoryDealsTotal();
   for(int i=0;i<deals;i++)
   {
      const ulong deal=HistoryDealGetTicket(i);
      if(deal==0)
         continue;
      net+=HistoryDealGetDouble(deal,DEAL_PROFIT);
      net+=HistoryDealGetDouble(deal,DEAL_SWAP);
      net+=HistoryDealGetDouble(deal,DEAL_COMMISSION);
      net+=HistoryDealGetDouble(deal,DEAL_FEE);
   }
   return net;
}

void QueueClosedExcursion(const ulong dealTicket)
{
   if(!Inp_ExportExcursions || !g_excursion.active || !HistoryDealSelect(dealTicket))
      return;
   const double exitPrice=HistoryDealGetDouble(dealTicket,DEAL_PRICE);
   UpdateExcursionPrice(exitPrice);

   ExcursionRecord record;
   record.setup=g_excursion.setup;
   record.wyckoff_event=g_excursion.wyckoff_event;
   record.direction=g_excursion.direction;
   record.signal_time=g_excursion.signal_time;
   record.entry_time=g_excursion.entry_time;
   record.exit_time=(datetime)HistoryDealGetInteger(dealTicket,DEAL_TIME);
   record.entry_price=g_excursion.entry_price;
   record.exit_price=exitPrice;
   record.initial_stop=g_excursion.initial_stop;
   record.initial_risk=g_excursion.initial_risk;
   record.target_rr=g_excursion.target_rr;
   record.max_favorable_r=g_excursion.max_favorable_r;
   record.max_adverse_r=g_excursion.max_adverse_r;
   record.first_mfe_025_time=g_excursion.first_mfe_025_time;
   record.first_mfe_050_time=g_excursion.first_mfe_050_time;
   record.first_mfe_075_time=g_excursion.first_mfe_075_time;
   record.first_mfe_100_time=g_excursion.first_mfe_100_time;
   record.first_return_entry_after_050_time=g_excursion.first_return_entry_after_050_time;
   record.first_return_entry_after_075_time=g_excursion.first_return_entry_after_075_time;
   record.first_return_entry_after_100_time=g_excursion.first_return_entry_after_100_time;
   record.exit_r=(record.initial_risk>0.0 ? record.direction*(exitPrice-record.entry_price)/record.initial_risk : 0.0);
   const ulong positionId=(ulong)HistoryDealGetInteger(dealTicket,DEAL_POSITION_ID);
   record.net_profit=PositionNetProfit(positionId);
   record.exit_reason=EnumToString((ENUM_DEAL_REASON)HistoryDealGetInteger(dealTicket,DEAL_REASON));
   record.post_best_r=record.exit_r;
   record.post_worst_r=MathMax(0.0,-record.exit_r);
   record.post_bars_observed=0;
   record.context=g_excursion.context;
   record.m5_signal_time=g_excursion.m5_signal_time;
   record.m5_signal_open=g_excursion.m5_signal_open;
   record.m5_signal_high=g_excursion.m5_signal_high;
   record.m5_signal_low=g_excursion.m5_signal_low;
   record.m5_signal_close=g_excursion.m5_signal_close;
   record.m5_atr=g_excursion.m5_atr;
   record.m5_body_ratio=g_excursion.m5_body_ratio;
   record.m5_wait_bars=g_excursion.m5_wait_bars;

   const int index=ArraySize(g_postExitRecords);
   ArrayResize(g_postExitRecords,index+1);
   g_postExitRecords[index]=record;
   ResetExcursionTracker();
}

void FlushPostExitRecords()
{
   for(int i=ArraySize(g_postExitRecords)-1;i>=0;i--)
   {
      WriteExcursionRecord(g_postExitRecords[i]);
      RemovePostExitRecord(i);
   }
}

void ResetWyckoffContext(WyckoffContext &context)
{
   context.valid=false;
   context.event=WY_NONE;
   context.primary_event=WY_NONE;
   context.bias=0;
   context.event_time=0;
   context.age_bars=0;
   context.level=0.0;
   context.score=0.0;
}

double AverageTickVolume(const MqlRates &rates[],const int start,const int count)
{
   if(count<=0)
      return 0.0;
   double total=0.0;
   for(int i=start;i<start+count;i++)
      total+=(double)rates[i].tick_volume;
   return total/count;
}

bool DetectWyckoffContext(const MqlRates &rates[],const double &atr[],WyckoffContext &context)
{
   ResetWyckoffContext(context);
   const int lookback=MathMax(6,Inp_WyckoffLookback);
   const int validBars=MathMax(1,Inp_WyckoffValidBars);
   for(int shift=1;shift<=validBars;shift++)
   {
      if(atr[shift]<=0.0)
         continue;
      const double priorHigh=WindowHigh(rates,shift+1,lookback);
      const double priorLow=WindowLow(rates,shift+1,lookback);
      const double avgVolume=AverageTickVolume(rates,shift+1,lookback);
      const double penetration=MathMax(0.0,Inp_WyckoffPenetrationATR)*atr[shift];
      const double breakout=MathMax(0.0,Inp_WyckoffBreakoutATR)*atr[shift];
      const bool spring=(rates[shift].low<priorLow-penetration &&
                         rates[shift].close>priorLow && CloseLocation(rates[shift])>=0.55);
      const bool upthrust=(rates[shift].high>priorHigh+penetration &&
                           rates[shift].close<priorHigh && CloseLocation(rates[shift])<=0.45);
      const bool sos=(rates[shift].close>priorHigh+breakout && IsBull(rates[shift]) &&
                      BodyRatio(rates[shift])>=Inp_WyckoffMinBodyRatio &&
                      (avgVolume<=0.0 || (double)rates[shift].tick_volume>=avgVolume*Inp_WyckoffVolumeFactor));
      const bool sow=(rates[shift].close<priorLow-breakout && IsBear(rates[shift]) &&
                      BodyRatio(rates[shift])>=Inp_WyckoffMinBodyRatio &&
                      (avgVolume<=0.0 || (double)rates[shift].tick_volume>=avgVolume*Inp_WyckoffVolumeFactor));

      if(!spring && !upthrust && !sos && !sow)
         continue;

      context.valid=true;
      context.event=(spring ? WY_SPRING : (upthrust ? WY_UPTHRUST : (sos ? WY_SOS : WY_SOW)));
      context.primary_event=context.event;
      context.bias=(spring || sos ? 1 : -1);
      context.event_time=rates[shift].time;
      context.age_bars=shift;
      context.level=(spring || sow ? priorLow : priorHigh);
      context.score=100.0+(double)rates[shift].tick_volume/MathMax(avgVolume,1.0);

      // A lower-volume retest after the primary event is stronger confirmation.
      for(int recent=1;recent<shift;recent++)
      {
         const double zone=MathMax(0.0,Inp_WyckoffRetestZoneATR)*atr[recent];
         const bool lowerVolume=((double)rates[recent].tick_volume<=
                                 (double)rates[shift].tick_volume*Inp_WyckoffTestVolumeFactor);
         if(!lowerVolume)
            continue;
         bool confirmed=false;
         if(context.primary_event==WY_SPRING)
            confirmed=(rates[recent].low<=context.level+zone && rates[recent].close>context.level &&
                       CloseLocation(rates[recent])>=0.55);
         else if(context.primary_event==WY_UPTHRUST)
            confirmed=(rates[recent].high>=context.level-zone && rates[recent].close<context.level &&
                       CloseLocation(rates[recent])<=0.45);
         else if(context.primary_event==WY_SOS)
            confirmed=(rates[recent].low<=context.level+zone && rates[recent].close>context.level &&
                       CloseLocation(rates[recent])>=0.55);
         else if(context.primary_event==WY_SOW)
            confirmed=(rates[recent].high>=context.level-zone && rates[recent].close<context.level &&
                       CloseLocation(rates[recent])<=0.45);
         if(!confirmed)
            continue;
         if(context.primary_event==WY_SPRING || context.primary_event==WY_UPTHRUST)
            context.event=WY_TEST;
         else if(context.primary_event==WY_SOS)
            context.event=WY_LPS;
         else
            context.event=WY_LPSY;
         context.event_time=rates[recent].time;
         context.age_bars=recent;
         context.score+=25.0;
         break;
      }
      return true;
   }
   return false;
}

int WyckoffMaskForSetup(const ENUM_BV_SETUP setup)
{
   switch(setup)
   {
      case BV_DDB: return Inp_DDBWyckoffMask;
      case BV_FB:  return Inp_FBWyckoffMask;
      case BV_SB:  return Inp_SBWyckoffMask;
      case BV_BB:  return Inp_BBWyckoffMask;
      case BV_RB:  return Inp_RBWyckoffMask;
      case BV_IRB: return Inp_IRBWyckoffMask;
      case BV_ARB: return Inp_ARBWyckoffMask;
      default:     return 0;
   }
}

int WyckoffMaxAgeForSetup(const ENUM_BV_SETUP setup)
{
   switch(setup)
   {
      case BV_DDB: return Inp_DDBWyckoffMaxAge;
      case BV_FB:  return Inp_FBWyckoffMaxAge;
      case BV_SB:  return Inp_SBWyckoffMaxAge;
      case BV_BB:  return Inp_BBWyckoffMaxAge;
      case BV_RB:  return Inp_RBWyckoffMaxAge;
      case BV_IRB: return Inp_IRBWyckoffMaxAge;
      case BV_ARB: return Inp_ARBWyckoffMaxAge;
      default:     return Inp_WyckoffValidBars;
   }
}

double WyckoffMaxDistanceForSetup(const ENUM_BV_SETUP setup)
{
   switch(setup)
   {
      case BV_DDB: return Inp_DDBWyckoffMaxDistanceATR;
      case BV_FB:  return Inp_FBWyckoffMaxDistanceATR;
      case BV_SB:  return Inp_SBWyckoffMaxDistanceATR;
      case BV_BB:  return Inp_BBWyckoffMaxDistanceATR;
      case BV_RB:  return Inp_RBWyckoffMaxDistanceATR;
      case BV_IRB: return Inp_IRBWyckoffMaxDistanceATR;
      case BV_ARB: return Inp_ARBWyckoffMaxDistanceATR;
      default:     return 0.0;
   }
}

bool WyckoffAllowsSetup(const ENUM_BV_SETUP setup,const int direction,
                        const double trigger,const double atr,
                        const WyckoffContext &context)
{
   if(Inp_WyckoffFilterMode==WY_FILTER_OFF)
      return true;
   if(!context.valid || context.bias!=direction)
      return false;
   bool eventEnabled=false;
   switch(context.event)
   {
      case WY_SPRING:   eventEnabled=Inp_WyckoffAllowSpring;   break;
      case WY_UPTHRUST: eventEnabled=Inp_WyckoffAllowUpthrust; break;
      case WY_SOS:      eventEnabled=Inp_WyckoffAllowSOS;      break;
      case WY_SOW:      eventEnabled=Inp_WyckoffAllowSOW;      break;
      case WY_TEST:     eventEnabled=Inp_WyckoffAllowTest;     break;
      case WY_LPS:      eventEnabled=Inp_WyckoffAllowLPS;      break;
      case WY_LPSY:     eventEnabled=Inp_WyckoffAllowLPSY;     break;
      default: break;
   }
   if(!eventEnabled)
      return false;
   if(Inp_UseSetupEventMatrix)
   {
      const int eventBit=(1 << (int)context.event);
      if((WyckoffMaskForSetup(setup)&eventBit)==0)
         return false;
      const int maxAge=WyckoffMaxAgeForSetup(setup);
      if(maxAge>0 && context.age_bars>maxAge)
         return false;
      const double maxDistanceATR=WyckoffMaxDistanceForSetup(setup);
      if(maxDistanceATR>0.0 && atr>0.0 && MathAbs(trigger-context.level)>maxDistanceATR*atr)
         return false;
   }
   if(Inp_WyckoffFilterMode==WY_FILTER_BIAS)
      return true;

   if(setup==BV_ARB)
      return (direction>0 ? (context.event==WY_SPRING || context.event==WY_TEST)
                          : (context.event==WY_UPTHRUST || context.event==WY_TEST));
   if(setup==BV_RB || setup==BV_IRB)
      return (direction>0 ? (context.event==WY_SOS || context.event==WY_LPS)
                          : (context.event==WY_SOW || context.event==WY_LPSY));
   return (context.event==WY_TEST || context.event==WY_LPS || context.event==WY_LPSY);
}

double TargetRRForSetup(const ENUM_BV_SETUP type)
{
   double setupRR=0.0;
   switch(type)
   {
      case BV_DDB: setupRR=Inp_DDBTargetRR; break;
      case BV_FB:  setupRR=Inp_FBTargetRR;  break;
      case BV_SB:  setupRR=Inp_SBTargetRR;  break;
      case BV_BB:  setupRR=Inp_BBTargetRR;  break;
      case BV_RB:  setupRR=Inp_RBTargetRR;  break;
      case BV_IRB: setupRR=Inp_IRBTargetRR; break;
      case BV_ARB: setupRR=Inp_ARBTargetRR; break;
      default: break;
   }
   return (setupRR>0.0 ? setupRR : Inp_TargetRR);
}

int ExpiryBarsForSetup(const ENUM_BV_SETUP type)
{
   switch(type)
   {
      case BV_DDB: return Inp_DDBExpiryBars;
      case BV_FB:  return Inp_FBExpiryBars;
      case BV_SB:  return Inp_SBExpiryBars;
      case BV_BB:  return Inp_BBExpiryBars;
      case BV_RB:  return Inp_RBExpiryBars;
      case BV_IRB: return Inp_IRBExpiryBars;
      case BV_ARB: return Inp_ARBExpiryBars;
      default:     return Inp_EntryExpiryBars;
   }
}

int EMASlopeBarsForSetup(const ENUM_BV_SETUP type)
{
   switch(type)
   {
      case BV_DDB: return Inp_DDBEMASlopeBars;
      case BV_FB:  return Inp_FBEMASlopeBars;
      case BV_SB:  return Inp_SBEMASlopeBars;
      case BV_BB:  return Inp_BBEMASlopeBars;
      case BV_RB:  return Inp_RBEMASlopeBars;
      case BV_IRB: return Inp_IRBEMASlopeBars;
      case BV_ARB: return Inp_ARBEMASlopeBars;
      default:     return Inp_EMASlopeBars;
   }
}

double MaxSignalATRForSetup(const ENUM_BV_SETUP type)
{
   switch(type)
   {
      case BV_DDB: return Inp_DDBMaxSignalATR;
      case BV_FB:  return Inp_FBMaxSignalATR;
      case BV_SB:  return Inp_SBMaxSignalATR;
      case BV_BB:  return Inp_BBMaxSignalATR;
      case BV_RB:  return Inp_RBMaxSignalATR;
      case BV_IRB: return Inp_IRBMaxSignalATR;
      case BV_ARB: return Inp_ARBMaxSignalATR;
      default:     return Inp_MaxSignalRangeATR;
   }
}

bool DirectionAllowedForSetup(const ENUM_BV_SETUP type,const int direction)
{
   if(direction>0 && !Inp_AllowBuy)  return false;
   if(direction<0 && !Inp_AllowSell) return false;
   switch(type)
   {
      case BV_DDB: return (direction>0 ? Inp_DDBAllowBuy : Inp_DDBAllowSell);
      case BV_FB:  return (direction>0 ? Inp_FBAllowBuy  : Inp_FBAllowSell);
      case BV_SB:  return (direction>0 ? Inp_SBAllowBuy  : Inp_SBAllowSell);
      case BV_BB:  return (direction>0 ? Inp_BBAllowBuy  : Inp_BBAllowSell);
      case BV_RB:  return (direction>0 ? Inp_RBAllowBuy  : Inp_RBAllowSell);
      case BV_IRB: return (direction>0 ? Inp_IRBAllowBuy : Inp_IRBAllowSell);
      case BV_ARB: return (direction>0 ? Inp_ARBAllowBuy : Inp_ARBAllowSell);
      default:     return false;
   }
}

int SessionMaskForSetup(const ENUM_BV_SETUP type)
{
   switch(type)
   {
      case BV_DDB: return Inp_DDBSessionMask;
      case BV_FB:  return Inp_FBSessionMask;
      case BV_SB:  return Inp_SBSessionMask;
      case BV_BB:  return Inp_BBSessionMask;
      case BV_RB:  return Inp_RBSessionMask;
      case BV_IRB: return Inp_IRBSessionMask;
      case BV_ARB: return Inp_ARBSessionMask;
      default:     return 7;
   }
}

int DirectionalSessionMaskForSetup(const ENUM_BV_SETUP type,const int direction)
{
   switch(type)
   {
      case BV_DDB: return (direction>0 ? Inp_DDBBuySessionMask : Inp_DDBSellSessionMask);
      case BV_FB:  return (direction>0 ? Inp_FBBuySessionMask  : Inp_FBSellSessionMask);
      case BV_SB:  return (direction>0 ? Inp_SBBuySessionMask  : Inp_SBSellSessionMask);
      case BV_BB:  return (direction>0 ? Inp_BBBuySessionMask  : Inp_BBSellSessionMask);
      case BV_RB:  return (direction>0 ? Inp_RBBuySessionMask  : Inp_RBSellSessionMask);
      case BV_IRB: return (direction>0 ? Inp_IRBBuySessionMask : Inp_IRBSellSessionMask);
      case BV_ARB: return (direction>0 ? Inp_ARBBuySessionMask : Inp_ARBSellSessionMask);
      default:     return 0;
   }
}

bool SessionAllowedForSetup(const ENUM_BV_SETUP type,const int direction,const datetime signalTime)
{
   MqlDateTime value;
   TimeToStruct(signalTime,value);
   int bit=1;
   if(value.hour>=16) bit=4;
   else if(value.hour>=8) bit=2;
   const int mask=(Inp_UseDirectionalSessionMasks ?
                   DirectionalSessionMaskForSetup(type,direction) :
                   SessionMaskForSetup(type));
   return ((mask&bit)!=0);
}

int SessionBitAt(const datetime serverTime)
{
   MqlDateTime value;
   TimeToStruct(serverTime,value);
   if(value.hour>=16) return 4;
   if(value.hour>=8)  return 2;
   return 1;
}

bool SymbolTradingSessionOpen(const datetime serverTime)
{
   MqlDateTime current;
   TimeToStruct(serverTime,current);
   const int secondsNow=current.hour*3600+current.min*60+current.sec;
   datetime sessionFrom=0,sessionTo=0;
   for(uint index=0;index<24;index++)
   {
      if(!SymbolInfoSessionTrade(_Symbol,(ENUM_DAY_OF_WEEK)current.day_of_week,index,
                                 sessionFrom,sessionTo))
         break;
      const int secondsFrom=(int)(sessionFrom%86400);
      const int secondsTo=(int)(sessionTo%86400);
      if(secondsFrom==secondsTo)
         return true;
      if(secondsFrom<secondsTo)
      {
         if(secondsNow>=secondsFrom && secondsNow<secondsTo)
            return true;
      }
      else if(secondsNow>=secondsFrom || secondsNow<secondsTo)
         return true;
   }
   return false;
}

double CandleRange(const MqlRates &bar)
{
   return bar.high - bar.low;
}

double CandleBody(const MqlRates &bar)
{
   return MathAbs(bar.close - bar.open);
}

double BodyRatio(const MqlRates &bar)
{
   const double range = CandleRange(bar);
   if(range <= 0.0)
      return 1.0;
   return CandleBody(bar) / range;
}

bool IsBull(const MqlRates &bar)
{
   return bar.close > bar.open;
}

bool IsBear(const MqlRates &bar)
{
   return bar.close < bar.open;
}

bool IsDoji(const MqlRates &bar)
{
   return BodyRatio(bar) <= Inp_DojiBodyRatio;
}

double CloseLocation(const MqlRates &bar)
{
   const double range = CandleRange(bar);
   if(range <= 0.0)
      return 0.5;
   return (bar.close - bar.low) / range;
}

double OverlapRatio(const MqlRates &a,const MqlRates &b)
{
   const double overlap = MathMax(0.0,MathMin(a.high,b.high)-MathMax(a.low,b.low));
   const double base = MathMin(CandleRange(a),CandleRange(b));
   if(base <= 0.0)
      return 0.0;
   return overlap/base;
}

double WindowHigh(const MqlRates &rates[],const int start,const int count)
{
   double value = rates[start].high;
   for(int i=start+1;i<start+count;i++)
      value = MathMax(value,rates[i].high);
   return value;
}

double WindowLow(const MqlRates &rates[],const int start,const int count)
{
   double value = rates[start].low;
   for(int i=start+1;i<start+count;i++)
      value = MathMin(value,rates[i].low);
   return value;
}

double NormalizePriceNearest(const double price)
{
   const double tickSize = SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE);
   if(tickSize <= 0.0)
      return NormalizeDouble(price,_Digits);
   return NormalizeDouble(MathRound(price/tickSize)*tickSize,_Digits);
}

double NormalizeTrigger(const double price,const int direction)
{
   const double tickSize = SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE);
   if(tickSize <= 0.0)
      return NormalizeDouble(price,_Digits);
   const double ticks = price/tickSize;
   const double normalized = (direction > 0 ? MathCeil(ticks) : MathFloor(ticks))*tickSize;
   return NormalizeDouble(normalized,_Digits);
}

double NormalizeStop(const double price,const int direction)
{
   const double tickSize = SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE);
   if(tickSize <= 0.0)
      return NormalizeDouble(price,_Digits);
   const double ticks = price/tickSize;
   const double normalized = (direction > 0 ? MathFloor(ticks) : MathCeil(ticks))*tickSize;
   return NormalizeDouble(normalized,_Digits);
}

int VolumeDigits()
{
   const double step = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP);
   if(step >= 1.0)   return 0;
   if(step >= 0.1)   return 1;
   if(step >= 0.01)  return 2;
   if(step >= 0.001) return 3;
   return 4;
}

double NormalizeVolumeDown(const double rawVolume)
{
   const double minVolume = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN);
   const double maxVolume = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MAX);
   const double step = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP);
   if(step <= 0.0 || rawVolume < minVolume)
      return 0.0;
   double volume = MathFloor((rawVolume+1e-12)/step)*step;
   volume = MathMin(volume,maxVolume);
   if(volume < minVolume)
      return 0.0;
   return NormalizeDouble(volume,VolumeDigits());
}

bool IsSuccessfulRetcode(const uint retcode)
{
   return (retcode==TRADE_RETCODE_DONE ||
           retcode==TRADE_RETCODE_DONE_PARTIAL ||
           retcode==TRADE_RETCODE_PLACED);
}

bool HasOwnPosition()
{
   for(int i=PositionsTotal()-1;i>=0;i--)
   {
      const ulong ticket = PositionGetTicket(i);
      if(ticket==0 || !PositionSelectByTicket(ticket))
         continue;
      if(PositionGetString(POSITION_SYMBOL)==_Symbol &&
         (ulong)PositionGetInteger(POSITION_MAGIC)==Inp_MagicNumber)
         return true;
   }
   return false;
}

int OwnPositionCount()
{
   int count=0;
   for(int i=PositionsTotal()-1;i>=0;i--)
   {
      const ulong ticket=PositionGetTicket(i);
      if(ticket==0 || !PositionSelectByTicket(ticket))
         continue;
      if(PositionGetString(POSITION_SYMBOL)==_Symbol &&
         (ulong)PositionGetInteger(POSITION_MAGIC)==Inp_MagicNumber)
         count++;
   }
   return count;
}

bool CanOpenAnotherPosition()
{
   const int ownPositions=OwnPositionCount();
   if(!Inp_AllowMultiplePositions)
      return (ownPositions==0);
   return (Inp_MaxOpenPositions<=0 || ownPositions<Inp_MaxOpenPositions);
}

double EntryBuffer()
{
   return MathMax(0.0,Inp_EntryBufferPoints)*_Point;
}

double StopBuffer(const double atr)
{
   return MathMax(MathMax(0.0,Inp_SLBufferPoints)*_Point,
                  MathMax(0.0,Inp_SLBufferATR)*atr);
}

int TrendDirection(const MqlRates &rates[],const double &ema[],const int slopeBars)
{
   const int back = MathMax(1,slopeBars);
   if(rates[1].close>ema[1] && ema[1]>ema[1+back])
      return 1;
   if(rates[1].close<ema[1] && ema[1]<ema[1+back])
      return -1;
   return 0;
}

void ResetCandidate(SetupCandidate &candidate)
{
   candidate.valid=false;
   candidate.type=BV_NONE;
   candidate.direction=0;
   candidate.signal_time=0;
   candidate.trigger=0.0;
   candidate.stop_loss=0.0;
   candidate.score=0.0;
   candidate.reason="";
   candidate.wyckoff_event=WY_NONE;
   ResetMarketContext(candidate.context);
   candidate.m5_signal_time=0;
   candidate.m5_signal_open=0.0;
   candidate.m5_signal_high=0.0;
   candidate.m5_signal_low=0.0;
   candidate.m5_signal_close=0.0;
   candidate.m5_atr=0.0;
   candidate.m5_body_ratio=0.0;
   candidate.m5_wait_bars=0;
}

void BuildCandidate(SetupCandidate &candidate,
                    const ENUM_BV_SETUP type,
                    const int direction,
                    const MqlRates &signalBar,
                    const double trigger,
                    const double stopLoss,
                    const double score,
                    const string reason)
{
   ResetCandidate(candidate);
   candidate.valid=true;
   candidate.type=type;
   candidate.direction=direction;
   candidate.signal_time=signalBar.time;
   candidate.trigger=NormalizeTrigger(trigger,direction);
   candidate.stop_loss=NormalizeStop(stopLoss,direction);
   candidate.score=score;
   candidate.reason=reason;
}

bool CandidateGeometryValid(const SetupCandidate &candidate,const double atr)
{
   if(!candidate.valid || atr<=0.0)
      return false;
   if(!DirectionAllowedForSetup(candidate.type,candidate.direction))
      return false;
   const double risk = (candidate.direction>0 ? candidate.trigger-candidate.stop_loss
                                               : candidate.stop_loss-candidate.trigger);
   if(risk<=0.0)
      return false;
   return risk<=MaxSignalATRForSetup(candidate.type)*atr;
}

//+------------------------------------------------------------------+
//| SETUP DDB - Double Doji Break                                    |
//| Two overlapping compact doji bars; breakout follows H1 context.  |
//+------------------------------------------------------------------+
bool DetectDDB(const MqlRates &rates[],const int trend,const double atr,SetupCandidate &candidate)
{
   ResetCandidate(candidate);
   if(!Inp_EnableDDB || trend==0 || !IsDoji(rates[1]) || !IsDoji(rates[2]))
      return false;
   if(OverlapRatio(rates[1],rates[2])<Inp_DDBMinOverlapRatio)
      return false;
   const double combinedHigh=MathMax(rates[1].high,rates[2].high);
   const double combinedLow=MathMin(rates[1].low,rates[2].low);
   if(combinedHigh-combinedLow>1.10*atr)
      return false;
   const double buffer=StopBuffer(atr);
   const double entryBuffer=EntryBuffer()+Inp_DDBEntryBufferATR*atr;
   if(trend>0)
      BuildCandidate(candidate,BV_DDB,1,rates[1],combinedHigh+entryBuffer,rates[1].low-buffer,70.0,"two overlapping doji bars in bullish context");
   else
      BuildCandidate(candidate,BV_DDB,-1,rates[1],combinedLow-entryBuffer,rates[1].high+buffer,70.0,"two overlapping doji bars in bearish context");
   return CandidateGeometryValid(candidate,atr);
}

int CountPullbackBars(const MqlRates &rates[],const int trend)
{
   int count=0;
   for(int i=1;i<=Inp_MaxPullbackBars;i++)
   {
      bool pullback=false;
      if(trend>0)
         pullback=(rates[i].close<=rates[i].open || rates[i].high<rates[i+1].high);
      else
         pullback=(rates[i].close>=rates[i].open || rates[i].low>rates[i+1].low);
      if(!pullback)
         break;
      count++;
   }
   return count;
}

//+------------------------------------------------------------------+
//| SETUP FB - First Break                                           |
//| First with-trend break attempt after an orderly H1 pullback.      |
//+------------------------------------------------------------------+
bool DetectFB(const MqlRates &rates[],const int trend,const double atr,SetupCandidate &candidate)
{
   ResetCandidate(candidate);
   if(!Inp_EnableFB || trend==0)
      return false;
   const int pullbackBars=CountPullbackBars(rates,trend);
   if(pullbackBars<Inp_MinPullbackBars || pullbackBars>Inp_MaxPullbackBars)
      return false;
   const double buffer=StopBuffer(atr);
   if(trend>0 && CloseLocation(rates[1])<0.20)
      BuildCandidate(candidate,BV_FB,1,rates[1],rates[1].high+EntryBuffer(),rates[1].low-buffer,65.0+pullbackBars,"first bullish break after orderly pullback");
   else if(trend<0 && CloseLocation(rates[1])>0.80)
      BuildCandidate(candidate,BV_FB,-1,rates[1],rates[1].low-EntryBuffer(),rates[1].high+buffer,65.0+pullbackBars,"first bearish break after orderly pullback");
   return CandidateGeometryValid(candidate,atr);
}

//+------------------------------------------------------------------+
//| SETUP SB - Second Break                                          |
//| A first reversal attempt stalls, followed by a second pullback.  |
//+------------------------------------------------------------------+
bool DetectSB(const MqlRates &rates[],const int trend,const double atr,SetupCandidate &candidate)
{
   ResetCandidate(candidate);
   if(!Inp_EnableSB || trend==0)
      return false;
   const double tolerance=0.15*atr;
   const double buffer=StopBuffer(atr)+Inp_SBExtraSLBufferATR*atr;
   const double entryBuffer=EntryBuffer()+Inp_SBEntryBufferATR*atr;
   if(trend>0)
   {
      const bool firstLeg=(rates[4].low>rates[3].low);
      const bool firstAttempt=(IsBull(rates[2]) && rates[2].high>rates[3].high &&
                               BodyRatio(rates[2])>=Inp_SBMinAttemptBodyRatio);
      const bool secondPullback=(!IsBull(rates[1]) && rates[1].low>=rates[3].low-tolerance &&
                                 CloseLocation(rates[1])>=Inp_SBMinSignalCloseZone);
      if(firstLeg && firstAttempt && secondPullback)
         BuildCandidate(candidate,BV_SB,1,rates[1],rates[1].high+entryBuffer,rates[1].low-buffer,90.0,"second bullish break after first attempt stalled");
   }
   else
   {
      const bool firstLeg=(rates[4].high<rates[3].high);
      const bool firstAttempt=(IsBear(rates[2]) && rates[2].low<rates[3].low &&
                               BodyRatio(rates[2])>=Inp_SBMinAttemptBodyRatio);
      const bool secondPullback=(!IsBear(rates[1]) && rates[1].high<=rates[3].high+tolerance &&
                                 CloseLocation(rates[1])<=1.0-Inp_SBMinSignalCloseZone);
      if(firstLeg && firstAttempt && secondPullback)
         BuildCandidate(candidate,BV_SB,-1,rates[1],rates[1].low-entryBuffer,rates[1].high+buffer,90.0,"second bearish break after first attempt stalled");
   }
   return CandidateGeometryValid(candidate,atr);
}

//+------------------------------------------------------------------+
//| SETUP BB - Block Break                                           |
//| Tight multi-bar overlap block; breakout follows H1 context.      |
//+------------------------------------------------------------------+
bool DetectBB(const MqlRates &rates[],const int trend,const double atr,SetupCandidate &candidate)
{
   ResetCandidate(candidate);
   if(!Inp_EnableBB || trend==0 || Inp_BlockBars<3)
      return false;
   const double blockHigh=WindowHigh(rates,1,Inp_BlockBars);
   const double blockLow=WindowLow(rates,1,Inp_BlockBars);
   if(blockHigh-blockLow>Inp_BlockMaxATR*atr)
      return false;
   double overlapSum=0.0;
   for(int i=1;i<Inp_BlockBars;i++)
      overlapSum+=OverlapRatio(rates[i],rates[i+1]);
   if(overlapSum/(Inp_BlockBars-1)<Inp_BBMinOverlapRatio)
      return false;
   if(BodyRatio(rates[1])<Inp_BBMinSignalBodyRatio)
      return false;
   const double blockHeight=MathMax(blockHigh-blockLow,_Point);
   const double location=(rates[1].close-blockLow)/blockHeight;
   const double pressureZone=MathMin(0.50,MathMax(0.05,Inp_BBPressureZonePct));
   int topPressure=0,bottomPressure=0;
   for(int i=1;i<=Inp_BlockBars;i++)
   {
      if(rates[i].close>=blockHigh-pressureZone*blockHeight) topPressure++;
      if(rates[i].close<=blockLow+pressureZone*blockHeight) bottomPressure++;
   }
   const double buffer=StopBuffer(atr)+Inp_BBExtraSLBufferATR*atr;
   if(trend>0 && location>=0.55 && topPressure>=Inp_BBMinPressureBars)
      BuildCandidate(candidate,BV_BB,1,rates[1],blockHigh+EntryBuffer(),rates[1].low-buffer,76.0+topPressure,"tight bullish pressure block");
   else if(trend<0 && location<=0.45 && bottomPressure>=Inp_BBMinPressureBars)
      BuildCandidate(candidate,BV_BB,-1,rates[1],blockLow-EntryBuffer(),rates[1].high+buffer,76.0+bottomPressure,"tight bearish pressure block");
   return CandidateGeometryValid(candidate,atr);
}

bool RangeQuality(const MqlRates &rates[],const int start,const int count,const double atr,
                  const double minATR,const double maxATR,const int minTouches,
                  double &rangeHigh,double &rangeLow,int &highTouches,int &lowTouches)
{
   rangeHigh=WindowHigh(rates,start,count);
   rangeLow=WindowLow(rates,start,count);
   const double height=rangeHigh-rangeLow;
   if(height<minATR*atr || height>maxATR*atr)
      return false;
   const double tolerance=MathMax(0.10*height,0.12*atr);
   highTouches=0;
   lowTouches=0;
   for(int i=start;i<start+count;i++)
   {
      if(rangeHigh-rates[i].high<=tolerance) highTouches++;
      if(rates[i].low-rangeLow<=tolerance)   lowTouches++;
   }
   return (highTouches>=minTouches && lowTouches>=minTouches);
}

//+------------------------------------------------------------------+
//| SETUP RB - Range Break                                           |
//| Established range plus repeated closes pressing one edge.        |
//+------------------------------------------------------------------+
bool DetectRB(const MqlRates &rates[],const int trend,const double atr,SetupCandidate &candidate)
{
   ResetCandidate(candidate);
   if(!Inp_EnableRB || Inp_RangeBars<6)
      return false;
   double rangeHigh,rangeLow;
   int highTouches,lowTouches;
   if(!RangeQuality(rates,1,Inp_RangeBars,atr,Inp_RangeMinATR,Inp_RangeMaxATR,
                    Inp_MinRangeTouches,rangeHigh,rangeLow,highTouches,lowTouches))
      return false;
   const double height=rangeHigh-rangeLow;
   int topPressure=0,bottomPressure=0;
   for(int i=1;i<=3;i++)
   {
      if(rates[i].close>=rangeHigh-Inp_EdgeZonePct*height) topPressure++;
      if(rates[i].close<=rangeLow+Inp_EdgeZonePct*height)  bottomPressure++;
   }
   const double buffer=StopBuffer(atr);
   if(topPressure>=2 && trend>=0)
      BuildCandidate(candidate,BV_RB,1,rates[1],rangeHigh+EntryBuffer(),rates[1].low-buffer,60.0+topPressure,"repeated pressure at upper range edge");
   else if(bottomPressure>=2 && trend<=0)
      BuildCandidate(candidate,BV_RB,-1,rates[1],rangeLow-EntryBuffer(),rates[1].high+buffer,60.0+bottomPressure,"repeated pressure at lower range edge");
   return CandidateGeometryValid(candidate,atr);
}

//+------------------------------------------------------------------+
//| SETUP IRB - Inside Range Break                                   |
//| Two compressed bars remain inside an older range near one edge.  |
//+------------------------------------------------------------------+
bool DetectIRB(const MqlRates &rates[],const int trend,const double atr,SetupCandidate &candidate)
{
   ResetCandidate(candidate);
   if(!Inp_EnableIRB || Inp_IRBRangeBars<6)
      return false;
   double rangeHigh,rangeLow;
   int highTouches,lowTouches;
   if(!RangeQuality(rates,3,Inp_IRBRangeBars,atr,Inp_IRBRangeMinATR,Inp_IRBRangeMaxATR,
                    Inp_IRBMinRangeTouches,rangeHigh,rangeLow,highTouches,lowTouches))
      return false;
   const bool inside=(rates[1].high<=rangeHigh && rates[1].low>=rangeLow &&
                      rates[2].high<=rangeHigh && rates[2].low>=rangeLow);
   if(!inside || CandleRange(rates[1])>Inp_IRBMaxCandleATR*atr ||
      CandleRange(rates[2])>Inp_IRBMaxCandleATR*atr)
      return false;
   const double height=rangeHigh-rangeLow;
   const double buffer=StopBuffer(atr);
   if(rates[1].close>=rangeHigh-Inp_IRBEdgeZonePct*height && trend>=0)
      BuildCandidate(candidate,BV_IRB,1,rates[1],rangeHigh+EntryBuffer(),rates[1].low-buffer,82.0,"inside compression at upper range edge");
   else if(rates[1].close<=rangeLow+Inp_IRBEdgeZonePct*height && trend<=0)
      BuildCandidate(candidate,BV_IRB,-1,rates[1],rangeLow-EntryBuffer(),rates[1].high+buffer,82.0,"inside compression at lower range edge");
   return CandidateGeometryValid(candidate,atr);
}

//+------------------------------------------------------------------+
//| SETUP ARB - Advanced Range Break                                 |
//| False break of one edge, re-entry, then pressure to other edge.  |
//+------------------------------------------------------------------+
bool DetectARB(const MqlRates &rates[],const int trend,const double atr,SetupCandidate &candidate)
{
   ResetCandidate(candidate);
   if(!Inp_EnableARB || Inp_ARBRangeBars<6)
      return false;
   double rangeHigh,rangeLow;
   int highTouches,lowTouches;
   if(!RangeQuality(rates,4,Inp_ARBRangeBars,atr,Inp_ARBRangeMinATR,Inp_ARBRangeMaxATR,
                    Inp_ARBMinRangeTouches,rangeHigh,rangeLow,highTouches,lowTouches))
      return false;
   const double falseBreakBuffer=0.05*atr;
   const bool falseDown=(rates[3].low<rangeLow-falseBreakBuffer && rates[3].close>rangeLow);
   const bool falseUp=(rates[3].high>rangeHigh+falseBreakBuffer && rates[3].close<rangeHigh);
   const bool bullFollow=(rates[2].close>rates[3].close && rates[1].close>=rates[2].close);
   const bool bearFollow=(rates[2].close<rates[3].close && rates[1].close<=rates[2].close);
   const double buffer=StopBuffer(atr);
   if(falseDown && bullFollow && trend>=0 && rates[1].close>=rangeHigh-Inp_ARBEdgeZonePct*(rangeHigh-rangeLow))
      BuildCandidate(candidate,BV_ARB,1,rates[1],rangeHigh+EntryBuffer(),rates[1].low-buffer,86.0,"false downside break followed by bullish range pressure");
   else if(falseUp && bearFollow && trend<=0 && rates[1].close<=rangeLow+Inp_ARBEdgeZonePct*(rangeHigh-rangeLow))
      BuildCandidate(candidate,BV_ARB,-1,rates[1],rangeLow-EntryBuffer(),rates[1].high+buffer,86.0,"false upside break followed by bearish range pressure");
   return CandidateGeometryValid(candidate,atr);
}

//+------------------------------------------------------------------+
//| Annotation and logging                                           |
//+------------------------------------------------------------------+
void DrawTextTag(const string prefix,const datetime time,const double price,const string text,const color clr)
{
   if(!Inp_DrawAnnotations)
      return;
   const string name=prefix+"_"+IntegerToString((int)time)+"_"+IntegerToString((int)GetTickCount());
   if(!ObjectCreate(0,name,OBJ_TEXT,0,time,price))
      return;
   ObjectSetString(0,name,OBJPROP_TEXT,text);
   ObjectSetInteger(0,name,OBJPROP_COLOR,clr);
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,8);
   ObjectSetInteger(0,name,OBJPROP_ANCHOR,ANCHOR_CENTER);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
}

void AnnotateSetup(const SetupCandidate &candidate,const double atr)
{
   const color clr=(candidate.direction>0 ? clrDeepSkyBlue : clrTomato);
   const double y=(candidate.direction>0 ? candidate.stop_loss-0.10*atr : candidate.stop_loss+0.10*atr);
   const string wy=(candidate.wyckoff_event==WY_NONE ? "" : " | WY:"+WyckoffEventCode(candidate.wyckoff_event));
   const string context=(candidate.context.valid ? " | CTX:"+candidate.context.confluence_tier+
                         " ELL:"+candidate.context.elliott_phase : "");
   const string label=SetupCode(candidate.type)+" "+DirectionText(candidate.direction)+" SETUP"+wy+context;
   DrawTextTag("BV_SETUP",candidate.signal_time,y,label,clr);
   PrintFormat("[BV-H1][SETUP:%s][%s][WY:%s] signal=%s trigger=%.*f SL=%.*f score=%.1f | T24=%s T72=%s(%.5f/R2 %.3f) T240=%s | TRANS=%s VOL=%s(%.3f) ACT=%s(%.3f) LOC=%s(%.3f) WYP=%s ELL=%s/%s CONF=%s(%d) | %s",
               SetupCode(candidate.type),DirectionText(candidate.direction),
               WyckoffEventCode(candidate.wyckoff_event),
               TimeToString(candidate.signal_time,TIME_DATE|TIME_MINUTES),
               _Digits,candidate.trigger,_Digits,candidate.stop_loss,
               candidate.score,candidate.context.trend_24,candidate.context.trend_72,
               candidate.context.slope_72_atr,candidate.context.r2_72,candidate.context.trend_240,
               candidate.context.transition_state,candidate.context.volatility_state,candidate.context.volatility_ratio,
               candidate.context.activity_state,candidate.context.activity_ratio,
               candidate.context.location_state,candidate.context.range_position_240,
               candidate.context.wyckoff_phase,candidate.context.elliott_phase,
               candidate.context.elliott_alignment,candidate.context.confluence_tier,
               candidate.context.confluence_score,candidate.reason);
}

void AnnotateEntry(const SetupCandidate &candidate,const double entryPrice)
{
   const color clr=(candidate.direction>0 ? clrLimeGreen : clrOrangeRed);
   const string wy=(candidate.wyckoff_event==WY_NONE ? "" : " | WY:"+WyckoffEventCode(candidate.wyckoff_event));
   const string context=(candidate.context.valid ? " | CTX:"+candidate.context.confluence_tier+
                         " ELL:"+candidate.context.elliott_phase : "");
   const string label="ENTRY "+SetupCode(candidate.type)+" "+DirectionText(candidate.direction)+wy+context;
   DrawTextTag("BV_ENTRY",TimeCurrent(),entryPrice,label,clr);
}

void AnnotateWyckoff(const WyckoffContext &context,const MqlRates &rates[],const double atr)
{
   if(!Inp_DrawWyckoffAnnotations || !context.valid || context.event_time==g_lastWyckoffAnnotationTime)
      return;
   int shift=iBarShift(_Symbol,PERIOD_H1,context.event_time,false);
   if(shift<1)
      return;
   const double y=(context.bias>0 ? rates[shift].low-0.15*atr : rates[shift].high+0.15*atr);
   const color clr=(context.bias>0 ? clrMediumSeaGreen : clrIndianRed);
   DrawTextTag("WY_EVENT",context.event_time,y,"WY "+WyckoffEventCode(context.event),clr);
   g_lastWyckoffAnnotationTime=context.event_time;
}

//+------------------------------------------------------------------+
//| Detection orchestration                                          |
//+------------------------------------------------------------------+
bool GetMarketData(MqlRates &rates[],double &ema[],double &atr[])
{
   const int wyckoffNeeded=MathMax(6,Inp_WyckoffLookback)+MathMax(1,Inp_WyckoffValidBars)+5;
   const int rangeNeeded=MathMax(Inp_RangeBars,MathMax(Inp_IRBRangeBars,Inp_ARBRangeBars))+12;
   const int contextNeeded=MathMax(Inp_ContextLongTrendBars+2,
                                   Inp_ElliottLookback+Inp_ElliottPivotSpan+2);
   const int needed=MathMax(MathMax(80,MathMax(Inp_ContextTrendBars+2,contextNeeded)),
                            MathMax(rangeNeeded,wyckoffNeeded));
   ArraySetAsSeries(rates,true);
   ArraySetAsSeries(ema,true);
   ArraySetAsSeries(atr,true);
   if(CopyRates(_Symbol,PERIOD_H1,0,needed,rates)<needed)
      return false;
   if(CopyBuffer(g_emaHandle,0,0,needed,ema)<needed)
      return false;
   if(CopyBuffer(g_atrHandle,0,0,needed,atr)<needed)
      return false;
   return true;
}

bool GetM5SetupData(MqlRates &rates[],double &atr[])
{
   const int rangeNeeded=MathMax(Inp_RangeBars,MathMax(Inp_IRBRangeBars,Inp_ARBRangeBars))+12;
   const int pullbackNeeded=Inp_MaxPullbackBars+8;
   const int needed=MathMax(80,MathMax(rangeNeeded,pullbackNeeded));
   ArraySetAsSeries(rates,true);
   ArraySetAsSeries(atr,true);
   if(CopyRates(_Symbol,PERIOD_M5,0,needed,rates)<needed)
      return false;
   if(CopyBuffer(g_m5AtrHandle,0,0,needed,atr)<needed)
      return false;
   return true;
}

bool RollingTrendStats(const MqlRates &rates[],const int bars,const double atr,
                       double &slopeATR,double &rSquared)
{
   slopeATR=0.0;
   rSquared=0.0;
   if(atr<=0.0 || bars<12 || ArraySize(rates)<=bars)
      return false;

   double sumX=0.0,sumY=0.0,sumXX=0.0,sumYY=0.0,sumXY=0.0;
   for(int x=0;x<bars;x++)
   {
      // rates[] is series: shift=bars is oldest and shift=1 is the signal bar.
      const int shift=bars-x;
      const double y=rates[shift].close;
      sumX+=(double)x;
      sumY+=y;
      sumXX+=(double)x*(double)x;
      sumYY+=y*y;
      sumXY+=(double)x*y;
   }
   const double n=(double)bars;
   const double xDenominator=n*sumXX-sumX*sumX;
   const double yDenominator=n*sumYY-sumY*sumY;
   if(xDenominator<=0.0 || yDenominator<=0.0)
      return false;
   const double numerator=n*sumXY-sumX*sumY;
   const double slope=numerator/xDenominator;
   slopeATR=slope/atr;
   rSquared=(numerator*numerator)/(xDenominator*yDenominator);
   return true;
}

string ClassifyTrend(const double slopeATR,const double rSquared,
                     const double minR2,const double minSlopeATR)
{
   if(rSquared<minR2 || MathAbs(slopeATR)<minSlopeATR)
      return "RANGE";
   return (slopeATR>0.0 ? "UP" : "DOWN");
}

string DirectionalAlignment(const string trend,const int direction)
{
   if(trend=="RANGE")
      return "RANGE";
   const bool aligned=((trend=="UP" && direction>0) || (trend=="DOWN" && direction<0));
   return (aligned ? "ALIGNED" : "COUNTER");
}

int AlignmentScore(const string alignment)
{
   if(alignment=="ALIGNED") return 1;
   if(alignment=="COUNTER") return -1;
   return 0;
}

double RMSLogReturn(const MqlRates &rates[],const int count)
{
   if(count<1 || ArraySize(rates)<=count+1)
      return 0.0;
   double sumSquares=0.0;
   for(int shift=1;shift<=count;shift++)
   {
      if(rates[shift].close<=0.0 || rates[shift+1].close<=0.0)
         continue;
      const double value=MathLog(rates[shift].close/rates[shift+1].close);
      sumSquares+=value*value;
   }
   return MathSqrt(sumSquares/count);
}

double ContextActivity(const MqlRates &rates[],const int count)
{
   if(count<1 || ArraySize(rates)<=count)
      return 0.0;
   double total=0.0;
   for(int shift=1;shift<=count;shift++)
      total+=(double)rates[shift].tick_volume;
   return total/count;
}

string WyckoffPhase(const ENUM_WYCKOFF_EVENT event,const int direction)
{
   switch(event)
   {
      case WY_SPRING:   return "ACCUMULATION_REVERSAL";
      case WY_SOS:      return "MARKUP_CONFIRMATION";
      case WY_LPS:      return "REACCUMULATION";
      case WY_UPTHRUST: return "DISTRIBUTION_REVERSAL";
      case WY_SOW:      return "MARKDOWN_CONFIRMATION";
      case WY_LPSY:     return "REDISTRIBUTION";
      case WY_TEST:     return (direction>0 ? "ACCUMULATION_TEST" : "DISTRIBUTION_TEST");
      default:          return "NO_EVENT";
   }
}

void AddConfirmedPivot(int &types[],double &prices[],const int type,const double price)
{
   int count=ArraySize(types);
   if(count>0 && types[count-1]==type)
   {
      const bool moreExtreme=((type>0 && price>=prices[count-1]) ||
                              (type<0 && price<=prices[count-1]));
      if(moreExtreme)
         prices[count-1]=price;
      return;
   }
   ArrayResize(types,count+1);
   ArrayResize(prices,count+1);
   types[count]=type;       // +1 swing high, -1 swing low
   prices[count]=price;
}

void BuildConfirmedPivots(const MqlRates &rates[],int &types[],double &prices[])
{
   ArrayResize(types,0);
   ArrayResize(prices,0);
   const int span=MathMax(1,Inp_ElliottPivotSpan);
   const int maximum=MathMin(Inp_ElliottLookback,ArraySize(rates)-span-1);
   // Walk oldest to newest. A pivot is only accepted after 'span' newer bars.
   for(int shift=maximum;shift>=span+1;shift--)
   {
      bool isHigh=true,isLow=true;
      for(int offset=1;offset<=span;offset++)
      {
         if(rates[shift].high<=rates[shift+offset].high || rates[shift].high<rates[shift-offset].high)
            isHigh=false;
         if(rates[shift].low>=rates[shift+offset].low || rates[shift].low>rates[shift-offset].low)
            isLow=false;
      }
      if(isHigh && !isLow) AddConfirmedPivot(types,prices,1,rates[shift].high);
      if(isLow && !isHigh) AddConfirmedPivot(types,prices,-1,rates[shift].low);
   }
}

bool BetweenInclusive(const double value,const double minimum,const double maximum)
{
   return (value>=minimum && value<=maximum);
}

bool BullImpulseBase(const int &types[],const double &prices[],const int start)
{
   if(types[start]!=-1 || types[start+1]!=1 || types[start+2]!=-1)
      return false;
   const double wave1=prices[start+1]-prices[start];
   if(wave1<=0.0 || prices[start+2]<=prices[start])
      return false;
   const double retrace2=(prices[start+1]-prices[start+2])/wave1;
   return BetweenInclusive(retrace2,0.236,0.886);
}

bool BearImpulseBase(const int &types[],const double &prices[],const int start)
{
   if(types[start]!=1 || types[start+1]!=-1 || types[start+2]!=1)
      return false;
   const double wave1=prices[start]-prices[start+1];
   if(wave1<=0.0 || prices[start+2]>=prices[start])
      return false;
   const double retrace2=(prices[start+2]-prices[start+1])/wave1;
   return BetweenInclusive(retrace2,0.236,0.886);
}

string ClassifyElliottFive(const int &types[],const double &prices[],const int start)
{
   if(types[start]==-1 && types[start+1]==1 && types[start+2]==-1 &&
      types[start+3]==1 && types[start+4]==-1 && BullImpulseBase(types,prices,start) &&
      prices[start+3]>prices[start+1] && prices[start+4]>prices[start+2])
   {
      const double wave3=prices[start+3]-prices[start+2];
      const double retrace4=(wave3>0.0 ? (prices[start+3]-prices[start+4])/wave3 : -1.0);
      if(BetweenInclusive(retrace4,0.146,0.786)) return "BULL_W5";
   }
   if(types[start]==1 && types[start+1]==-1 && types[start+2]==1 &&
      types[start+3]==-1 && types[start+4]==1 && BearImpulseBase(types,prices,start) &&
      prices[start+3]<prices[start+1] && prices[start+4]<prices[start+2])
   {
      const double wave3=prices[start+2]-prices[start+3];
      const double retrace4=(wave3>0.0 ? (prices[start+4]-prices[start+3])/wave3 : -1.0);
      if(BetweenInclusive(retrace4,0.146,0.786)) return "BEAR_W5";
   }
   return "UNDEFINED";
}

string DetectElliottPhase(const MqlRates &rates[])
{
   int types[];
   double prices[];
   BuildConfirmedPivots(rates,types,prices);
   const int count=ArraySize(types);
   if(count>=6)
   {
      const int start=count-6;
      const string firstFive=ClassifyElliottFive(types,prices,start);
      if(firstFive=="BULL_W5" && types[start+5]==1 && prices[start+5]>prices[start+3])
         return "BULL_IMPULSE_COMPLETE";
      if(firstFive=="BEAR_W5" && types[start+5]==-1 && prices[start+5]<prices[start+3])
         return "BEAR_IMPULSE_COMPLETE";
   }
   if(count>=5)
   {
      const string phase=ClassifyElliottFive(types,prices,count-5);
      if(phase!="UNDEFINED") return phase;
   }
   if(count>=4)
   {
      const int start=count-4;
      if(types[start]==-1 && types[start+1]==1 && types[start+2]==-1 && types[start+3]==1 &&
         BullImpulseBase(types,prices,start) && prices[start+3]>prices[start+1]) return "BULL_W4";
      if(types[start]==1 && types[start+1]==-1 && types[start+2]==1 && types[start+3]==-1 &&
         BearImpulseBase(types,prices,start) && prices[start+3]<prices[start+1]) return "BEAR_W4";
   }
   if(count>=3)
   {
      const int start=count-3;
      if(BullImpulseBase(types,prices,start)) return "BULL_W3";
      if(BearImpulseBase(types,prices,start)) return "BEAR_W3";
   }
   return "UNDEFINED";
}

string ElliottAlignment(const string phase,const int direction)
{
   if(phase=="BULL_W3" || phase=="BULL_W5") return (direction>0 ? "ALIGNED" : "COUNTER");
   if(phase=="BEAR_W3" || phase=="BEAR_W5") return (direction<0 ? "ALIGNED" : "COUNTER");
   if(StringFind(phase,"W4")>=0 || StringFind(phase,"COMPLETE")>=0) return "CORRECTIVE";
   return "UNDEFINED";
}

ENUM_IMBALANCE_FILTER_MODE ImbalanceModeForSetup(const ENUM_BV_SETUP setup,const int direction)
{
   switch(setup)
   {
      case BV_DDB: return (direction>0 ? Inp_DDBBuyImbalanceMode  : Inp_DDBSellImbalanceMode);
      case BV_FB:  return (direction>0 ? Inp_FBBuyImbalanceMode   : Inp_FBSellImbalanceMode);
      case BV_SB:  return (direction>0 ? Inp_SBBuyImbalanceMode   : Inp_SBSellImbalanceMode);
      case BV_BB:  return (direction>0 ? Inp_BBBuyImbalanceMode   : Inp_BBSellImbalanceMode);
      case BV_RB:  return (direction>0 ? Inp_RBBuyImbalanceMode   : Inp_RBSellImbalanceMode);
      case BV_IRB: return (direction>0 ? Inp_IRBBuyImbalanceMode  : Inp_IRBSellImbalanceMode);
      case BV_ARB: return (direction>0 ? Inp_ARBBuyImbalanceMode  : Inp_ARBSellImbalanceMode);
      default:     return IMB_FILTER_OFF;
   }
}

// Returns the direction and price zone of the most recent active three-candle FVG.
// A gap remains active until a later closed candle fully crosses its far edge.
int RecentActiveImbalanceZone(const MqlRates &rates[],const double &atr[],
                              const int lookback,double &zoneLow,double &zoneHigh,
                              double &gapATR,int &ageBars)
{
   zoneLow=0.0;
   zoneHigh=0.0;
   gapATR=0.0;
   ageBars=-1;
   const int maximum=MathMin(MathMax(1,lookback),MathMin(ArraySize(rates),ArraySize(atr))-3);
   for(int shift=1;shift<=maximum;shift++)
   {
      if(atr[shift]<=0.0 || BodyRatio(rates[shift+1])<Inp_ImbalanceMinBody)
         continue;
      const double bullishGap=rates[shift].low-rates[shift+2].high;
      const double bearishGap=rates[shift+2].low-rates[shift].high;
      const bool bullish=(bullishGap>=Inp_ImbalanceMinGapATR*atr[shift] && IsBull(rates[shift+1]));
      const bool bearish=(bearishGap>=Inp_ImbalanceMinGapATR*atr[shift] && IsBear(rates[shift+1]));
      if(!bullish && !bearish)
         continue;

      bool active=true;
      for(int recent=shift-1;recent>=1;recent--)
      {
         if((bullish && rates[recent].low<=rates[shift+2].high) ||
            (bearish && rates[recent].high>=rates[shift+2].low))
         {
            active=false;
            break;
         }
      }
      if(!active)
         continue;
      if(bullish)
      {
         zoneLow=rates[shift+2].high;
         zoneHigh=rates[shift].low;
      }
      else
      {
         zoneLow=rates[shift].high;
         zoneHigh=rates[shift+2].low;
      }
      gapATR=(zoneHigh-zoneLow)/atr[shift];
      ageBars=shift-1;
      return (bullish ? 1 : -1);
   }
   return 0;
}

int RecentActiveImbalanceBias(const MqlRates &rates[],const double &atr[],
                              const int lookback,double &gapATR,int &ageBars)
{
   double zoneLow=0.0,zoneHigh=0.0;
   return RecentActiveImbalanceZone(rates,atr,lookback,zoneLow,zoneHigh,gapATR,ageBars);
}

bool BBImpulseAligned(const SetupCandidate &candidate)
{
   const bool allowW3=((Inp_BBImpulsePhaseMask&1)!=0);
   const bool allowW5=((Inp_BBImpulsePhaseMask&2)!=0);
   if(candidate.direction>0)
      return ((allowW3 && candidate.context.elliott_phase=="BULL_W3") ||
              (allowW5 && candidate.context.elliott_phase=="BULL_W5"));
   return ((allowW3 && candidate.context.elliott_phase=="BEAR_W3") ||
           (allowW5 && candidate.context.elliott_phase=="BEAR_W5"));
}

bool BBLateWyckoffAligned(const SetupCandidate &candidate)
{
   if(!g_wyckoff.valid || g_wyckoff.bias!=candidate.direction ||
      g_wyckoff.age_bars>MathMax(1,Inp_BBLateWyckoffMaxAge))
      return false;
   if(candidate.direction>0)
      return (candidate.wyckoff_event==WY_SOS || candidate.wyckoff_event==WY_LPS);
   return (candidate.wyckoff_event==WY_SOW || candidate.wyckoff_event==WY_LPSY);
}

bool IRBContextAllowsSetup(const SetupCandidate &candidate)
{
   if(candidate.type!=BV_IRB)
      return true;
   if(Inp_IRBContextEventMask!=0)
   {
      const int eventBit=(1 << (int)candidate.wyckoff_event);
      if((Inp_IRBContextEventMask&eventBit)==0)
      {
         PrintFormat("[BV-H1CTX-M5][IRB-CONTEXT-REJECT] direction=%s Wyckoff=%s mask=%d",
                     DirectionText(candidate.direction),WyckoffEventCode(candidate.wyckoff_event),
                     Inp_IRBContextEventMask);
         return false;
      }
   }
   if(Inp_IRBBlockBuyLongDown && candidate.direction>0 && candidate.context.trend_240=="DOWN")
   {
      PrintFormat("[BV-H1CTX-M5][IRB-CONTEXT-REJECT] BUY conflicts with 240H trend; slope=%.4fATR r2=%.3f",
                  candidate.context.slope_240_atr,candidate.context.r2_240);
      return false;
   }
   return true;
}

bool BBStructureAllowsSetup(const SetupCandidate &candidate,
                            const MqlRates &m5Rates[],const double &m5Atr[])
{
   if(candidate.type!=BV_BB || Inp_BBStructureMode==BB_STRUCTURE_OFF)
      return true;

   double zoneLow=0.0,zoneHigh=0.0,gapATR=0.0;
   int ageBars=-1;
   const int imbalanceBias=RecentActiveImbalanceZone(m5Rates,m5Atr,Inp_M5ImbalanceLookback,
                                                      zoneLow,zoneHigh,gapATR,ageBars);
   const double atr=(ArraySize(m5Atr)>1 ? m5Atr[1] : 0.0);
   if(imbalanceBias!=candidate.direction || atr<=0.0)
   {
      PrintFormat("[BV-H1CTX-M5][BB-STRUCTURE-REJECT] direction=%s no aligned active M5 imbalance; bias=%d age=%d",
                  DirectionText(candidate.direction),imbalanceBias,ageBars);
      return false;
   }
   if(ageBars<0 || ageBars>Inp_BBImbalanceMaxAge)
   {
      PrintFormat("[BV-H1CTX-M5][BB-STRUCTURE-REJECT] %s aligned M5 imbalance too old; age=%d max=%d",
                  DirectionText(candidate.direction),ageBars,Inp_BBImbalanceMaxAge);
      return false;
   }
   if(Inp_BBRequireWyckoffEvent &&
      (!g_wyckoff.valid || candidate.wyckoff_event==WY_NONE))
   {
      PrintFormat("[BV-H1CTX-M5][BB-STRUCTURE-REJECT] %s FVG/impulse valid but no active H1 Wyckoff event",
                  DirectionText(candidate.direction));
      return false;
   }

   const double blockHigh=WindowHigh(m5Rates,1,Inp_BlockBars);
   const double blockLow=WindowLow(m5Rates,1,Inp_BlockBars);
   const double maxDistance=MathMax(0.0,Inp_BBImbalanceMaxDistanceATR)*atr;
   double edgeDistance=0.0;
   bool supportResistanceAligned=false;
   if(candidate.direction>0)
   {
      edgeDistance=(blockLow>zoneHigh ? blockLow-zoneHigh :
                    (blockLow<zoneLow ? zoneLow-blockLow : 0.0));
      supportResistanceAligned=(zoneLow<=blockLow+maxDistance);
   }
   else
   {
      edgeDistance=(blockHigh<zoneLow ? zoneLow-blockHigh :
                    (blockHigh>zoneHigh ? blockHigh-zoneHigh : 0.0));
      supportResistanceAligned=(zoneHigh>=blockHigh-maxDistance);
   }
   if(!supportResistanceAligned || edgeDistance>maxDistance)
   {
      PrintFormat("[BV-H1CTX-M5][BB-STRUCTURE-REJECT] %s block %.3f ATR from M5 imbalance S/R; max=%.3f zone=%.*f-%.*f",
                  DirectionText(candidate.direction),edgeDistance/atr,Inp_BBImbalanceMaxDistanceATR,
                  _Digits,zoneLow,_Digits,zoneHigh);
      return false;
   }

   const bool impulseAligned=BBImpulseAligned(candidate);
   const bool lateWyckoffAligned=BBLateWyckoffAligned(candidate);
   bool contextAllowed=false;
   if(Inp_BBStructureMode==BB_STRUCTURE_IMBALANCE_ONLY)
      contextAllowed=true;
   else if(Inp_BBStructureMode==BB_STRUCTURE_IMBALANCE_IMPULSE)
      contextAllowed=impulseAligned;
   else if(Inp_BBStructureMode==BB_STRUCTURE_IMBALANCE_LATE_WYCKOFF)
      contextAllowed=lateWyckoffAligned;
   else if(Inp_BBStructureMode==BB_STRUCTURE_IMBALANCE_IMPULSE_OR_WY)
      contextAllowed=(impulseAligned || lateWyckoffAligned);

   if(!contextAllowed)
      PrintFormat("[BV-H1CTX-M5][BB-STRUCTURE-REJECT] M5 imbalance S/R valid but context fails; Elliott=%s Wyckoff=%s age=%d mode=%d",
                  candidate.context.elliott_phase,WyckoffEventCode(candidate.wyckoff_event),
                  g_wyckoff.age_bars,(int)Inp_BBStructureMode);
   else
      PrintFormat("[BV-H1CTX-M5][BB-STRUCTURE-ACCEPT] %s FVG=%.*f-%.*f distance=%.3fATR gap=%.3fATR age=%d Elliott=%s Wyckoff=%s",
                  DirectionText(candidate.direction),_Digits,zoneLow,_Digits,zoneHigh,
                  edgeDistance/atr,gapATR,ageBars,candidate.context.elliott_phase,
                  WyckoffEventCode(candidate.wyckoff_event));
   return contextAllowed;
}

bool ImbalanceAllowsSetup(const SetupCandidate &candidate,
                          const MqlRates &m5Rates[],const double &m5Atr[])
{
   const ENUM_IMBALANCE_FILTER_MODE mode=ImbalanceModeForSetup(candidate.type,candidate.direction);
   if(mode==IMB_FILTER_OFF)
      return true;
   if(candidate.type==BV_SB && candidate.direction>0 && Inp_SBBuyImbalanceWyckoffMask>0)
   {
      const int eventBit=(1 << (int)candidate.wyckoff_event);
      if(candidate.wyckoff_event==WY_NONE || (Inp_SBBuyImbalanceWyckoffMask&eventBit)==0)
         return true;
   }
   double m5GapATR=0.0;
   int m5Age=-1;
   const int m5Bias=RecentActiveImbalanceBias(m5Rates,m5Atr,Inp_M5ImbalanceLookback,m5GapATR,m5Age);
   const bool m5Aligned=(m5Bias==candidate.direction);
   const bool allowed=m5Aligned;
   if(!allowed)
      PrintFormat("[BV-H1CTX-M5][IMBALANCE-M5-REJECT:%s] direction=%s event=%s bias=%d age=%d gap=%.3fATR",
                  SetupCode(candidate.type),DirectionText(candidate.direction),
                  WyckoffEventCode(candidate.wyckoff_event),m5Bias,m5Age,m5GapATR);
   return allowed;
}

void BuildMarketContext(const MqlRates &rates[],const double atr,
                        const int direction,const ENUM_WYCKOFF_EVENT event,
                        MarketContextSnapshot &context)
{
   ResetMarketContext(context);
   if(atr<=0.0)
      return;
   if(!RollingTrendStats(rates,Inp_ContextFastTrendBars,atr,context.slope_24_atr,context.r2_24) ||
      !RollingTrendStats(rates,Inp_ContextTrendBars,atr,context.slope_72_atr,context.r2_72) ||
      !RollingTrendStats(rates,Inp_ContextLongTrendBars,atr,context.slope_240_atr,context.r2_240))
      return;

   context.trend_24=ClassifyTrend(context.slope_24_atr,context.r2_24,
                                  Inp_ContextFastMinTrendR2,Inp_ContextFastMinSlopeATR);
   context.trend_72=ClassifyTrend(context.slope_72_atr,context.r2_72,
                                  Inp_ContextMinTrendR2,Inp_ContextMinSlopeATR);
   context.trend_240=ClassifyTrend(context.slope_240_atr,context.r2_240,
                                   Inp_ContextLongMinTrendR2,Inp_ContextLongMinSlopeATR);
   const string align24=DirectionalAlignment(context.trend_24,direction);
   const string align72=DirectionalAlignment(context.trend_72,direction);
   const string align240=DirectionalAlignment(context.trend_240,direction);
   if(context.trend_24=="RANGE") context.transition_state="NO_FAST_TREND";
   else if(context.trend_72=="RANGE") context.transition_state=(align24=="ALIGNED" ? "EMERGING_ALIGNED" : "EMERGING_COUNTER");
   else if(context.trend_24!=context.trend_72) context.transition_state=(align24=="ALIGNED" ? "REVERSAL_ALIGNED" : "REVERSAL_COUNTER");
   else context.transition_state=(align24=="ALIGNED" ? "CONTINUATION_ALIGNED" : "CONTINUATION_COUNTER");

   const double fastVol=RMSLogReturn(rates,Inp_ContextFastTrendBars);
   const double longVol=RMSLogReturn(rates,Inp_ContextLongTrendBars);
   context.volatility_ratio=(longVol>0.0 ? fastVol/longVol : 1.0);
   context.volatility_state=(context.volatility_ratio>1.25 ? "EXPANDING" :
                             (context.volatility_ratio<0.80 ? "CONTRACTING" : "NORMAL"));
   const double fastActivity=ContextActivity(rates,Inp_ContextFastTrendBars);
   const double longActivity=ContextActivity(rates,Inp_ContextLongTrendBars);
   context.activity_ratio=(longActivity>0.0 ? fastActivity/longActivity : 1.0);
   context.activity_state=(context.activity_ratio>1.20 ? "EXPANDING" :
                           (context.activity_ratio<0.80 ? "CONTRACTING" : "NORMAL"));

   const double longHigh=WindowHigh(rates,1,Inp_ContextLongTrendBars);
   const double longLow=WindowLow(rates,1,Inp_ContextLongTrendBars);
   context.range_position_240=(longHigh>longLow ? (rates[1].close-longLow)/(longHigh-longLow) : 0.5);
   const bool extended=(direction>0 ? context.range_position_240>=0.80 : context.range_position_240<=0.20);
   const bool valueEdge=(direction>0 ? context.range_position_240<=0.20 : context.range_position_240>=0.80);
   context.location_state=(extended ? "EXTENDED" : (valueEdge ? "VALUE_EDGE" : "MID"));

   context.wyckoff_phase=WyckoffPhase(event,direction);
   context.elliott_phase=DetectElliottPhase(rates);
   context.elliott_alignment=ElliottAlignment(context.elliott_phase,direction);
   const int wyckoffScore=(g_wyckoff.valid && g_wyckoff.bias==direction ? 1 : 0);
   context.confluence_score=wyckoffScore+AlignmentScore(align72)+AlignmentScore(align240)+
                            AlignmentScore(context.elliott_alignment);
   context.confluence_tier=(context.confluence_score>=3 ? "HIGH" :
                            (context.confluence_score>=1 ? "MEDIUM" : "LOW"));
   context.valid=true;
}

bool RollingTrendIsCounter(const MqlRates &rates[],
                           const int direction,
                           const double atr,
                           double &slopeATR,
                           double &rSquared)
{
   if(direction==0 || !RollingTrendStats(rates,Inp_ContextTrendBars,atr,slopeATR,rSquared))
      return false;
   if(rSquared<Inp_ContextMinTrendR2 || MathAbs(slopeATR)<Inp_ContextMinSlopeATR)
      return false;
   return ((direction>0 && slopeATR<0.0) || (direction<0 && slopeATR>0.0));
}

void ConsiderCandidate(const SetupCandidate &candidate,SetupCandidate &best,const double atr)
{
   if(!candidate.valid)
      return;
   if((candidate.direction>0 && !Inp_AllowBuy) || (candidate.direction<0 && !Inp_AllowSell))
      return;
   // Reject an out-of-session M5 setup before it occupies the single pending
   // slot; entry time is checked again in case the breakout crosses a boundary.
   if(!SessionAllowedForSetup(candidate.type,candidate.direction,candidate.signal_time))
      return;
   if(!WyckoffAllowsSetup(candidate.type,candidate.direction,candidate.trigger,atr,g_wyckoff))
      return;
   SetupCandidate enriched=candidate;
   if(g_wyckoff.valid)
   {
      enriched.wyckoff_event=g_wyckoff.event;
      // In OFF mode Wyckoff is telemetry only; simultaneous setup ranking
      // must stay identical to the v1.73 baseline.
      if(Inp_WyckoffFilterMode!=WY_FILTER_OFF)
         enriched.score+=0.01*g_wyckoff.score;
   }
   if(!best.valid || enriched.score>best.score)
      best=enriched;
}

bool CooldownComplete()
{
   if(g_lastEntryBarTime==0 || Inp_CooldownBars<=0)
      return true;
   const int shift=iBarShift(_Symbol,PERIOD_M5,g_lastEntryBarTime,false);
   return (shift>Inp_CooldownBars);
}

void DetectNewSetup()
{
   if(g_pending.valid || g_inverseShadow.active || !CanOpenAnotherPosition() || !CooldownComplete())
      return;
   MqlRates h1Rates[],m5Rates[];
   double h1Ema[],h1Atr[],m5Atr[];
   if(!GetMarketData(h1Rates,h1Ema,h1Atr) || h1Atr[1]<=0.0 ||
      !GetM5SetupData(m5Rates,m5Atr) || m5Atr[1]<=0.0)
      return;
   DetectWyckoffContext(h1Rates,h1Atr,g_wyckoff);
   AnnotateWyckoff(g_wyckoff,h1Rates,h1Atr[1]);
   SetupCandidate best,candidate;
   ResetCandidate(best);

   if(DetectDDB(m5Rates,TrendDirection(h1Rates,h1Ema,EMASlopeBarsForSetup(BV_DDB)),m5Atr[1],candidate)) ConsiderCandidate(candidate,best,h1Atr[1]);
   if(DetectFB(m5Rates,TrendDirection(h1Rates,h1Ema,EMASlopeBarsForSetup(BV_FB)),m5Atr[1],candidate))   ConsiderCandidate(candidate,best,h1Atr[1]);
   if(DetectSB(m5Rates,TrendDirection(h1Rates,h1Ema,EMASlopeBarsForSetup(BV_SB)),m5Atr[1],candidate))   ConsiderCandidate(candidate,best,h1Atr[1]);
   if(DetectBB(m5Rates,TrendDirection(h1Rates,h1Ema,EMASlopeBarsForSetup(BV_BB)),m5Atr[1],candidate))
   {
      // BB context is part of the setup definition. Validate it before ranking;
      // otherwise a high-scoring but invalid BB can suppress another valid setup
      // on the same M5 bar and then be rejected only after selection.
      const double bbH1ATRPercent=(h1Rates[1].close>0.0 ? 100.0*h1Atr[1]/h1Rates[1].close : 0.0);
      if(Inp_BBMinH1ATRPercent<=0.0 || bbH1ATRPercent>=Inp_BBMinH1ATRPercent)
      {
         candidate.wyckoff_event=(g_wyckoff.valid ? g_wyckoff.event : WY_NONE);
         BuildMarketContext(h1Rates,h1Atr[1],candidate.direction,candidate.wyckoff_event,candidate.context);
         if(BBStructureAllowsSetup(candidate,m5Rates,m5Atr))
            ConsiderCandidate(candidate,best,h1Atr[1]);
      }
      else
         PrintFormat("[BV-H1CTX-M5][CONTEXT-REJECT:BB] H1 ATR/close=%.4f%% below %.4f%%",
                     bbH1ATRPercent,Inp_BBMinH1ATRPercent);
   }
   if(DetectRB(m5Rates,TrendDirection(h1Rates,h1Ema,EMASlopeBarsForSetup(BV_RB)),m5Atr[1],candidate))   ConsiderCandidate(candidate,best,h1Atr[1]);
   if(DetectIRB(m5Rates,TrendDirection(h1Rates,h1Ema,EMASlopeBarsForSetup(BV_IRB)),m5Atr[1],candidate))
   {
      // IRB range context is part of the candidate definition and must be
      // checked before ranking so a rejected IRB cannot suppress another setup.
      candidate.wyckoff_event=(g_wyckoff.valid ? g_wyckoff.event : WY_NONE);
      BuildMarketContext(h1Rates,h1Atr[1],candidate.direction,candidate.wyckoff_event,candidate.context);
      if(IRBContextAllowsSetup(candidate))
         ConsiderCandidate(candidate,best,h1Atr[1]);
   }
   if(DetectARB(m5Rates,TrendDirection(h1Rates,h1Ema,EMASlopeBarsForSetup(BV_ARB)),m5Atr[1],candidate)) ConsiderCandidate(candidate,best,h1Atr[1]);

   if(best.valid)
   {
      if(!best.context.valid)
         BuildMarketContext(h1Rates,h1Atr[1],best.direction,best.wyckoff_event,best.context);
      if(!ImbalanceAllowsSetup(best,m5Rates,m5Atr))
         return;
      if(Inp_SBUseWyckoffElliottFilter && best.type==BV_SB && !g_wyckoff.valid &&
         (best.context.elliott_alignment=="ALIGNED" || best.context.elliott_alignment=="UNDEFINED"))
      {
         PrintFormat("[BV-H1CTX-M5][CONTEXT-REJECT:SB] no Wyckoff event with Elliott=%s",
                     best.context.elliott_alignment);
         return;
      }
      if(Inp_DDBBlockBuyUpthrustExtended && best.type==BV_DDB && best.direction>0 &&
         best.wyckoff_event==WY_UPTHRUST && best.context.location_state=="EXTENDED")
      {
         PrintFormat("[BV-H1CTX-M5][CONTEXT-REJECT:DDB] BUY into Wyckoff UT at range240=%.3f",
                     best.context.range_position_240);
         return;
      }
      if(Inp_FBBlockBullImpulseSell && best.type==BV_FB && best.direction<0 &&
         (best.context.elliott_phase=="BULL_W3" ||
          best.context.elliott_phase=="BULL_IMPULSE_COMPLETE"))
      {
         PrintFormat("[BV-H1CTX-M5][CONTEXT-REJECT:FB] SELL conflicts with H1 Elliott phase=%s",
                     best.context.elliott_phase);
         return;
      }
      if(Inp_RBBlockBuyUpthrustWeakTransition && best.type==BV_RB && best.direction>0 &&
         best.wyckoff_event==WY_UPTHRUST &&
         (best.context.transition_state=="NO_FAST_TREND" ||
          best.context.transition_state=="REVERSAL_ALIGNED"))
      {
         PrintFormat("[BV-H1CTX-M5][CONTEXT-REJECT:RB] BUY into Wyckoff UT with H1 transition=%s",
                     best.context.transition_state);
         return;
      }
      if(Inp_RBBuyBlockLongDown && best.type==BV_RB && best.direction>0 &&
         best.context.trend_240=="DOWN")
      {
         Print("[BV-H1CTX-M5][CONTEXT-REJECT:RB-v190-A] BUY conflicts with 240H downtrend");
         return;
      }
      if(Inp_RBBuyBlockSOSMid && best.type==BV_RB && best.direction>0 &&
         best.wyckoff_event==WY_SOS && best.context.location_state=="MID")
      {
         Print("[BV-H1CTX-M5][CONTEXT-REJECT:RB-v190-B] BUY SOS is still in the middle of the 240H range");
         return;
      }
      if(Inp_RBBuyBlockNoEventExpanding && best.type==BV_RB && best.direction>0 &&
         best.wyckoff_event==WY_NONE && best.context.activity_state=="EXPANDING")
      {
         Print("[BV-H1CTX-M5][CONTEXT-REJECT:RB-v190-C] eventless BUY during expanding H1 activity");
         return;
      }
      if(Inp_DDBSellBlockCorrectiveLongUp && best.type==BV_DDB && best.direction<0 &&
         best.context.elliott_alignment=="CORRECTIVE" && best.context.trend_240=="UP")
      {
         PrintFormat("[BV-H1CTX-M5][CONTEXT-REJECT:DDB] SELL corrective inside 240H uptrend; Elliott=%s",
                     best.context.elliott_phase);
         return;
      }
      if(Inp_DDBSellBlockMidNoFastContracting && best.type==BV_DDB && best.direction<0 &&
         SessionBitAt(best.signal_time)==2 &&
         best.context.transition_state=="NO_FAST_TREND" &&
         best.context.volatility_state=="CONTRACTING")
      {
         Print("[BV-H1CTX-M5][CONTEXT-REJECT:DDB-v188-B] SELL 08-15 no-fast-trend with contracting volatility");
         return;
      }
      if(Inp_DDBSellBlockMidContinuationNonContracting && best.type==BV_DDB && best.direction<0 &&
         SessionBitAt(best.signal_time)==2 &&
         best.context.transition_state=="CONTINUATION_ALIGNED" &&
         best.context.volatility_state!="CONTRACTING")
      {
         PrintFormat("[BV-H1CTX-M5][CONTEXT-REJECT:DDB-v188-C] SELL 08-15 continuation with volatility=%s",
                     best.context.volatility_state);
         return;
      }
      if(Inp_FBBuyBlockLateBullContext && best.type==BV_FB && best.direction>0 &&
         (best.wyckoff_event==WY_SOS ||
          (best.context.elliott_phase=="BULL_W3" && best.context.location_state=="EXTENDED")))
      {
         PrintFormat("[BV-H1CTX-M5][CONTEXT-REJECT:FB] BUY late bull context; Wyckoff=%s Elliott=%s location=%s",
                     WyckoffEventCode(best.wyckoff_event),best.context.elliott_phase,best.context.location_state);
         return;
      }
      if(Inp_RBSellRequireActiveContext && best.type==BV_RB && best.direction<0 &&
         best.context.wyckoff_phase=="NO_EVENT" && best.context.activity_state=="NORMAL")
      {
         Print("[BV-H1CTX-M5][CONTEXT-REJECT:RB] SELL has no Wyckoff event and normal H1 activity");
         return;
      }
      if(Inp_SBBuyBlockBullW4LongUp && best.type==BV_SB && best.direction>0 &&
         best.context.elliott_phase=="BULL_W4" && best.context.trend_240=="UP")
      {
         Print("[BV-H1CTX-M5][CONTEXT-REJECT:SB] BUY during Bull W4 inside 240H uptrend");
         return;
      }
      if(Inp_SBBuyBlockUpthrustExtendedAbnormalVol && best.type==BV_SB && best.direction>0 &&
         best.wyckoff_event==WY_UPTHRUST && best.context.location_state=="EXTENDED" &&
         best.context.volatility_state!="NORMAL")
      {
         PrintFormat("[BV-H1CTX-M5][CONTEXT-REJECT:SB-v189-A] BUY UT at extended location with volatility=%s",
                     best.context.volatility_state);
         return;
      }
      if(Inp_SBBuyBlockSpringEmergingCounter && best.type==BV_SB && best.direction>0 &&
         best.wyckoff_event==WY_SPRING && best.context.transition_state=="EMERGING_COUNTER")
      {
         Print("[BV-H1CTX-M5][CONTEXT-REJECT:SB-v189-B] BUY Spring while fast H1 structure remains counter");
         return;
      }
      if(Inp_SBSellBlockRangeOrDistributionTest && best.type==BV_SB && best.direction<0 &&
         ((best.context.transition_state=="NO_FAST_TREND" && best.context.trend_72=="RANGE") ||
          (best.context.wyckoff_phase=="DISTRIBUTION_TEST" && best.context.confluence_tier=="MEDIUM")))
      {
         PrintFormat("[BV-H1CTX-M5][CONTEXT-REJECT:SB] SELL weak context; transition=%s Wyckoff=%s confluence=%s",
                     best.context.transition_state,best.context.wyckoff_phase,best.context.confluence_tier);
         return;
      }
      if(Inp_FBBuyBlockCorrectiveNormalActivity && best.type==BV_FB && best.direction>0 &&
         best.context.elliott_alignment=="CORRECTIVE" && best.context.activity_state=="NORMAL")
      {
         PrintFormat("[BV-H1CTX-M5][CONTEXT-REJECT:FB] BUY corrective with normal H1 activity; Elliott=%s",
                     best.context.elliott_phase);
         return;
      }
      if(Inp_FBBuyBlockExpandingLongDown && best.type==BV_FB && best.direction>0 &&
         best.context.activity_state=="EXPANDING" && best.context.trend_72=="DOWN")
      {
         PrintFormat("[BV-H1CTX-M5][CONTEXT-REJECT:FB-v198] BUY against 72H downtrend during expanding activity ratio=%.3f",
                     best.context.activity_ratio);
         return;
      }
      if(Inp_SBBuyBlockCounterFastUp && best.type==BV_SB && best.direction>0 &&
         best.context.elliott_alignment=="COUNTER" && best.context.trend_24=="UP")
      {
         PrintFormat("[BV-H1CTX-M5][CONTEXT-REJECT:SB] BUY has counter Elliott impulse inside 24H uptrend; phase=%s",
                     best.context.elliott_phase);
         return;
      }
      if(Inp_SBSellBlockSOWLongUp && best.type==BV_SB && best.direction<0 &&
         best.context.wyckoff_phase=="MARKDOWN_CONFIRMATION" && best.context.trend_240=="UP")
      {
         Print("[BV-H1CTX-M5][CONTEXT-REJECT:SB] SELL SOW conflicts with 240H uptrend");
         return;
      }
      double contextSlopeATR=0.0,contextR2=0.0;
      if(Inp_SBBlockCounterTrend72 && best.type==BV_SB &&
         RollingTrendIsCounter(h1Rates,best.direction,h1Atr[1],contextSlopeATR,contextR2))
      {
         PrintFormat("[BV-H1CTX-M5][CONTEXT-REJECT:%s] direction=%s slope72=%.5f ATR/bar R2=%.3f",
                     SetupCode(best.type),DirectionText(best.direction),contextSlopeATR,contextR2);
         return;
      }
      g_pending=best;
      AnnotateSetup(g_pending,m5Atr[1]);
   }
}

int PendingWaitBars()
{
   if(!g_pending.valid)
      return -1;
   // Count actual M5 bars, not elapsed wall-clock minutes. This keeps the
   // first tradable confirmation after a weekend/session gap at wait=0.
   const int signalShift=iBarShift(_Symbol,PERIOD_M5,g_pending.signal_time,true);
   if(signalShift<0)
      return -1;
   return MathMax(0,signalShift-2);
}

void ExpirePendingIfNeeded()
{
   if(!g_pending.valid)
      return;
   const int waitBars=PendingWaitBars();
   const int expiryBars=MathMax(0,ExpiryBarsForSetup(g_pending.type));
   if(waitBars<0 || waitBars>=expiryBars)
   {
      PrintFormat("[BV-H1CTX-M5][EXPIRE:%s] setup at %s was not triggered within %d M5 bars",
                  SetupCode(g_pending.type),
                  TimeToString(g_pending.signal_time,TIME_DATE|TIME_MINUTES),
                  expiryBars);
      ResetCandidate(g_pending);
   }
}

double CalculateRiskVolume(const int direction,const double entry,const double stopLoss)
{
   const double riskMoney=AccountInfoDouble(ACCOUNT_EQUITY)*Inp_RiskPercent/100.0;
   if(riskMoney<=0.0)
      return 0.0;
   double oneLotProfit=0.0;
   const ENUM_ORDER_TYPE orderType=(direction>0 ? ORDER_TYPE_BUY : ORDER_TYPE_SELL);
   if(!OrderCalcProfit(orderType,_Symbol,1.0,entry,stopLoss,oneLotProfit))
      return 0.0;
   const double oneLotLoss=MathAbs(oneLotProfit);
   if(oneLotLoss<=0.0)
      return 0.0;
   return NormalizeVolumeDown(riskMoney/oneLotLoss);
}

bool StopsAreBrokerValid(const int direction,const double entry,const double stopLoss,const double takeProfit)
{
   const int stopsLevel=(int)SymbolInfoInteger(_Symbol,SYMBOL_TRADE_STOPS_LEVEL);
   const double minimumDistance=stopsLevel*_Point;
   const double slDistance=(direction>0 ? entry-stopLoss : stopLoss-entry);
   if(slDistance<minimumDistance)
      return false;
   if(takeProfit>0.0)
   {
      const double tpDistance=(direction>0 ? takeProfit-entry : entry-takeProfit);
      if(tpDistance<minimumDistance)
         return false;
   }
   return true;
}

int ConfirmWaitMaskForSetup(const ENUM_BV_SETUP setup,const int direction)
{
   switch(setup)
   {
      case BV_DDB: return (direction>0 ? Inp_DDBBuyWaitMask : Inp_DDBSellWaitMask);
      case BV_FB:  return (direction>0 ? Inp_FBBuyWaitMask  : Inp_FBSellWaitMask);
      case BV_SB:  return (direction>0 ? Inp_SBBuyWaitMask  : Inp_SBSellWaitMask);
      case BV_BB:  return (direction>0 ? Inp_BBBuyWaitMask  : Inp_BBSellWaitMask);
      case BV_RB:  return (direction>0 ? Inp_RBBuyWaitMask  : Inp_RBSellWaitMask);
      case BV_IRB: return (direction>0 ? Inp_IRBBuyWaitMask : Inp_IRBSellWaitMask);
      case BV_ARB: return (direction>0 ? Inp_ARBBuyWaitMask : Inp_ARBSellWaitMask);
      default:     return 0;
   }
}

bool ConfirmWaitAllowed(const ENUM_BV_SETUP setup,const int direction,const int waitBars)
{
   if(!Inp_UseConfirmWaitMatrix)
      return true;
   const int bit=(waitBars<=0 ? 1 : (waitBars==1 ? 2 : 4));
   return ((ConfirmWaitMaskForSetup(setup,direction)&bit)!=0);
}

ENUM_BV_SETUP SetupFromPositionComment(const string comment)
{
   if(StringFind(comment,"BVCTXM5_DDB_")==0) return BV_DDB;
   if(StringFind(comment,"BVCTXM5_FB_")==0)  return BV_FB;
   if(StringFind(comment,"BVCTXM5_SB_")==0)  return BV_SB;
   if(StringFind(comment,"BVCTXM5_BB_")==0)  return BV_BB;
   if(StringFind(comment,"BVCTXM5_RB_")==0)  return BV_RB;
   if(StringFind(comment,"BVCTXM5_IRB_")==0) return BV_IRB;
   if(StringFind(comment,"BVCTXM5_ARB_")==0) return BV_ARB;
   if(StringFind(comment,"BVH1M5_DDB_")==0) return BV_DDB;
   if(StringFind(comment,"BVH1M5_FB_")==0)  return BV_FB;
   if(StringFind(comment,"BVH1M5_SB_")==0)  return BV_SB;
   if(StringFind(comment,"BVH1M5_BB_")==0)  return BV_BB;
   if(StringFind(comment,"BVH1M5_RB_")==0)  return BV_RB;
   if(StringFind(comment,"BVH1M5_IRB_")==0) return BV_IRB;
   if(StringFind(comment,"BVH1M5_ARB_")==0) return BV_ARB;
   if(StringFind(comment,"BVH1_DDB_")==0) return BV_DDB;
   if(StringFind(comment,"BVH1_FB_")==0)  return BV_FB;
   if(StringFind(comment,"BVH1_SB_")==0)  return BV_SB;
   if(StringFind(comment,"BVH1_BB_")==0)  return BV_BB;
   if(StringFind(comment,"BVH1_RB_")==0)  return BV_RB;
   if(StringFind(comment,"BVH1_IRB_")==0) return BV_IRB;
   if(StringFind(comment,"BVH1_ARB_")==0) return BV_ARB;
   return BV_NONE;
}

bool BreakEvenParameters(const ENUM_BV_SETUP setup,double &triggerR,double &offsetR)
{
   triggerR=0.0;
   offsetR=0.0;
   if(setup==BV_SB && Inp_SBUseBreakEven)
   {
      triggerR=Inp_SBBreakEvenTriggerR;
      offsetR=Inp_SBBreakEvenOffsetR;
      return true;
   }
   if(setup==BV_BB && Inp_BBUseBreakEven)
   {
      triggerR=Inp_BBBreakEvenTriggerR;
      offsetR=Inp_BBBreakEvenOffsetR;
      return true;
   }
   return false;
}

void ManageOpenPosition()
{
   MqlTick tick;
   if(!SymbolInfoTick(_Symbol,tick))
      return;
   for(int i=PositionsTotal()-1;i>=0;i--)
   {
      const ulong ticket=PositionGetTicket(i);
      if(ticket==0 || !PositionSelectByTicket(ticket))
         continue;
      if(PositionGetString(POSITION_SYMBOL)!=_Symbol ||
         (ulong)PositionGetInteger(POSITION_MAGIC)!=Inp_MagicNumber)
         continue;

      const ENUM_BV_SETUP setup=SetupFromPositionComment(PositionGetString(POSITION_COMMENT));
      double triggerR,offsetR;
      if(!BreakEvenParameters(setup,triggerR,offsetR) || triggerR<=0.0)
         continue;
      const long positionType=PositionGetInteger(POSITION_TYPE);
      const int direction=(positionType==POSITION_TYPE_BUY ? 1 : -1);
      const double openPrice=PositionGetDouble(POSITION_PRICE_OPEN);
      const double oldSL=PositionGetDouble(POSITION_SL);
      const double takeProfit=PositionGetDouble(POSITION_TP);
      const double targetRR=TargetRRForSetup(setup);
      if(openPrice<=0.0 || takeProfit<=0.0 || targetRR<=0.0)
         continue;
      const double initialRisk=MathAbs(takeProfit-openPrice)/targetRR;
      const double currentPrice=(direction>0 ? tick.bid : tick.ask);
      const double favorableMove=direction*(currentPrice-openPrice);
      if(initialRisk<=0.0 || favorableMove<triggerR*initialRisk)
         continue;

      const double newSL=NormalizeStop(openPrice+direction*offsetR*initialRisk,direction);
      const double tickSize=MathMax(SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE),_Point);
      if((direction>0 && oldSL>=newSL-tickSize*0.5) ||
         (direction<0 && oldSL>0.0 && oldSL<=newSL+tickSize*0.5))
         continue;
      const int stopLevel=(int)MathMax(SymbolInfoInteger(_Symbol,SYMBOL_TRADE_STOPS_LEVEL),
                                       SymbolInfoInteger(_Symbol,SYMBOL_TRADE_FREEZE_LEVEL));
      const double minimumDistance=stopLevel*_Point;
      if((direction>0 && currentPrice-newSL<minimumDistance) ||
         (direction<0 && newSL-currentPrice<minimumDistance))
         continue;

      trade.SetExpertMagicNumber(Inp_MagicNumber);
      if(trade.PositionModify(ticket,newSL,takeProfit) && IsSuccessfulRetcode(trade.ResultRetcode()))
         PrintFormat("[BV-H1][BE:%s] ticket=%I64u trigger=%.2fR newSL=%.*f",
                     SetupCode(setup),ticket,triggerR,_Digits,newSL);
      else
         PrintFormat("[BV-H1][BE-REJECT:%s] ticket=%I64u retcode=%u (%s)",
                     SetupCode(setup),ticket,trade.ResultRetcode(),trade.ResultRetcodeDescription());
   }
}

void OpenInverseAfterShadowFailure(const MqlTick &tick,
                                   const double requestedStop=0.0,
                                   const string failureReason="full virtual SL")
{
   const SetupCandidate source=g_inverseShadow.source;
   const int direction=-source.direction;
   if((direction>0 && !Inp_InverseAllowBuy) || (direction<0 && !Inp_InverseAllowSell))
   {
      PrintFormat("[BV-INVERSE][SKIP:%s] inverse %s disabled",
                  SetupCode(source.type),DirectionText(direction));
      ResetInverseShadow();
      return;
   }
   if(Inp_InverseRejectSpring && source.wyckoff_event==WY_SPRING)
   {
      PrintFormat("[BV-INVERSE][SKIP:%s] source context is Wyckoff SPRING",
                  SetupCode(source.type));
      ResetInverseShadow();
      return;
   }
   const double entry=NormalizePriceNearest(direction>0 ? tick.ask : tick.bid);
   const double stopLoss=NormalizeStop(requestedStop>0.0 ? requestedStop : g_inverseShadow.main_entry,direction);
   const double riskDistance=(direction>0 ? entry-stopLoss : stopLoss-entry);
   if(riskDistance<=0.0)
   {
      PrintFormat("[BV-INVERSE][SKIP:%s] failure gap crossed inverse SL",SetupCode(source.type));
      ResetInverseShadow();
      return;
   }
   const double spread=tick.ask-tick.bid;
   const double spreadPoints=spread/_Point;
   if((Inp_MaxSpreadPoints>0 && spreadPoints>Inp_MaxSpreadPoints) ||
      (Inp_MaxSpreadToRiskPct>0.0 && spread/riskDistance*100.0>Inp_MaxSpreadToRiskPct))
   {
      PrintFormat("[BV-INVERSE][SKIP:%s] spread %.1f points is too large for risk distance %.1f points",
                  SetupCode(source.type),spreadPoints,riskDistance/_Point);
      ResetInverseShadow();
      return;
   }
   const double takeProfit=NormalizePriceNearest(entry+direction*Inp_InverseTargetRR*riskDistance);
   if(!StopsAreBrokerValid(direction,entry,stopLoss,takeProfit))
   {
      PrintFormat("[BV-INVERSE][SKIP:%s] inverse SL/TP violates broker stop level",SetupCode(source.type));
      ResetInverseShadow();
      return;
   }
   const double volume=CalculateRiskVolume(direction,entry,stopLoss);
   if(volume<=0.0)
   {
      PrintFormat("[BV-INVERSE][SKIP:%s] calculated risk lot is invalid",SetupCode(source.type));
      ResetInverseShadow();
      return;
   }
   trade.SetExpertMagicNumber(Inp_MagicNumber);
   trade.SetTypeFillingBySymbol(_Symbol);
   trade.SetDeviationInPoints(20);
   const string comment="BVINV_"+SetupCode(source.type)+"_"+DirectionText(direction);
   const bool sent=(direction>0 ? trade.Buy(volume,_Symbol,0.0,stopLoss,takeProfit,comment) :
                                  trade.Sell(volume,_Symbol,0.0,stopLoss,takeProfit,comment));
   const uint retcode=trade.ResultRetcode();
   if(sent && IsSuccessfulRetcode(retcode))
   {
      const double fill=(trade.ResultPrice()>0.0 ? trade.ResultPrice() : entry);
      SetupCandidate inverse=source;
      inverse.direction=direction;
      inverse.stop_loss=stopLoss;
      inverse.reason="inverse after "+failureReason;
      StartExcursionTracker(inverse,fill);
      if(g_excursion.active)
         g_excursion.target_rr=Inp_InverseTargetRR;
      AnnotateEntry(inverse,fill);
      g_lastEntryBarTime=iTime(_Symbol,PERIOD_M5,0);
      PrintFormat("[BV-INVERSE][ENTRY:%s][%s] volume=%.3f fill=%.*f SL=%.*f TP=%.*f risk=%.2f%% mainEntry=%.*f reason=%s",
                  SetupCode(source.type),DirectionText(direction),volume,_Digits,fill,
                  _Digits,stopLoss,_Digits,takeProfit,Inp_RiskPercent,_Digits,g_inverseShadow.main_entry,
                  failureReason);
   }
   else
      PrintFormat("[BV-INVERSE][ORDER-REJECT:%s] retcode=%u (%s) lastError=%d",
                  SetupCode(source.type),retcode,trade.ResultRetcodeDescription(),GetLastError());
   ResetInverseShadow();
}

void UpdateInverseShadow()
{
   if(!Inp_EnableInverseFailureMode || !g_inverseShadow.active || !CanOpenAnotherPosition())
      return;
   MqlTick tick;
   if(!SymbolInfoTick(_Symbol,tick))
      return;
   const bool failed=(g_inverseShadow.source.direction>0 ? tick.bid<=g_inverseShadow.main_stop :
                                                          tick.ask>=g_inverseShadow.main_stop);
   const bool succeeded=(g_inverseShadow.source.direction>0 ? tick.bid>=g_inverseShadow.main_target :
                                                             tick.ask<=g_inverseShadow.main_target);
   if(failed)
   {
      if(Inp_InverseFailureTrigger==INVERSE_AT_MAIN_SL)
      {
         if(!SymbolTradingSessionOpen(tick.time))
         {
            PrintFormat("[BV-INVERSE][SKIP:%s] virtual failure occurred outside broker session",
                        SetupCode(g_inverseShadow.source.type));
            ResetInverseShadow();
            return;
         }
         OpenInverseAfterShadowFailure(tick);
         return;
      }
      else
      {
         if(!g_inverseShadow.main_sl_seen)
            PrintFormat("[BV-INVERSE][SWEEP:%s] main SL swept; waiting for M5 close-back confirmation",
                        SetupCode(g_inverseShadow.source.type));
         g_inverseShadow.main_sl_seen=true;
      }
   }
   else if(succeeded && !g_inverseShadow.main_sl_seen)
   {
      PrintFormat("[BV-INVERSE][SHADOW-WIN:%s] main setup reached TP before SL; no inverse",
                  SetupCode(g_inverseShadow.source.type));
      ResetInverseShadow();
      return;
   }

   if(Inp_InverseFailureTrigger!=INVERSE_ON_M5_CLOSE_BACK)
      return;

   const datetime currentM5Bar=iTime(_Symbol,PERIOD_M5,0);
   if(currentM5Bar==0 || currentM5Bar==g_inverseShadow.last_m5_bar_time)
      return;
   g_inverseShadow.last_m5_bar_time=currentM5Bar;
   g_inverseShadow.bars_elapsed++;

   MqlRates failedBar[1];
   if(CopyRates(_Symbol,PERIOD_M5,1,1,failedBar)!=1)
      return;
   const SetupCandidate source=g_inverseShadow.source;
   const double closeBuffer=MathMax(0.0,Inp_InverseCloseBufferATR)*MathMax(source.m5_atr,_Point);
   const bool closedBack=(source.direction>0 ? failedBar[0].close<source.trigger-closeBuffer :
                                               failedBar[0].close>source.trigger+closeBuffer);
   const bool reversalBody=(source.direction>0 ? failedBar[0].close<failedBar[0].open :
                                                 failedBar[0].close>failedBar[0].open);
   if(closedBack && (!Inp_InverseRequireReversalBody || reversalBody))
   {
      if(!SymbolTradingSessionOpen(tick.time))
      {
         PrintFormat("[BV-INVERSE][SKIP:%s] early close-back outside broker session",
                     SetupCode(source.type));
         ResetInverseShadow();
         return;
      }
      const double stopBuffer=MathMax(0.0,Inp_InverseSLBufferATR)*MathMax(source.m5_atr,_Point);
      const double inverseStop=(source.direction>0 ?
                                MathMax(source.m5_signal_high,failedBar[0].high)+stopBuffer :
                                MathMin(source.m5_signal_low,failedBar[0].low)-stopBuffer);
      PrintFormat("[BV-INVERSE][EARLY-FAIL:%s] bar=%s close=%.*f trigger=%.*f elapsed=%d",
                  SetupCode(source.type),TimeToString(failedBar[0].time,TIME_DATE|TIME_MINUTES),
                  _Digits,failedBar[0].close,_Digits,source.trigger,g_inverseShadow.bars_elapsed);
      OpenInverseAfterShadowFailure(tick,inverseStop,"early M5 close-back");
      return;
   }

   if(g_inverseShadow.bars_elapsed>=MathMax(1,Inp_InverseFailureBars))
   {
      PrintFormat("[BV-INVERSE][EXPIRE:%s] no early close-back within %d M5 bars",
                  SetupCode(source.type),g_inverseShadow.bars_elapsed);
      ResetInverseShadow();
   }
}

string IndependentInverseCode(const ENUM_INDEPENDENT_INVERSE_SETUP setup)
{
   if(setup==IND_INV_NO_ENTRY)   return "NOENTRY";
   if(setup==IND_INV_ENGULFED)   return "ENGULFED";
   if(setup==IND_INV_EMA_ENGULF) return "EMAENGULF";
   return "NONE";
}

bool IndependentInverseSessionAllowed(const ENUM_INDEPENDENT_INVERSE_SETUP setup,
                                      const datetime time)
{
   MqlDateTime value;
   TimeToStruct(time,value);
   const int bit=(value.hour>=16 ? 4 : (value.hour>=8 ? 2 : 1));
   int mask=0;
   if(setup==IND_INV_NO_ENTRY) mask=Inp_IndInvNoEntrySessionMask;
   else if(setup==IND_INV_ENGULFED) mask=Inp_IndInvEngulfSessionMask;
   else if(setup==IND_INV_EMA_ENGULF) mask=Inp_IndInvEMASessionMask;
   return ((mask&bit)!=0);
}

bool IndependentInverseDirectionAllowed(const ENUM_INDEPENDENT_INVERSE_SETUP setup,
                                        const int direction)
{
   if(setup==IND_INV_NO_ENTRY)
      return (direction>0 ? Inp_IndInvNoEntryAllowBuy : Inp_IndInvNoEntryAllowSell);
   if(setup==IND_INV_ENGULFED)
      return (direction>0 ? Inp_IndInvEngulfAllowBuy : Inp_IndInvEngulfAllowSell);
   if(setup==IND_INV_EMA_ENGULF)
      return (direction>0 ? Inp_IndInvEMAAllowBuy : Inp_IndInvEMAAllowSell);
   return false;
}

double IndependentInverseTargetRR(const ENUM_INDEPENDENT_INVERSE_SETUP setup)
{
   if(setup==IND_INV_NO_ENTRY)   return Inp_IndInvNoEntryTargetRR;
   if(setup==IND_INV_ENGULFED)   return Inp_IndInvEngulfTargetRR;
   if(setup==IND_INV_EMA_ENGULF) return Inp_IndInvEMATargetRR;
   return 0.0;
}

bool IndependentInverseCooldownComplete()
{
   if(g_indInvLastStateEndBar==0 || Inp_IndInvCooldownBars<=0)
      return true;
   const int shift=iBarShift(_Symbol,PERIOD_M5,g_indInvLastStateEndBar,false);
   return (shift>Inp_IndInvCooldownBars);
}

bool DetectIndependentAccumulation(const MqlRates &rates[],const double atr,
                                   const int mainDirection)
{
   if(mainDirection==0 || atr<=0.0)
      return false;
   double high=rates[1].high,low=rates[1].low,overlap=0.0,body=0.0;
   for(int i=1;i<=Inp_IndInvAccumBars;i++)
   {
      high=MathMax(high,rates[i].high);
      low=MathMin(low,rates[i].low);
      body+=BodyRatio(rates[i]);
      if(i<Inp_IndInvAccumBars)
         overlap+=OverlapRatio(rates[i],rates[i+1]);
   }
   const double height=high-low;
   const double averageOverlap=overlap/MathMax(1,Inp_IndInvAccumBars-1);
   const double averageBody=body/Inp_IndInvAccumBars;
   if(height<Inp_IndInvAccumMinATR*atr || height>Inp_IndInvAccumMaxATR*atr ||
      averageOverlap<Inp_IndInvMinOverlap || averageBody<Inp_IndInvMinAvgBody ||
      averageBody>Inp_IndInvMaxAvgBody)
      return false;
   const double zone=MathMin(0.50,MathMax(0.05,Inp_IndInvPressureZonePct))*height;
   int pressure=0;
   for(int i=1;i<=MathMin(3,Inp_IndInvAccumBars);i++)
   {
      if(mainDirection>0 && rates[i].close>=high-zone) pressure++;
      if(mainDirection<0 && rates[i].close<=low+zone) pressure++;
   }
   if(pressure<Inp_IndInvMinPressureCloses)
      return false;

   g_independentInverse.active=true;
   g_independentInverse.detected_time=rates[1].time;
   g_independentInverse.main_direction=mainDirection;
   g_independentInverse.high=high;
   g_independentInverse.low=low;
   g_independentInverse.atr=atr;
   g_independentInverse.wait_bars=0;
   g_independentInverse.entry_candle_seen=false;
   g_independentInverse.bars_after_entry=0;
   PrintFormat("[BV-INDINV][ACCUM][MAIN:%s] time=%s low=%.*f high=%.*f height=%.2fATR overlap=%.2f body=%.2f pressure=%d",
               DirectionText(mainDirection),TimeToString(rates[1].time,TIME_DATE|TIME_MINUTES),
               _Digits,low,_Digits,high,height/atr,averageOverlap,averageBody,pressure);
   return true;
}

double CalculateIndependentRiskVolume(const int direction,const double entry,const double stopLoss)
{
   const double riskMoney=AccountInfoDouble(ACCOUNT_EQUITY)*Inp_IndependentRiskPercent/100.0;
   double oneLotProfit=0.0;
   if(riskMoney<=0.0 || !OrderCalcProfit(direction>0 ? ORDER_TYPE_BUY : ORDER_TYPE_SELL,
                                         _Symbol,1.0,entry,stopLoss,oneLotProfit))
      return 0.0;
   const double oneLotLoss=MathAbs(oneLotProfit);
   return (oneLotLoss>0.0 ? NormalizeVolumeDown(riskMoney/oneLotLoss) : 0.0);
}

bool IndependentEMAEngulf(const MqlRates &bar,const double ema,const int mainDirection)
{
   if(BodyRatio(bar)<Inp_IndInvEMAMinBody)
      return false;
   if(mainDirection>0)
      return (IsBear(bar) && bar.open>ema && bar.close<ema);
   return (IsBull(bar) && bar.open<ema && bar.close>ema);
}

bool IndependentEntryEngulfed(const MqlRates &bar,const MqlRates &entryBar,
                              const int mainDirection)
{
   const double tolerance=Inp_IndInvEngulfToleranceATR*g_independentInverse.atr;
   if(mainDirection>0)
      return (IsBull(entryBar) && IsBear(bar) &&
              bar.open>=entryBar.close-tolerance && bar.close<=entryBar.open+tolerance &&
              bar.close<g_independentInverse.high);
   return (IsBear(entryBar) && IsBull(bar) &&
           bar.open<=entryBar.close+tolerance && bar.close>=entryBar.open-tolerance &&
           bar.close>g_independentInverse.low);
}

bool OpenIndependentInverse(const ENUM_INDEPENDENT_INVERSE_SETUP setup,
                            const MqlRates &signalBar,const int direction,
                            const MqlTick &tick)
{
   if(!IndependentInverseDirectionAllowed(setup,direction) ||
      !IndependentInverseSessionAllowed(setup,tick.time) ||
      !SymbolTradingSessionOpen(tick.time))
   {
      PrintFormat("[BV-INDINV][SKIP:%s] direction or session disabled",IndependentInverseCode(setup));
      ResetIndependentInverse(true);
      return false;
   }
   const double entry=NormalizePriceNearest(direction>0 ? tick.ask : tick.bid);
   const double buffer=Inp_IndInvStopBufferATR*g_independentInverse.atr;
   double rawStop=(direction>0 ? MathMin(g_independentInverse.low,signalBar.low)-buffer :
                                  MathMax(g_independentInverse.high,signalBar.high)+buffer);
   const double minimumRisk=Inp_IndInvMinRiskATR*g_independentInverse.atr;
   if(direction>0) rawStop=MathMin(rawStop,entry-minimumRisk);
   else            rawStop=MathMax(rawStop,entry+minimumRisk);
   const double stopLoss=NormalizeStop(rawStop,direction);
   const double riskDistance=(direction>0 ? entry-stopLoss : stopLoss-entry);
   if(riskDistance<=0.0 || riskDistance>Inp_IndInvMaxRiskATR*g_independentInverse.atr)
   {
      PrintFormat("[BV-INDINV][SKIP:%s] invalid risk %.2fATR",
                  IndependentInverseCode(setup),riskDistance/g_independentInverse.atr);
      ResetIndependentInverse(true);
      return false;
   }
   const double spread=tick.ask-tick.bid;
   if((Inp_MaxSpreadPoints>0 && spread/_Point>Inp_MaxSpreadPoints) ||
      (Inp_MaxSpreadToRiskPct>0.0 && 100.0*spread/riskDistance>Inp_MaxSpreadToRiskPct))
   {
      PrintFormat("[BV-INDINV][SKIP:%s] spread %.1f points / %.1f%% risk",
                  IndependentInverseCode(setup),spread/_Point,100.0*spread/riskDistance);
      ResetIndependentInverse(true);
      return false;
   }
   const double targetRR=IndependentInverseTargetRR(setup);
   const double takeProfit=NormalizePriceNearest(entry+direction*targetRR*riskDistance);
   if(!StopsAreBrokerValid(direction,entry,stopLoss,takeProfit))
   {
      ResetIndependentInverse(true);
      return false;
   }
   const double volume=CalculateIndependentRiskVolume(direction,entry,stopLoss);
   if(volume<=0.0)
   {
      ResetIndependentInverse(true);
      return false;
   }

   trade.SetExpertMagicNumber(Inp_MagicNumber);
   trade.SetTypeFillingBySymbol(_Symbol);
   trade.SetDeviationInPoints(20);
   const string comment="BVIX_"+IndependentInverseCode(setup)+"_"+DirectionText(direction);
   const bool sent=(direction>0 ? trade.Buy(volume,_Symbol,0.0,stopLoss,takeProfit,comment) :
                                  trade.Sell(volume,_Symbol,0.0,stopLoss,takeProfit,comment));
   if(sent && IsSuccessfulRetcode(trade.ResultRetcode()))
   {
      const double fill=(trade.ResultPrice()>0.0 ? trade.ResultPrice() : entry);
      PrintFormat("[BV-INDINV][ENTRY:%s][%s] volume=%.3f fill=%.*f SL=%.*f TP=%.*f target=%.2fR risk=%.2f%%",
                  IndependentInverseCode(setup),DirectionText(direction),volume,_Digits,fill,
                  _Digits,stopLoss,_Digits,takeProfit,targetRR,Inp_IndependentRiskPercent);
      DrawTextTag("BV_INDINV",tick.time,fill,
                  IndependentInverseCode(setup)+" "+DirectionText(direction),
                  direction>0 ? clrDeepSkyBlue : clrTomato);
      g_lastEntryBarTime=iTime(_Symbol,PERIOD_M5,0);
      ResetCandidate(g_pending);
      ResetIndependentInverse(true);
      return true;
   }
   PrintFormat("[BV-INDINV][ORDER-REJECT:%s] retcode=%u (%s) error=%d",
               IndependentInverseCode(setup),trade.ResultRetcode(),trade.ResultRetcodeDescription(),GetLastError());
   ResetIndependentInverse(true);
   return false;
}

void ProcessIndependentInverse(const MqlRates &rates[],const double &m5Ema[],
                               const MqlTick &tick)
{
   const MqlRates bar=rates[1];
   const int inverseDirection=-g_independentInverse.main_direction;
   if(g_independentInverse.entry_candle_seen)
   {
      g_independentInverse.bars_after_entry++;
      if(Inp_IndInvEnableEngulfed &&
         IndependentEntryEngulfed(bar,g_independentInverse.entry_candle,
                                  g_independentInverse.main_direction))
      {
         OpenIndependentInverse(IND_INV_ENGULFED,bar,inverseDirection,tick);
         return;
      }
      if(Inp_IndInvEnableEMAEngulf &&
         IndependentEMAEngulf(bar,m5Ema[1],g_independentInverse.main_direction))
      {
         OpenIndependentInverse(IND_INV_EMA_ENGULF,bar,inverseDirection,tick);
         return;
      }
      if(g_independentInverse.bars_after_entry>=Inp_IndInvEngulfWindowBars)
         ResetIndependentInverse(true);
      return;
   }

   if(Inp_IndInvEnableEMAEngulf &&
      IndependentEMAEngulf(bar,m5Ema[1],g_independentInverse.main_direction))
   {
      OpenIndependentInverse(IND_INV_EMA_ENGULF,bar,inverseDirection,tick);
      return;
   }
   const double breakoutBuffer=Inp_IndInvBreakoutBufferATR*g_independentInverse.atr;
   const bool mainEntry=(g_independentInverse.main_direction>0 ?
                         IsBull(bar) && bar.close>g_independentInverse.high+breakoutBuffer :
                         IsBear(bar) && bar.close<g_independentInverse.low-breakoutBuffer);
   if(mainEntry)
   {
      g_independentInverse.entry_candle_seen=true;
      g_independentInverse.entry_candle=bar;
      g_independentInverse.bars_after_entry=0;
      return;
   }

   g_independentInverse.wait_bars++;
   const bool oppositeBreak=(g_independentInverse.main_direction>0 ?
                             IsBear(bar) && bar.close<g_independentInverse.low-breakoutBuffer :
                             IsBull(bar) && bar.close>g_independentInverse.high+breakoutBuffer);
   if(Inp_IndInvEnableNoEntry &&
      g_independentInverse.wait_bars>=Inp_IndInvNoEntryWaitBars && oppositeBreak &&
      BodyRatio(bar)>=Inp_IndInvNoEntryMinBody)
   {
      OpenIndependentInverse(IND_INV_NO_ENTRY,bar,inverseDirection,tick);
      return;
   }
   if(g_independentInverse.wait_bars>=Inp_IndInvNoEntryWaitBars+3)
      ResetIndependentInverse(true);
}

void UpdateIndependentInverseOnNewBar()
{
   if(!Inp_EnableIndependentInverse)
      return;
   if(!CanOpenAnotherPosition())
   {
      ResetIndependentInverse(true);
      return;
   }
   MqlRates h1Rates[],m5Rates[];
   double h1Ema[],h1Atr[],m5Atr[],m5Ema[];
   if(!GetMarketData(h1Rates,h1Ema,h1Atr) ||
      !GetM5SetupData(m5Rates,m5Atr) || m5Atr[1]<=0.0)
      return;
   ArraySetAsSeries(m5Ema,true);
   const int needed=ArraySize(m5Rates);
   if(CopyBuffer(g_indInvM5EmaHandle,0,0,needed,m5Ema)<needed)
      return;
   MqlTick tick;
   if(!SymbolInfoTick(_Symbol,tick))
      return;
   if(g_independentInverse.active)
   {
      ProcessIndependentInverse(m5Rates,m5Ema,tick);
      return;
   }
   if(!IndependentInverseCooldownComplete())
      return;
   const int mainDirection=TrendDirection(h1Rates,h1Ema,Inp_IndInvH1SlopeBars);
   DetectIndependentAccumulation(m5Rates,m5Atr[1],mainDirection);
}

void TryTriggerPendingM5()
{
   if(!g_pending.valid)
      return;
   if(!CanOpenAnotherPosition())
      return;
   MqlTick tick;
   if(!SymbolInfoTick(_Symbol,tick))
      return;

   MqlRates m5Rates[];
   double m5Atr[];
   ArraySetAsSeries(m5Rates,true);
   ArraySetAsSeries(m5Atr,true);
   if(CopyRates(_Symbol,PERIOD_M5,0,3,m5Rates)<3 ||
      CopyBuffer(g_m5AtrHandle,0,0,3,m5Atr)<3 || m5Atr[1]<=0.0)
      return;
   const MqlRates confirmation=m5Rates[1];
   const datetime setupClose=g_pending.signal_time+PeriodSeconds(PERIOD_M5);
   if(confirmation.time<setupClose)
      return;
   const int waitBars=PendingWaitBars();
   if(waitBars<0)
   {
      PrintFormat("[BV-H1CTX-M5][WAIT-ERROR:%s] signal M5 bar is unavailable",
                  SetupCode(g_pending.type));
      ResetCandidate(g_pending);
      return;
   }
   const bool triggered=(g_pending.direction>0 ? confirmation.close>=g_pending.trigger :
                                                   confirmation.close<=g_pending.trigger);
   if(!triggered)
      return;
   if(!ConfirmWaitAllowed(g_pending.type,g_pending.direction,waitBars))
   {
      PrintFormat("[BV-H1CTX-M5][WAIT-REJECT:%s] direction=%s wait=%d M5 bars",
                  SetupCode(g_pending.type),DirectionText(g_pending.direction),waitBars);
      ResetCandidate(g_pending);
      return;
   }
   if(Inp_FBBlockEmergingWait1 && g_pending.type==BV_FB && waitBars==1 &&
      g_pending.context.transition_state=="EMERGING_ALIGNED")
   {
      PrintFormat("[BV-H1CTX-M5][CONTEXT-REJECT:FB] wait=1 while transition=%s",
                  g_pending.context.transition_state);
      ResetCandidate(g_pending);
      return;
   }
   const double candleRange=confirmation.high-confirmation.low;
   if(candleRange<=0.0)
      return;
   const double bodyRatio=MathAbs(confirmation.close-confirmation.open)/candleRange;
   const bool directional=(g_pending.direction>0 ? confirmation.close>confirmation.open :
                                                   confirmation.close<confirmation.open);
   if(Inp_M5RequireDirectionalCandle && !directional)
   {
      PrintFormat("[BV-H1-M5][WAIT:%s] close crossed H1 trigger but M5 candle is not directional",
                  SetupCode(g_pending.type));
      return;
   }
   if(bodyRatio<Inp_M5MinBodyRatio)
   {
      PrintFormat("[BV-H1-M5][WAIT:%s] M5 body ratio %.3f is below %.3f",
                  SetupCode(g_pending.type),bodyRatio,Inp_M5MinBodyRatio);
      return;
   }
   if(Inp_DDBSellBlockFullBodyConfirm && g_pending.type==BV_DDB && g_pending.direction<0 &&
      bodyRatio>=0.75)
   {
      PrintFormat("[BV-H1CTX-M5][ENTRY-REJECT:DDB-v193] SELL confirmation body ratio %.3f is full-body (>=0.750)",
                  bodyRatio);
      ResetCandidate(g_pending);
      return;
   }
   if(Inp_RBBuyBlockMidBodyConfirm && g_pending.type==BV_RB && g_pending.direction>0 &&
      bodyRatio>=0.50 && bodyRatio<0.75)
   {
      PrintFormat("[BV-H1CTX-M5][ENTRY-REJECT:RB-v196] BUY confirmation body ratio %.3f is in ambiguous 0.50-0.75 band",
                  bodyRatio);
      ResetCandidate(g_pending);
      return;
   }
   if(Inp_M5MaxCandleATR>0.0 && candleRange>Inp_M5MaxCandleATR*m5Atr[1])
   {
      PrintFormat("[BV-H1-M5][WAIT:%s] M5 candle range %.3f ATR exceeds %.3f",
                  SetupCode(g_pending.type),candleRange/m5Atr[1],Inp_M5MaxCandleATR);
      return;
   }
   const double closeBeyond=g_pending.direction*(confirmation.close-g_pending.trigger);
   if(Inp_M5MaxChaseATR>0.0 && closeBeyond>Inp_M5MaxChaseATR*m5Atr[1])
   {
      PrintFormat("[BV-H1-M5][WAIT:%s] M5 close is %.3f ATR beyond H1 trigger; max %.3f",
                  SetupCode(g_pending.type),closeBeyond/m5Atr[1],Inp_M5MaxChaseATR);
      return;
   }
   if(!SessionAllowedForSetup(g_pending.type,g_pending.direction,tick.time))
   {
      PrintFormat("[BV-H1][SKIP:%s] breakout triggered outside the setup session mask",
                  SetupCode(g_pending.type));
      ResetCandidate(g_pending);
      return;
   }
   if(!SymbolTradingSessionOpen(tick.time))
   {
      PrintFormat("[BV-H1][SKIP:%s] broker trading session is closed",
                  SetupCode(g_pending.type));
      ResetCandidate(g_pending);
      return;
   }

   const double entry=NormalizePriceNearest(g_pending.direction>0 ? tick.ask : tick.bid);
   const double stopBuffer=MathMax(MathMax(0.0,Inp_SLBufferPoints)*_Point,
                                   MathMax(0.0,Inp_M5SLBufferATR)*m5Atr[1]);
   double m5Stop=(g_pending.direction>0 ? confirmation.low-stopBuffer : confirmation.high+stopBuffer);
   const double minimumRisk=MathMax(0.0,Inp_M5MinRiskATR)*m5Atr[1];
   if(g_pending.direction>0)
      m5Stop=MathMin(m5Stop,entry-minimumRisk);
   else
      m5Stop=MathMax(m5Stop,entry+minimumRisk);
   g_pending.stop_loss=NormalizeStop(m5Stop,g_pending.direction);
   g_pending.m5_signal_time=confirmation.time;
   g_pending.m5_signal_open=confirmation.open;
   g_pending.m5_signal_high=confirmation.high;
   g_pending.m5_signal_low=confirmation.low;
   g_pending.m5_signal_close=confirmation.close;
   g_pending.m5_atr=m5Atr[1];
   g_pending.m5_body_ratio=bodyRatio;
   g_pending.m5_wait_bars=waitBars;
   if(Inp_DDBSellBlockEarlyEmergingWait0 && g_pending.type==BV_DDB && g_pending.direction<0 &&
      SessionBitAt(tick.time)==1 && g_pending.context.transition_state=="EMERGING_ALIGNED" &&
      g_pending.m5_wait_bars==0)
   {
      Print("[BV-H1CTX-M5][ENTRY-REJECT:DDB-v188-A] SELL 00-07 emerging trend with wait0 confirmation");
      ResetCandidate(g_pending);
      return;
   }
   const double riskDistance=(g_pending.direction>0 ? entry-g_pending.stop_loss : g_pending.stop_loss-entry);
   if(riskDistance<=0.0)
   {
      PrintFormat("[BV-H1][SKIP:%s] gap crossed the signal-candle SL",SetupCode(g_pending.type));
      ResetCandidate(g_pending);
      return;
   }
   const double spread=tick.ask-tick.bid;
   const double spreadPoints=spread/_Point;
   if((Inp_MaxSpreadPoints>0 && spreadPoints>Inp_MaxSpreadPoints) ||
      (Inp_MaxSpreadToRiskPct>0.0 && spread/riskDistance*100.0>Inp_MaxSpreadToRiskPct))
   {
      PrintFormat("[BV-H1][SKIP:%s] spread %.1f points is too large for risk distance %.1f points",
                  SetupCode(g_pending.type),spreadPoints,riskDistance/_Point);
      ResetCandidate(g_pending);
      return;
   }

   double takeProfit=0.0;
   const double targetRR=TargetRRForSetup(g_pending.type);
   if(targetRR>0.0)
      takeProfit=NormalizePriceNearest(entry+g_pending.direction*targetRR*riskDistance);
   if(!StopsAreBrokerValid(g_pending.direction,entry,g_pending.stop_loss,takeProfit))
   {
      PrintFormat("[BV-H1][SKIP:%s] entry/SL/TP violates broker stop level",SetupCode(g_pending.type));
      ResetCandidate(g_pending);
      return;
   }

   if(Inp_EnableInverseFailureMode)
   {
      g_inverseShadow.active=true;
      g_inverseShadow.source=g_pending;
      g_inverseShadow.open_time=tick.time;
      g_inverseShadow.main_entry=entry;
      g_inverseShadow.main_stop=g_pending.stop_loss;
      g_inverseShadow.main_target=takeProfit;
      g_inverseShadow.last_m5_bar_time=iTime(_Symbol,PERIOD_M5,0);
      g_inverseShadow.bars_elapsed=0;
      g_inverseShadow.main_sl_seen=false;
      PrintFormat("[BV-INVERSE][SHADOW:%s][%s] virtualEntry=%.*f SL=%.*f TP=%.*f wait=%d",
                  SetupCode(g_pending.type),DirectionText(g_pending.direction),
                  _Digits,entry,_Digits,g_pending.stop_loss,_Digits,takeProfit,waitBars);
      ResetCandidate(g_pending);
      return;
   }

   const double volume=CalculateRiskVolume(g_pending.direction,entry,g_pending.stop_loss);
   if(volume<=0.0)
   {
      PrintFormat("[BV-H1][SKIP:%s] calculated risk lot is below symbol minimum or invalid",SetupCode(g_pending.type));
      ResetCandidate(g_pending);
      return;
   }

   trade.SetExpertMagicNumber(Inp_MagicNumber);
   trade.SetTypeFillingBySymbol(_Symbol);
   trade.SetDeviationInPoints(20);
   string tradeComment="BVCTXM5_"+SetupCode(g_pending.type)+"_"+DirectionText(g_pending.direction);
   if(g_pending.wyckoff_event!=WY_NONE)
      tradeComment+="_"+WyckoffEventCode(g_pending.wyckoff_event);
   bool sent=false;
   if(g_pending.direction>0)
      sent=trade.Buy(volume,_Symbol,0.0,g_pending.stop_loss,takeProfit,tradeComment);
   else
      sent=trade.Sell(volume,_Symbol,0.0,g_pending.stop_loss,takeProfit,tradeComment);

   const uint retcode=trade.ResultRetcode();
   if(sent && IsSuccessfulRetcode(retcode))
   {
      const double fill=(trade.ResultPrice()>0.0 ? trade.ResultPrice() : entry);
      StartExcursionTracker(g_pending,fill);
      AnnotateEntry(g_pending,fill);
      PrintFormat("[BV-H1CTX-M5][ENTRY:%s][%s][WY:%s] volume=%.3f fill=%.*f SL=%.*f TP=%.*f risk=%.2f%% comment=%s",
                  SetupCode(g_pending.type),DirectionText(g_pending.direction),
                  WyckoffEventCode(g_pending.wyckoff_event),volume,
                  _Digits,fill,_Digits,g_pending.stop_loss,_Digits,takeProfit,
                   Inp_RiskPercent,tradeComment);
      PrintFormat("[BV-H1CTX-M5][CONFIRM:%s] candle=%s O=%.*f H=%.*f L=%.*f C=%.*f ATR=%.*f body=%.3f wait=%d M5 bars",
                  SetupCode(g_pending.type),TimeToString(confirmation.time,TIME_DATE|TIME_MINUTES),
                  _Digits,confirmation.open,_Digits,confirmation.high,_Digits,confirmation.low,
                  _Digits,confirmation.close,_Digits,m5Atr[1],bodyRatio,g_pending.m5_wait_bars);
      g_lastEntryBarTime=iTime(_Symbol,PERIOD_M5,0);
      ResetCandidate(g_pending);
   }
   else
   {
      PrintFormat("[BV-H1][ORDER-REJECT:%s] retcode=%u (%s) lastError=%d",
                  SetupCode(g_pending.type),retcode,trade.ResultRetcodeDescription(),GetLastError());
      // Do not retry every tick. In particular, a market-closed rejection can
      // otherwise survive the weekend and become a stale fill.
      ResetCandidate(g_pending);
   }
}

void UpdateStatusPanel()
{
   if(!Inp_ShowStatusPanel)
   {
      Comment("");
      return;
   }
   const int ownPositions=OwnPositionCount();
   string state="WAITING FOR M5 SETUP IN H1 CONTEXT";
   if(g_pending.valid)
      state=StringFormat("%d POSITION(S) | PENDING %s %s | WY %s | ELL %s | CTX %s | trigger %.*f | SL %.*f",
                         ownPositions,SetupCode(g_pending.type),DirectionText(g_pending.direction),
                         WyckoffEventCode(g_pending.wyckoff_event),
                         g_pending.context.elliott_phase,g_pending.context.confluence_tier,
                         _Digits,g_pending.trigger,_Digits,g_pending.stop_loss);
   else if(Inp_EnableIndependentInverse && g_independentInverse.active)
      state=StringFormat("INVERSE ACCUM %s | range %.*f - %.*f | wait %d",
                         DirectionText(-g_independentInverse.main_direction),
                         _Digits,g_independentInverse.low,_Digits,g_independentInverse.high,
                         g_independentInverse.wait_bars);
   else if(ownPositions>0)
      state=StringFormat("%d POSITION(S) OPEN | waiting for another valid setup",ownPositions);
   const string wyState=(Inp_WyckoffFilterMode==WY_FILTER_OFF ? "OFF" :
                         (g_wyckoff.valid ? WyckoffEventCode(g_wyckoff.event)+" "+DirectionText(g_wyckoff.bias) : "NO EVENT"));
   string inverseState="OFF";
   if(Inp_EnableIndependentInverse)
   {
      inverseState="ON";
      if(Inp_IndInvEnableNoEntry)   inverseState+=" NOENTRY";
      if(Inp_IndInvEnableEngulfed)  inverseState+=" ENGULFED";
      if(Inp_IndInvEnableEMAEngulf) inverseState+=" EMAENGULF";
   }
   Comment("IndiSingle H1 context / Bob Volman M5 setup+entry\n",
            "State: ",state,"\n",
            "Risk: ",DoubleToString(Inp_RiskPercent,2),"% equity = 1R\n",
            "Position mode: ",(Inp_AllowMultiplePositions ? "MULTI" : "SINGLE"),
            (Inp_AllowMultiplePositions && Inp_MaxOpenPositions>0 ?
             StringFormat(" (max %d)",Inp_MaxOpenPositions) : ""),"\n",
            "Enabled: ",EnabledSetupsText(),"\n",
            "Independent inverse: ",inverseState,"\n",
            "Wyckoff: ",wyState);
}

//+------------------------------------------------------------------+
//| Standard events                                                  |
//+------------------------------------------------------------------+
int OnInit()
{
   if(_Period!=PERIOD_M5)
   {
      Print("[BV-H1CTX-M5][INIT] Attach the EA to M5; setup/entry are M5 and context remains H1.");
      return INIT_PARAMETERS_INCORRECT;
   }
   const ENUM_ACCOUNT_MARGIN_MODE marginMode=(ENUM_ACCOUNT_MARGIN_MODE)AccountInfoInteger(ACCOUNT_MARGIN_MODE);
   if(Inp_AllowMultiplePositions && marginMode!=ACCOUNT_MARGIN_MODE_RETAIL_HEDGING)
   {
      PrintFormat("[BV-H1CTX-M5][INIT] Multiple positions require a hedging account; margin mode=%d.",(int)marginMode);
      return INIT_PARAMETERS_INCORRECT;
   }
   if(Inp_AllowMultiplePositions && Inp_ExportExcursions)
   {
      Print("[BV-H1CTX-M5][INIT] Multi-position mode cannot use the single-position excursion tracker. Disable Inp_ExportExcursions.");
      return INIT_PARAMETERS_INCORRECT;
   }
   if((int)Inp_DDBBuyImbalanceMode<0 || (int)Inp_DDBBuyImbalanceMode>1 ||
      (int)Inp_DDBSellImbalanceMode<0 || (int)Inp_DDBSellImbalanceMode>1 ||
      (int)Inp_FBBuyImbalanceMode<0 || (int)Inp_FBBuyImbalanceMode>1 ||
      (int)Inp_FBSellImbalanceMode<0 || (int)Inp_FBSellImbalanceMode>1 ||
      (int)Inp_SBBuyImbalanceMode<0 || (int)Inp_SBBuyImbalanceMode>1 ||
      (int)Inp_SBSellImbalanceMode<0 || (int)Inp_SBSellImbalanceMode>1 ||
      (int)Inp_BBBuyImbalanceMode<0 || (int)Inp_BBBuyImbalanceMode>1 ||
      (int)Inp_BBSellImbalanceMode<0 || (int)Inp_BBSellImbalanceMode>1 ||
      (int)Inp_RBBuyImbalanceMode<0 || (int)Inp_RBBuyImbalanceMode>1 ||
      (int)Inp_RBSellImbalanceMode<0 || (int)Inp_RBSellImbalanceMode>1 ||
      (int)Inp_IRBBuyImbalanceMode<0 || (int)Inp_IRBBuyImbalanceMode>1 ||
      (int)Inp_IRBSellImbalanceMode<0 || (int)Inp_IRBSellImbalanceMode>1 ||
      (int)Inp_ARBBuyImbalanceMode<0 || (int)Inp_ARBBuyImbalanceMode>1 ||
      (int)Inp_ARBSellImbalanceMode<0 || (int)Inp_ARBSellImbalanceMode>1)
   {
      Print("[BV-H1CTX-M5][INIT] Imbalance mode supports only OFF(0) or M5_ALIGNED(1).");
      return INIT_PARAMETERS_INCORRECT;
   }
   if((int)Inp_BBStructureMode<0 || (int)Inp_BBStructureMode>4)
   {
      Print("[BV-H1CTX-M5][INIT] BB structure mode supports values 0..4.");
      return INIT_PARAMETERS_INCORRECT;
   }
   if(Inp_RiskPercent<=0.0 || Inp_RiskPercent>10.0 || Inp_EMAPeriod<2 ||
      Inp_ATRPeriod<2 || Inp_RangeBars<6 || Inp_BlockBars<3 || Inp_IRBRangeBars<6 ||
      Inp_BBMinPressureBars<0 || Inp_BBMinPressureBars>Inp_BlockBars ||
      Inp_BBPressureZonePct<=0.0 || Inp_BBPressureZonePct>0.5 ||
      Inp_BBMinSignalBodyRatio<0.0 || Inp_BBMinSignalBodyRatio>1.0 ||
      Inp_SBExtraSLBufferATR<0.0 || Inp_SBExtraSLBufferATR>1.0 ||
      Inp_BBExtraSLBufferATR<0.0 || Inp_BBExtraSLBufferATR>1.0 ||
      Inp_DDBEntryBufferATR<0.0 || Inp_DDBEntryBufferATR>0.5 ||
      Inp_SBEntryBufferATR<0.0 || Inp_SBEntryBufferATR>0.5 ||
      Inp_SBMinAttemptBodyRatio<0.0 || Inp_SBMinAttemptBodyRatio>1.0 ||
      Inp_SBMinSignalCloseZone<0.0 || Inp_SBMinSignalCloseZone>0.5 ||
      Inp_IRBRangeMinATR<=0.0 || Inp_IRBRangeMaxATR<Inp_IRBRangeMinATR ||
      Inp_IRBMinRangeTouches<1 || Inp_IRBEdgeZonePct<=0.0 ||
      Inp_IRBEdgeZonePct>0.5 || Inp_IRBMaxCandleATR<=0.0 ||
      Inp_WyckoffLookback<6 || Inp_WyckoffValidBars<1 ||
      Inp_WyckoffVolumeFactor<0.0 || Inp_WyckoffTestVolumeFactor<0.0 ||
      Inp_DDBWyckoffMaxAge<0 || Inp_FBWyckoffMaxAge<0 || Inp_SBWyckoffMaxAge<0 ||
      Inp_BBWyckoffMaxAge<0 || Inp_RBWyckoffMaxAge<0 || Inp_IRBWyckoffMaxAge<0 ||
      Inp_ARBWyckoffMaxAge<0 || Inp_DDBWyckoffMaxDistanceATR<0.0 ||
      Inp_FBWyckoffMaxDistanceATR<0.0 || Inp_SBWyckoffMaxDistanceATR<0.0 ||
      Inp_BBWyckoffMaxDistanceATR<0.0 || Inp_RBWyckoffMaxDistanceATR<0.0 ||
      Inp_IRBWyckoffMaxDistanceATR<0.0 || Inp_ARBWyckoffMaxDistanceATR<0.0 ||
       Inp_SBBreakEvenTriggerR<=0.0 || Inp_BBBreakEvenTriggerR<=0.0 ||
       Inp_ContextTrendBars<12 || Inp_ContextTrendBars>240 ||
       Inp_ContextFastTrendBars<12 || Inp_ContextFastTrendBars>72 ||
       Inp_ContextLongTrendBars<72 || Inp_ContextLongTrendBars>500 ||
       Inp_ContextMinTrendR2<0.0 || Inp_ContextMinTrendR2>1.0 ||
       Inp_ContextMinSlopeATR<0.0 || Inp_ContextMinSlopeATR>1.0 ||
       Inp_ContextFastMinTrendR2<0.0 || Inp_ContextFastMinTrendR2>1.0 ||
       Inp_ContextFastMinSlopeATR<0.0 || Inp_ContextFastMinSlopeATR>1.0 ||
       Inp_ContextLongMinTrendR2<0.0 || Inp_ContextLongMinTrendR2>1.0 ||
       Inp_ContextLongMinSlopeATR<0.0 || Inp_ContextLongMinSlopeATR>1.0 ||
       Inp_BBMinH1ATRPercent<0.0 || Inp_BBMinH1ATRPercent>10.0 ||
       Inp_ElliottPivotSpan<1 || Inp_ElliottPivotSpan>12 ||
       Inp_ElliottLookback<40 || Inp_ElliottLookback>500 ||
       Inp_M5MinBodyRatio<0.0 || Inp_M5MinBodyRatio>1.0 ||
       Inp_M5MaxCandleATR<0.0 || Inp_M5MaxCandleATR>10.0 ||
       Inp_M5MaxChaseATR<0.0 || Inp_M5MaxChaseATR>10.0 ||
       Inp_M5SLBufferATR<0.0 || Inp_M5SLBufferATR>2.0 ||
       Inp_M5MinRiskATR<0.0 || Inp_M5MinRiskATR>5.0 ||
       Inp_DDBBuyWaitMask<0 || Inp_DDBBuyWaitMask>7 || Inp_DDBSellWaitMask<0 || Inp_DDBSellWaitMask>7 ||
       Inp_FBBuyWaitMask<0 || Inp_FBBuyWaitMask>7 || Inp_FBSellWaitMask<0 || Inp_FBSellWaitMask>7 ||
       Inp_SBBuyWaitMask<0 || Inp_SBBuyWaitMask>7 || Inp_SBSellWaitMask<0 || Inp_SBSellWaitMask>7 ||
       Inp_BBBuyWaitMask<0 || Inp_BBBuyWaitMask>7 || Inp_BBSellWaitMask<0 || Inp_BBSellWaitMask>7 ||
       Inp_RBBuyWaitMask<0 || Inp_RBBuyWaitMask>7 || Inp_RBSellWaitMask<0 || Inp_RBSellWaitMask>7 ||
       Inp_IRBBuyWaitMask<0 || Inp_IRBBuyWaitMask>7 || Inp_IRBSellWaitMask<0 || Inp_IRBSellWaitMask>7 ||
       Inp_ARBBuyWaitMask<0 || Inp_ARBBuyWaitMask>7 || Inp_ARBSellWaitMask<0 || Inp_ARBSellWaitMask>7 ||
       Inp_M5ImbalanceLookback<1 || Inp_M5ImbalanceLookback>80 ||
       Inp_ImbalanceMinGapATR<0.0 || Inp_ImbalanceMinGapATR>2.0 ||
       Inp_ImbalanceMinBody<0.0 || Inp_ImbalanceMinBody>1.0 ||
       Inp_SBBuyImbalanceWyckoffMask<0 || Inp_SBBuyImbalanceWyckoffMask>255 ||
       Inp_BBImbalanceMaxDistanceATR<0.0 || Inp_BBImbalanceMaxDistanceATR>3.0 ||
       Inp_BBImbalanceMaxAge<0 || Inp_BBImbalanceMaxAge>Inp_M5ImbalanceLookback ||
       Inp_BBImpulsePhaseMask<1 || Inp_BBImpulsePhaseMask>3 ||
       Inp_BBLateWyckoffMaxAge<1 || Inp_BBLateWyckoffMaxAge>Inp_WyckoffValidBars ||
       Inp_IRBContextEventMask<0 || Inp_IRBContextEventMask>255 ||
      Inp_InverseTargetRR<=0.0 || Inp_InverseTargetRR>10.0 ||
      Inp_InverseFailureBars<1 || Inp_InverseFailureBars>12 ||
      Inp_InverseCloseBufferATR<0.0 || Inp_InverseCloseBufferATR>1.0 ||
       Inp_InverseSLBufferATR<0.0 || Inp_InverseSLBufferATR>1.0 ||
       Inp_IndependentRiskPercent<=0.0 || Inp_IndependentRiskPercent>10.0 ||
       Inp_IndInvNoEntryTargetRR<=0.0 || Inp_IndInvNoEntryTargetRR>10.0 ||
       Inp_IndInvEngulfTargetRR<=0.0 || Inp_IndInvEngulfTargetRR>10.0 ||
       Inp_IndInvEMATargetRR<=0.0 || Inp_IndInvEMATargetRR>10.0 ||
       Inp_IndInvAccumBars<3 || Inp_IndInvAccumBars>20 ||
       Inp_IndInvAccumMinATR<=0.0 || Inp_IndInvAccumMaxATR<Inp_IndInvAccumMinATR ||
       Inp_IndInvMinOverlap<0.0 || Inp_IndInvMinOverlap>1.0 ||
       Inp_IndInvMinAvgBody<0.0 || Inp_IndInvMinAvgBody>Inp_IndInvMaxAvgBody ||
       Inp_IndInvMaxAvgBody<0.0 || Inp_IndInvMaxAvgBody>1.0 ||
       Inp_IndInvMinPressureCloses<0 || Inp_IndInvMinPressureCloses>3 ||
       Inp_IndInvPressureZonePct<=0.0 || Inp_IndInvPressureZonePct>0.5 ||
       Inp_IndInvBreakoutBufferATR<0.0 || Inp_IndInvBreakoutBufferATR>1.0 ||
       Inp_IndInvNoEntryWaitBars<1 || Inp_IndInvEngulfWindowBars<1 ||
       Inp_IndInvNoEntryMinBody<0.0 || Inp_IndInvNoEntryMinBody>1.0 ||
       Inp_IndInvEngulfToleranceATR<0.0 || Inp_IndInvEngulfToleranceATR>1.0 ||
       Inp_IndInvM5EMAPeriod<2 || Inp_IndInvEMAMinBody<0.0 || Inp_IndInvEMAMinBody>1.0 ||
       Inp_IndInvH1SlopeBars<1 || Inp_IndInvStopBufferATR<0.0 || Inp_IndInvStopBufferATR>1.0 ||
       Inp_IndInvMinRiskATR<=0.0 || Inp_IndInvMaxRiskATR<Inp_IndInvMinRiskATR ||
       Inp_IndInvCooldownBars<0 ||
       Inp_IndInvNoEntrySessionMask<0 || Inp_IndInvNoEntrySessionMask>7 ||
       Inp_IndInvEngulfSessionMask<0 || Inp_IndInvEngulfSessionMask>7 ||
       Inp_IndInvEMASessionMask<0 || Inp_IndInvEMASessionMask>7 ||
       Inp_MaxOpenPositions<0 || Inp_MaxOpenPositions>1000 ||
       Inp_TesterMinTrades<1 || Inp_PostExitBars<0 ||
       (Inp_ExportExcursions && StringLen(Inp_ExcursionFileName)<1))
   {
      Print("[BV-H1][INIT] Invalid input parameters.");
      return INIT_PARAMETERS_INCORRECT;
   }
   if(Inp_EnableInverseFailureMode && Inp_EnableIndependentInverse)
   {
      Print("[BV-H1][INIT] Select only one inverse engine: legacy shadow or independent accumulation failure.");
      return INIT_PARAMETERS_INCORRECT;
   }
   g_emaHandle=iMA(_Symbol,PERIOD_H1,Inp_EMAPeriod,0,MODE_EMA,PRICE_CLOSE);
   g_atrHandle=iATR(_Symbol,PERIOD_H1,Inp_ATRPeriod);
   g_m5AtrHandle=iATR(_Symbol,PERIOD_M5,Inp_ATRPeriod);
   g_indInvM5EmaHandle=iMA(_Symbol,PERIOD_M5,Inp_IndInvM5EMAPeriod,0,MODE_EMA,PRICE_CLOSE);
   if(g_emaHandle==INVALID_HANDLE || g_atrHandle==INVALID_HANDLE ||
      g_m5AtrHandle==INVALID_HANDLE || g_indInvM5EmaHandle==INVALID_HANDLE)
   {
      PrintFormat("[BV-H1][INIT] Cannot create indicators. error=%d",GetLastError());
      return INIT_FAILED;
   }
   ResetCandidate(g_pending);
   ResetWyckoffContext(g_wyckoff);
   ResetExcursionTracker();
   ResetInverseShadow();
   ResetIndependentInverse(false);
   g_indInvLastStateEndBar=0;
   ArrayResize(g_postExitRecords,0);
   if(!OpenExcursionFile())
      return INIT_FAILED;
   trade.SetExpertMagicNumber(Inp_MagicNumber);
   trade.SetTypeFillingBySymbol(_Symbol);
   PrintFormat("[BV-H1CTX-M5][INIT] v2.02 loaded: multi-position=%s max=%d account-mode=%d; BB-structure-mode=%d; FB BUY expanding/72H-down filter=%s; legacy inverse=%s; independent inverse=%s. Wyckoff mode=%d; Elliott pivots=%d/%d",
                (Inp_AllowMultiplePositions ? "ON" : "OFF"),Inp_MaxOpenPositions,(int)marginMode,
                (int)Inp_BBStructureMode,
                (Inp_FBBuyBlockExpandingLongDown ? "ON" : "OFF"),
                (Inp_EnableInverseFailureMode ? "ON" : "OFF"),
                (Inp_EnableIndependentInverse ? "ON" : "OFF"),
                (int)Inp_WyckoffFilterMode,Inp_ElliottPivotSpan,Inp_ElliottLookback);
   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
   FlushPostExitRecords();
   if(g_excursionFile!=INVALID_HANDLE)
   {
      FileClose(g_excursionFile);
      g_excursionFile=INVALID_HANDLE;
   }
   if(g_emaHandle!=INVALID_HANDLE) IndicatorRelease(g_emaHandle);
   if(g_atrHandle!=INVALID_HANDLE) IndicatorRelease(g_atrHandle);
   if(g_m5AtrHandle!=INVALID_HANDLE) IndicatorRelease(g_m5AtrHandle);
   if(g_indInvM5EmaHandle!=INVALID_HANDLE) IndicatorRelease(g_indInvM5EmaHandle);
   Comment("");
}

void OnTick()
{
   MqlTick diagnosticTick;
   if(Inp_ExportExcursions && SymbolInfoTick(_Symbol,diagnosticTick))
   {
      if(g_excursion.active)
         UpdateExcursionPrice(g_excursion.direction>0 ? diagnosticTick.bid : diagnosticTick.ask);
      UpdatePostExitRecords(diagnosticTick);
   }
   UpdateInverseShadow();
   const datetime currentM5Bar=iTime(_Symbol,PERIOD_M5,0);
   if(currentM5Bar!=0 && currentM5Bar!=g_lastM5BarTime)
   {
      g_lastM5BarTime=currentM5Bar;
      ExpirePendingIfNeeded();
      // Confirmed independent inverse entries get first refusal on this M5 bar.
      // This deliberately favours the higher-win-rate failure setup over quantity.
      UpdateIndependentInverseOnNewBar();
      TryTriggerPendingM5();
      DetectNewSetup();
   }
   ManageOpenPosition();
   UpdateStatusPanel();
}

void OnTradeTransaction(const MqlTradeTransaction &trans,
                        const MqlTradeRequest &request,
                        const MqlTradeResult &result)
{
   if(!Inp_ExportExcursions || trans.type!=TRADE_TRANSACTION_DEAL_ADD || trans.deal==0)
      return;
   if(!HistoryDealSelect(trans.deal))
      return;
   if((ulong)HistoryDealGetInteger(trans.deal,DEAL_MAGIC)!=Inp_MagicNumber ||
      HistoryDealGetString(trans.deal,DEAL_SYMBOL)!=_Symbol)
      return;
   const ENUM_DEAL_ENTRY entryType=(ENUM_DEAL_ENTRY)HistoryDealGetInteger(trans.deal,DEAL_ENTRY);
   if(entryType==DEAL_ENTRY_OUT || entryType==DEAL_ENTRY_OUT_BY)
      QueueClosedExcursion(trans.deal);
}

double OnTester()
{
   const double trades=TesterStatistics(STAT_TRADES);
   const double profit=TesterStatistics(STAT_PROFIT);
   const double profitFactor=TesterStatistics(STAT_PROFIT_FACTOR);
   if(trades<(double)MathMax(1,Inp_TesterMinTrades) || profit<=0.0 || profitFactor<1.05)
      return 0.0;
   return 100.0*TesterStatistics(STAT_PROFIT_TRADES)/trades;
}
//+------------------------------------------------------------------+
