//+------------------------------------------------------------------+
//|             IndiSingle_BobVolman_Inverse_M5.mq5                 |
//| Independent Bob Volman accumulation-failure entries on M5.      |
//| H1 supplies context only; no main setup or virtual main trade is |
//| required. 1R defaults to 1% of account equity.                   |
//+------------------------------------------------------------------+
#property copyright "IndiSingle - independent inverse M5"
#property version   "1.03"
#property strict

#include <Trade\Trade.mqh>

CTrade trade;

enum ENUM_INDEPENDENT_INVERSE_SETUP
{
   IX_NONE       = 0,
   IX_NO_ENTRY   = 1, // Accumulation produces no with-context entry candle
   IX_ENGULFED   = 2, // With-context entry candle is body-engulfed
   IX_EMA_ENGULF = 3  // Reversal candle crosses and closes through M5 EMA
};

struct AccumulationState
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

input group "01. EXECUTION"
input ulong  Inp_MagicNumber          = 20261017;
input double Inp_RiskPercent          = 1.00;
input double Inp_TargetRR             = 1.00;
input double Inp_NoEntryTargetRR      = 0.75;
input double Inp_EngulfedTargetRR     = 1.00;
input double Inp_EMAEngulfTargetRR    = 1.00;
input bool   Inp_AllowBuy             = true;
input bool   Inp_AllowSell            = true;
input int    Inp_MaxSpreadPoints      = 500;
input double Inp_MaxSpreadRiskPct     = 15.0;
input int    Inp_CooldownBars         = 2;

input group "02. ACCUMULATION"
input int    Inp_AccumulationBars     = 6;
input double Inp_AccumulationMinATR   = 0.40;
input double Inp_AccumulationMaxATR   = 1.50;
input double Inp_MinOverlapRatio      = 0.55;
input double Inp_MaxAverageBodyRatio  = 0.55;
input int    Inp_MinPressureCloses    = 2;
input double Inp_PressureZonePct      = 0.40;
input double Inp_BreakoutBufferATR    = 0.05;

input group "03. THREE INVERSE TRIGGERS"
input bool   Inp_EnableNoEntry        = true;
input int    Inp_NoEntryWaitBars      = 3;
input double Inp_NoEntryMinBodyRatio  = 0.35;
input bool   Inp_EnableEngulfedEntry  = true;
input int    Inp_EngulfWindowBars     = 2;
input double Inp_EngulfToleranceATR   = 0.05;
input bool   Inp_EnableEMAEngulf      = true;
input int    Inp_M5EMAPeriod          = 25;
input double Inp_EMAEngulfMinBodyRatio= 0.50;
// Session masks use server hour: 1=00-07, 2=08-15, 4=16-23, 7=all.
input int    Inp_NoEntrySessionMask    = 7;
input int    Inp_EngulfedSessionMask   = 7;
input int    Inp_EMAEngulfSessionMask  = 7;

input group "04. H1 CONTEXT AND STOP"
input int    Inp_H1EMAPeriod          = 25;
input int    Inp_H1EMASlopeBars       = 4;
input int    Inp_ATRPeriod            = 14;
input double Inp_StopBufferATR        = 0.10;
input double Inp_MinRiskATR           = 0.50;
input double Inp_MaxRiskATR           = 3.00;

input group "05. DISPLAY"
input bool   Inp_DrawAnnotations      = true;
input bool   Inp_ShowStatusPanel      = true;

int g_h1EmaHandle=INVALID_HANDLE;
int g_m5EmaHandle=INVALID_HANDLE;
int g_m5AtrHandle=INVALID_HANDLE;
datetime g_lastM5BarTime=0;
datetime g_lastStateEndBar=0;
AccumulationState g_accum;

string InverseCode(const ENUM_INDEPENDENT_INVERSE_SETUP setup)
{
   if(setup==IX_NO_ENTRY)   return "NOENTRY";
   if(setup==IX_ENGULFED)   return "ENGULFED";
   if(setup==IX_EMA_ENGULF) return "EMAENGULF";
   return "NONE";
}

