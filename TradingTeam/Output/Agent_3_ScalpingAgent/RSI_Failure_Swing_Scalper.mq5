//+------------------------------------------------------------------+
//|                                     RSI_Failure_Swing_Scalper.mq5 |
//|                                          Copyright Trading Agent |
//+------------------------------------------------------------------+
#property copyright "Trading Agent"
#property version   "2.00"

#include <Trade\Trade.mqh>

//--- Cấu hình RSI
input group "=== RSI Settings ==="
input int InpRSILength    = 23;           // RSI Length
input int InpLookbackLeft = 5;            // Pivot Lookback Left
input int InpLookbackRight= 5;            // Pivot Lookback Right
input int InpRangeLower   = 5;            // Divergence Range Lower (Số nến tối thiểu)
input int InpRangeUpper   = 60;           // Divergence Range Upper (Số nến tối đa)

enum ENUM_MA_TYPE_TV {
    MA_NONE = 0, // None
    MA_SMA = 1,  // SMA
    MA_BB = 2,   // SMA + Bollinger Bands
    MA_EMA = 3,  // EMA
    MA_SMMA = 4, // SMMA (RMA)
    MA_WMA = 5   // WMA
};

enum ENUM_SIGNAL_MODE {
    MODE_REGULAR_ONLY = 0,  // Regular Divergence Only
    MODE_HIDDEN_ONLY  = 1,  // Hidden Divergence Only
    MODE_BOTH         = 2   // Both Regular + Hidden
};

enum ENUM_EXIT_MODE {
    EXIT_FIXED_SLTP    = 0, // Fixed SL/TP (Pips)
    EXIT_TRAILING_STOP = 1  // Trailing Stop
};

enum ENUM_ORDER_MODE {
    ORDER_SINGLE = 0,  // Single (1 lệnh duy nhất)
    ORDER_MULTI  = 1   // Multi (đa lệnh độc lập)
};

//--- Cấu hình Smoothing MA
enum ENUM_ENTRY_METHOD {
    ENTRY_IN_ZONE        = 0, // Gia nam trong zone la vao lenh
    ENTRY_RETEST_OUTSIDE = 1  // Gia phai di tu ngoai vao lai zone
};

input group "=== Smoothing Settings ==="
input ENUM_MA_TYPE_TV InpMAType   = MA_SMA;       // Smoothing Type
input int             InpMALength = 23;           // Smoothing Length
input double          InpBBMul    = 2.0;          // Bollinger Bands StdDev

//--- Cấu hình Signal Mode
input group "=== Signal Mode ==="
input ENUM_SIGNAL_MODE InpSignalMode = MODE_BOTH;  // Signal Filter Mode

//--- Cấu hình Quản lý vốn & Lệnh
input group "=== Trade Settings ==="
input double InpLotSize      = 0.1;          // Lot Size
input int    InpMagicNum     = 123456;       // Magic Number
input ENUM_EXIT_MODE InpExitMode = EXIT_TRAILING_STOP; // Exit Mode
input ENUM_ORDER_MODE InpOrderMode = ORDER_SINGLE;     // Order Mode

//--- Cấu hình Fixed SL/TP (chỉ dùng khi Exit Mode = Fixed)
input group "=== Fixed SL/TP (Pips) ==="
input double InpFixedSL = 30.0;   // Stop Loss (Pips)
input double InpFixedTP = 60.0;   // Take Profit (Pips)

//--- Cấu hình Trailing Stop (chỉ dùng khi Exit Mode = Trailing)
input group "=== Trailing ==="
input bool   InpUseTrailing     = true;  // Sử dụng trailing?
input double InpTrailStart      = 50.0;  // Pips bắt đầu trailing
input double InpTrailStep       = 20.0;  // Bước trailing (Pips)
input double InpTrailFirstSL    = 10.0;  // Điểm đặt SL lần đầu trailing (Pips)
input double InpInitialSL       = 50.0;  // SL ban đầu khi vào lệnh (Pips)
input bool   InpShowTrailLine   = true;  // Hiển thị line bắt đầu trailing?

//--- Cấu hình Entry Zone
input group "=== Entry Zone ==="
input ENUM_ENTRY_METHOD InpEntryMethod = ENTRY_IN_ZONE; // Entry Method
input double InpZoneBuffer = 0.0;    // Zone Buffer (Pips, moi ben)
input int    InpEntryBars  = 5;      // Số nến sau Signal Candle mà zone còn hiệu lực

input bool   InpDrawHistoryZones = true; // Draw visual zones for history signals

//--- Handles
int rsi_handle;
int smoothing_handle = INVALID_HANDLE;

//--- Pip Multiplier (tự động tính theo số digit của symbol)
double pip_value = 0;

//--- Trade Object
CTrade trade;

//--- Global Flags
bool is_history_drawn = false;
datetime last_time = 0;

//--- Pending Signal Struct (Entry Zone)
struct PendingEntry {
    int      signal;       // 1=Bull, 2=HBull, -1=Bear, -2=HBear
    string   sig_name;
    double   zone_high;
    double   zone_low;
    bool     outside_seen; // Da co luc gia nam ngoai zone chua
    bool     retest_ready; // Da co retest tu ngoai vao zone chua
    datetime signal_time;  // Thời gian của Signal Candle
    datetime expire_time;  // Thời gian hết hạn zone
};
PendingEntry pending_list[];
#define MAX_PENDING 10

