//+------------------------------------------------------------------+
//| Research-only exporter: monthly XAU price/activity structure      |
//| It does not place or modify orders.                               |
//+------------------------------------------------------------------+
#property copyright "IndiSingle research"
#property version   "1.00"
#property strict

input string InpOutputFile   = "XAUUSDm-H1-monthly-structure.csv";
input int    InpFromYearMonth= 202301;
input int    InpToYearMonth  = 202609;

int      g_file=INVALID_HANDLE;
datetime g_lastOpenBar=0;
datetime g_lastProcessedBar=0;

struct MonthStats
  {
   int      yearMonth;
   datetime firstTime;
   datetime lastTime;
   long     bars;
   double   open;
   double   high;
   double   low;
   double   close;
   double   previousClose;
   double   sumLogReturnSq;
   double   sumTrueRange;
   double   sumAbsCloseChange;
   double   sumBodyRangeRatio;
   double   sumUpperWickRatio;
   double   sumLowerWickRatio;
   long     upBars;
   long     tickVolume;
   double   bucketVolume0;
   double   bucketVolume1;
   double   bucketVolume2;
   double   bucketVolume3;
   double   bucketReturn0;
   double   bucketReturn1;
   double   bucketReturn2;
   double   bucketReturn3;
   double   sumX;
   double   sumY;
   double   sumXX;
   double   sumYY;
   double   sumXY;
   double   highWater;
   double   lowWater;
   double   maxDrawdownPct;
   double   maxRunupPct;
  };

MonthStats g_month;
bool       g_hasMonth=false;

int YearMonth(const datetime value)
  {
   MqlDateTime parts;
   TimeToStruct(value,parts);
   return parts.year*100+parts.mon;
  }

string MonthLabel(const int yearMonth)
  {
   return StringFormat("%04d-%02d",yearMonth/100,yearMonth%100);
  }

int HourBucket(const datetime value)
  {
   MqlDateTime parts;
   TimeToStruct(value,parts);
   if(parts.hour<6)  return 0;
   if(parts.hour<12) return 1;
   if(parts.hour<18) return 2;
   return 3;
  }

void ResetMonth(const MqlRates &bar,const double priorClose)
  {
   ZeroMemory(g_month);
   g_month.yearMonth=YearMonth(bar.time);
   g_month.firstTime=bar.time;
   g_month.lastTime=bar.time;
   g_month.open=bar.open;
   g_month.high=bar.high;
   g_month.low=bar.low;
   g_month.close=bar.close;
   g_month.previousClose=priorClose;
   g_month.highWater=bar.open;
   g_month.lowWater=bar.open;
   g_hasMonth=true;
  }

void AddBucket(const int bucket,const double volume,const double logReturn)
  {
   if(bucket==0)
     {
      g_month.bucketVolume0+=volume;
      g_month.bucketReturn0+=logReturn;
     }
   else if(bucket==1)
     {
      g_month.bucketVolume1+=volume;
      g_month.bucketReturn1+=logReturn;
     }
   else if(bucket==2)
     {
      g_month.bucketVolume2+=volume;
      g_month.bucketReturn2+=logReturn;
     }
   else
     {
      g_month.bucketVolume3+=volume;
      g_month.bucketReturn3+=logReturn;
     }
  }