string DirectionText(const int direction)
{
   return (direction>0 ? "BUY" : "SELL");
}

double CandleRange(const MqlRates &bar)
{
   return bar.high-bar.low;
}

double BodyRatio(const MqlRates &bar)
{
   const double range=CandleRange(bar);
   return (range>0.0 ? MathAbs(bar.close-bar.open)/range : 0.0);
}

bool IsBull(const MqlRates &bar)
{
   return bar.close>bar.open;
}

bool IsBear(const MqlRates &bar)
{
   return bar.close<bar.open;
}

double OverlapRatio(const MqlRates &a,const MqlRates &b)
{
   const double overlap=MathMax(0.0,MathMin(a.high,b.high)-MathMax(a.low,b.low));
   const double base=MathMin(CandleRange(a),CandleRange(b));
   return (base>0.0 ? overlap/base : 0.0);
}

double NormalizePriceNearest(const double price)
{
   const double tickSize=SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE);
   if(tickSize<=0.0)
      return NormalizeDouble(price,_Digits);
   return NormalizeDouble(MathRound(price/tickSize)*tickSize,_Digits);
}

double NormalizeStop(const double price,const int direction)
{
   const double tickSize=SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE);
   if(tickSize<=0.0)
      return NormalizeDouble(price,_Digits);
   const double ticks=price/tickSize;
   return NormalizeDouble((direction>0 ? MathFloor(ticks) : MathCeil(ticks))*tickSize,_Digits);
}

int VolumeDigits()
{
   const double step=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP);
   if(step>=1.0) return 0;
   if(step>=0.1) return 1;
   if(step>=0.01) return 2;
   if(step>=0.001) return 3;
   return 4;
}

double NormalizeVolumeDown(const double rawVolume)
{
   const double minimum=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN);
   const double maximum=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MAX);
   const double step=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP);
   if(step<=0.0 || rawVolume<minimum)
      return 0.0;
   const double volume=MathMin(maximum,MathFloor((rawVolume+1e-12)/step)*step);
   return (volume>=minimum ? NormalizeDouble(volume,VolumeDigits()) : 0.0);
}

bool IsSuccessfulRetcode(const uint retcode)
{
   return (retcode==TRADE_RETCODE_DONE || retcode==TRADE_RETCODE_DONE_PARTIAL ||
           retcode==TRADE_RETCODE_PLACED);
}

bool HasOwnPosition()
{
   for(int i=PositionsTotal()-1;i>=0;i--)
   {
      const ulong ticket=PositionGetTicket(i);
      if(ticket==0 || !PositionSelectByTicket(ticket))
         continue;
      if(PositionGetString(POSITION_SYMBOL)==_Symbol &&
         (ulong)PositionGetInteger(POSITION_MAGIC)==Inp_MagicNumber)
         return true;
   }
   return false;
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
      if(secondsFrom==secondsTo) return true;
      if(secondsFrom<secondsTo && secondsNow>=secondsFrom && secondsNow<secondsTo) return true;
      if(secondsFrom>secondsTo && (secondsNow>=secondsFrom || secondsNow<secondsTo)) return true;
   }
   return false;
}

bool SetupSessionAllowed(const ENUM_INDEPENDENT_INVERSE_SETUP setup,const datetime time)
{
   MqlDateTime value;
   TimeToStruct(time,value);
   const int bit=(value.hour>=16 ? 4 : (value.hour>=8 ? 2 : 1));
   int mask=7;
   if(setup==IX_NO_ENTRY) mask=Inp_NoEntrySessionMask;
   else if(setup==IX_ENGULFED) mask=Inp_EngulfedSessionMask;
   else if(setup==IX_EMA_ENGULF) mask=Inp_EMAEngulfSessionMask;
   return ((mask&bit)!=0);
}