//+------------------------------------------------------------------+
//| Hàm dọn dẹp Subwindow rác
//+------------------------------------------------------------------+
void CleanupSubwindows()
{
    int total_windows = (int)ChartGetInteger(0, CHART_WINDOWS_TOTAL);
    // Duyệt từ subwindow cuối cùng về 1 (0 là main chart)
    for(int w = total_windows - 1; w >= 1; w--) {
        int total_inds = ChartIndicatorsTotal(0, w);
        bool has_our_rsi = false;
        
        for(int i = 0; i < total_inds; i++) {
            string name = ChartIndicatorName(0, w, i);
            if(StringFind(name, "RSI(" + IntegerToString(InpRSILength) + ")") >= 0) {
                has_our_rsi = true;
                break;
            }
        }
        
        // Nếu subwindow này chứa RSI của ta, xóa sạch mọi indicator trong đó
        if(has_our_rsi) {
            for(int i = total_inds - 1; i >= 0; i--) {
                ChartIndicatorDelete(0, w, ChartIndicatorName(0, w, i));
            }
        }
    }
}

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
    // Dọn dẹp các subwindow rác từ phiên bản/khung thời gian cũ
    CleanupSubwindows();

    // Khởi tạo RSI theo chuẩn SMMA (tương đương RMA của Pine Script)
    rsi_handle = iRSI(_Symbol, _Period, InpRSILength, PRICE_CLOSE);
    if(rsi_handle == INVALID_HANDLE) {
        Print("Lỗi khởi tạo iRSI: ", GetLastError());
        return(INIT_FAILED);
    }
    
    // Thêm Indicator RSI vào Subwindow trên biểu đồ để dễ quan sát bằng mắt
    int sub_window = (int)ChartGetInteger(0, CHART_WINDOWS_TOTAL); 
    if(!ChartIndicatorAdd(0, sub_window, rsi_handle)) {
        Print("Không thể thêm RSI vào biểu đồ: ", GetLastError());
    }
    
    // Thêm Smoothing MA / Bollinger Bands vào Subwindow RSI
    if (InpMAType != MA_NONE) {
        if (InpMAType == MA_BB) {
            smoothing_handle = iBands(_Symbol, _Period, InpMALength, 0, InpBBMul, rsi_handle);
        } else {
            ENUM_MA_METHOD method = MODE_SMA;
            if(InpMAType == MA_EMA) method = MODE_EMA;
            if(InpMAType == MA_SMMA) method = MODE_SMMA;
            if(InpMAType == MA_WMA) method = MODE_LWMA;
            smoothing_handle = iMA(_Symbol, _Period, InpMALength, 0, method, rsi_handle);
        }
        
        if (smoothing_handle != INVALID_HANDLE) {
            ChartIndicatorAdd(0, sub_window, smoothing_handle);
        } else {
            Print("Lỗi khởi tạo Smoothing MA: ", GetLastError());
        }
    }
    
    // Tính pip_value: 5 digit (0.00001) => pip = 0.0001 | 3 digit (0.001) => pip = 0.01
    int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
    if(digits == 5 || digits == 3)
        pip_value = SymbolInfoDouble(_Symbol, SYMBOL_POINT) * 10;
    else
        pip_value = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
    
    
    // Thiết lập CTrade
    trade.SetExpertMagicNumber(InpMagicNum);
    trade.SetDeviationInPoints(10);
    trade.SetTypeFilling(ORDER_FILLING_FOK);
    
    is_history_drawn = false;
    last_time = 0;

    if(false && InpEntryBars < InpLookbackRight) {
        Print("!! Warning: InpEntryBars (", InpEntryBars,
              ") < InpLookbackRight (", InpLookbackRight,
              ") => visual zone van duoc ve dung theo signal candle,",
              " nhung pending entry co the het han truoc luc signal duoc xac nhan.");
    }
    
    Print("EA v2.0 Khởi tạo thành công! Mode: ", EnumToString(InpSignalMode), " | Exit: ", EnumToString(InpExitMode));
    return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    // Dọn dẹp sạch sẽ subwindow RSI khi tắt EA hoặc đổi Timeframe
    CleanupSubwindows();
    
    // Xóa các đường nối phân kỳ, trailing line, và entry zone
    ObjectsDeleteAll(0, "PriceDiv_");
    ObjectsDeleteAll(0, "RSIDiv_");
    ObjectsDeleteAll(0, "RSILbl_");
    ObjectsDeleteAll(0, "TrailLine_");
    ObjectsDeleteAll(0, "EntryZone_");
    ObjectsDeleteAll(0, "EntryZoneFill_");
    ObjectsDeleteAll(0, "EntryZoneBox_");
    
    if(smoothing_handle != INVALID_HANDLE) IndicatorRelease(smoothing_handle);
    IndicatorRelease(rsi_handle);
}

//+------------------------------------------------------------------+
//| Hàm phụ trợ dò Pivot Low (ArraySeries)
//+------------------------------------------------------------------+
bool IsPivotLow(int shift, const double &rsi[], int left, int right) {
    for(int j=1; j<=left; j++) {
        if(rsi[shift] > rsi[shift+j]) return false; // Nến cũ hơn
    }
    for(int j=1; j<=right; j++) {
        if(rsi[shift] >= rsi[shift-j]) return false; // Nến mới hơn
    }
    return true;
}

//+------------------------------------------------------------------+
//| Hàm phụ trợ dò Pivot High (ArraySeries)
//+------------------------------------------------------------------+
bool IsPivotHigh(int shift, const double &rsi[], int left, int right) {
    for(int j=1; j<=left; j++) {
        if(rsi[shift] < rsi[shift+j]) return false;
    }
    for(int j=1; j<=right; j++) {
        if(rsi[shift] <= rsi[shift-j]) return false;
    }
    return true;
}

