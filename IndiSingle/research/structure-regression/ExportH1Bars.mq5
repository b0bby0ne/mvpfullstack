//+------------------------------------------------------------------+
//| Research-only H1 bar exporter. Never places or modifies orders.   |
//+------------------------------------------------------------------+
#property copyright "IndiSingle research"
#property version   "1.00"
#property strict

input string InpOutputFile    = "XAUUSDm-H1-bars.csv";
input int    InpFromYearMonth = 202301;
input int    InpToYearMonth   = 202609;

int      g_file=INVALID_HANDLE;
datetime g_lastOpenBar=0;
datetime g_lastProcessedBar=0;

int YearMonth(const datetime value)
  {
   MqlDateTime parts;
   TimeToStruct(value,parts);
   return parts.year*100+parts.mon;
  }

bool ProcessClosedBar(const int shift)
  {
   MqlRates rates[2];
   if(CopyRates(_Symbol,PERIOD_H1,shift,2,rates)!=2)
      return false;
   // Static arrays receive the oldest requested bar at index 0.
   const MqlRates bar=rates[1];
   if(bar.time==g_lastProcessedBar)
      return true;
   g_lastProcessedBar=bar.time;
   const int yearMonth=YearMonth(bar.time);
   if(yearMonth<InpFromYearMonth || yearMonth>InpToYearMonth)
      return true;
   FileWrite(g_file,
             TimeToString(bar.time,TIME_DATE|TIME_MINUTES),
             DoubleToString(bar.open,_Digits),
             DoubleToString(bar.high,_Digits),
             DoubleToString(bar.low,_Digits),
             DoubleToString(bar.close,_Digits),
             bar.tick_volume,
             bar.spread,
             bar.real_volume);
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
   FileWrite(g_file,"time_server","open","high","low","close","tick_volume","spread_points","real_volume");
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
   if(g_file!=INVALID_HANDLE)
      FileClose(g_file);
   g_file=INVALID_HANDLE;
  }
//+------------------------------------------------------------------+