void ResetAccumulation(const bool completed=false)
{
   g_accum.active=false;
   g_accum.detected_time=0;
   g_accum.main_direction=0;
   g_accum.high=0.0;
   g_accum.low=0.0;
   g_accum.atr=0.0;
   g_accum.wait_bars=0;
   g_accum.entry_candle_seen=false;
   ZeroMemory(g_accum.entry_candle);
   g_accum.bars_after_entry=0;
   if(completed)
      g_lastStateEndBar=iTime(_Symbol,PERIOD_M5,0);
}

bool CooldownComplete()
{
   if(g_lastStateEndBar==0 || Inp_CooldownBars<=0)
      return true;
   const int shift=iBarShift(_Symbol,PERIOD_M5,g_lastStateEndBar,false);
   return (shift>Inp_CooldownBars);
}

bool LoadData(MqlRates &m5Rates[],double &m5Atr[],double &m5Ema[],
              MqlRates &h1Rates[],double &h1Ema[])
{
   const int m5Needed=MathMax(40,Inp_AccumulationBars+10);
   const int h1Needed=MathMax(20,Inp_H1EMASlopeBars+5);
   ArraySetAsSeries(m5Rates,true);
   ArraySetAsSeries(m5Atr,true);
   ArraySetAsSeries(m5Ema,true);
   ArraySetAsSeries(h1Rates,true);
   ArraySetAsSeries(h1Ema,true);
   if(CopyRates(_Symbol,PERIOD_M5,0,m5Needed,m5Rates)<m5Needed) return false;
   if(CopyBuffer(g_m5AtrHandle,0,0,m5Needed,m5Atr)<m5Needed) return false;
   if(CopyBuffer(g_m5EmaHandle,0,0,m5Needed,m5Ema)<m5Needed) return false;
   if(CopyRates(_Symbol,PERIOD_H1,0,h1Needed,h1Rates)<h1Needed) return false;
   if(CopyBuffer(g_h1EmaHandle,0,0,h1Needed,h1Ema)<h1Needed) return false;
   return true;
}

int H1ContextDirection(const MqlRates &rates[],const double &ema[])
{
   const int older=1+Inp_H1EMASlopeBars;
   if(rates[1].close>ema[1] && ema[1]>ema[older]) return 1;
   if(rates[1].close<ema[1] && ema[1]<ema[older]) return -1;
   return 0;
}

bool DetectAccumulation(const MqlRates &rates[],const double atr,const int mainDirection)
{
   if(mainDirection==0 || atr<=0.0)
      return false;
   double high=rates[1].high,low=rates[1].low,overlap=0.0,body=0.0;
   for(int i=1;i<=Inp_AccumulationBars;i++)
   {
      high=MathMax(high,rates[i].high);
      low=MathMin(low,rates[i].low);
      body+=BodyRatio(rates[i]);
      if(i<Inp_AccumulationBars)
         overlap+=OverlapRatio(rates[i],rates[i+1]);
   }
   const double height=high-low;
   const double averageOverlap=overlap/MathMax(1,Inp_AccumulationBars-1);
   const double averageBody=body/Inp_AccumulationBars;
   if(height<Inp_AccumulationMinATR*atr || height>Inp_AccumulationMaxATR*atr ||
      averageOverlap<Inp_MinOverlapRatio || averageBody>Inp_MaxAverageBodyRatio)
      return false;

   const double zone=MathMin(0.50,MathMax(0.05,Inp_PressureZonePct))*height;
   int pressure=0;
   for(int i=1;i<=MathMin(3,Inp_AccumulationBars);i++)
   {
      if(mainDirection>0 && rates[i].close>=high-zone) pressure++;
      if(mainDirection<0 && rates[i].close<=low+zone) pressure++;
   }
   if(pressure<Inp_MinPressureCloses)
      return false;

   g_accum.active=true;
   g_accum.detected_time=rates[1].time;
   g_accum.main_direction=mainDirection;
   g_accum.high=high;
   g_accum.low=low;
   g_accum.atr=atr;
   g_accum.wait_bars=0;
   g_accum.entry_candle_seen=false;
   g_accum.bars_after_entry=0;
   PrintFormat("[BV-IX][ACCUM][MAIN:%s] time=%s bars=%d low=%.*f high=%.*f height=%.2fATR overlap=%.2f body=%.2f pressure=%d",
               DirectionText(mainDirection),TimeToString(rates[1].time,TIME_DATE|TIME_MINUTES),
               Inp_AccumulationBars,_Digits,low,_Digits,high,height/atr,averageOverlap,averageBody,pressure);
   return true;
}