int GetConfirmationShift(int pivot_shift)
{
    return MathMax(pivot_shift - InpLookbackRight, 1);
}

//+------------------------------------------------------------------+
//| Hàm vẽ đường phân kỳ Bullish trên chart                          |
//+------------------------------------------------------------------+
void DrawBullishDivergence(string suffix, datetime t1, datetime t2, datetime t_signal,
                           double price1, double price2,
                           double rsi1, double rsi2, double rsi_signal,
                           color clr, ENUM_LINE_STYLE style, int width)
{
    // Vẽ trên Main Chart (nối 2 đáy giá)
    string price_obj = "PriceDiv_" + suffix + "_" + TimeToString(t2);
    if(ObjectFind(0, price_obj) < 0) {
        ObjectCreate(0, price_obj, OBJ_TREND, 0, t1, price1, t2, price2);
        ObjectSetInteger(0, price_obj, OBJPROP_COLOR, clr);
        ObjectSetInteger(0, price_obj, OBJPROP_STYLE, style);
        ObjectSetInteger(0, price_obj, OBJPROP_WIDTH, width);
        ObjectSetInteger(0, price_obj, OBJPROP_RAY_RIGHT, false);
    }

    // Vẽ trên RSI Subwindow (nối 2 đáy RSI)
    int sub_window = ChartWindowFind(0, "RSI(" + IntegerToString(InpRSILength) + ")");
    if(sub_window >= 0) {
        string rsi_obj = "RSIDiv_" + suffix + "_" + TimeToString(t2);
        if(ObjectFind(0, rsi_obj) < 0) {
            ObjectCreate(0, rsi_obj, OBJ_TREND, sub_window, t1, rsi1, t2, rsi2);
            ObjectSetInteger(0, rsi_obj, OBJPROP_COLOR, clr);
            ObjectSetInteger(0, rsi_obj, OBJPROP_STYLE, style);
            ObjectSetInteger(0, rsi_obj, OBJPROP_WIDTH, width);
            ObjectSetInteger(0, rsi_obj, OBJPROP_RAY_RIGHT, false);

            // Nhãn text
            string label = (suffix == "Bull") ? "Bull" : "H.Bull";
            string rsi_lbl = "RSILbl_" + suffix + "_" + TimeToString(t_signal);
            ObjectCreate(0, rsi_lbl, OBJ_TEXT, sub_window, t_signal, rsi_signal - 1.5);
            ObjectSetString(0, rsi_lbl, OBJPROP_TEXT, label);
            ObjectSetString(0, rsi_lbl, OBJPROP_FONT, "Arial");
            ObjectSetInteger(0, rsi_lbl, OBJPROP_FONTSIZE, 9);
            ObjectSetInteger(0, rsi_lbl, OBJPROP_COLOR, clr);
            ObjectSetInteger(0, rsi_lbl, OBJPROP_ANCHOR, ANCHOR_TOP);
        }
    }
}

//+------------------------------------------------------------------+
//| Hàm vẽ đường phân kỳ Bearish trên chart                          |
//+------------------------------------------------------------------+
void DrawBearishDivergence(string suffix, datetime t1, datetime t2, datetime t_signal,
                            double price1, double price2,
                            double rsi1, double rsi2, double rsi_signal,
                            color clr, ENUM_LINE_STYLE style, int width)
{
    // Vẽ trên Main Chart (nối 2 đỉnh giá)
    string price_obj = "PriceDiv_" + suffix + "_" + TimeToString(t2);
    if(ObjectFind(0, price_obj) < 0) {
        ObjectCreate(0, price_obj, OBJ_TREND, 0, t1, price1, t2, price2);
        ObjectSetInteger(0, price_obj, OBJPROP_COLOR, clr);
        ObjectSetInteger(0, price_obj, OBJPROP_STYLE, style);
        ObjectSetInteger(0, price_obj, OBJPROP_WIDTH, width);
        ObjectSetInteger(0, price_obj, OBJPROP_RAY_RIGHT, false);
    }

    // Vẽ trên RSI Subwindow (nối 2 đỉnh RSI)
    int sub_window = ChartWindowFind(0, "RSI(" + IntegerToString(InpRSILength) + ")");
    if(sub_window >= 0) {
        string rsi_obj = "RSIDiv_" + suffix + "_" + TimeToString(t2);
        if(ObjectFind(0, rsi_obj) < 0) {
            ObjectCreate(0, rsi_obj, OBJ_TREND, sub_window, t1, rsi1, t2, rsi2);
            ObjectSetInteger(0, rsi_obj, OBJPROP_COLOR, clr);
            ObjectSetInteger(0, rsi_obj, OBJPROP_STYLE, style);
            ObjectSetInteger(0, rsi_obj, OBJPROP_WIDTH, width);
            ObjectSetInteger(0, rsi_obj, OBJPROP_RAY_RIGHT, false);

            // Nhãn text
            string label = (suffix == "Bear") ? "Bear" : "H.Bear";
            string rsi_lbl = "RSILbl_" + suffix + "_" + TimeToString(t_signal);
            ObjectCreate(0, rsi_lbl, OBJ_TEXT, sub_window, t_signal, rsi_signal + 1.5);
            ObjectSetString(0, rsi_lbl, OBJPROP_TEXT, label);
            ObjectSetString(0, rsi_lbl, OBJPROP_FONT, "Arial");
            ObjectSetInteger(0, rsi_lbl, OBJPROP_FONTSIZE, 9);
            ObjectSetInteger(0, rsi_lbl, OBJPROP_COLOR, clr);
            ObjectSetInteger(0, rsi_lbl, OBJPROP_ANCHOR, ANCHOR_BOTTOM);
        }
    }
}