void WriteMonth()
  {
   if(!g_hasMonth || g_month.bars<=0 || g_file==INVALID_HANDLE)
      return;

   const double priceReturnPct=(g_month.close/g_month.open-1.0)*100.0;
   const double rangePct=(g_month.high-g_month.low)/g_month.open*100.0;
   const double realizedVolPct=MathSqrt(g_month.sumLogReturnSq)*100.0;
   const double averageTR=g_month.sumTrueRange/(double)g_month.bars;
   const double atrProxyPct=averageTR/g_month.close*100.0;
   const double pathEfficiency=(g_month.sumAbsCloseChange>0.0 ? MathAbs(g_month.close-g_month.open)/g_month.sumAbsCloseChange : 0.0);
   const double upBarPct=(double)g_month.upBars/(double)g_month.bars*100.0;
   const double averageTickVolume=(double)g_month.tickVolume/(double)g_month.bars;
   const double denominator=(double)g_month.bars*g_month.sumXX-g_month.sumX*g_month.sumX;
   double slope=0.0;
   double rSquared=0.0;
   if(MathAbs(denominator)>1e-12)
     {
      slope=((double)g_month.bars*g_month.sumXY-g_month.sumX*g_month.sumY)/denominator;
      const double yDenominator=(double)g_month.bars*g_month.sumYY-g_month.sumY*g_month.sumY;
      if(yDenominator>1e-12)
        {
         const double numerator=(double)g_month.bars*g_month.sumXY-g_month.sumX*g_month.sumY;
         rSquared=(numerator*numerator)/(denominator*yDenominator);
        }
     }
   const double slopeATR=(averageTR>0.0 ? slope/averageTR : 0.0);
   const double totalVolume=(double)g_month.tickVolume;

   FileWrite(g_file,
             MonthLabel(g_month.yearMonth),
             TimeToString(g_month.firstTime,TIME_DATE|TIME_MINUTES),
             TimeToString(g_month.lastTime,TIME_DATE|TIME_MINUTES),
             g_month.bars,
             DoubleToString(g_month.open,_Digits),
             DoubleToString(g_month.high,_Digits),
             DoubleToString(g_month.low,_Digits),
             DoubleToString(g_month.close,_Digits),
             DoubleToString(priceReturnPct,6),
             DoubleToString(rangePct,6),
             DoubleToString(realizedVolPct,6),
             DoubleToString(atrProxyPct,6),
             DoubleToString(pathEfficiency,6),
             DoubleToString(slopeATR,6),
             DoubleToString(rSquared,6),
             DoubleToString(upBarPct,6),
             DoubleToString(g_month.sumBodyRangeRatio/(double)g_month.bars,6),
             DoubleToString(g_month.sumUpperWickRatio/(double)g_month.bars,6),
             DoubleToString(g_month.sumLowerWickRatio/(double)g_month.bars,6),
             g_month.tickVolume,
             DoubleToString(averageTickVolume,3),
             DoubleToString(totalVolume>0.0 ? g_month.bucketVolume0/totalVolume : 0.0,6),
             DoubleToString(totalVolume>0.0 ? g_month.bucketVolume1/totalVolume : 0.0,6),
             DoubleToString(totalVolume>0.0 ? g_month.bucketVolume2/totalVolume : 0.0,6),
             DoubleToString(totalVolume>0.0 ? g_month.bucketVolume3/totalVolume : 0.0,6),
             DoubleToString(g_month.bucketReturn0*100.0,6),
             DoubleToString(g_month.bucketReturn1*100.0,6),
             DoubleToString(g_month.bucketReturn2*100.0,6),
             DoubleToString(g_month.bucketReturn3*100.0,6),
             DoubleToString(g_month.maxDrawdownPct,6),
             DoubleToString(g_month.maxRunupPct,6));
   FileFlush(g_file);
  }