double RiskVolume(const int direction,const double entry,const double stopLoss)
{
   const double riskMoney=AccountInfoDouble(ACCOUNT_EQUITY)*Inp_RiskPercent/100.0;
   double oneLotProfit=0.0;
   if(riskMoney<=0.0 || !OrderCalcProfit(direction>0 ? ORDER_TYPE_BUY : ORDER_TYPE_SELL,
                                         _Symbol,1.0,entry,stopLoss,oneLotProfit))
      return 0.0;
   const double oneLotLoss=MathAbs(oneLotProfit);
   return (oneLotLoss>0.0 ? NormalizeVolumeDown(riskMoney/oneLotLoss) : 0.0);
}

bool StopsValid(const int direction,const double entry,const double stopLoss,const double takeProfit)
{
   const double minimum=(double)SymbolInfoInteger(_Symbol,SYMBOL_TRADE_STOPS_LEVEL)*_Point;
   const double slDistance=(direction>0 ? entry-stopLoss : stopLoss-entry);
   const double tpDistance=(direction>0 ? takeProfit-entry : entry-takeProfit);
   return (slDistance>=minimum && tpDistance>=minimum);
}

double TargetRRForSetup(const ENUM_INDEPENDENT_INVERSE_SETUP setup)
{
   if(setup==IX_NO_ENTRY && Inp_NoEntryTargetRR>0.0) return Inp_NoEntryTargetRR;
   if(setup==IX_ENGULFED && Inp_EngulfedTargetRR>0.0) return Inp_EngulfedTargetRR;
   if(setup==IX_EMA_ENGULF && Inp_EMAEngulfTargetRR>0.0) return Inp_EMAEngulfTargetRR;
   return Inp_TargetRR;
}

void AnnotateEntry(const ENUM_INDEPENDENT_INVERSE_SETUP setup,const int direction,
                   const datetime time,const double price)
{
   if(!Inp_DrawAnnotations)
      return;
   const string name="BV_IX_"+InverseCode(setup)+"_"+IntegerToString((int)time);
   if(ObjectCreate(0,name,OBJ_ARROW,0,time,price))
   {
      ObjectSetInteger(0,name,OBJPROP_ARROWCODE,direction>0 ? 233 : 234);
      ObjectSetInteger(0,name,OBJPROP_COLOR,direction>0 ? clrDeepSkyBlue : clrTomato);
      ObjectSetInteger(0,name,OBJPROP_WIDTH,2);
      ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   }
}