//+------------------------------------------------------------------+
//| Hàm kiểm tra Phân Kỳ RSI                                         |
//| Trả về: 1=Bull, 2=H.Bull, -1=Bear, -2=H.Bear, 0=Không có        |
//+------------------------------------------------------------------+
int GetRSIDivergenceSignal(int check_shift)
{
    int total_copy = check_shift + InpRangeUpper + InpLookbackLeft + 5;
    double rsi[];
    ArraySetAsSeries(rsi, true);
    if(CopyBuffer(rsi_handle, 0, 0, total_copy, rsi) <= 0) return 0;

    double low[], high[];
    ArraySetAsSeries(low, true);
    ArraySetAsSeries(high, true);
    if(CopyLow(_Symbol, _Period, 0, total_copy, low) <= 0) return 0;
    if(CopyHigh(_Symbol, _Period, 0, total_copy, high) <= 0) return 0;

    int max_search = total_copy - InpLookbackLeft - 1;

    //=================================================================
    // PHA 1+2 BULLISH: Xác định cấu trúc đáy RSI, rồi kiểm tra phân kỳ
    //=================================================================
    if(IsPivotLow(check_shift, rsi, InpLookbackLeft, InpLookbackRight)) {
        // Pha 1: Tìm đáy RSI gần nhất trước đó (KHÔNG nhảy cóc)
        int prev_pivot = -1;
        for(int k = check_shift + 1; k <= max_search; k++) {
            if(IsPivotLow(k, rsi, InpLookbackLeft, InpLookbackRight)) {
                prev_pivot = k;
                break;
            }
        }

        // Pha 2: Kiểm tra phân kỳ giữa 2 đáy liền kề
        if(prev_pivot != -1) {
            int distance = prev_pivot - check_shift;
            if(distance >= InpRangeLower && distance <= InpRangeUpper + 1) {
                datetime t1 = iTime(_Symbol, _Period, prev_pivot);
                datetime t2 = iTime(_Symbol, _Period, check_shift);
                int confirm_shift = GetConfirmationShift(check_shift);
                datetime t_signal = iTime(_Symbol, _Period, confirm_shift);
                double rsi_signal = rsi[confirm_shift];

                // Regular Bullish: Giá đáy thấp hơn + RSI đáy cao hơn
                if(low[check_shift] < low[prev_pivot] && rsi[check_shift] > rsi[prev_pivot]) {
                    DrawBullishDivergence("Bull", t1, t2, t_signal,
                        low[prev_pivot], low[check_shift],
                        rsi[prev_pivot], rsi[check_shift], rsi_signal,
                        clrLime, STYLE_SOLID, 2);
                    return 1;
                }
                // Hidden Bullish: Giá đáy cao hơn + RSI đáy thấp hơn
                if(low[check_shift] > low[prev_pivot] && rsi[check_shift] < rsi[prev_pivot]) {
                    DrawBullishDivergence("HBull", t1, t2, t_signal,
                        low[prev_pivot], low[check_shift],
                        rsi[prev_pivot], rsi[check_shift], rsi_signal,
                        clrDarkGreen, STYLE_DOT, 1);
                    return 2;
                }
            }
        }
    }

    //=================================================================
    // PHA 1+2 BEARISH: Xác định cấu trúc đỉnh RSI, rồi kiểm tra phân kỳ
    //=================================================================
    if(IsPivotHigh(check_shift, rsi, InpLookbackLeft, InpLookbackRight)) {
        // Pha 1: Tìm đỉnh RSI gần nhất trước đó (KHÔNG nhảy cóc)
        int prev_pivot = -1;
        for(int k = check_shift + 1; k <= max_search; k++) {
            if(IsPivotHigh(k, rsi, InpLookbackLeft, InpLookbackRight)) {
                prev_pivot = k;
                break;
            }
        }

        // Pha 2: Kiểm tra phân kỳ giữa 2 đỉnh liền kề
        if(prev_pivot != -1) {
            int distance = prev_pivot - check_shift;
            if(distance >= InpRangeLower && distance <= InpRangeUpper + 1) {
                datetime t1 = iTime(_Symbol, _Period, prev_pivot);
                datetime t2 = iTime(_Symbol, _Period, check_shift);
                int confirm_shift = GetConfirmationShift(check_shift);
                datetime t_signal = iTime(_Symbol, _Period, confirm_shift);
                double rsi_signal = rsi[confirm_shift];

                // Regular Bearish: Giá đỉnh cao hơn + RSI đỉnh thấp hơn
                if(high[check_shift] > high[prev_pivot] && rsi[check_shift] < rsi[prev_pivot]) {
                    DrawBearishDivergence("Bear", t1, t2, t_signal,
                        high[prev_pivot], high[check_shift],
                        rsi[prev_pivot], rsi[check_shift], rsi_signal,
                        clrRed, STYLE_SOLID, 2);
                    return -1;
                }
                // Hidden Bearish: Giá đỉnh thấp hơn + RSI đỉnh cao hơn
                if(high[check_shift] < high[prev_pivot] && rsi[check_shift] > rsi[prev_pivot]) {
                    DrawBearishDivergence("HBear", t1, t2, t_signal,
                        high[prev_pivot], high[check_shift],
                        rsi[prev_pivot], rsi[check_shift], rsi_signal,
                        clrMaroon, STYLE_DOT, 1);
                    return -2;
                }
            }
        }
    }

    return 0;
}