void AddBar(const MqlRates &bar,const double priorClose)
  {
   const int yearMonth=YearMonth(bar.time);
   if(yearMonth<InpFromYearMonth || yearMonth>InpToYearMonth)
      return;

   if(!g_hasMonth || g_month.yearMonth!=yearMonth)
     {
      if(g_hasMonth)
         WriteMonth();
      ResetMonth(bar,priorClose);
     }

   const double safePrior=(priorClose>0.0 ? priorClose : bar.open);
   const double logReturn=(safePrior>0.0 && bar.close>0.0 ? MathLog(bar.close/safePrior) : 0.0);
   const double trueRange=MathMax(bar.high-bar.low,MathMax(MathAbs(bar.high-safePrior),MathAbs(bar.low-safePrior)));
   const double candleRange=bar.high-bar.low;
   const double body=MathAbs(bar.close-bar.open);
   const double upperWick=bar.high-MathMax(bar.open,bar.close);
   const double lowerWick=MathMin(bar.open,bar.close)-bar.low;
   const double x=(double)g_month.bars;

   g_month.lastTime=bar.time;
   g_month.high=MathMax(g_month.high,bar.high);
   g_month.low=MathMin(g_month.low,bar.low);
   g_month.close=bar.close;
   g_month.sumLogReturnSq+=logReturn*logReturn;
   g_month.sumTrueRange+=trueRange;
   g_month.sumAbsCloseChange+=MathAbs(bar.close-safePrior);
   if(candleRange>0.0)
     {
      g_month.sumBodyRangeRatio+=body/candleRange;
      g_month.sumUpperWickRatio+=upperWick/candleRange;
      g_month.sumLowerWickRatio+=lowerWick/candleRange;
     }
   if(bar.close>bar.open)
      g_month.upBars++;
   g_month.tickVolume+=bar.tick_volume;
   AddBucket(HourBucket(bar.time),(double)bar.tick_volume,logReturn);
   g_month.sumX+=x;
   g_month.sumY+=bar.close;
   g_month.sumXX+=x*x;
   g_month.sumYY+=bar.close*bar.close;
   g_month.sumXY+=x*bar.close;

   g_month.highWater=MathMax(g_month.highWater,bar.high);
   if(g_month.highWater>0.0)
      g_month.maxDrawdownPct=MathMax(g_month.maxDrawdownPct,(g_month.highWater-bar.low)/g_month.highWater*100.0);
   g_month.lowWater=MathMin(g_month.lowWater,bar.low);
   if(g_month.lowWater>0.0)
      g_month.maxRunupPct=MathMax(g_month.maxRunupPct,(bar.high-g_month.lowWater)/g_month.lowWater*100.0);
   g_month.previousClose=bar.close;
   g_month.bars++;
  }

bool ProcessClosedBar(const int shift)
  {
   MqlRates rates[2];
   if(CopyRates(_Symbol,PERIOD_H1,shift,2,rates)!=2)
      return false;
   // CopyRates stores the oldest requested bar at index 0 for static arrays.
   const MqlRates bar=rates[1];
   if(bar.time==g_lastProcessedBar)
      return true;
   AddBar(bar,rates[0].close);
   g_lastProcessedBar=bar.time;
   return true;
  }

int OnInit()
  {
   if(_Period!=PERIOD_H1 || InpFromYearMonth>InpToYearMonth || StringLen(InpOutputFile)<1)
      return INIT_PARAMETERS_INCORRECT;
   g_file=FileOpen(InpOutputFile,FILE_WRITE|FILE_CSV|FILE_ANSI,';');
   if(g_file==INVALID_HANDLE)
     {
      PrintFormat("Cannot open %s, error=%d",InpOutputFile,GetLastError());
      return INIT_FAILED;
     }
   FileWrite(g_file,
             "month","first_bar_server","last_bar_server","bars","open","high","low","close",
             "return_pct","range_pct","realized_vol_pct","atr_proxy_pct","path_efficiency",
             "trend_slope_atr","trend_r2","up_bar_pct","mean_body_range","mean_upper_wick","mean_lower_wick",
             "tick_volume_total","tick_volume_avg","volume_share_00_05","volume_share_06_11",
             "volume_share_12_17","volume_share_18_23","return_00_05_pct","return_06_11_pct",
             "return_12_17_pct","return_18_23_pct","max_drawdown_pct","max_runup_pct");
   g_lastOpenBar=iTime(_Symbol,PERIOD_H1,0);
   ProcessClosedBar(1);
   return INIT_SUCCEEDED;
  }

void OnTick()
  {
   const datetime currentOpen=iTime(_Symbol,PERIOD_H1,0);
   if(currentOpen<=0 || currentOpen==g_lastOpenBar)
      return;
   g_lastOpenBar=currentOpen;
   ProcessClosedBar(1);
  }

void OnDeinit(const int reason)
  {
   ProcessClosedBar(1);
   WriteMonth();
   if(g_file!=INVALID_HANDLE)
      FileClose(g_file);
   g_file=INVALID_HANDLE;
  }

void OnTradeTransaction(const MqlTradeTransaction &trans,
                        const MqlTradeRequest &request,
                        const MqlTradeResult &result)
  {
   // Research exporter intentionally never trades.
  }
//+------------------------------------------------------------------+