bool OpenInverse(const ENUM_INDEPENDENT_INVERSE_SETUP setup,const MqlRates &signalBar,
                 const int direction,const MqlTick &tick)
{
   if((direction>0 && !Inp_AllowBuy) || (direction<0 && !Inp_AllowSell) ||
      !SymbolTradingSessionOpen(tick.time) || !SetupSessionAllowed(setup,tick.time))
   {
      PrintFormat("[BV-IX][SKIP:%s] direction or session disabled",InverseCode(setup));
      ResetAccumulation(true);
      return false;
   }
   const double entry=NormalizePriceNearest(direction>0 ? tick.ask : tick.bid);
   const double buffer=Inp_StopBufferATR*g_accum.atr;
   double rawStop=(direction>0 ? MathMin(g_accum.low,signalBar.low)-buffer :
                                  MathMax(g_accum.high,signalBar.high)+buffer);
   const double minimumRisk=Inp_MinRiskATR*g_accum.atr;
   if(direction>0) rawStop=MathMin(rawStop,entry-minimumRisk);
   else            rawStop=MathMax(rawStop,entry+minimumRisk);
   const double stopLoss=NormalizeStop(rawStop,direction);
   const double riskDistance=(direction>0 ? entry-stopLoss : stopLoss-entry);
   if(riskDistance<=0.0 || riskDistance>Inp_MaxRiskATR*g_accum.atr)
   {
      PrintFormat("[BV-IX][SKIP:%s] invalid risk %.2fATR",InverseCode(setup),riskDistance/g_accum.atr);
      return false;
   }
   const double spread=tick.ask-tick.bid;
   if((Inp_MaxSpreadPoints>0 && spread/_Point>Inp_MaxSpreadPoints) ||
      (Inp_MaxSpreadRiskPct>0.0 && 100.0*spread/riskDistance>Inp_MaxSpreadRiskPct))
   {
      PrintFormat("[BV-IX][SKIP:%s] spread %.1f points / %.1f%% risk",
                  InverseCode(setup),spread/_Point,100.0*spread/riskDistance);
      return false;
   }
   const double targetRR=TargetRRForSetup(setup);
   const double takeProfit=NormalizePriceNearest(entry+direction*targetRR*riskDistance);
   if(!StopsValid(direction,entry,stopLoss,takeProfit))
      return false;
   const double volume=RiskVolume(direction,entry,stopLoss);
   if(volume<=0.0)
      return false;

   trade.SetExpertMagicNumber(Inp_MagicNumber);
   trade.SetTypeFillingBySymbol(_Symbol);
   trade.SetDeviationInPoints(20);
   const string comment="BVIX_"+InverseCode(setup)+"_"+DirectionText(direction);
   const bool sent=(direction>0 ? trade.Buy(volume,_Symbol,0.0,stopLoss,takeProfit,comment) :
                                  trade.Sell(volume,_Symbol,0.0,stopLoss,takeProfit,comment));
   if(sent && IsSuccessfulRetcode(trade.ResultRetcode()))
   {
      const double fill=(trade.ResultPrice()>0.0 ? trade.ResultPrice() : entry);
      PrintFormat("[BV-IX][ENTRY:%s][%s] volume=%.3f fill=%.*f SL=%.*f TP=%.*f target=%.2fR risk=%.2f%%",
                  InverseCode(setup),DirectionText(direction),volume,_Digits,fill,
                  _Digits,stopLoss,_Digits,takeProfit,targetRR,Inp_RiskPercent);
      AnnotateEntry(setup,direction,tick.time,fill);
      ResetAccumulation(true);
      return true;
   }
   PrintFormat("[BV-IX][ORDER-REJECT:%s] retcode=%u (%s) error=%d",
               InverseCode(setup),trade.ResultRetcode(),trade.ResultRetcodeDescription(),GetLastError());
   ResetAccumulation(true);
   return false;
}

bool IsEMAEngulf(const MqlRates &bar,const double ema,const int mainDirection)
{
   if(BodyRatio(bar)<Inp_EMAEngulfMinBodyRatio)
      return false;
   if(mainDirection>0)
      return (IsBear(bar) && bar.open>ema && bar.close<ema);
   return (IsBull(bar) && bar.open<ema && bar.close>ema);
}

bool EntryBodyEngulfed(const MqlRates &bar,const MqlRates &entryBar,const int mainDirection)
{
   const double tolerance=Inp_EngulfToleranceATR*g_accum.atr;
   if(mainDirection>0)
      return (IsBull(entryBar) && IsBear(bar) &&
              bar.open>=entryBar.close-tolerance && bar.close<=entryBar.open+tolerance &&
              bar.close<g_accum.high);
   return (IsBear(entryBar) && IsBull(bar) &&
           bar.open<=entryBar.close+tolerance && bar.close>=entryBar.open-tolerance &&
           bar.close>g_accum.low);
}