//+------------------------------------------------------------------+
//| Kiểm tra xem đã có position của EA trên symbol này chưa           |
//+------------------------------------------------------------------+
bool HasOpenPosition()
{
    for(int i = PositionsTotal() - 1; i >= 0; i--) {
        ulong ticket = PositionGetTicket(i);
        if(ticket > 0) {
            if(PositionGetString(POSITION_SYMBOL) == _Symbol &&
               PositionGetInteger(POSITION_MAGIC) == InpMagicNum) {
                return true;
            }
        }
    }
    return false;
}

//+------------------------------------------------------------------+
//| Thực hiện lệnh BUY                                                |
//+------------------------------------------------------------------+
bool ExecuteBuy(string comment)
{
    // Single mode: chỉ cho phép 1 lệnh
    if(InpOrderMode == ORDER_SINGLE && HasOpenPosition()) return false;
    
    double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
    int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
    double sl = 0, tp = 0;
    
    if(InpExitMode == EXIT_FIXED_SLTP) {
        sl = NormalizeDouble(ask - InpFixedSL * pip_value, digits);
        tp = NormalizeDouble(ask + InpFixedTP * pip_value, digits);
    } else {
        // Trailing mode: SL ban đầu theo InpInitialSL, TP = 0
        sl = NormalizeDouble(ask - InpInitialSL * pip_value, digits);
        tp = 0;
    }
    
    // Kiểm tra Stops Level
    double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
    int stops_level = (int)SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL);
    double min_distance = stops_level * point;
    if(ask - sl < min_distance) {
        sl = NormalizeDouble(ask - min_distance - point, digits);
    }
    if(tp > 0 && tp - ask < min_distance) {
        tp = NormalizeDouble(ask + min_distance + point, digits);
    }
    
    if(trade.Buy(InpLotSize, _Symbol, ask, sl, tp, comment)) {
        Print("+++ BUY ", InpLotSize, " lots @ ", ask, " SL=", sl, " TP=", tp, " [", comment, "]");
        // Vẽ trailing start line nếu được bật
        if(InpExitMode == EXIT_TRAILING_STOP && InpShowTrailLine) {
            double trail_price = NormalizeDouble(ask + InpTrailStart * pip_value, digits);
            string line_name = "TrailLine_" + IntegerToString(trade.ResultOrder());
            ObjectCreate(0, line_name, OBJ_HLINE, 0, 0, trail_price);
            ObjectSetInteger(0, line_name, OBJPROP_COLOR, clrDodgerBlue);
            ObjectSetInteger(0, line_name, OBJPROP_STYLE, STYLE_DOT);
            ObjectSetInteger(0, line_name, OBJPROP_WIDTH, 1);
        }
        return true;
    } else {
        Print("!!! BUY FAILED: retcode=", trade.ResultRetcode(), " ", trade.ResultRetcodeDescription());
        return false;
    }
}

//+------------------------------------------------------------------+
//| Thực hiện lệnh SELL                                               |
//+------------------------------------------------------------------+
bool ExecuteSell(string comment)
{
    if(InpOrderMode == ORDER_SINGLE && HasOpenPosition()) return false;
    
    double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
    int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
    double sl = 0, tp = 0;
    
    if(InpExitMode == EXIT_FIXED_SLTP) {
        sl = NormalizeDouble(bid + InpFixedSL * pip_value, digits);
        tp = NormalizeDouble(bid - InpFixedTP * pip_value, digits);
    } else {
        sl = NormalizeDouble(bid + InpInitialSL * pip_value, digits);
        tp = 0;
    }
    
    double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
    int stops_level = (int)SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL);
    double min_distance = stops_level * point;
    if(sl - bid < min_distance) {
        sl = NormalizeDouble(bid + min_distance + point, digits);
    }
    if(tp > 0 && bid - tp < min_distance) {
        tp = NormalizeDouble(bid - min_distance - point, digits);
    }
    
    if(trade.Sell(InpLotSize, _Symbol, bid, sl, tp, comment)) {
        Print("--- SELL ", InpLotSize, " lots @ ", bid, " SL=", sl, " TP=", tp, " [", comment, "]");
        if(InpExitMode == EXIT_TRAILING_STOP && InpShowTrailLine) {
            double trail_price = NormalizeDouble(bid - InpTrailStart * pip_value, digits);
            string line_name = "TrailLine_" + IntegerToString(trade.ResultOrder());
            ObjectCreate(0, line_name, OBJ_HLINE, 0, 0, trail_price);
            ObjectSetInteger(0, line_name, OBJPROP_COLOR, clrOrangeRed);
            ObjectSetInteger(0, line_name, OBJPROP_STYLE, STYLE_DOT);
            ObjectSetInteger(0, line_name, OBJPROP_WIDTH, 1);
        }
        return true;
    } else {
        Print("!!! SELL FAILED: retcode=", trade.ResultRetcode(), " ", trade.ResultRetcodeDescription());
        return false;
    }
}

