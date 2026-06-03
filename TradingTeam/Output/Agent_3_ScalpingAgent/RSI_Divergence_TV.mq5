//+------------------------------------------------------------------+
//|                                           RSI_Divergence_TV.mq5  |
//|                                          Copyright Trading Agent |
//+------------------------------------------------------------------+
#property copyright "Trading Agent"
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   3

//--- Cài đặt hiển thị RSI
#property indicator_label1  "RSI"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrMediumPurple
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2

//--- Cài đặt hiển thị Phân Kỳ Tăng
#property indicator_label2  "Bullish Div"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrLime
#property indicator_width2  2

//--- Cài đặt hiển thị Phân Kỳ Giảm
#property indicator_label3  "Bearish Div"
#property indicator_type3   DRAW_ARROW
#property indicator_color3  clrRed
#property indicator_width3  2

#property indicator_minimum 0
#property indicator_maximum 100
#property indicator_level1  30
#property indicator_level2  50
#property indicator_level3  70
#property indicator_levelcolor clrGray
#property indicator_levelstyle STYLE_DOT

//--- Inputs
input int InpRSILength    = 14;           // RSI Length
input int InpLookbackLeft = 5;            // Pivot Lookback Left
input int InpLookbackRight= 5;            // Pivot Lookback Right
input int InpRangeLower   = 5;            // Khoảng cách tối thiểu
input int InpRangeUpper   = 60;           // Khoảng cách tối đa

double RSIBuffer[];
double BullDivBuffer[];
double BearDivBuffer[];

int rsi_handle;

int OnInit()
{
    SetIndexBuffer(0, RSIBuffer, INDICATOR_DATA);
    SetIndexBuffer(1, BullDivBuffer, INDICATOR_DATA);
    SetIndexBuffer(2, BearDivBuffer, INDICATOR_DATA);
    
    PlotIndexSetInteger(1, PLOT_ARROW, 233);
    PlotIndexSetInteger(2, PLOT_ARROW, 234);

    PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, EMPTY_VALUE);
    PlotIndexSetDouble(2, PLOT_EMPTY_VALUE, EMPTY_VALUE);

    rsi_handle = iRSI(_Symbol, _Period, InpRSILength, PRICE_CLOSE);
    if(rsi_handle == INVALID_HANDLE) return(INIT_FAILED);

    return(INIT_SUCCEEDED);
}

bool IsPivotLow(int index, const double &rsi[], int left, int right) {
    for(int j=1; j<=left; j++) { if(rsi[index] > rsi[index-j]) return false; }
    for(int j=1; j<=right; j++) { if(rsi[index] >= rsi[index+j]) return false; }
    return true;
}

bool IsPivotHigh(int index, const double &rsi[], int left, int right) {
    for(int j=1; j<=left; j++) { if(rsi[index] < rsi[index-j]) return false; }
    for(int j=1; j<=right; j++) { if(rsi[index] <= rsi[index+j]) return false; }
    return true;
}

int OnCalculate(const int rates_total, const int prev_calculated,
                const datetime &time[], const double &open[], const double &high[],
                const double &low[], const double &close[],
                const long &tick_volume[], const long &volume[], const int &spread[])
{
    if(rates_total < InpRSILength + InpLookbackLeft + InpLookbackRight) return(0);

    int to_copy = rates_total - prev_calculated;
    if(prev_calculated > 0) to_copy++; 
    if(CopyBuffer(rsi_handle, 0, 0, rates_total, RSIBuffer) <= 0) return(0);

    int start = prev_calculated > 0 ? prev_calculated - 1 : InpLookbackLeft;
    int max_process = rates_total - InpLookbackRight - 1;

    if(prev_calculated == 0) {
        ArrayInitialize(BullDivBuffer, EMPTY_VALUE);
        ArrayInitialize(BearDivBuffer, EMPTY_VALUE);
    }

    for(int i = start; i <= max_process; i++)
    {
        BullDivBuffer[i] = EMPTY_VALUE;
        BearDivBuffer[i] = EMPTY_VALUE;

        if(IsPivotLow(i, RSIBuffer, InpLookbackLeft, InpLookbackRight)) 
        {
            int prev_pivot_idx = -1;
            int limit_back = MathMax(InpLookbackLeft, i - InpRangeUpper);
            int start_back = i - InpRangeLower;
            for(int k = start_back; k >= limit_back; k--) {
                if(IsPivotLow(k, RSIBuffer, InpLookbackLeft, InpLookbackRight)) {
                    prev_pivot_idx = k; break;
                }
            }
            if(prev_pivot_idx != -1) {
                if(RSIBuffer[i] > RSIBuffer[prev_pivot_idx] && low[i] < low[prev_pivot_idx]) {
                    BullDivBuffer[i] = RSIBuffer[i]; // Vẽ mũi tên
                }
            }
        }

        if(IsPivotHigh(i, RSIBuffer, InpLookbackLeft, InpLookbackRight)) 
        {
            int prev_pivot_idx = -1;
            int limit_back = MathMax(InpLookbackLeft, i - InpRangeUpper);
            int start_back = i - InpRangeLower;
            for(int k = start_back; k >= limit_back; k--) {
                if(IsPivotHigh(k, RSIBuffer, InpLookbackLeft, InpLookbackRight)) {
                    prev_pivot_idx = k; break;
                }
            }
            if(prev_pivot_idx != -1) {
                if(RSIBuffer[i] < RSIBuffer[prev_pivot_idx] && high[i] > high[prev_pivot_idx]) {
                    BearDivBuffer[i] = RSIBuffer[i]; // Vẽ mũi tên
                }
            }
        }
    }
    
    return(rates_total);
}