void ProcessAccumulation(const MqlRates &rates[],const double &m5Ema[],const MqlTick &tick)
{
   const MqlRates bar=rates[1];
   const int inverseDirection=-g_accum.main_direction;

   if(g_accum.entry_candle_seen)
   {
      g_accum.bars_after_entry++;
      if(Inp_EnableEngulfedEntry &&
         EntryBodyEngulfed(bar,g_accum.entry_candle,g_accum.main_direction))
      {
         OpenInverse(IX_ENGULFED,bar,inverseDirection,tick);
         return;
      }
      if(Inp_EnableEMAEngulf && IsEMAEngulf(bar,m5Ema[1],g_accum.main_direction))
      {
         OpenInverse(IX_EMA_ENGULF,bar,inverseDirection,tick);
         return;
      }
      if(g_accum.bars_after_entry>=Inp_EngulfWindowBars)
      {
         Print("[BV-IX][EXPIRE] entry candle was not engulfed");
         ResetAccumulation(true);
      }
      return;
   }

   if(Inp_EnableEMAEngulf && IsEMAEngulf(bar,m5Ema[1],g_accum.main_direction))
   {
      OpenInverse(IX_EMA_ENGULF,bar,inverseDirection,tick);
      return;
   }

   const double breakoutBuffer=Inp_BreakoutBufferATR*g_accum.atr;
   const bool mainEntry=(g_accum.main_direction>0 ?
                         IsBull(bar) && bar.close>g_accum.high+breakoutBuffer :
                         IsBear(bar) && bar.close<g_accum.low-breakoutBuffer);
   if(mainEntry)
   {
      g_accum.entry_candle_seen=true;
      g_accum.entry_candle=bar;
      g_accum.bars_after_entry=0;
      PrintFormat("[BV-IX][MAIN-ENTRY-CANDLE][%s] time=%s close=%.*f",
                  DirectionText(g_accum.main_direction),TimeToString(bar.time,TIME_DATE|TIME_MINUTES),
                  _Digits,bar.close);
      return;
   }

   g_accum.wait_bars++;
   // No-entry is not a timeout market order. The opposite candle must break
   // and close beyond the far edge of the frozen accumulation block.
   const bool oppositeConfirmation=(g_accum.main_direction>0 ?
                                    IsBear(bar) && bar.close<g_accum.low-breakoutBuffer :
                                    IsBull(bar) && bar.close>g_accum.high+breakoutBuffer);
   if(Inp_EnableNoEntry && g_accum.wait_bars>=Inp_NoEntryWaitBars &&
      oppositeConfirmation && BodyRatio(bar)>=Inp_NoEntryMinBodyRatio)
   {
      OpenInverse(IX_NO_ENTRY,bar,inverseDirection,tick);
      return;
   }
   if(g_accum.wait_bars>=Inp_NoEntryWaitBars+3)
   {
      Print("[BV-IX][EXPIRE] accumulation produced no inverse confirmation");
      ResetAccumulation(true);
   }
}

void OnNewM5Bar()
{
   if(HasOwnPosition())
      return;
   MqlRates m5Rates[],h1Rates[];
   double m5Atr[],m5Ema[],h1Ema[];
   if(!LoadData(m5Rates,m5Atr,m5Ema,h1Rates,h1Ema) || m5Atr[1]<=0.0)
      return;
   MqlTick tick;
   if(!SymbolInfoTick(_Symbol,tick))
      return;
   if(g_accum.active)
   {
      ProcessAccumulation(m5Rates,m5Ema,tick);
      return;
   }
   if(!CooldownComplete())
      return;
   DetectAccumulation(m5Rates,m5Atr[1],H1ContextDirection(h1Rates,h1Ema));
}