//+------------------------------------------------------------------+
//| Quản lý Trailing Stop theo bước (Step-Based)                      |
//| Logic: Khi lãi đạt TrailStart pips -> đặt SL tại entry ± FirstSL |
//|        Mỗi thêm TrailStep pips lãi  -> dời SL thêm TrailStep pips |
//+------------------------------------------------------------------+
void ManageTrailingStop()
{
    if(InpExitMode != EXIT_TRAILING_STOP || !InpUseTrailing) return;
    
    int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
    
    for(int i = PositionsTotal() - 1; i >= 0; i--) {
        ulong ticket = PositionGetTicket(i);
        if(ticket == 0) continue;
        if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
        if(PositionGetInteger(POSITION_MAGIC) != InpMagicNum) continue;
        
        double open_price = PositionGetDouble(POSITION_PRICE_OPEN);
        double current_sl = PositionGetDouble(POSITION_SL);
        double current_tp = PositionGetDouble(POSITION_TP);
        long pos_type = PositionGetInteger(POSITION_TYPE);
        
        if(pos_type == POSITION_TYPE_BUY) {
            double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
            double profit_pips = (bid - open_price) / pip_value;
            
            if(profit_pips >= InpTrailStart) {
                // Tính SL mục tiêu dựa trên số bước đã đạt được
                // Bước 0: lãi = TrailStart -> SL = entry + FirstSL
                // Bước 1: lãi = TrailStart + TrailStep -> SL = entry + FirstSL + TrailStep
                // Bước n: SL = entry + FirstSL + n * TrailStep
                double extra_pips = profit_pips - InpTrailStart;
                int steps = (int)MathFloor(extra_pips / InpTrailStep);
                double target_sl_pips = InpTrailFirstSL + steps * InpTrailStep;
                double new_sl = NormalizeDouble(open_price + target_sl_pips * pip_value, digits);
                
                if(new_sl > current_sl + pip_value * 0.1) {
                    if(trade.PositionModify(ticket, new_sl, current_tp)) {
                        Print(">> Trail BUY #", ticket, " SL -> ", new_sl, " (step ", steps, ")");
                    }
                }
                
                // Xóa trailing line khi đã kích hoạt
                string line_name = "TrailLine_" + IntegerToString(ticket);
                if(ObjectFind(0, line_name) >= 0) ObjectDelete(0, line_name);
            }
        }
        else if(pos_type == POSITION_TYPE_SELL) {
            double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
            double profit_pips = (open_price - ask) / pip_value;
            
            if(profit_pips >= InpTrailStart) {
                double extra_pips = profit_pips - InpTrailStart;
                int steps = (int)MathFloor(extra_pips / InpTrailStep);
                double target_sl_pips = InpTrailFirstSL + steps * InpTrailStep;
                double new_sl = NormalizeDouble(open_price - target_sl_pips * pip_value, digits);
                
                if(new_sl < current_sl - pip_value * 0.1 || current_sl == 0) {
                    if(trade.PositionModify(ticket, new_sl, current_tp)) {
                        Print(">> Trail SELL #", ticket, " SL -> ", new_sl, " (step ", steps, ")");
                    }
                }
                
                string line_name = "TrailLine_" + IntegerToString(ticket);
                if(ObjectFind(0, line_name) >= 0) ObjectDelete(0, line_name);
            }
        }
    }
}

//+------------------------------------------------------------------+
//| Kiểm tra tín hiệu có phù hợp với Signal Mode hay không            |
//+------------------------------------------------------------------+
bool IsSignalAllowed(int signal)
{
    // signal: 1=Bull, 2=H.Bull, -1=Bear, -2=H.Bear
    bool is_regular = (signal == 1 || signal == -1);
    bool is_hidden  = (signal == 2 || signal == -2);
    
    switch(InpSignalMode) {
        case MODE_REGULAR_ONLY: return is_regular;
        case MODE_HIDDEN_ONLY:  return is_hidden;
        case MODE_BOTH:         return (is_regular || is_hidden);
    }
    return false;
}

//+------------------------------------------------------------------+
//| Vẽ Entry Zone (hình chữ nhật) trên chart                        |
//| Zone bắt đầu từ Signal Candle, kéo dài InpEntryBars nến           |
//+------------------------------------------------------------------+
void DrawEntryZone(datetime t_signal, datetime t_expire, double zone_high, double zone_low, int signal_type)
{
    string fill_name = "EntryZoneFill_" + TimeToString(t_signal);
    string box_name  = "EntryZoneBox_"  + TimeToString(t_signal);
    color zone_clr = (signal_type > 0) ? clrLime : clrRed;

    if(ObjectFind(0, fill_name) < 0) {
        ObjectCreate(0, fill_name, OBJ_RECTANGLE, 0, t_signal, zone_high, t_expire, zone_low);
    }
    ObjectMove(0, fill_name, 0, t_signal, zone_high);
    ObjectMove(0, fill_name, 1, t_expire, zone_low);
    ObjectSetInteger(0, fill_name, OBJPROP_COLOR, ColorToARGB(zone_clr, 55));
    ObjectSetInteger(0, fill_name, OBJPROP_STYLE, STYLE_SOLID);
    ObjectSetInteger(0, fill_name, OBJPROP_WIDTH, 1);
    ObjectSetInteger(0, fill_name, OBJPROP_FILL, true);
    ObjectSetInteger(0, fill_name, OBJPROP_BACK, true);
    ObjectSetInteger(0, fill_name, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, fill_name, OBJPROP_SELECTED, false);
    ObjectSetInteger(0, fill_name, OBJPROP_HIDDEN, false);

    if(ObjectFind(0, box_name) < 0) {
        ObjectCreate(0, box_name, OBJ_RECTANGLE, 0, t_signal, zone_high, t_expire, zone_low);
    }
    ObjectMove(0, box_name, 0, t_signal, zone_high);
    ObjectMove(0, box_name, 1, t_expire, zone_low);
    ObjectSetInteger(0, box_name, OBJPROP_COLOR, zone_clr);
    ObjectSetInteger(0, box_name, OBJPROP_STYLE, STYLE_SOLID);
    ObjectSetInteger(0, box_name, OBJPROP_WIDTH, 2);
    ObjectSetInteger(0, box_name, OBJPROP_FILL, false);
    ObjectSetInteger(0, box_name, OBJPROP_BACK, false);
    ObjectSetInteger(0, box_name, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, box_name, OBJPROP_SELECTED, false);
    ObjectSetInteger(0, box_name, OBJPROP_HIDDEN, false);
}

//+------------------------------------------------------------------+
//| Tinh moc het han zone dung theo so bar, tranh lech do +seconds   |
//| Zone bao gom Signal Candle + InpEntryBars bar tiep theo          |
//+------------------------------------------------------------------+
datetime GetEntryZoneExpireTime(int signal_shift)
{
    int bars_to_cover = InpEntryBars + 1;
    int expire_shift = signal_shift - bars_to_cover;

    if(expire_shift >= 0) {
        return iTime(_Symbol, _Period, expire_shift);
    }

    datetime current_bar_time = iTime(_Symbol, _Period, 0);
    return current_bar_time + (datetime)(PeriodSeconds(_Period) * (-expire_shift));
}

//+------------------------------------------------------------------+
//| Thêm pending entry vào danh sách                                   |
//+------------------------------------------------------------------+
void BuildSignalZone(int signal_shift, double &zone_high, double &zone_low,
                     datetime &signal_time, datetime &expire_time)
{
    double sc_high = iHigh(_Symbol, _Period, signal_shift);
    double sc_low  = iLow(_Symbol, _Period, signal_shift);
    double buffer = MathMax(InpZoneBuffer, 0.0) * pip_value;

    zone_high = sc_high + buffer;
    zone_low  = sc_low - buffer;
    signal_time = iTime(_Symbol, _Period, signal_shift);
    expire_time = GetEntryZoneExpireTime(signal_shift);
}

int GetZoneLocation(double price, double zone_low, double zone_high)
{
    if(price < zone_low)  return -1;
    if(price > zone_high) return 1;
    return 0;
}

void AddPendingEntry(int signal, string sig_name, double zone_high, double zone_low,
                     datetime sig_time, datetime exp_time,
                     bool outside_seen, bool retest_ready)
{
    int size = ArraySize(pending_list);
    if(size >= MAX_PENDING) {
        Print("!! Pending list full (", MAX_PENDING, "), skip signal ", sig_name);
        return;
    }
    ArrayResize(pending_list, size + 1);
    pending_list[size].signal = signal;
    pending_list[size].sig_name = sig_name;
    pending_list[size].zone_high = zone_high;
    pending_list[size].zone_low = zone_low;
    pending_list[size].signal_time = sig_time;
    pending_list[size].expire_time = exp_time;
    pending_list[size].outside_seen = outside_seen;
    pending_list[size].retest_ready = retest_ready;
}