int OnInit()
{
   if(_Period!=PERIOD_M5)
   {
      Print("[BV-IX][INIT] Attach this independent inverse EA to M5.");
      return INIT_PARAMETERS_INCORRECT;
   }
   if(Inp_RiskPercent<=0.0 || Inp_RiskPercent>10.0 || Inp_TargetRR<=0.0 ||
      Inp_NoEntryTargetRR<=0.0 || Inp_EngulfedTargetRR<=0.0 || Inp_EMAEngulfTargetRR<=0.0 ||
      Inp_AccumulationBars<3 || Inp_AccumulationBars>20 ||
      Inp_AccumulationMinATR<=0.0 || Inp_AccumulationMaxATR<Inp_AccumulationMinATR ||
      Inp_MinOverlapRatio<0.0 || Inp_MinOverlapRatio>1.0 ||
      Inp_MaxAverageBodyRatio<=0.0 || Inp_MaxAverageBodyRatio>1.0 ||
      Inp_MinPressureCloses<0 || Inp_MinPressureCloses>3 ||
      Inp_PressureZonePct<=0.0 || Inp_PressureZonePct>0.5 ||
      Inp_NoEntrySessionMask<0 || Inp_NoEntrySessionMask>7 ||
      Inp_EngulfedSessionMask<0 || Inp_EngulfedSessionMask>7 ||
      Inp_EMAEngulfSessionMask<0 || Inp_EMAEngulfSessionMask>7 ||
      Inp_NoEntryWaitBars<1 || Inp_EngulfWindowBars<1 ||
      Inp_M5EMAPeriod<2 || Inp_H1EMAPeriod<2 || Inp_H1EMASlopeBars<1 ||
      Inp_ATRPeriod<2 || Inp_StopBufferATR<0.0 || Inp_MinRiskATR<=0.0 ||
      Inp_MaxRiskATR<Inp_MinRiskATR)
      return INIT_PARAMETERS_INCORRECT;

   g_h1EmaHandle=iMA(_Symbol,PERIOD_H1,Inp_H1EMAPeriod,0,MODE_EMA,PRICE_CLOSE);
   g_m5EmaHandle=iMA(_Symbol,PERIOD_M5,Inp_M5EMAPeriod,0,MODE_EMA,PRICE_CLOSE);
   g_m5AtrHandle=iATR(_Symbol,PERIOD_M5,Inp_ATRPeriod);
   if(g_h1EmaHandle==INVALID_HANDLE || g_m5EmaHandle==INVALID_HANDLE ||
      g_m5AtrHandle==INVALID_HANDLE)
      return INIT_FAILED;
   ResetAccumulation(false);
   trade.SetExpertMagicNumber(Inp_MagicNumber);
   trade.SetTypeFillingBySymbol(_Symbol);
   Print("[BV-IX][INIT] v1.03 independent accumulation-failure EA loaded");
   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
   if(g_h1EmaHandle!=INVALID_HANDLE) IndicatorRelease(g_h1EmaHandle);
   if(g_m5EmaHandle!=INVALID_HANDLE) IndicatorRelease(g_m5EmaHandle);
   if(g_m5AtrHandle!=INVALID_HANDLE) IndicatorRelease(g_m5AtrHandle);
   Comment("");
}

void OnTick()
{
   const datetime currentBar=iTime(_Symbol,PERIOD_M5,0);
   if(currentBar!=0 && currentBar!=g_lastM5BarTime)
   {
      g_lastM5BarTime=currentBar;
      OnNewM5Bar();
   }
   if(Inp_ShowStatusPanel)
   {
      const string state=(HasOwnPosition() ? "POSITION OPEN" :
                          (g_accum.active ? "ACCUM "+DirectionText(g_accum.main_direction)+
                           " | wait="+IntegerToString(g_accum.wait_bars) : "SCANNING"));
      Comment("IndiSingle Bob Volman independent inverse M5\n",
              "State: ",state,"\nRisk: ",DoubleToString(Inp_RiskPercent,2),
              "% | TP: ",DoubleToString(Inp_TargetRR,2),"R");
   }
}