//+------------------------------------------------------------------+
//| Xóa pending entry khỏi danh sách theo index                       |
//+------------------------------------------------------------------+
void RemovePendingEntry(int index, bool remove_zone)
{
    if(remove_zone) {
        string legacy_name = "EntryZone_" + TimeToString(pending_list[index].signal_time);
        string fill_name   = "EntryZoneFill_" + TimeToString(pending_list[index].signal_time);
        string box_name    = "EntryZoneBox_" + TimeToString(pending_list[index].signal_time);
        if(ObjectFind(0, legacy_name) >= 0) ObjectDelete(0, legacy_name);
        if(ObjectFind(0, fill_name) >= 0) ObjectDelete(0, fill_name);
        if(ObjectFind(0, box_name) >= 0) ObjectDelete(0, box_name);
    }
    int size = ArraySize(pending_list);
    // Dịch mảng lên
    for(int j = index; j < size - 1; j++) {
        pending_list[j] = pending_list[j + 1];
    }
    ArrayResize(pending_list, size - 1);
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//| Signal Candle = nến mang flag Bull/Bear/H.Bull/H.Bear            |
//| Entry Zone = High/Low của Signal Candle                          |
//|   Zone hình thành từ Signal Candle, tồn tại InpEntryBars nến     |
//|   Vào lệnh khi giá nằm trong zone và zone chưa hết hạn           |
//+------------------------------------------------------------------+
void OnTick()
{
    // Vẽ lại lịch sử phân kỳ 1 lần duy nhất khi EA vừa nạp
    if(!is_history_drawn) {
        int limit = iBars(_Symbol, _Period) - 2;
        if(limit > 1000) limit = 1000;
        for(int i = limit; i >= InpLookbackRight + 1; i--) {
            int history_signal = GetRSIDivergenceSignal(i);
            if(InpDrawHistoryZones && history_signal != 0) {
                double zh = 0, zl = 0;
                datetime sc_time = 0, expire = 0;
                int history_signal_shift = GetConfirmationShift(i);
                BuildSignalZone(history_signal_shift, zh, zl, sc_time, expire);
                DrawEntryZone(sc_time, expire, zh, zl, history_signal);
            }
        }
        is_history_drawn = true;
        ChartRedraw();
    }

    // Quản lý Trailing Stop mỗi tick (độc lập cho từng lệnh)
    ManageTrailingStop();

    //=================================================================
    // Mỗi TICK: kiểm tra tất cả pending entry còn hiệu lực
    //=================================================================
    double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
    double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
    datetime now = TimeCurrent();
    
    for(int p = ArraySize(pending_list) - 1; p >= 0; p--) {
        // Xóa zone hết hạn
        if(now >= pending_list[p].expire_time) {
            Print(">> Entry Zone EXPIRED for ", pending_list[p].sig_name,
                  " at ", TimeToString(pending_list[p].signal_time));
            RemovePendingEntry(p, true);
            continue;
        }
        
        // Single mode: dừng nếu đã có lệnh
        if(InpOrderMode == ORDER_SINGLE && HasOpenPosition()) break;
        
        // Kiểm tra giá có trong zone không
        double check_price = (pending_list[p].signal > 0) ? ask : bid;
        int zone_location = GetZoneLocation(check_price, pending_list[p].zone_low, pending_list[p].zone_high);
        bool in_zone = (zone_location == 0);
        bool should_enter = false;

        if(InpEntryMethod == ENTRY_RETEST_OUTSIDE) {
            if(zone_location != 0) {
                pending_list[p].outside_seen = true;
            } else if(pending_list[p].outside_seen) {
                pending_list[p].retest_ready = true;
            }
            should_enter = (in_zone && pending_list[p].retest_ready);
        } else {
            should_enter = in_zone;
        }
        
        if(should_enter) {
            bool executed = false;
            Print(">> Entry Zone HIT! [", pending_list[p].zone_low, " - ", pending_list[p].zone_high,
                  "] | ", pending_list[p].sig_name,
                  " | Ask=", ask, " Bid=", bid);
            if(pending_list[p].signal > 0) {
                executed = ExecuteBuy(pending_list[p].sig_name);
            } else {
                executed = ExecuteSell(pending_list[p].sig_name);
            }

            if(executed) {
                RemovePendingEntry(p, true);
            } else {
                Print(">> Entry Zone retained after execution failure for ", pending_list[p].sig_name);
            }
        }
    }

    //=================================================================
    // Mỗi NếN MỚI: detect signal và tạo pending entry
    //=================================================================
    datetime current_time = iTime(_Symbol, _Period, 0);
    if(current_time == last_time) return;

    // Pivot duoc xac nhan tren bar da dong de tranh repaint.
    // Signal Candle cho entry/zone la confirmation bar gan nhat (thuong la shift = 1).
    int pivot_shift = MathMax(InpLookbackRight + 1, 1);
    int signal_candle_shift = GetConfirmationShift(pivot_shift);
    int signal = GetRSIDivergenceSignal(pivot_shift);
    
    // Điều kiện tạo pending mới
    if(signal != 0) {
        double sc_high = iHigh(_Symbol, _Period, signal_candle_shift);
        double sc_low  = iLow(_Symbol, _Period, signal_candle_shift);
        datetime sc_time = iTime(_Symbol, _Period, signal_candle_shift);
        
        // Zone ket thuc tai open time ngay sau bar thu InpEntryBars ke tu Signal Candle.
        datetime expire = GetEntryZoneExpireTime(signal_candle_shift);
        
        // Nếu zone đã hết hạn tại thời điểm detect -> bỏ qua
        bool signal_allowed = IsSignalAllowed(signal);
        bool has_open_position = HasOpenPosition();
        bool has_pending_zone = (ArraySize(pending_list) > 0);
        bool zone_expired = (TimeCurrent() >= expire);
        
        string sig_name = "";
        switch(signal) {
            case  1: sig_name = "Regular Bullish";  break;
            case  2: sig_name = "Hidden Bullish";   break;
            case -1: sig_name = "Regular Bearish";  break;
            case -2: sig_name = "Hidden Bearish";   break;
        }
        
        double buffer = MathMax(InpZoneBuffer, 0.0) * pip_value;
        double zh = sc_high + buffer;
        double zl = sc_low - buffer;

        DrawEntryZone(sc_time, expire, zh, zl, signal);
        ChartRedraw();

        bool can_create = signal_allowed && !zone_expired;
        string block_reason = "";
        if(!signal_allowed) {
            block_reason = "filtered by InpSignalMode";
        } else if(zone_expired) {
            block_reason = "zone expired for live entry"
                           " (increase InpEntryBars if you want a wider entry window)";
        } else if(InpOrderMode == ORDER_SINGLE && has_open_position) {
            can_create = false;
            block_reason = "existing open position";
        } else if(InpOrderMode == ORDER_SINGLE && has_pending_zone) {
            can_create = false;
            block_reason = "existing pending zone";
        }

        Print(">> Visual Zone DRAWN | SC=", TimeToString(sc_time),
              " | ", sig_name,
              " | Zone: [", zl, " - ", zh, "]",
              " | EntryBars=", InpEntryBars,
              " | Active=", can_create ? "YES" : "NO");

        if(!can_create) {
            Print(">> Pending Zone NOT activated | ", sig_name,
                  " | Reason: ", block_reason);
            last_time = current_time;
            return;
        }

        double current_price = (signal > 0) ? ask : bid;
        int current_location = GetZoneLocation(current_price, zl, zh);
        bool current_in_zone = (current_location == 0);
        bool outside_seen = (current_location != 0);

        if(InpEntryMethod == ENTRY_IN_ZONE && current_in_zone) {
            bool executed_now = false;
            if(signal > 0) {
                executed_now = ExecuteBuy(sig_name);
            } else {
                executed_now = ExecuteSell(sig_name);
            }

            if(executed_now) {
                Print(">> Entry Zone HIT immediately at signal detection | ",
                      sig_name, " | Zone: [", zl, " - ", zh, "]");
                last_time = current_time;
                return;
            }

            Print(">> Immediate entry failed, keep zone active | ", sig_name);
        }

        AddPendingEntry(signal, sig_name, zh, zl, sc_time, expire, outside_seen, false);
        
        Print(">> Pending Zone ACTIVATED | SC=", TimeToString(sc_time),
              " | ", sig_name,
              " | Zone: [", zl, " - ", zh, "]",
              " | Expires: ", TimeToString(expire),
              " | Mode: ", EnumToString(InpOrderMode));
    }
    
    last_time = current_time;
}
//+------------------------------------------------------------------+
