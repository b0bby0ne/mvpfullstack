//+------------------------------------------------------------------+
//|                                     SMC_Controller.mq5 v0.15.0   |
//| One-shot SMC New Cycle permission controller for CCBSN Buy-only |
//+------------------------------------------------------------------+
#property copyright "TradingTeam"
#property version   "1.150"
#property strict
#property description "SMC M30 watchout + M15 liquidity/displacement/FVG/retest controller."
#property description "Visual-only by default. Controls New Cycle, never strategy positions."

#include <Trade/Trade.mqh>

#define SMC_CONTROLLER_VERSION "0.15.0"
#define SMC_POLICY_VERSION "smc-xau-m15-m30-v0.15"

const double COMMAND_PRICE = 888888.0;
const int TIMER_MILLISECONDS = 500;
const int MAX_TRACKED_BUY_SIDE_FVGS = 100;

enum ENUM_SMC_CONTROL_MODE
  {
   SMC_VISUAL_ONLY = 0,
   SMC_CONTROL_ENABLED = 1
  };

enum ENUM_SMC_SETUP_PATH
  {
   SMC_PATH_CONTINUATION_HL = 0,
   SMC_PATH_SSL_SWEEP = 1,
   SMC_PATH_EITHER = 2
  };

enum ENUM_SMC_POLICY_STATE
  {
   SMC_STATE_BLOCKED = 0,
   SMC_STATE_WAIT_RETEST = 1,
   SMC_STATE_ENTRY_WINDOW = 2,
   SMC_STATE_RISK_LOCK = 3,
   SMC_STATE_DATA_ERROR = 4
  };

enum ENUM_SMC_CONTEXT
  {
   SMC_CONTEXT_UNKNOWN = 0,
   SMC_CONTEXT_BULLISH = 1,
   SMC_CONTEXT_NEUTRAL = 2,
   SMC_CONTEXT_BEARISH = 3
  };

enum ENUM_SMC_COMMAND
  {
   SMC_COMMAND_NONE = 0,
   SMC_COMMAND_NEW_CYCLE_ON = 1,
   SMC_COMMAND_NEW_CYCLE_OFF = 2
  };

enum ENUM_SMC_CONTROL_STATE
  {
   SMC_CONTROL_DISABLED = 0,
   SMC_CONTROL_UNKNOWN = 1,
   SMC_CONTROL_ON_PENDING = 2,
   SMC_CONTROL_ON_CONFIRMED = 3,
   SMC_CONTROL_OFF_PENDING = 4,
   SMC_CONTROL_OFF_CONFIRMED = 5,
   SMC_CONTROL_ERROR = 6
  };

enum ENUM_SMC_ON_TRIGGER_MODE
  {
   SMC_ON_BEAR_FVG_FILL_OR_SSL_SWEEP = 0,
   SMC_ON_BULL_FVG_RECLAIM = 1
  };

struct SMC_BEAR_FVG_ZONE
  {
   datetime createdTime;
   double top;
   double bottom;
   string objectName;
  };

struct SMC_BULL_FVG_ZONE
  {
   datetime createdTime;
   double top;
   double bottom;
   string objectName;
  };

input group "01. Market & Structure"
input string InpExpectedSymbolPrefix = "XAUUSD";
input ENUM_TIMEFRAMES InpContextTimeframe = PERIOD_M30;
input ENUM_TIMEFRAMES InpDecisionTimeframe = PERIOD_M15;
input int InpATRPeriod = 14;
input int InpHistoryBars = 300;

input int InpContextSwingBars = 2;
input int InpDecisionSwingBars = 2;
input int InpSwingSearchBars = 120;
input ENUM_SMC_SETUP_PATH InpSetupPath = SMC_PATH_EITHER;
input int InpLiquidityMemoryBars = 8;
input double InpBreakToleranceATR = 0.05;

input group "02. ON Cycle & FVG"
input double InpBullDisplacementBodyATR = 0.80;
input double InpBullMinCloseLocation = 0.70;
input double InpMinFVGATR = 0.05;
input bool InpRequireTarget = true;
input double InpMinResearchRR = 1.20;

input int InpSetupExpiryBars = 12;
input bool InpRequireFullFVGReclaim = false;
input double InpRetestMinCloseLocation = 0.55;
input int InpEntryWindowBars = 8;
input bool InpOneShotPerSetup = true;
input ENUM_SMC_ON_TRIGGER_MODE InpOnTriggerMode = SMC_ON_BEAR_FVG_FILL_OR_SSL_SWEEP;

input group "03. OFF Events - OR / First Veto Wins"
input double InpBearDisplacementBodyATR = 1.20;
input double InpBearMaxCloseLocation = 0.30;
input bool InpOffOnCausalLow = true;
input bool InpOffOnBearishBreak = true;
input bool InpOffOnBuySideSweep = true;
input bool InpOffOnBearishFVG = false;
input bool InpOffOnTargetReached = false;
input int InpRiskLockBars = 2;

input group "04. Operational Guards"
input bool InpSystemReadinessAffectsCycle = false;
input bool InpEnableSession = true;
input int InpSessionStartHHMM = 600;
input int InpSessionEndHHMM = 300;
input int InpSessionTimeShiftMinutes = 0;
input bool InpEnableSpreadATRGuard = true;
input double InpMaxSpreadATRRatio = 0.15;
input int InpMaxTickAgeSeconds = 30;

input group "05. CCBSN New Cycle Control"
input ENUM_SMC_CONTROL_MODE InpControlMode = SMC_VISUAL_ONLY;
input ulong InpCCBSNMagic = 9696;
input ulong InpControllerMagic = 997969;
input bool InpRequireHedgingAccount = true;
input int InpCommandTimeoutSeconds = 30;
input int InpCommandRetryMilliseconds = 2000;
input int InpControllerLockStaleSeconds = 15;
input bool InpDeletePendingOnRemove = true;

input group "06. Trading Zone & SMC Visual"
input bool InpDrawSetupZone = true;
input bool InpDrawTradingZone = true;
input bool InpDrawEventMarkers = true;
input bool InpDrawTradingZoneHistory = true;
input int InpTradingZoneHistoryBars = 4500;
input int InpMaxStoredTradingZones = 100;
input bool InpDrawHistoricalSetupZones = false;
input bool InpDrawHistoricalEventMarkers = false;
input int InpMaxHistoricalEventMarkers = 250;
input bool InpShowLiquidityMarkers = true;
input bool InpShowStructureMarkers = true;
input bool InpShowFVGMarkers = true;
input bool InpShowLifecycleMarkers = true;
input bool InpDrawSetupReferenceLevels = true;
input bool InpDrawActiveBearFVGZones = true;
input int InpMaxActiveBearFVGZones = 3;
input bool InpDrawLatestBuySideFVG = true;
input int InpBuySideFVGMaxAgeBars = 30;
input color InpBullishEventColor = C'35,160,110';
input color InpBearishEventColor = C'205,70,80';
input color InpSetupZoneColor = C'70,125,220';
input color InpTradingZoneColor = C'120,185,245';
input int InpZoneOpacityPercent = 70;
input double InpTradingZonePaddingATR = 0.25;
input bool InpKeepObjectsOnRemove = true;

input group "07. Dashboard"
input bool InpApplyChartTheme = true;
input bool InpShowTopDashboard = true;
input bool InpShowOffDashboard = true;
input int InpDashboardX = 10;
input int InpTopDashboardY = 15;
input int InpBottomDashboardY = 15;
input int InpDashboardWidth = 440;
input int InpTopDashboardHeight = 360;
input int InpOffDashboardHeight = 230;
input int InpDashboardFontSize = 9;
input int InpDashboardOpacityPercent = 92;

input group "08. Editable Event Names"
input string InpLabelBearFVGFill = "bFvgFill";
input string InpLabelSSLSweep = "sSwept";
input string InpLabelBSLSweep = "bSwept";
input string InpLabelBullDisplacement = "bullDisp";
input string InpLabelBearBreak = "bBreak";
input string InpLabelBullBreak = "bullBreak";
input string InpLabelBullFVG = "bullFvg";
input string InpLabelFVGTouch = "fvgTouch";
input string InpLabelOnTrigger = "onTrig";
input string InpLabelZoneOn = "zOn";
input string InpLabelZoneOff = "zOff";
input string InpLabelBearLock = "bLock";
input string InpLabelChainStart = "chainStart";

input group "09. Audit"
input bool InpWriteCsvAudit = true;
input string InpAuditFileName = "SMC_Controller_Events_v0_15.csv";

// Fixed visual palette keeps Inputs focused on policy and operations.
const color InpBearFVGZoneColor = C'150,200,245';
const int InpBearFVGOpacityPercent = 20;
const color InpBuySideFVGZoneColor = C'150,225,175';
const int InpBuySideFVGOpacityPercent = 20;
const string InpLabelBuySideFVG = "buyFvg";
const color InpDashboardBackgroundColor = clrWhite;
const color InpDashboardTextColor = C'45,55,70';
const color InpDashboardPassColor = C'0,120,80';
const color InpDashboardOffColor = C'190,50,60';
const color InpChartBackgroundColor = clrLightYellow;
const color InpChartForegroundColor = C'25,30,40';
const color InpChartGridColor = C'230,233,238';
const color InpChartBullColor = C'0,145,105';
const color InpChartBearColor = C'215,65,75';
const color InpChartLineColor = C'55,65,81';
const color InpChartVolumeColor = C'150,158,170';
const color InpChartBidColor = C'65,105,170';
const color InpChartAskColor = C'205,65,75';
const color InpChartLastColor = C'110,85,165';
const color InpChartStopLevelColor = C'190,65,90';
const color InpPanelBorderColor = C'205,210,218';

CTrade g_trade;
int g_atrHandle = INVALID_HANDLE;
bool g_configurationValid = false;
bool g_auditReady = false;
bool g_controllerLockHeld = false;
double g_instanceToken = 0.0;

ENUM_SMC_POLICY_STATE g_policyState = SMC_STATE_BLOCKED;
ENUM_SMC_CONTEXT g_context = SMC_CONTEXT_UNKNOWN;
ENUM_SMC_CONTROL_STATE g_controlState = SMC_CONTROL_DISABLED;
ENUM_SMC_COMMAND g_pendingCommand = SMC_COMMAND_NONE;

datetime g_currentOpenBarTime = 0;
datetime g_lastDecisionTime = 0;
datetime g_lastSSLSweepTime = 0;
datetime g_setupCreatedTime = 0;
datetime g_entryWindowStartTime = 0;
datetime g_zoneStartTime = 0;
datetime g_zoneEndTime = 0;
datetime g_commandSentTime = 0;
datetime g_lastDataErrorBar = 0;

ulong g_commandTicket = 0;
ulong g_nextCommandAttemptTick = 0;
bool g_commandCancelRequested = false;

int g_setupBars = 0;
int g_entryWindowBars = 0;
int g_riskLockRemaining = 0;
int g_ccbsnPositionCount = 0;
int g_previousCCBSNPositionCount = 0;
double g_ccbsnPositionVolume = 0.0;

double g_lastATR = 0.0;
double g_lastSpreadATR = 0.0;
double g_lastCloseLocation = 0.5;
double g_lastBodyATR = 0.0;
double g_lastClose = 0.0;
double g_lastSwingHigh = 0.0;
double g_lastSwingLow = 0.0;
double g_previousSwingHigh = 0.0;
double g_previousSwingLow = 0.0;
double g_lastSSLSweepLow = 0.0;
double g_setupFVGTop = 0.0;
double g_setupFVGBottom = 0.0;
double g_setupCausalLow = 0.0;
double g_setupTarget = 0.0;
double g_setupResearchRR = 0.0;
double g_zoneHigh = 0.0;
double g_zoneLow = 0.0;

string g_configurationError = "NONE";
string g_lastEvent = "INIT";
string g_lastReason = "WAITING_FOR_CLOSED_BAR";
string g_lastControlError = "NONE";
string g_previousOperationalBlock = "";
string g_dataBlockReason = "WAITING_FOR_CLOSED_BAR";
string g_operationalBlockReason = "NOT_EVALUATED";
string g_m15StructureWatchout = "UNKNOWN";
string g_setupId = "NONE";
string g_zoneSetupId = "NONE";
string g_zoneOffReason = "ACTIVE";
string g_objectPrefix = "";
string g_setupZoneObject = "";
string g_tradingZoneObject = "";
bool g_setupTouched = false;
bool g_setupConsumed = false;
bool g_tradingZoneConfirmed = false;
bool g_processingHistory = false;
int g_historicalShift = 0;
datetime g_tradingZoneHistoryCutoff = 0;
string g_closedZoneObjectNames[];
string g_eventObjectNames[];
SMC_BEAR_FVG_ZONE g_activeBearFVGs[];
SMC_BULL_FVG_ZONE g_activeBuySideFVGs[];
SMC_BULL_FVG_ZONE g_latestBuySideFVG;
bool g_buySideFVGActive = false;
bool g_latestBearFVGFillEvent = false;
bool g_sslSweepOnEvent = false;
datetime g_filledBearFVGCreatedTime = 0;
double g_filledBearFVGTop = 0.0;
double g_filledBearFVGBottom = 0.0;
bool g_setupFromDirectEvent = false;
int g_historyBarsProcessed = 0;
int g_historyBullContextBars = 0;
int g_historyLocationPassBars = 0;
int g_historyBullBreakBars = 0;
int g_historyBullFVGBars = 0;
int g_historyCorePassBars = 0;
int g_historyTargetPassBars = 0;
int g_historySetups = 0;
int g_historyEntryWindows = 0;
int g_historyZonesClosed = 0;
int g_historyTouches = 0;
int g_historyReclaims = 0;
int g_historyCancelOperational = 0;
int g_historyCancelLow = 0;
int g_historyCancelBearBreak = 0;
int g_historyCancelBSL = 0;
int g_historyCancelBearFVG = 0;
int g_historyCancelFill = 0;
int g_historyCancelTarget = 0;
int g_historyCancelTimeout = 0;

// Dashboard gate snapshot. ON gates are conjunctive; OFF flags are vetoes.
bool g_onDataGate = false;
bool g_onOperationalGate = false;
bool g_contextBullishWatchout = false;
bool g_onLocationGate = false;
bool g_onBreakGate = false;
bool g_onDisplacementGate = false;
bool g_onFVGGate = false;
bool g_onTargetGate = false;
bool g_onRetestGate = false;
bool g_onFlatGate = false;
bool g_onBuySideFVGGate = false;
bool g_offOperational = false;
bool g_offCausalLow = false;
bool g_offBearBreak = false;
bool g_offBSLSweep = false;
bool g_offBearFVG = false;
bool g_offFVGInvalid = false;
bool g_offTarget = false;
bool g_offTimeout = false;
bool g_offTokenConsumed = false;
// Event checklist is separate from persistent system readiness. ON is a
// one-bar event emitted only when the final reclaim event closes.
bool g_eventBreak = false;
bool g_eventDisplacement = false;
bool g_eventFVG = false;
bool g_eventTouch = false;
bool g_eventReclaim = false;
bool g_eventOnTrigger = false;
bool g_watchoutContinuationHL = false;
bool g_watchoutRecentSSLSweep = false;
bool g_watchoutBullBreak = false;
bool g_watchoutBullDisplacement = false;

string PolicyStateToString(const ENUM_SMC_POLICY_STATE state)
  {
   if(state == SMC_STATE_BLOCKED) return "BLOCKED";
   if(state == SMC_STATE_WAIT_RETEST) return "WAIT_RETEST";
   if(state == SMC_STATE_ENTRY_WINDOW) return "ENTRY_WINDOW";
   if(state == SMC_STATE_RISK_LOCK) return "RISK_LOCK";
   if(state == SMC_STATE_DATA_ERROR) return "DATA_ERROR";
   return "UNKNOWN";
  }

string ContextToString(const ENUM_SMC_CONTEXT context)
  {
   if(context == SMC_CONTEXT_BULLISH) return "BULLISH";
   if(context == SMC_CONTEXT_NEUTRAL) return "NEUTRAL";
   if(context == SMC_CONTEXT_BEARISH) return "BEARISH";
   return "UNKNOWN";
  }

string ControlStateToString(const ENUM_SMC_CONTROL_STATE state)
  {
   if(state == SMC_CONTROL_DISABLED) return "DISABLED";
   if(state == SMC_CONTROL_UNKNOWN) return "UNKNOWN";
   if(state == SMC_CONTROL_ON_PENDING) return "ON_PENDING";
   if(state == SMC_CONTROL_ON_CONFIRMED) return "ON_CONFIRMED";
   if(state == SMC_CONTROL_OFF_PENDING) return "OFF_PENDING";
   if(state == SMC_CONTROL_OFF_CONFIRMED) return "OFF_CONFIRMED";
   if(state == SMC_CONTROL_ERROR) return "ERROR";
   return "UNKNOWN";
  }

string CommandToString(const ENUM_SMC_COMMAND command)
  {
   if(command == SMC_COMMAND_NEW_CYCLE_ON) return "NEW_CYCLE_ON";
   if(command == SMC_COMMAND_NEW_CYCLE_OFF) return "NEW_CYCLE_OFF";
   return "NONE";
  }

string OnTriggerModeToString(const ENUM_SMC_ON_TRIGGER_MODE mode)
  {
   if(mode == SMC_ON_BEAR_FVG_FILL_OR_SSL_SWEEP)
      return "BEAR_FVG_FILL_OR_SSL_SWEEP";
   if(mode == SMC_ON_BULL_FVG_RECLAIM)
      return "BULL_FVG_RECLAIM";
   return "UNKNOWN";
  }

string OnEventMask()
  {
   if(g_latestBearFVGFillEvent && g_sslSweepOnEvent)
      return "BEAR_FVG_FILL|SSL_SWEEP";
   if(g_latestBearFVGFillEvent) return "BEAR_FVG_FILL";
   if(g_sslSweepOnEvent) return "SSL_SWEEP";
   return "NONE";
  }

string FormatPrice(const double value)
  {
   if(value <= 0.0 || !MathIsValidNumber(value)) return "n/a";
   return DoubleToString(value, (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS));
  }

string TimeframeText(const ENUM_TIMEFRAMES timeframe)
  {
   string value = EnumToString(timeframe);
   if(StringFind(value, "PERIOD_") == 0) return StringSubstr(value, 7);
   return value;
  }

string GateText(const bool value)
  {
   return value ? "PASS" : "BLOCK";
  }

string VetoText(const bool value)
  {
   return value ? "OFF" : "--";
  }

long ColorWithOpacity(const color baseColor, const int opacityPercent)
  {
   int bounded = MathMax(0, MathMin(100, opacityPercent));
   uchar alpha = (uchar)MathRound(255.0 * bounded / 100.0);
   return (long)ColorToARGB(baseColor, alpha);
  }

void TrackClosedZoneObject(const string name)
  {
   int size = ArraySize(g_closedZoneObjectNames);
   ArrayResize(g_closedZoneObjectNames, size + 1);
   g_closedZoneObjectNames[size] = name;
   while(ArraySize(g_closedZoneObjectNames) > InpMaxStoredTradingZones)
     {
      string oldest = g_closedZoneObjectNames[0];
      if(ObjectFind(0, oldest) >= 0) ObjectDelete(0, oldest);
      int currentSize = ArraySize(g_closedZoneObjectNames);
      for(int i = 1; i < currentSize; i++)
         g_closedZoneObjectNames[i - 1] = g_closedZoneObjectNames[i];
      ArrayResize(g_closedZoneObjectNames, currentSize - 1);
     }
  }

void TrackEventObject(const string name)
  {
   int size = ArraySize(g_eventObjectNames);
   ArrayResize(g_eventObjectNames, size + 1);
   g_eventObjectNames[size] = name;
   while(ArraySize(g_eventObjectNames) > InpMaxHistoricalEventMarkers)
     {
      string oldest = g_eventObjectNames[0];
      if(ObjectFind(0, oldest) >= 0) ObjectDelete(0, oldest);
      int currentSize = ArraySize(g_eventObjectNames);
      for(int i = 1; i < currentSize; i++)
         g_eventObjectNames[i - 1] = g_eventObjectNames[i];
      ArrayResize(g_eventObjectNames, currentSize - 1);
     }
  }

bool IsEventCategoryEnabled(const string eventType)
  {
   if(StringFind(eventType, "SSL") >= 0 ||
      StringFind(eventType, "BSL") >= 0)
      return InpShowLiquidityMarkers;
   if(StringFind(eventType, "DISP") >= 0 ||
      StringFind(eventType, "BREAK") >= 0 ||
      StringFind(eventType, "BEAR LOCK") >= 0)
      return InpShowStructureMarkers;
   if(StringFind(eventType, "FVG") >= 0)
      return InpShowFVGMarkers;
   return InpShowLifecycleMarkers;
  }

void CreateOrMoveLevel(const string name, const datetime startTime,
                       const datetime endTime, const double price,
                       const color lineColor,
                       const ENUM_LINE_STYLE lineStyle,
                       const string tooltip)
  {
   if(price <= 0.0 || startTime <= 0 || endTime <= startTime) return;
   bool created = ObjectFind(0, name) < 0;
   if(created && !ObjectCreate(0, name, OBJ_TREND, 0,
                               startTime, price, endTime, price)) return;
   ObjectMove(0, name, 0, startTime, price);
   ObjectMove(0, name, 1, endTime, price);
   if(created)
     {
      ObjectSetInteger(0, name, OBJPROP_COLOR, lineColor);
      ObjectSetInteger(0, name, OBJPROP_STYLE, lineStyle);
      ObjectSetInteger(0, name, OBJPROP_WIDTH, 1);
      ObjectSetInteger(0, name, OBJPROP_RAY_RIGHT, false);
      ObjectSetInteger(0, name, OBJPROP_BACK, true);
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, name, OBJPROP_SELECTED, false);
     }
   ObjectSetString(0, name, OBJPROP_TOOLTIP, tooltip);
  }

void DeleteBearFVGZoneAt(const int index)
  {
   int size = ArraySize(g_activeBearFVGs);
   if(index < 0 || index >= size) return;
   string name = g_activeBearFVGs[index].objectName;
   if(name != "" && ObjectFind(0, name) >= 0) ObjectDelete(0, name);
   for(int i = index + 1; i < size; i++)
      g_activeBearFVGs[i - 1] = g_activeBearFVGs[i];
   ArrayResize(g_activeBearFVGs, size - 1);
  }

void UpdateActiveBearFVGZones(const datetime endTime)
  {
   if(!InpDrawActiveBearFVGZones) return;
   int size = ArraySize(g_activeBearFVGs);
   for(int i = 0; i < size; i++)
     {
      SMC_BEAR_FVG_ZONE zone = g_activeBearFVGs[i];
      datetime safeEnd = endTime > zone.createdTime
                         ? endTime
                         : zone.createdTime +
                           PeriodSeconds(InpDecisionTimeframe);
      bool created = ObjectFind(0, zone.objectName) < 0;
      if(created &&
         !ObjectCreate(0, zone.objectName, OBJ_RECTANGLE, 0,
                       zone.createdTime, zone.top,
                       safeEnd, zone.bottom)) continue;
      ObjectMove(0, zone.objectName, 0, zone.createdTime, zone.top);
      ObjectMove(0, zone.objectName, 1, safeEnd, zone.bottom);
      if(created)
        {
         ObjectSetInteger(0, zone.objectName, OBJPROP_COLOR,
                          ColorWithOpacity(InpBearFVGZoneColor,
                                           InpBearFVGOpacityPercent));
         ObjectSetInteger(0, zone.objectName, OBJPROP_FILL, true);
         ObjectSetInteger(0, zone.objectName, OBJPROP_BACK, true);
         ObjectSetInteger(0, zone.objectName, OBJPROP_ZORDER, 0);
         ObjectSetInteger(0, zone.objectName, OBJPROP_SELECTABLE, false);
         ObjectSetInteger(0, zone.objectName, OBJPROP_SELECTED, false);
        }
      ObjectSetString(0, zone.objectName, OBJPROP_TOOLTIP,
                      "ACTIVE SELL-SIDE FVG " + IntegerToString(i + 1) +
                      "/" + IntegerToString(size) +
                      "\ncreated=" +
                      TimeToString(zone.createdTime,
                                   TIME_DATE | TIME_MINUTES) +
                      "\nrange=" + FormatPrice(zone.bottom) + ".." +
                      FormatPrice(zone.top) +
                      "\nfull_fill=" + FormatPrice(zone.top));
     }
  }

void AddActiveBearFVG(const datetime createdTime,
                      const double top, const double bottom)
  {
   if(top <= bottom || createdTime <= 0) return;
   while(ArraySize(g_activeBearFVGs) >= InpMaxActiveBearFVGZones)
      DeleteBearFVGZoneAt(0);
   int size = ArraySize(g_activeBearFVGs);
   ArrayResize(g_activeBearFVGs, size + 1);
   g_activeBearFVGs[size].createdTime = createdTime;
   g_activeBearFVGs[size].top = top;
   g_activeBearFVGs[size].bottom = bottom;
   g_activeBearFVGs[size].objectName = g_objectPrefix + "BEAR_FVG.ACTIVE." +
                                      IntegerToString((long)createdTime);
   UpdateActiveBearFVGZones(createdTime);
  }

void ProcessActiveBearFVGFills(const MqlRates &bar,
                               const datetime decisionTime)
  {
   g_latestBearFVGFillEvent = false;
   g_filledBearFVGCreatedTime = 0;
   g_filledBearFVGTop = 0.0;
   g_filledBearFVGBottom = 0.0;
   int newestIndex = ArraySize(g_activeBearFVGs) - 1;
   for(int i = newestIndex; i >= 0; i--)
     {
      SMC_BEAR_FVG_ZONE zone = g_activeBearFVGs[i];
      if(decisionTime <= zone.createdTime || bar.high < zone.top) continue;
      bool wasLatest = i == newestIndex;
      if(wasLatest)
        {
         g_latestBearFVGFillEvent = true;
         g_filledBearFVGCreatedTime = zone.createdTime;
         g_filledBearFVGTop = zone.top;
         g_filledBearFVGBottom = zone.bottom;
        }
      DeleteBearFVGZoneAt(i);
     }
   UpdateActiveBearFVGZones(decisionTime);
  }

void DeleteLatestBuySideFVG()
  {
   if(g_latestBuySideFVG.objectName != "")
     {
      if(ObjectFind(0, g_latestBuySideFVG.objectName) >= 0)
         ObjectDelete(0, g_latestBuySideFVG.objectName);
      string labelName = g_latestBuySideFVG.objectName + ".LABEL";
      if(ObjectFind(0, labelName) >= 0) ObjectDelete(0, labelName);
     }
   g_buySideFVGActive = false;
   g_latestBuySideFVG.createdTime = 0;
   g_latestBuySideFVG.top = 0.0;
   g_latestBuySideFVG.bottom = 0.0;
   g_latestBuySideFVG.objectName = "";
  }

int BuySideFVGAgeBars(const datetime createdTime,
                      const datetime decisionTime)
  {
   int seconds = PeriodSeconds(InpDecisionTimeframe);
   if(createdTime <= 0 || decisionTime <= createdTime || seconds <= 0)
      return 0;
   return (int)((decisionTime - createdTime) / seconds);
  }

void UpdateLatestBuySideFVG(const datetime endTime)
  {
   if(!g_buySideFVGActive) return;
   string zoneName = g_latestBuySideFVG.objectName;
   string labelName = zoneName + ".LABEL";
   if(!InpDrawLatestBuySideFVG)
     {
      if(ObjectFind(0, zoneName) >= 0) ObjectDelete(0, zoneName);
      if(ObjectFind(0, labelName) >= 0) ObjectDelete(0, labelName);
      return;
     }
   datetime safeEnd = endTime > g_latestBuySideFVG.createdTime
                      ? endTime
                      : g_latestBuySideFVG.createdTime +
                        PeriodSeconds(InpDecisionTimeframe);
   bool created = ObjectFind(0, zoneName) < 0;
   if(created &&
      !ObjectCreate(0, zoneName, OBJ_RECTANGLE, 0,
                    g_latestBuySideFVG.createdTime,
                    g_latestBuySideFVG.top,
                    safeEnd, g_latestBuySideFVG.bottom)) return;
   ObjectMove(0, zoneName, 0, g_latestBuySideFVG.createdTime,
              g_latestBuySideFVG.top);
   ObjectMove(0, zoneName, 1, safeEnd, g_latestBuySideFVG.bottom);
   if(created)
     {
      ObjectSetInteger(0, zoneName, OBJPROP_COLOR,
                       ColorWithOpacity(InpBuySideFVGZoneColor,
                                        InpBuySideFVGOpacityPercent));
      ObjectSetInteger(0, zoneName, OBJPROP_FILL, true);
      ObjectSetInteger(0, zoneName, OBJPROP_BACK, true);
      ObjectSetInteger(0, zoneName, OBJPROP_ZORDER, 0);
      ObjectSetInteger(0, zoneName, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, zoneName, OBJPROP_SELECTED, false);
     }
   ObjectSetString(0, zoneName, OBJPROP_TOOLTIP,
                   InpLabelBuySideFVG + " | ACTIVE\ncreated=" +
                   TimeToString(g_latestBuySideFVG.createdTime,
                                TIME_DATE | TIME_MINUTES) +
                   "\nrange=" + FormatPrice(g_latestBuySideFVG.bottom) +
                   ".." + FormatPrice(g_latestBuySideFVG.top) +
                   "\nfull_fill=" +
                   FormatPrice(g_latestBuySideFVG.bottom) +
                   "\nage_bars=" +
                   IntegerToString(BuySideFVGAgeBars(
                                      g_latestBuySideFVG.createdTime,
                                      endTime)) +
                   "/" + IntegerToString(InpBuySideFVGMaxAgeBars));

   // The box is the complete chart representation. Remove labels retained by
   // older versions so no BUY SIDE FVG text overlays price candles.
   if(ObjectFind(0, labelName) >= 0) ObjectDelete(0, labelName);
  }

void DeleteBuySideFVGAt(const int index)
  {
   int size = ArraySize(g_activeBuySideFVGs);
   if(index < 0 || index >= size) return;
   for(int i = index + 1; i < size; i++)
      g_activeBuySideFVGs[i - 1] = g_activeBuySideFVGs[i];
   ArrayResize(g_activeBuySideFVGs, size - 1);
  }

void SyncLatestBuySideFVG(const datetime endTime)
  {
   int size = ArraySize(g_activeBuySideFVGs);
   if(size <= 0)
     {
      DeleteLatestBuySideFVG();
      return;
     }
   SMC_BULL_FVG_ZONE candidate = g_activeBuySideFVGs[size - 1];
   bool changed = !g_buySideFVGActive ||
                  g_latestBuySideFVG.createdTime != candidate.createdTime ||
                  g_latestBuySideFVG.top != candidate.top ||
                  g_latestBuySideFVG.bottom != candidate.bottom;
   if(changed)
     {
      DeleteLatestBuySideFVG();
      g_latestBuySideFVG.createdTime = candidate.createdTime;
      g_latestBuySideFVG.top = candidate.top;
      g_latestBuySideFVG.bottom = candidate.bottom;
      g_latestBuySideFVG.objectName = g_objectPrefix +
                                      "BUY_SIDE_FVG.ACTIVE." +
                                      IntegerToString((long)candidate.createdTime);
      g_buySideFVGActive = true;
     }
   UpdateLatestBuySideFVG(endTime);
  }

void AddLatestBuySideFVG(const datetime createdTime,
                         const double top, const double bottom)
  {
   if(top <= bottom || createdTime <= 0) return;
   while(ArraySize(g_activeBuySideFVGs) >= MAX_TRACKED_BUY_SIDE_FVGS)
      DeleteBuySideFVGAt(0);
   int size = ArraySize(g_activeBuySideFVGs);
   ArrayResize(g_activeBuySideFVGs, size + 1);
   g_activeBuySideFVGs[size].createdTime = createdTime;
   g_activeBuySideFVGs[size].top = top;
   g_activeBuySideFVGs[size].bottom = bottom;
   g_activeBuySideFVGs[size].objectName = "";
   SyncLatestBuySideFVG(createdTime);
  }

void ProcessLatestBuySideFVGFill(const MqlRates &bar,
                                 const datetime decisionTime)
  {
   for(int i = ArraySize(g_activeBuySideFVGs) - 1; i >= 0; i--)
     {
      SMC_BULL_FVG_ZONE zone = g_activeBuySideFVGs[i];
      int ageBars = BuySideFVGAgeBars(zone.createdTime, decisionTime);
      bool expired = ageBars >= InpBuySideFVGMaxAgeBars;
      bool fullFilled = decisionTime > zone.createdTime &&
                        bar.low <= zone.bottom;
      if(expired || fullFilled)
         DeleteBuySideFVGAt(i);
     }
   SyncLatestBuySideFVG(decisionTime);
  }

bool ShouldRenderTradingZone()
  {
   return !g_processingHistory ||
          (InpDrawTradingZoneHistory && g_historicalShift > 0 &&
           g_historicalShift <= InpTradingZoneHistoryBars);
  }

int PolicyReferenceOpenShift(const ENUM_TIMEFRAMES timeframe)
  {
   if(!g_processingHistory) return 0;
   int shift = iBarShift(_Symbol, timeframe, g_lastDecisionTime, false);
   return shift >= 0 ? shift : 0;
  }

bool SystemReadinessPass()
  {
   return g_onDataGate &&
          g_onOperationalGate &&
          g_onFlatGate;
  }

bool SystemReadinessCycleGatePass()
  {
   return !InpSystemReadinessAffectsCycle || SystemReadinessPass();
  }

bool EventChecklistPass()
  {
   if(InpOnTriggerMode == SMC_ON_BEAR_FVG_FILL_OR_SSL_SWEEP)
      return g_onBuySideFVGGate &&
             (g_latestBearFVGFillEvent || g_sslSweepOnEvent);
   return g_onBuySideFVGGate &&
          g_onLocationGate &&
          g_onTargetGate &&
          g_eventBreak &&
          g_eventDisplacement &&
          g_eventFVG &&
          g_eventTouch &&
          g_eventReclaim;
  }

bool OnTriggerReady()
  {
   return g_eventOnTrigger &&
          SystemReadinessCycleGatePass() &&
          EventChecklistPass();
  }

bool SetupEventChecklistPass()
  {
   return g_onLocationGate &&
          g_onBreakGate &&
          g_onDisplacementGate &&
          g_onFVGGate;
  }

bool IsValidHHMM(const int hhmm)
  {
   int hour = hhmm / 100;
   int minute = hhmm % 100;
   return hour >= 0 && hour <= 23 && minute >= 0 && minute <= 59;
  }

int HHMMToMinute(const int hhmm)
  {
   return (hhmm / 100) * 60 + hhmm % 100;
  }

bool IsSessionAllowed(const datetime decisionTime)
  {
   if(!InpEnableSession) return true;
   MqlDateTime parts;
   TimeToStruct(decisionTime + InpSessionTimeShiftMinutes * 60, parts);
   int minuteOfDay = parts.hour * 60 + parts.min;
   int startMinute = HHMMToMinute(InpSessionStartHHMM);
   int endMinute = HHMMToMinute(InpSessionEndHHMM);
   if(startMinute == endMinute) return true;
   if(startMinute < endMinute)
      return minuteOfDay >= startMinute && minuteOfDay < endMinute;
   return minuteOfDay >= startMinute || minuteOfDay < endMinute;
  }

bool ReadBar(const ENUM_TIMEFRAMES timeframe, const int shift, MqlRates &bar)
  {
   MqlRates values[1];
   if(CopyRates(_Symbol, timeframe, shift, 1, values) != 1)
      return false;
   bar = values[0];
   return bar.time > 0;
  }

double BarHigh(const ENUM_TIMEFRAMES timeframe, const int shift)
  {
   return iHigh(_Symbol, timeframe, shift);
  }

double BarLow(const ENUM_TIMEFRAMES timeframe, const int shift)
  {
   return iLow(_Symbol, timeframe, shift);
  }

bool IsSwingHigh(const ENUM_TIMEFRAMES timeframe, const int shift,
                 const int wing)
  {
   if(shift <= wing) return false;
   double pivot = BarHigh(timeframe, shift);
   if(pivot <= 0.0) return false;
   for(int distance = 1; distance <= wing; distance++)
     {
      double newer = BarHigh(timeframe, shift - distance);
      double older = BarHigh(timeframe, shift + distance);
      if(newer <= 0.0 || older <= 0.0 || pivot <= newer || pivot < older)
         return false;
     }
   return true;
  }

bool IsSwingLow(const ENUM_TIMEFRAMES timeframe, const int shift,
                const int wing)
  {
   if(shift <= wing) return false;
   double pivot = BarLow(timeframe, shift);
   if(pivot <= 0.0) return false;
   for(int distance = 1; distance <= wing; distance++)
     {
      double newer = BarLow(timeframe, shift - distance);
      double older = BarLow(timeframe, shift + distance);
      if(newer <= 0.0 || older <= 0.0 || pivot >= newer || pivot > older)
         return false;
     }
   return true;
  }

bool FindSwing(const ENUM_TIMEFRAMES timeframe, const bool findHigh,
               const int wing, const int ordinal, double &price,
               datetime &pivotTime, int &pivotShift)
  {
   int found = 0;
   int referenceShift = PolicyReferenceOpenShift(timeframe);
   int firstShift = referenceShift + wing + 1;
   int maximum = referenceShift +
                 MathMax(wing * 2 + 4, InpSwingSearchBars);
   for(int shift = firstShift; shift <= maximum; shift++)
     {
      bool match = findHigh ? IsSwingHigh(timeframe, shift, wing)
                            : IsSwingLow(timeframe, shift, wing);
      if(!match) continue;
      found++;
      if(found == ordinal)
        {
         price = findHigh ? BarHigh(timeframe, shift)
                          : BarLow(timeframe, shift);
         pivotTime = iTime(_Symbol, timeframe, shift);
         pivotShift = shift;
         return price > 0.0 && pivotTime > 0;
        }
     }
   return false;
  }

ENUM_SMC_CONTEXT EvaluateContext()
  {
   double high1 = 0.0, high2 = 0.0, low1 = 0.0, low2 = 0.0;
   datetime ignoredTime = 0;
   int ignoredShift = 0;
   if(!FindSwing(InpContextTimeframe, true, InpContextSwingBars, 1,
                 high1, ignoredTime, ignoredShift) ||
      !FindSwing(InpContextTimeframe, true, InpContextSwingBars, 2,
                 high2, ignoredTime, ignoredShift) ||
      !FindSwing(InpContextTimeframe, false, InpContextSwingBars, 1,
                 low1, ignoredTime, ignoredShift) ||
      !FindSwing(InpContextTimeframe, false, InpContextSwingBars, 2,
                 low2, ignoredTime, ignoredShift))
      return SMC_CONTEXT_UNKNOWN;
   if(high1 > high2 && low1 > low2) return SMC_CONTEXT_BULLISH;
   if(high1 < high2 && low1 < low2) return SMC_CONTEXT_BEARISH;
   return SMC_CONTEXT_NEUTRAL;
  }

bool LoadDecisionFeatures(MqlRates &bar, MqlRates &twoBarsAgo,
                          datetime &decisionTime)
  {
   g_dataBlockReason = "";
   if(!ReadBar(InpDecisionTimeframe, 1, bar))
     {
      g_dataBlockReason = "M15_CLOSED_BAR_NOT_READY";
      return false;
     }
   if(!ReadBar(InpDecisionTimeframe, 3, twoBarsAgo))
     {
      g_dataBlockReason = "M15_FVG_REFERENCE_NOT_READY";
      return false;
     }

   double atrValues[1];
   if(CopyBuffer(g_atrHandle, 0, 1, 1, atrValues) != 1 ||
      !MathIsValidNumber(atrValues[0]) || atrValues[0] <= 0.0)
     {
      g_dataBlockReason = "M15_ATR_NOT_READY";
      return false;
     }

   MqlTick tick;
   if(!SymbolInfoTick(_Symbol, tick) || tick.ask <= 0.0 || tick.bid <= 0.0)
     {
      g_dataBlockReason = "TICK_PRICE_NOT_READY";
      return false;
     }

   g_lastATR = atrValues[0];
   g_lastClose = bar.close;
   double range = bar.high - bar.low;
   g_lastCloseLocation = range > 0.0 ? (bar.close - bar.low) / range : 0.5;
   g_lastBodyATR = MathAbs(bar.close - bar.open) / g_lastATR;
   g_lastSpreadATR = (tick.ask - tick.bid) / g_lastATR;
   decisionTime = bar.time + PeriodSeconds(InpDecisionTimeframe);
   g_dataBlockReason = "READY";
   return true;
  }

bool InitializeAudit()
  {
   if(!InpWriteCsvAudit)
     {
      g_auditReady = true;
      return true;
     }
   if(InpAuditFileName == "" || StringFind(InpAuditFileName, "..") >= 0)
     {
      g_configurationError = "INVALID_AUDIT_FILE_NAME";
      return false;
     }
   int handle = FileOpen(InpAuditFileName,
                         FILE_READ | FILE_WRITE | FILE_CSV |
                         FILE_ANSI | FILE_SHARE_READ, ';');
   if(handle == INVALID_HANDLE)
     {
      g_configurationError = "AUDIT_OPEN_FAILED:" +
                             IntegerToString(GetLastError());
      return false;
     }
   if(FileSize(handle) == 0)
      FileWrite(handle,
                "event_time_server", "decision_time_server", "version",
                "policy_version", "symbol", "context", "policy_state",
                "setup_id", "event", "reason", "close", "atr",
                "body_atr", "close_location", "spread_atr",
                "swing_high", "swing_low", "fvg_top", "fvg_bottom",
                "causal_low", "target", "research_rr", "setup_bars",
                "entry_window_bars", "positions", "volume",
                "on_data", "on_operational", "context_bullish_watchout", "on_location",
                "on_break", "on_displacement", "on_fvg", "on_target",
                "on_retest", "on_flat", "on_buy_side_fvg",
                "system_ready",
                "event_break", "event_displacement", "event_fvg",
                 "event_touch", "event_reclaim", "event_on_trigger",
                 "off_operational",
                "off_causal_low", "off_bear_break", "off_bsl_sweep",
                "off_bear_fvg", "off_fvg_invalid", "off_target",
                 "off_timeout", "off_token_consumed",
                 "on_trigger_mode", "active_bear_fvg_count",
                 "on_event_mask",
                 "filled_bear_fvg_created",
                 "filled_bear_fvg_top", "filled_bear_fvg_bottom",
                 "desired_cycle", "control_state", "command_ticket");
   FileFlush(handle);
   FileClose(handle);
   g_auditReady = true;
   return true;
  }

ENUM_SMC_COMMAND DesiredCommand()
  {
   bool flatAuthorized = !InpSystemReadinessAffectsCycle ||
                         g_ccbsnPositionCount == 0;
   if(g_policyState == SMC_STATE_ENTRY_WINDOW && !g_setupConsumed &&
      flatAuthorized)
      return SMC_COMMAND_NEW_CYCLE_ON;
   return SMC_COMMAND_NEW_CYCLE_OFF;
  }

void AuditEvent(const string eventType, const string reason)
  {
   // Historical reconstruction is visual-only. Do not pollute live telemetry,
   // CSV audit, or the dashboard's latest event with replayed decisions.
   if(g_processingHistory) return;
   g_lastEvent = eventType;
   g_lastReason = reason;
   PrintFormat("SMC CTRL | %s | state=%s context=%s setup=%s | %s",
               eventType, PolicyStateToString(g_policyState),
               ContextToString(g_context), g_setupId, reason);
   if(!InpWriteCsvAudit || !g_auditReady) return;

   int handle = FileOpen(InpAuditFileName,
                         FILE_READ | FILE_WRITE | FILE_CSV |
                         FILE_ANSI | FILE_SHARE_READ, ';');
   if(handle == INVALID_HANDLE)
     {
      g_auditReady = false;
      PrintFormat("SMC AUDIT ERROR | append failed | error=%d", GetLastError());
      return;
     }
   FileSeek(handle, 0, SEEK_END);
   FileWrite(handle,
             TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS),
             TimeToString(g_lastDecisionTime, TIME_DATE | TIME_MINUTES),
             SMC_CONTROLLER_VERSION, SMC_POLICY_VERSION, _Symbol,
             ContextToString(g_context), PolicyStateToString(g_policyState),
             g_setupId, eventType, reason,
             DoubleToString(g_lastClose, 6),
             DoubleToString(g_lastATR, 6),
             DoubleToString(g_lastBodyATR, 4),
             DoubleToString(g_lastCloseLocation, 4),
             DoubleToString(g_lastSpreadATR, 4),
             DoubleToString(g_lastSwingHigh, 6),
             DoubleToString(g_lastSwingLow, 6),
             DoubleToString(g_setupFVGTop, 6),
             DoubleToString(g_setupFVGBottom, 6),
             DoubleToString(g_setupCausalLow, 6),
             DoubleToString(g_setupTarget, 6),
             DoubleToString(g_setupResearchRR, 4),
             g_setupBars, g_entryWindowBars,
             g_ccbsnPositionCount, DoubleToString(g_ccbsnPositionVolume, 2),
             g_onDataGate ? 1 : 0, g_onOperationalGate ? 1 : 0,
             g_contextBullishWatchout ? 1 : 0, g_onLocationGate ? 1 : 0,
             g_onBreakGate ? 1 : 0, g_onDisplacementGate ? 1 : 0,
             g_onFVGGate ? 1 : 0, g_onTargetGate ? 1 : 0,
             g_onRetestGate ? 1 : 0, g_onFlatGate ? 1 : 0,
             g_onBuySideFVGGate ? 1 : 0,
             SystemReadinessPass() ? 1 : 0,
             g_eventBreak ? 1 : 0, g_eventDisplacement ? 1 : 0,
             g_eventFVG ? 1 : 0, g_eventTouch ? 1 : 0,
             g_eventReclaim ? 1 : 0, g_eventOnTrigger ? 1 : 0,
             g_offOperational ? 1 : 0,
             g_offCausalLow ? 1 : 0, g_offBearBreak ? 1 : 0,
             g_offBSLSweep ? 1 : 0, g_offBearFVG ? 1 : 0,
             g_offFVGInvalid ? 1 : 0, g_offTarget ? 1 : 0,
             g_offTimeout ? 1 : 0, g_offTokenConsumed ? 1 : 0,
             OnTriggerModeToString(InpOnTriggerMode),
             ArraySize(g_activeBearFVGs),
             OnEventMask(),
             TimeToString(g_filledBearFVGCreatedTime,
                          TIME_DATE | TIME_MINUTES),
             DoubleToString(g_filledBearFVGTop, 6),
             DoubleToString(g_filledBearFVGBottom, 6),
             CommandToString(DesiredCommand()),
             ControlStateToString(g_controlState),
             StringFormat("%I64u", g_commandTicket));
   FileFlush(handle);
   FileClose(handle);
  }

void CreateEventMarker(const string eventType, const datetime eventTime,
                       const double eventPrice, const bool bullish,
                       const string tooltip,
                       const string displayLabel = "")
  {
   if(!InpDrawEventMarkers) return;
   if(g_processingHistory && !InpDrawHistoricalEventMarkers) return;
   if(!IsEventCategoryEnabled(eventType)) return;
   string safeType = eventType;
   StringReplace(safeType, " ", "_");
   string renderedLabel = displayLabel == "" ? eventType : displayLabel;
   string name = g_objectPrefix + "EVENT." + safeType + "." +
                 IntegerToString((long)eventTime);
   if(ObjectFind(0, name) >= 0) return;
   if(!ObjectCreate(0, name, OBJ_TEXT, 0, eventTime, eventPrice)) return;
   ObjectSetString(0, name, OBJPROP_TEXT, renderedLabel);
   ObjectSetString(0, name, OBJPROP_FONT, "Arial");
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, name, OBJPROP_COLOR,
                    bullish ? InpBullishEventColor : InpBearishEventColor);
   ObjectSetInteger(0, name, OBJPROP_ANCHOR,
                    bullish ? ANCHOR_UPPER : ANCHOR_LOWER);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_SELECTED, false);
   ObjectSetString(0, name, OBJPROP_TOOLTIP,
                   renderedLabel + "\n" + tooltip + "\nconfirmed_at=" +
                   TimeToString(eventTime, TIME_DATE | TIME_MINUTES));
   TrackEventObject(name);
  }

void UpdateSetupZone(const datetime endTime, const bool finished,
                     const string status)
  {
   if(!InpDrawSetupZone || g_setupCreatedTime <= 0 ||
      g_setupFVGTop <= g_setupFVGBottom) return;
   if(g_processingHistory && !InpDrawHistoricalSetupZones) return;
   if(g_setupZoneObject == "")
      g_setupZoneObject = g_objectPrefix + "SETUP." + g_setupId;
   datetime safeEnd = endTime > g_setupCreatedTime
                      ? endTime
                      : g_setupCreatedTime + PeriodSeconds(InpDecisionTimeframe);
   if(ObjectFind(0, g_setupZoneObject) < 0)
     {
      if(!ObjectCreate(0, g_setupZoneObject, OBJ_RECTANGLE, 0,
                       g_setupCreatedTime, g_setupFVGTop,
                       safeEnd, g_setupFVGBottom)) return;
      ObjectSetInteger(0, g_setupZoneObject, OBJPROP_FILL, true);
      ObjectSetInteger(0, g_setupZoneObject, OBJPROP_BACK, true);
      ObjectSetInteger(0, g_setupZoneObject, OBJPROP_COLOR,
                       ColorWithOpacity(InpSetupZoneColor,
                                        InpZoneOpacityPercent));
      ObjectSetInteger(0, g_setupZoneObject, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, g_setupZoneObject, OBJPROP_SELECTED, false);
     }
   else
     {
      ObjectMove(0, g_setupZoneObject, 0,
                 g_setupCreatedTime, g_setupFVGTop);
      ObjectMove(0, g_setupZoneObject, 1, safeEnd, g_setupFVGBottom);
     }
   ObjectSetInteger(0, g_setupZoneObject, OBJPROP_STYLE,
                    finished ? STYLE_DOT : STYLE_SOLID);
   ObjectSetString(0, g_setupZoneObject, OBJPROP_TOOLTIP,
                   "SMC SETUP " + g_setupId + "\nstate=" + status +
                   "\nFVG=" + FormatPrice(g_setupFVGBottom) + ".." +
                   FormatPrice(g_setupFVGTop) +
                   "\ncausal_low=" + FormatPrice(g_setupCausalLow) +
                   "\ntarget=" + FormatPrice(g_setupTarget));
   if(InpDrawSetupReferenceLevels)
     {
      string base = g_setupZoneObject + ".";
      double midpoint = (g_setupFVGTop + g_setupFVGBottom) * 0.5;
      CreateOrMoveLevel(base + "CAUSAL_LOW", g_setupCreatedTime, safeEnd,
                        g_setupCausalLow, InpBearishEventColor, STYLE_DASH,
                        "SMC CAUSAL LOW\n" + FormatPrice(g_setupCausalLow));
      CreateOrMoveLevel(base + "FVG_EQ", g_setupCreatedTime, safeEnd,
                        midpoint, C'210,145,35', STYLE_DOT,
                        "SMC FVG 50%\n" + FormatPrice(midpoint));
      CreateOrMoveLevel(base + "TARGET", g_setupCreatedTime, safeEnd,
                        g_setupTarget, InpBullishEventColor, STYLE_DASH,
                        "SMC TARGET LIQUIDITY\n" +
                        FormatPrice(g_setupTarget));
     }
  }

string TradingZoneTooltip()
  {
   string zoneKind = InpControlMode == SMC_VISUAL_ONLY
                      ? "SIMULATED" :
                      (g_tradingZoneConfirmed ? "CONFIRMED" : "PENDING_ACK");
   string endText = g_zoneEndTime > 0
                    ? TimeToString(g_zoneEndTime,
                                   TIME_DATE | TIME_MINUTES)
                    : "ACTIVE";
   return "SMC TRADING ZONE " + zoneKind +
          "\nsetup=" + g_zoneSetupId +
          "\ntrigger=" +
           (StringFind(g_zoneSetupId, "BFVG-FILL-") == 0
            ? "LATEST_BEAR_FVG_FILL" :
            (StringFind(g_zoneSetupId, "SSL-SWEEP-") == 0
             ? "SSL_SWEEP" : "BULL_FVG_RECLAIM")) +
          "\nstart=" + TimeToString(g_zoneStartTime,
                                     TIME_DATE | TIME_MINUTES) +
          "\nend=" + endText +
           "\noff_reason=" + g_zoneOffReason +
           "\nrender=CCBSN_LITE_RANGE_BOX";
  }

void UpdateTradingZone(const datetime endTime)
  {
   if(!InpDrawTradingZone || g_zoneStartTime <= 0 ||
      g_tradingZoneObject == "" || !ShouldRenderTradingZone()) return;
   double padding = MathMax(g_lastATR * InpTradingZonePaddingATR,
                            SymbolInfoDouble(_Symbol, SYMBOL_POINT) * 10.0);
   double top = g_zoneHigh + padding;
   double bottom = g_zoneLow - padding;
   datetime renderStart = g_zoneStartTime;
   if(g_tradingZoneHistoryCutoff > 0 &&
      renderStart < g_tradingZoneHistoryCutoff)
      renderStart = g_tradingZoneHistoryCutoff;
   datetime safeEnd = endTime > renderStart
                      ? endTime
                      : renderStart + PeriodSeconds(InpDecisionTimeframe);
   bool created = ObjectFind(0, g_tradingZoneObject) < 0;
   if(created &&
      !ObjectCreate(0, g_tradingZoneObject, OBJ_RECTANGLE, 0,
                    renderStart, top, safeEnd, bottom)) return;
   ObjectMove(0, g_tradingZoneObject, 0, renderStart, top);
   ObjectMove(0, g_tradingZoneObject, 1, safeEnd, bottom);
   if(created)
     {
      ObjectSetInteger(0, g_tradingZoneObject, OBJPROP_FILL, true);
      ObjectSetInteger(0, g_tradingZoneObject, OBJPROP_BACK, true);
      ObjectSetInteger(0, g_tradingZoneObject, OBJPROP_COLOR,
                       ColorWithOpacity(InpTradingZoneColor,
                                        InpZoneOpacityPercent));
      ObjectSetInteger(0, g_tradingZoneObject, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSetInteger(0, g_tradingZoneObject, OBJPROP_WIDTH, 1);
      ObjectSetInteger(0, g_tradingZoneObject, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, g_tradingZoneObject, OBJPROP_SELECTED, false);
     }
   ObjectSetString(0, g_tradingZoneObject, OBJPROP_TOOLTIP,
                   TradingZoneTooltip());
  }

void UpdateLiveTradingZoneExtent()
  {
   if(g_zoneStartTime <= 0 || g_processingHistory) return;
   MqlRates currentBar;
   if(!ReadBar(InpDecisionTimeframe, 0, currentBar)) return;
   if(currentBar.high > 0.0) g_zoneHigh = MathMax(g_zoneHigh, currentBar.high);
   if(currentBar.low > 0.0) g_zoneLow = MathMin(g_zoneLow, currentBar.low);
   datetime liveEnd = currentBar.time +
                      PeriodSeconds(InpDecisionTimeframe);
   UpdateTradingZone(liveEnd);
  }

void StartTradingZone(const datetime startTime, const double price,
                      const bool confirmed,
                      const double triggerHigh = 0.0,
                      const double triggerLow = 0.0)
  {
   if(g_zoneStartTime > 0)
     {
      if(confirmed) g_tradingZoneConfirmed = true;
      return;
     }
   g_zoneStartTime = startTime;
   g_zoneEndTime = 0;
   g_zoneSetupId = g_setupId;
   g_zoneOffReason = "ACTIVE";
   // Seed the range with the complete trigger candle so the first visible box
   // starts on, and fully surrounds, the ON-trigger bar itself.
   g_zoneHigh = triggerHigh > 0.0 ? MathMax(triggerHigh, price) : price;
   g_zoneLow = triggerLow > 0.0 ? MathMin(triggerLow, price) : price;
   g_tradingZoneConfirmed = confirmed;
   g_tradingZoneObject = g_objectPrefix + "ZONE." + g_setupId + "." +
                         IntegerToString((long)startTime);
   UpdateTradingZone(startTime + PeriodSeconds(InpDecisionTimeframe));
   CreateEventMarker(confirmed ? "NC ON ACK" : "ZONE ON",
                     startTime, price, true,
                     confirmed ? "New Cycle ON confirmed" :
                     (InpOnTriggerMode == SMC_ON_BEAR_FVG_FILL_OR_SSL_SWEEP
                      ? "Bear FVG fill OR SSL sweep; Trading Zone ON"
                      : "Bullish FVG reclaim; Trading Zone ON"),
                     confirmed ? "" : InpLabelZoneOn);
  }

void CloseTradingZone(const datetime endTime, const string reason)
  {
   if(g_zoneStartTime <= 0) return;
   g_zoneEndTime = endTime;
   g_zoneOffReason = reason;
   UpdateTradingZone(endTime);
   if(ObjectFind(0, g_tradingZoneObject) >= 0)
     {
      ObjectSetInteger(0, g_tradingZoneObject, OBJPROP_STYLE, STYLE_DOT);
      TrackClosedZoneObject(g_tradingZoneObject);
     }
   if(g_processingHistory) g_historyZonesClosed++;
   CreateEventMarker("ZONE OFF", endTime, g_lastClose, false, reason,
                     InpLabelZoneOff);
   g_zoneStartTime = 0;
   g_zoneEndTime = 0;
   g_tradingZoneObject = "";
   g_tradingZoneConfirmed = false;
   g_zoneHigh = 0.0;
   g_zoneLow = 0.0;
   g_zoneSetupId = "NONE";
   g_zoneOffReason = "ACTIVE";
  }

void ResetSetupRuntime()
  {
   g_setupCreatedTime = 0;
   g_entryWindowStartTime = 0;
   g_setupBars = 0;
   g_entryWindowBars = 0;
   g_setupFVGTop = 0.0;
   g_setupFVGBottom = 0.0;
   g_setupCausalLow = 0.0;
   g_setupTarget = 0.0;
   g_setupResearchRR = 0.0;
   g_setupTouched = false;
   g_setupConsumed = false;
   g_setupFromDirectEvent = false;
   g_setupZoneObject = "";
   g_setupId = "NONE";
  }

void CancelSetup(const datetime eventTime, const string reason,
                 const bool riskLock)
  {
   if(g_processingHistory)
     {
      if(reason == "SESSION_BLOCK" || reason == "SPREAD_STRESS" ||
         reason == "AUDIT_NOT_READY" || reason == "TICK_NOT_READY" ||
         reason == "TICK_STALE") g_historyCancelOperational++;
      else if(reason == "CAUSAL_LOW_INVALIDATED") g_historyCancelLow++;
      else if(reason == "BEARISH_DISPLACEMENT_BREAK")
         g_historyCancelBearBreak++;
      else if(reason == "BUY_SIDE_SWEEP_REJECTION") g_historyCancelBSL++;
      else if(reason == "BEARISH_FVG_CREATED") g_historyCancelBearFVG++;
      else if(reason == "BULLISH_FVG_FULLY_FILLED") g_historyCancelFill++;
      else if(reason == "TARGET_LIQUIDITY_REACHED") g_historyCancelTarget++;
      else if(reason == "SETUP_EXPIRED" ||
              reason == "ENTRY_WINDOW_EXPIRED") g_historyCancelTimeout++;
     }
   bool wasEntryWindow = g_policyState == SMC_STATE_ENTRY_WINDOW;
   if(g_setupCreatedTime > 0 && !g_setupFromDirectEvent)
      UpdateSetupZone(eventTime, true, reason);
   // Ordinary setup cancellation remains in audit/state logic, but is not
   // rendered on the chart. Hard risk locks keep their bLock marker.
   if(riskLock)
      CreateEventMarker("BEAR OFF", eventTime, g_lastClose, false, reason,
                        InpLabelBearLock);
   AuditEvent(riskLock ? "BEARISH_POLICY_OFF" : "SETUP_CANCELLED",
              reason);
   g_policyState = riskLock ? SMC_STATE_RISK_LOCK : SMC_STATE_BLOCKED;
   g_riskLockRemaining = riskLock ? InpRiskLockBars : 0;
   if(wasEntryWindow && g_zoneStartTime > 0)
      CloseTradingZone(eventTime, reason);
   ResetSetupRuntime();
  }

double FindTargetAbove(const double currentPrice)
  {
   double best = 0.0;
   for(int ordinal = 1; ordinal <= 12; ordinal++)
     {
      double price = 0.0;
      datetime pivotTime = 0;
      int pivotShift = 0;
      if(!FindSwing(InpDecisionTimeframe, true, InpDecisionSwingBars,
                    ordinal, price, pivotTime, pivotShift)) break;
      if(price > currentPrice && (best <= 0.0 || price < best)) best = price;
     }
   return best;
  }

string OperationalBlockReason(const datetime decisionTime)
  {
   if(!g_processingHistory && InpWriteCsvAudit && !g_auditReady)
      return "AUDIT_NOT_READY";
   if(!IsSessionAllowed(decisionTime)) return "SESSION_BLOCK";
   if(g_processingHistory)
     {
      if(InpEnableSpreadATRGuard &&
         g_lastSpreadATR > InpMaxSpreadATRRatio)
         return "SPREAD_STRESS";
      return "";
     }
   MqlTick tick;
   if(!SymbolInfoTick(_Symbol, tick)) return "TICK_NOT_READY";
   int tickAge = (int)MathMax(0, TimeCurrent() - tick.time);
   if(InpMaxTickAgeSeconds > 0 && tickAge > InpMaxTickAgeSeconds)
      return "TICK_STALE";
   if(InpEnableSpreadATRGuard && g_lastSpreadATR > InpMaxSpreadATRRatio)
      return "SPREAD_STRESS";
   return "";
  }

bool SetupPathPass(const bool continuationHL,
                   const bool recentSSLSweep)
  {
   if(InpSetupPath == SMC_PATH_CONTINUATION_HL) return continuationHL;
   if(InpSetupPath == SMC_PATH_SSL_SWEEP) return recentSSLSweep;
   return continuationHL || recentSSLSweep;
  }

void CreateBullishSetup(const MqlRates &bar, const MqlRates &twoBarsAgo,
                        const datetime decisionTime,
                        const bool continuationHL,
                        const bool recentSSLSweep)
  {
   if(g_processingHistory) g_historySetups++;
   g_setupId = "SMC-" + IntegerToString((long)decisionTime);
   g_setupCreatedTime = decisionTime;
   g_setupBars = 0;
   g_entryWindowBars = 0;
   g_setupFVGBottom = twoBarsAgo.high;
   g_setupFVGTop = bar.low;
   g_setupCausalLow = recentSSLSweep && g_lastSSLSweepLow > 0.0
                      ? g_lastSSLSweepLow : g_lastSwingLow;
   g_setupTarget = FindTargetAbove(bar.close);
   double entryReference = (g_setupFVGTop + g_setupFVGBottom) * 0.5;
   double risk = entryReference - g_setupCausalLow;
   double reward = g_setupTarget > entryReference
                   ? g_setupTarget - entryReference : 0.0;
   g_setupResearchRR = risk > 0.0 ? reward / risk : 0.0;
   g_setupTouched = false;
   g_setupConsumed = false;
   g_policyState = SMC_STATE_WAIT_RETEST;
   g_setupZoneObject = "";
   UpdateSetupZone(decisionTime, false, "WAIT_RETEST");

   string path = continuationHL && recentSSLSweep ? "HL+SSL_SWEEP" :
                 continuationHL ? "HL_CONTINUATION" : "SSL_SWEEP_REVERSAL";
   CreateEventMarker("BULL BREAK", decisionTime,
                     bar.low - g_lastATR * 0.15, true,
                     "accepted close above internal swing high",
                     InpLabelBullBreak);
   CreateEventMarker("BULL FVG", decisionTime,
                     g_setupFVGBottom, true,
                     "causal bullish FVG created", InpLabelBullFVG);
   AuditEvent("BULLISH_SETUP_CONFIRMED",
              "path=" + path + ";fvg=" +
              FormatPrice(g_setupFVGBottom) + ".." +
              FormatPrice(g_setupFVGTop) + ";rr=" +
              DoubleToString(g_setupResearchRR, 2));
  }

void EnterEntryWindow(const MqlRates &bar, const datetime decisionTime)
  {
   if(g_processingHistory) g_historyEntryWindows++;
   g_policyState = SMC_STATE_ENTRY_WINDOW;
   g_entryWindowStartTime = decisionTime;
   g_entryWindowBars = 0;
   UpdateSetupZone(decisionTime, false, "RETEST_RECLAIMED");
   CreateEventMarker("BULL ON", decisionTime,
                     bar.low - g_lastATR * 0.20, true,
                     "FVG retest reclaimed; New Cycle desired ON",
                     InpLabelZoneOn);
   AuditEvent("BULLISH_ENTRY_WINDOW_ON",
              "FVG_RETEST_RECLAIMED");
   if(InpControlMode == SMC_VISUAL_ONLY || g_processingHistory)
      StartTradingZone(decisionTime, bar.close, false, bar.high, bar.low);
  }

void EnterDirectEventWindow(const MqlRates &bar,
                            const datetime decisionTime)
  {
   if(g_processingHistory) g_historyEntryWindows++;
   bool fromBearFVGFill = g_latestBearFVGFillEvent;
   g_setupId = (fromBearFVGFill ? "BFVG-FILL-" : "SSL-SWEEP-") +
               IntegerToString((long)(fromBearFVGFill
                                      ? g_filledBearFVGCreatedTime
                                      : decisionTime));
   g_setupCreatedTime = decisionTime;
   g_entryWindowStartTime = decisionTime;
   g_setupBars = 0;
   g_entryWindowBars = 0;
   g_setupFVGTop = fromBearFVGFill ? g_filledBearFVGTop : 0.0;
   g_setupFVGBottom = fromBearFVGFill ? g_filledBearFVGBottom : 0.0;
   g_setupCausalLow = fromBearFVGFill ? g_lastSwingLow : bar.low;
   g_setupTarget = FindTargetAbove(bar.close);
   double risk = bar.close - g_setupCausalLow;
   double reward = g_setupTarget > bar.close
                   ? g_setupTarget - bar.close : 0.0;
   g_setupResearchRR = risk > 0.0 ? reward / risk : 0.0;
   g_setupTouched = true;
   g_setupConsumed = false;
   g_setupFromDirectEvent = true;
   g_setupZoneObject = "";
   g_policyState = SMC_STATE_ENTRY_WINDOW;
   CreateEventMarker("ON TRIGGER", decisionTime,
                     bar.low - g_lastATR * 0.24, true,
                     fromBearFVGFill
                     ? "latest active bearish FVG fully filled"
                     : "sell-side liquidity sweep closed back above swing low",
                     InpLabelOnTrigger);
   AuditEvent(fromBearFVGFill
              ? "LATEST_BEAR_FVG_FILL_ON_TRIGGER"
              : "SSL_SWEEP_ON_TRIGGER",
              fromBearFVGFill
              ? "SYSTEM_READY_EVENT_FULL_FILL"
              : "SYSTEM_READY_EVENT_SSL_SWEEP");
   // Visual/replay zones start on the trigger close and include the complete
   // trigger candle. Control mode preserves its OFF-confirmed transport gate.
   if(InpControlMode == SMC_VISUAL_ONLY || g_processingHistory)
      StartTradingZone(decisionTime, bar.close, false, bar.high, bar.low);
  }

void ConsumeSetupToken(const datetime eventTime)
  {
   if(g_policyState != SMC_STATE_ENTRY_WINDOW || g_setupConsumed) return;
   g_setupConsumed = true;
   g_offTokenConsumed = true;
   if(g_setupCreatedTime > 0 && !g_setupFromDirectEvent)
      UpdateSetupZone(eventTime, true, "TOKEN_CONSUMED");
   CreateEventMarker("CHAIN START", eventTime, g_lastClose, false,
                     "first CCBSN position consumed one-shot setup token",
                     InpLabelChainStart);
   AuditEvent("CCBSN_CHAIN_STARTED_TOKEN_CONSUMED",
              "ONE_SHOT_NEW_CYCLE_OFF");
   g_policyState = SMC_STATE_BLOCKED;
   if(g_zoneStartTime > 0)
      CloseTradingZone(eventTime, "TOKEN_CONSUMED");
   ResetSetupRuntime();
  }

void ResetGateSnapshot()
  {
   g_onDataGate = false;
   g_onOperationalGate = false;
   g_contextBullishWatchout = false;
   g_onLocationGate = false;
   g_onBreakGate = false;
   g_onDisplacementGate = false;
   g_onFVGGate = false;
   g_onTargetGate = false;
   g_onRetestGate = false;
   g_onFlatGate = false;
   g_onBuySideFVGGate = false;
   g_offOperational = false;
   g_offCausalLow = false;
   g_offBearBreak = false;
   g_offBSLSweep = false;
   g_offBearFVG = false;
   g_offFVGInvalid = false;
   g_offTarget = false;
   g_offTimeout = false;
   g_offTokenConsumed = false;
   g_eventBreak = false;
   g_eventDisplacement = false;
   g_eventFVG = false;
   g_eventTouch = false;
   g_eventReclaim = false;
   g_eventOnTrigger = false;
   g_sslSweepOnEvent = false;
   g_m15StructureWatchout = "UNKNOWN";
   g_watchoutContinuationHL = false;
   g_watchoutRecentSSLSweep = false;
   g_watchoutBullBreak = false;
   g_watchoutBullDisplacement = false;
  }

int ReadCCBSNPositions(double &totalVolume)
  {
   int count = 0;
   totalVolume = 0.0;
   for(int index = PositionsTotal() - 1; index >= 0; index--)
     {
      ulong ticket = PositionGetTicket(index);
      if(ticket == 0) continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
      if((ulong)PositionGetInteger(POSITION_MAGIC) != InpCCBSNMagic) continue;
      count++;
      totalVolume += PositionGetDouble(POSITION_VOLUME);
     }
   return count;
  }

void RefreshCCBSNPositions(const bool initialize)
  {
   double volume = 0.0;
   int count = ReadCCBSNPositions(volume);
   if(initialize)
     {
      g_ccbsnPositionCount = count;
      g_previousCCBSNPositionCount = count;
      g_ccbsnPositionVolume = volume;
      g_onFlatGate = count == 0;
      return;
     }
   g_previousCCBSNPositionCount = g_ccbsnPositionCount;
   g_ccbsnPositionCount = count;
   g_ccbsnPositionVolume = volume;
   // Keep the dashboard/system-readiness inventory gate synchronized on every
   // 500 ms timer refresh instead of waiting for the next closed M15 candle.
   g_onFlatGate = count == 0;
   if(g_previousCCBSNPositionCount == 0 && g_ccbsnPositionCount > 0)
     {
      if(InpOneShotPerSetup)
         ConsumeSetupToken(TimeCurrent());
      else
         AuditEvent("CCBSN_CHAIN_STARTED", "TOKEN_REUSE_ALLOWED_BY_INPUT");
     }
  }

void EnterRiskLock(const datetime eventTime, const string reason)
  {
   if(g_policyState == SMC_STATE_WAIT_RETEST ||
      g_policyState == SMC_STATE_ENTRY_WINDOW)
     {
      CancelSetup(eventTime, reason, true);
      return;
     }
   g_policyState = SMC_STATE_RISK_LOCK;
   g_riskLockRemaining = InpRiskLockBars;
   CreateEventMarker("BEAR LOCK", eventTime, g_lastClose, false, reason,
                     InpLabelBearLock);
   AuditEvent("BEARISH_RISK_LOCK", reason);
  }

void ProcessDecisionBar(const MqlRates &bar,
                        const MqlRates &twoBarsAgo,
                        const datetime decisionTime)
  {
   g_lastDecisionTime = decisionTime;
   g_context = EvaluateContext();
   ResetGateSnapshot();
   g_onDataGate = true;

   MqlRates previousBar;
   int previousShift = g_processingHistory ? g_historicalShift + 1 : 2;
   if(!ReadBar(InpDecisionTimeframe, previousShift, previousBar))
     {
      g_onDataGate = false;
      g_dataBlockReason = "M15_PREVIOUS_BAR_NOT_READY";
      g_operationalBlockReason = "NOT_EVALUATED_DATA_BLOCK";
      g_policyState = SMC_STATE_DATA_ERROR;
      AuditEvent("DATA_ERROR", "PREVIOUS_BAR_NOT_READY");
      return;
     }

   datetime swingTime = 0;
   int swingShift = 0;
   datetime previousLowTime = 0;
   int previousLowShift = 0;
   datetime previousHighTime = 0;
   int previousHighShift = 0;
   bool highReady = FindSwing(InpDecisionTimeframe, true,
                              InpDecisionSwingBars, 1,
                              g_lastSwingHigh, swingTime, swingShift);
   bool lowReady = FindSwing(InpDecisionTimeframe, false,
                             InpDecisionSwingBars, 1,
                             g_lastSwingLow, swingTime, swingShift);
   bool previousLowReady = FindSwing(InpDecisionTimeframe, false,
                                     InpDecisionSwingBars, 2,
                                     g_previousSwingLow,
                                     previousLowTime, previousLowShift);
   bool previousHighReady = FindSwing(InpDecisionTimeframe, true,
                                      InpDecisionSwingBars, 2,
                                      g_previousSwingHigh,
                                      previousHighTime, previousHighShift);
   if(!highReady || !lowReady)
     {
      g_onDataGate = false;
      g_dataBlockReason = !highReady && !lowReady
                          ? "M15_SWINGS_NOT_READY"
                          : (!highReady ? "M15_SWING_HIGH_NOT_READY"
                                        : "M15_SWING_LOW_NOT_READY");
      g_operationalBlockReason = "NOT_EVALUATED_DATA_BLOCK";
      g_policyState = SMC_STATE_DATA_ERROR;
      AuditEvent("DATA_ERROR", "STRUCTURE_NOT_READY");
      return;
     }
   g_dataBlockReason = "READY";

   string operationalBlock = OperationalBlockReason(decisionTime);
   g_onOperationalGate = operationalBlock == "";
   g_offOperational = InpSystemReadinessAffectsCycle &&
                      operationalBlock != "";
   g_operationalBlockReason = operationalBlock == ""
                              ? "READY" : operationalBlock;
   if(operationalBlock != g_previousOperationalBlock)
     {
      AuditEvent(operationalBlock == "" ? "OPERATIONAL_BLOCK_CLEARED" :
                 "OPERATIONAL_BLOCK_ENTERED",
                 operationalBlock == "" ? g_previousOperationalBlock :
                 operationalBlock);
      g_previousOperationalBlock = operationalBlock;
     }

   double breakBuffer = g_lastATR * InpBreakToleranceATR;
   bool sellSideSweep = bar.low < g_lastSwingLow &&
                        bar.close > g_lastSwingLow;
   bool buySideSweep = bar.high > g_lastSwingHigh &&
                       bar.close < g_lastSwingHigh;
   bool acceptedBullBreak = previousBar.close <= g_lastSwingHigh + breakBuffer &&
                            bar.close > g_lastSwingHigh + breakBuffer;
   bool acceptedBearBreak = previousBar.close >= g_lastSwingLow - breakBuffer &&
                            bar.close < g_lastSwingLow - breakBuffer;
   bool bullishDisplacement = bar.close > bar.open &&
                              g_lastBodyATR >= InpBullDisplacementBodyATR &&
                              g_lastCloseLocation >= InpBullMinCloseLocation;
   bool bearishDisplacement = bar.close < bar.open &&
                              g_lastBodyATR >= InpBearDisplacementBodyATR &&
                              g_lastCloseLocation <= InpBearMaxCloseLocation;
   bool bullishFVG = bar.low > twoBarsAgo.high +
                     g_lastATR * InpMinFVGATR;
   bool bearishFVG = bar.high < twoBarsAgo.low -
                     g_lastATR * InpMinFVGATR;
   bool hardBearishBreak = acceptedBearBreak && bearishDisplacement;
   bool continuationHL = previousLowReady &&
                          g_lastSwingLow > g_previousSwingLow + breakBuffer;
   if(previousHighReady && previousLowReady)
     {
      bool higherHigh = g_lastSwingHigh > g_previousSwingHigh + breakBuffer;
      bool lowerHigh = g_lastSwingHigh < g_previousSwingHigh - breakBuffer;
      bool higherLow = g_lastSwingLow > g_previousSwingLow + breakBuffer;
      bool lowerLow = g_lastSwingLow < g_previousSwingLow - breakBuffer;
      if(higherHigh && higherLow) g_m15StructureWatchout = "BULLISH HH+HL";
      else if(lowerHigh && lowerLow) g_m15StructureWatchout = "BEARISH LH+LL";
      else g_m15StructureWatchout = "MIXED/RANGE";
     }
   else
      g_m15StructureWatchout = "UNKNOWN";

   // Resolve old gaps before registering FVGs created by this closed candle.
   // A bear-FVG ON event therefore always refers to a prior bearish zone.
   ProcessLatestBuySideFVGFill(bar, decisionTime);
   ProcessActiveBearFVGFills(bar, decisionTime);

   if(sellSideSweep)
     {
      g_sslSweepOnEvent = true;
      g_lastSSLSweepTime = decisionTime;
      g_lastSSLSweepLow = bar.low;
      CreateEventMarker("SSL SWEEP", decisionTime,
                        bar.low - g_lastATR * 0.12, true,
                        "sell-side liquidity swept and close re-entered",
                        InpLabelSSLSweep);
      AuditEvent("BULLISH_SSL_SWEEP", "PRE_EXISTING_SWING_LOW_SWEPT");
     }
   if(buySideSweep)
     {
      CreateEventMarker("BSL SWEEP", decisionTime,
                        bar.high + g_lastATR * 0.12, false,
                        "buy-side liquidity swept and close rejected",
                        InpLabelBSLSweep);
      AuditEvent("BEARISH_BSL_SWEEP", "PRE_EXISTING_SWING_HIGH_SWEPT");
     }
   if(acceptedBullBreak && bullishDisplacement)
     {
      CreateEventMarker("BULL DISP", decisionTime,
                        bar.low - g_lastATR * 0.15, true,
                        "bullish displacement accepted above swing high",
                        InpLabelBullDisplacement);
      AuditEvent("BULLISH_DISPLACEMENT_BREAK",
                 "CLOSE_ABOVE_SWING_HIGH");
     }
   if(bullishFVG)
     {
      AuditEvent("BULLISH_FVG_CREATED", "THREE_CANDLE_GAP");
      AddLatestBuySideFVG(decisionTime, bar.low, twoBarsAgo.high);
     }
   if(hardBearishBreak)
     {
      CreateEventMarker("BEAR BREAK", decisionTime,
                        bar.high + g_lastATR * 0.15, false,
                        "bearish displacement accepted below swing low",
                        InpLabelBearBreak);
      AuditEvent("BEARISH_DISPLACEMENT_BREAK", "CLOSE_BELOW_SWING_LOW");
     }
   if(bearishFVG)
     {
      AuditEvent("BEARISH_FVG_CREATED", "THREE_CANDLE_GAP");
      AddActiveBearFVG(decisionTime, twoBarsAgo.low, bar.high);
     }

   int elapsedSweepBars = g_lastSSLSweepTime > 0
                          ? (int)((decisionTime - g_lastSSLSweepTime) /
                                  PeriodSeconds(InpDecisionTimeframe))
                          : 999999;
   bool recentSSLSweep = elapsedSweepBars >= 0 &&
                         elapsedSweepBars <= InpLiquidityMemoryBars;
   bool pathPass = SetupPathPass(continuationHL, recentSSLSweep);
   g_watchoutContinuationHL = continuationHL;
   g_watchoutRecentSSLSweep = recentSSLSweep;
   g_watchoutBullBreak = acceptedBullBreak;
   g_watchoutBullDisplacement = bullishDisplacement;
   if(g_processingHistory)
     {
      g_historyBarsProcessed++;
      if(g_context == SMC_CONTEXT_BULLISH) g_historyBullContextBars++;
      if(pathPass) g_historyLocationPassBars++;
      if(acceptedBullBreak && bullishDisplacement)
         g_historyBullBreakBars++;
      if(bullishFVG) g_historyBullFVGBars++;
      if(pathPass && acceptedBullBreak && bullishDisplacement && bullishFVG)
         g_historyCorePassBars++;
     }
   bool setupLatched = g_setupCreatedTime > 0;
   double latchedEntry = (g_setupFVGTop + g_setupFVGBottom) * 0.5;
   // M30 context is telemetry/watchout only. It never grants or vetoes cycle.
   g_contextBullishWatchout = g_context == SMC_CONTEXT_BULLISH;
   g_onBuySideFVGGate = g_buySideFVGActive;
   g_onLocationGate = setupLatched || pathPass;
   g_onBreakGate = setupLatched || acceptedBullBreak;
   g_onDisplacementGate = setupLatched || bullishDisplacement;
   g_onFVGGate = setupLatched || bullishFVG;
   g_onTargetGate = setupLatched &&
                    (!InpRequireTarget ||
                     (g_setupTarget > latchedEntry &&
                      g_setupResearchRR >= InpMinResearchRR));
   g_eventBreak = g_onBreakGate;
   g_eventDisplacement = g_onDisplacementGate;
   g_eventFVG = g_onFVGGate;
   g_eventTouch = setupLatched && g_setupTouched;
   g_eventReclaim = g_policyState == SMC_STATE_ENTRY_WINDOW;
   if(InpOnTriggerMode == SMC_ON_BEAR_FVG_FILL_OR_SSL_SWEEP)
      g_eventOnTrigger = g_latestBearFVGFillEvent || g_sslSweepOnEvent;
   g_onRetestGate = g_eventReclaim;
   // Historical zones model policy permission, not today's position inventory.
   g_onFlatGate = g_processingHistory || g_ccbsnPositionCount == 0;
   g_offCausalLow = InpOffOnCausalLow && setupLatched &&
                    bar.close < g_setupCausalLow;
   g_offBearBreak = InpOffOnBearishBreak && hardBearishBreak;
   g_offBSLSweep = InpOffOnBuySideSweep && buySideSweep;
   g_offBearFVG = InpOffOnBearishFVG && bearishFVG;
   g_offFVGInvalid = setupLatched &&
                     g_policyState == SMC_STATE_WAIT_RETEST &&
                     bar.low <= g_setupFVGBottom;
   g_offTarget = InpOffOnTargetReached && setupLatched &&
                 g_setupTarget > 0.0 &&
                  bar.high >= g_setupTarget;

   if(g_zoneStartTime > 0)
     {
      g_zoneHigh = MathMax(g_zoneHigh, bar.high);
      g_zoneLow = MathMin(g_zoneLow, bar.low);
      UpdateTradingZone(decisionTime);
     }

   if(g_policyState == SMC_STATE_RISK_LOCK)
     {
      if(hardBearishBreak)
        {
         g_riskLockRemaining = InpRiskLockBars;
         AuditEvent("BEARISH_RISK_LOCK_REFRESHED", "NEW_BEAR_BREAK");
         return;
        }
      if(g_riskLockRemaining > 0) g_riskLockRemaining--;
      if(g_riskLockRemaining <= 0)
        {
         g_policyState = SMC_STATE_BLOCKED;
         AuditEvent("RISK_LOCK_CLEARED", "WAIT_FOR_NEW_SETUP");
        }
      return;
     }

   if(g_policyState == SMC_STATE_DATA_ERROR)
     {
      g_policyState = SMC_STATE_BLOCKED;
      AuditEvent("DATA_RECOVERED", "STRUCTURE_AND_ATR_READY");
     }

   if(g_policyState == SMC_STATE_WAIT_RETEST)
     {
      g_setupBars++;
      UpdateSetupZone(decisionTime, false,
                      g_setupTouched ? "TOUCHED" : "WAIT_RETEST");
      if(g_offOperational)
        {
         CancelSetup(decisionTime, operationalBlock, false);
         return;
        }
      if(g_offCausalLow)
        {
         CancelSetup(decisionTime, "CAUSAL_LOW_INVALIDATED", true);
         return;
        }
      if(g_offBearBreak)
        {
         CancelSetup(decisionTime, "BEARISH_DISPLACEMENT_BREAK", true);
         return;
        }
      if(g_offBSLSweep)
        {
         CancelSetup(decisionTime, "BUY_SIDE_SWEEP_REJECTION", false);
         return;
        }
      if(g_offBearFVG)
        {
         CancelSetup(decisionTime, "BEARISH_FVG_CREATED", false);
         return;
        }
      if(g_offFVGInvalid)
        {
         CancelSetup(decisionTime, "BULLISH_FVG_FULLY_FILLED", false);
         return;
        }
      if(g_offTarget)
        {
         CancelSetup(decisionTime, "TARGET_LIQUIDITY_REACHED", false);
         return;
        }
      if(g_setupBars > InpSetupExpiryBars)
        {
         g_offTimeout = true;
         CancelSetup(decisionTime, "SETUP_EXPIRED", false);
         return;
        }

      bool touched = bar.low <= g_setupFVGTop &&
                     bar.high >= g_setupFVGBottom;
      if(touched && !g_setupTouched)
        {
         g_setupTouched = true;
         g_eventTouch = true;
         if(g_processingHistory) g_historyTouches++;
         CreateEventMarker("FVG TOUCH", decisionTime,
                           bar.low - g_lastATR * 0.08, true,
                           "first interaction with causal bullish FVG",
                           InpLabelFVGTouch);
         AuditEvent("BULLISH_FVG_TOUCHED", "WAIT_RECLAIM");
        }
      double reclaimLevel = InpRequireFullFVGReclaim
                            ? g_setupFVGTop
                            : (g_setupFVGTop + g_setupFVGBottom) * 0.5;
      bool reclaimed = g_setupTouched && bar.close > reclaimLevel &&
                       bar.close > bar.open &&
                       g_lastCloseLocation >= InpRetestMinCloseLocation;
      g_onRetestGate = reclaimed;
      g_eventTouch = g_setupTouched;
      g_eventReclaim = reclaimed;
      g_eventOnTrigger = InpOnTriggerMode == SMC_ON_BULL_FVG_RECLAIM &&
                         reclaimed;
      if(g_processingHistory && reclaimed) g_historyReclaims++;
      if(OnTriggerReady())
        {
         CreateEventMarker("ON TRIGGER", decisionTime,
                           bar.low - g_lastATR * 0.24, true,
                           "system readiness PASS; reclaim event fired",
                           InpLabelOnTrigger);
         AuditEvent("BULLISH_ON_TRIGGER",
                    "SYSTEM_READY_EVENT_RECLAIM");
         EnterEntryWindow(bar, decisionTime);
        }
      else if(g_eventOnTrigger)
         AuditEvent("BULLISH_ON_TRIGGER_BLOCKED",
                    "SYSTEM_OR_EVENT_CHECKLIST_BLOCK");
      return;
     }

   if(g_policyState == SMC_STATE_ENTRY_WINDOW)
     {
      g_entryWindowBars++;
      if(g_offOperational)
        {
         CancelSetup(decisionTime, operationalBlock, false);
         return;
        }
      if(g_offCausalLow)
        {
         CancelSetup(decisionTime, "CAUSAL_LOW_INVALIDATED", true);
         return;
        }
      if(g_offBearBreak)
        {
         CancelSetup(decisionTime, "BEARISH_DISPLACEMENT_BREAK", true);
         return;
        }
      if(g_offBSLSweep)
        {
         CancelSetup(decisionTime, "BUY_SIDE_SWEEP_REJECTION", false);
         return;
        }
      if(g_offBearFVG)
        {
         CancelSetup(decisionTime, "BEARISH_FVG_CREATED", false);
         return;
        }
      if(g_offFVGInvalid)
        {
         CancelSetup(decisionTime, "BULLISH_FVG_FULLY_FILLED", false);
         return;
        }
      if(g_offTarget)
        {
         CancelSetup(decisionTime, "TARGET_LIQUIDITY_REACHED", false);
         return;
        }
      if(g_entryWindowBars >= InpEntryWindowBars)
        {
         g_offTimeout = true;
         CancelSetup(decisionTime, "ENTRY_WINDOW_EXPIRED", false);
         return;
        }
      return;
     }

   if(g_offBearBreak)
     {
      EnterRiskLock(decisionTime, "BEARISH_DISPLACEMENT_BREAK");
      return;
     }

   if(InpOnTriggerMode == SMC_ON_BEAR_FVG_FILL_OR_SSL_SWEEP &&
      g_eventOnTrigger)
     {
      bool transportReady = InpControlMode == SMC_VISUAL_ONLY ||
                            g_controlState == SMC_CONTROL_OFF_CONFIRMED;
      bool offVetoClear = !g_offBSLSweep && !g_offBearFVG;
      if(OnTriggerReady() && transportReady && offVetoClear)
         EnterDirectEventWindow(bar, decisionTime);
      else
         AuditEvent(g_sslSweepOnEvent
                    ? "SSL_SWEEP_ON_TRIGGER_BLOCKED"
                    : "LATEST_BEAR_FVG_FILL_ON_TRIGGER_BLOCKED",
                    !offVetoClear
                    ? "OFF_VETO_HAS_PRIORITY"
                    : (transportReady
                       ? "SYSTEM_READINESS_BLOCK"
                       : "CONTROL_NOT_OFF_CONFIRMED"));
      return;
     }
   if(g_offOperational || !g_onFlatGate) return;
   // A live controller may evaluate a new setup only after the previous OFF
   // command is acknowledged. This prevents setup overlap during transport lag.
   if(InpControlMode == SMC_CONTROL_ENABLED &&
      g_controlState != SMC_CONTROL_OFF_CONFIRMED) return;
   bool setupCore = SetupEventChecklistPass();
   if(!setupCore) return;

   double target = FindTargetAbove(bar.close);
   double causalLow = recentSSLSweep && g_lastSSLSweepLow > 0.0
                      ? g_lastSSLSweepLow : g_lastSwingLow;
   double entryReference = (bar.low + twoBarsAgo.high) * 0.5;
   double risk = entryReference - causalLow;
   double reward = target > entryReference ? target - entryReference : 0.0;
   double researchRR = risk > 0.0 ? reward / risk : 0.0;
   g_onTargetGate = !InpRequireTarget ||
                    (target > entryReference &&
                     researchRR >= InpMinResearchRR);
   if(g_processingHistory && g_onTargetGate) g_historyTargetPassBars++;
   if(InpRequireTarget && target <= entryReference)
     {
      AuditEvent("BULLISH_SETUP_REJECTED", "NO_TARGET_ABOVE");
      return;
     }
   if(InpRequireTarget && researchRR < InpMinResearchRR)
     {
      AuditEvent("BULLISH_SETUP_REJECTED",
                 "RESEARCH_RR=" + DoubleToString(researchRR, 2));
      return;
     }
   CreateBullishSetup(bar, twoBarsAgo, decisionTime,
                      continuationHL, recentSSLSweep);
  }

void ResetPolicyRuntimeForHistory()
  {
   g_policyState = SMC_STATE_BLOCKED;
   g_context = SMC_CONTEXT_UNKNOWN;
   g_lastDecisionTime = 0;
   g_lastSSLSweepTime = 0;
   g_lastSSLSweepLow = 0.0;
   g_riskLockRemaining = 0;
   g_lastDataErrorBar = 0;
   g_previousOperationalBlock = "";
   g_zoneStartTime = 0;
   g_zoneEndTime = 0;
   g_zoneHigh = 0.0;
   g_zoneLow = 0.0;
   g_zoneSetupId = "NONE";
   g_zoneOffReason = "ACTIVE";
   g_tradingZoneObject = "";
   g_tradingZoneConfirmed = false;
   ResetSetupRuntime();
   ResetGateSnapshot();
   ArrayResize(g_activeBearFVGs, 0);
   ArrayResize(g_activeBuySideFVGs, 0);
   g_buySideFVGActive = false;
   g_latestBuySideFVG.createdTime = 0;
   g_latestBuySideFVG.top = 0.0;
   g_latestBuySideFVG.bottom = 0.0;
   g_latestBuySideFVG.objectName = "";
   g_latestBearFVGFillEvent = false;
   g_sslSweepOnEvent = false;
   g_filledBearFVGCreatedTime = 0;
   g_filledBearFVGTop = 0.0;
   g_filledBearFVGBottom = 0.0;
   ArrayResize(g_closedZoneObjectNames, 0);
   ArrayResize(g_eventObjectNames, 0);
   g_historyBarsProcessed = 0;
   g_historyBullContextBars = 0;
   g_historyLocationPassBars = 0;
   g_historyBullBreakBars = 0;
   g_historyBullFVGBars = 0;
   g_historyCorePassBars = 0;
   g_historyTargetPassBars = 0;
   g_historySetups = 0;
   g_historyEntryWindows = 0;
   g_historyZonesClosed = 0;
   g_historyTouches = 0;
   g_historyReclaims = 0;
   g_historyCancelOperational = 0;
   g_historyCancelLow = 0;
   g_historyCancelBearBreak = 0;
   g_historyCancelBSL = 0;
   g_historyCancelBearFVG = 0;
   g_historyCancelFill = 0;
   g_historyCancelTarget = 0;
   g_historyCancelTimeout = 0;
  }

bool BuildHistoricalZones()
  {
   if(g_atrHandle == INVALID_HANDLE) return false;
   ObjectsDeleteAll(0, g_objectPrefix);
   g_processingHistory = true;
   g_historicalShift = 0;
   g_tradingZoneHistoryCutoff = 0;
   ResetPolicyRuntimeForHistory();

   int warmup = MathMax(InpHistoryBars, InpATRPeriod + 5);
   int featurePadding = InpSwingSearchBars +
                        MathMax(InpContextSwingBars,
                                InpDecisionSwingBars) * 2 + 10;
   int requested = InpTradingZoneHistoryBars + warmup +
                   featurePadding + 5;
   MqlRates rates[];
   double atrValues[];
   ArraySetAsSeries(rates, true);
   ArraySetAsSeries(atrValues, true);
   int ratesCopied = CopyRates(_Symbol, InpDecisionTimeframe, 0,
                               requested, rates);
   int atrCopied = CopyBuffer(g_atrHandle, 0, 0, requested, atrValues);
   int available = MathMin(ratesCopied, atrCopied);
   int minimum = MathMax(InpATRPeriod + 5, InpDecisionSwingBars * 2 + 6);
   if(available < minimum)
     {
      g_processingHistory = false;
      g_policyState = SMC_STATE_DATA_ERROR;
      g_lastReason = "HISTORY_DATA_NOT_READY";
      PrintFormat("SMC HISTORY WAIT | required=%d available=%d",
                  minimum, available);
      return false;
     }

   if(InpDrawTradingZoneHistory)
     {
      int cutoffIndex = MathMin(InpTradingZoneHistoryBars - 1,
                                available - 1);
      g_tradingZoneHistoryCutoff = rates[cutoffIndex].time;
     }

   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   // Keep an older, unprocessed tail so the first reconstructed decision can
   // query confirmed swings without falling off the copied series.
   int oldestShift = MathMax(1, available - featurePadding - 3);
   for(int shift = oldestShift; shift >= 1; shift--)
     {
      if(!MathIsValidNumber(atrValues[shift]) || atrValues[shift] <= 0.0)
         continue;
      g_historicalShift = shift;
      MqlRates bar = rates[shift];
      MqlRates twoBarsAgo = rates[shift + 2];
      g_lastATR = atrValues[shift];
      g_lastClose = bar.close;
      double range = bar.high - bar.low;
      g_lastCloseLocation = range > 0.0
                            ? (bar.close - bar.low) / range : 0.5;
      g_lastBodyATR = MathAbs(bar.close - bar.open) / g_lastATR;
      g_lastSpreadATR = point > 0.0
                        ? bar.spread * point / g_lastATR : 0.0;
      datetime decisionTime = rates[shift - 1].time;
      ProcessDecisionBar(bar, twoBarsAgo, decisionTime);
     }

   g_historicalShift = 0;
   g_processingHistory = false;
   g_onFlatGate = g_ccbsnPositionCount == 0;
   g_currentOpenBarTime = rates[0].time;
   if(g_zoneStartTime > 0) UpdateTradingZone(rates[0].time);
   UpdateActiveBearFVGZones(rates[0].time);
   UpdateLatestBuySideFVG(rates[0].time);
   if(g_setupCreatedTime > 0 && !g_setupFromDirectEvent)
      UpdateSetupZone(rates[0].time, false,
                      PolicyStateToString(g_policyState));

   // Integrated control remains fail-closed after a visual replay. Historical
   // permission must never become a live New Cycle command on startup.
   if(InpControlMode == SMC_CONTROL_ENABLED)
     {
      if(g_zoneStartTime > 0 && ObjectFind(0, g_tradingZoneObject) >= 0)
         ObjectDelete(0, g_tradingZoneObject);
      g_zoneStartTime = 0;
      g_tradingZoneObject = "";
      g_tradingZoneConfirmed = false;
      ResetSetupRuntime();
      g_policyState = SMC_STATE_BLOCKED;
     }
   ChartRedraw();
   PrintFormat("SMC HISTORY READY | bars=%d cutoff=%s zones=%d",
               available,
               TimeToString(g_tradingZoneHistoryCutoff,
                            TIME_DATE | TIME_MINUTES),
               ArraySize(g_closedZoneObjectNames));
   PrintFormat("SMC HISTORY CONFIG | decision_tf=%s seconds=%d context_tf=%s history_bars=%d",
               EnumToString(InpDecisionTimeframe),
               PeriodSeconds(InpDecisionTimeframe),
               EnumToString(InpContextTimeframe),
               InpTradingZoneHistoryBars);
   PrintFormat("SMC HISTORY OBJECTS | event_markers=%d chart_objects=%d setup_history=%s events_history=%s",
               ArraySize(g_eventObjectNames), ObjectsTotal(0),
               InpDrawHistoricalSetupZones ? "true" : "false",
               InpDrawHistoricalEventMarkers ? "true" : "false");
   PrintFormat("SMC BEAR FVG STATE | active=%d max=%d mode=%s",
               ArraySize(g_activeBearFVGs), InpMaxActiveBearFVGZones,
               OnTriggerModeToString(InpOnTriggerMode));
   PrintFormat("SMC BUY SIDE FVG STATE | active=%s tracked=%d age=%d/%d created=%s range=%s..%s",
               g_buySideFVGActive ? "true" : "false",
               ArraySize(g_activeBuySideFVGs),
               BuySideFVGAgeBars(g_latestBuySideFVG.createdTime,
                                 rates[0].time),
               InpBuySideFVGMaxAgeBars,
               TimeToString(g_latestBuySideFVG.createdTime,
                            TIME_DATE | TIME_MINUTES),
               FormatPrice(g_latestBuySideFVG.bottom),
               FormatPrice(g_latestBuySideFVG.top));
   PrintFormat("SMC HISTORY FUNNEL | processed=%d bull_ctx=%d location=%d bull_break=%d bull_fvg=%d core=%d target=%d setups=%d entries=%d closed=%d",
               g_historyBarsProcessed, g_historyBullContextBars,
               g_historyLocationPassBars, g_historyBullBreakBars,
               g_historyBullFVGBars, g_historyCorePassBars,
               g_historyTargetPassBars, g_historySetups,
               g_historyEntryWindows, g_historyZonesClosed);
   PrintFormat("SMC HISTORY RETEST | touches=%d reclaims=%d | cancel ops=%d low=%d break=%d bsl=%d bfvg=%d fill=%d target=%d timeout=%d",
               g_historyTouches, g_historyReclaims,
               g_historyCancelOperational, g_historyCancelLow,
               g_historyCancelBearBreak,
               g_historyCancelBSL, g_historyCancelBearFVG,
               g_historyCancelFill, g_historyCancelTarget,
               g_historyCancelTimeout);
   return true;
  }

bool ProcessLatestClosedBar()
  {
   datetime currentOpen = iTime(_Symbol, InpDecisionTimeframe, 0);
   if(currentOpen <= 0 || currentOpen == g_currentOpenBarTime) return false;
   int decisionSeconds = PeriodSeconds(InpDecisionTimeframe);
   if(g_currentOpenBarTime > 0 &&
      currentOpen - g_currentOpenBarTime != decisionSeconds)
     {
      PrintFormat("SMC DATA RECONCILE | sequence gap=%d sec; rebuilding history",
                  (int)(currentOpen - g_currentOpenBarTime));
      return BuildHistoricalZones();
     }

   MqlRates bar, twoBarsAgo;
   datetime decisionTime = 0;
   if(!LoadDecisionFeatures(bar, twoBarsAgo, decisionTime))
     {
      ResetGateSnapshot();
      g_onDataGate = false;
      g_operationalBlockReason = "NOT_EVALUATED_DATA_BLOCK";
      if(g_lastDataErrorBar != currentOpen)
        {
         g_lastDataErrorBar = currentOpen;
         g_lastDecisionTime = currentOpen;
         if(g_policyState == SMC_STATE_WAIT_RETEST ||
            g_policyState == SMC_STATE_ENTRY_WINDOW)
            CancelSetup(currentOpen, "M15_DATA_NOT_READY", false);
         else
           {
            g_policyState = SMC_STATE_DATA_ERROR;
            AuditEvent("DATA_ERROR", "M15_DATA_NOT_READY");
           }
        }
      return false;
     }

   g_lastDataErrorBar = 0;
   g_currentOpenBarTime = currentOpen;
   ProcessDecisionBar(bar, twoBarsAgo, decisionTime);
   return true;
  }

string ControllerLockKey(const string suffix)
  {
   return "CCBSN.NC.LOCK." +
          IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN)) + "." +
          _Symbol + "." + IntegerToString((long)InpCCBSNMagic) + "." +
          suffix;
  }

bool AcquireControllerLock()
  {
   if(InpControlMode == SMC_VISUAL_ONLY) return true;
   ulong rawChart = (ulong)ChartID();
   ulong rawTick = GetTickCount64();
   ulong exactToken = (rawChart % 9000000000) * 1000000 +
                      (rawTick % 1000000);
   if(exactToken == 0) exactToken = 1;
   g_instanceToken = (double)exactToken;

   string ownerKey = ControllerLockKey("OWNER");
   string heartbeatKey = ControllerLockKey("HEARTBEAT");
   if(!GlobalVariableCheck(ownerKey)) GlobalVariableSet(ownerKey, 0.0);
   double currentOwner = GlobalVariableGet(ownerKey);
   datetime heartbeat = GlobalVariableCheck(heartbeatKey)
                        ? (datetime)MathRound(GlobalVariableGet(heartbeatKey))
                        : 0;
   datetime now = TimeLocal();
   if(currentOwner != 0.0 && heartbeat > 0 &&
      now - heartbeat <= InpControllerLockStaleSeconds)
     {
      g_lastControlError = "CONTROLLER_MUTEX_BUSY";
      return false;
     }
   if(!GlobalVariableSetOnCondition(ownerKey, g_instanceToken, currentOwner))
     {
      g_lastControlError = "CONTROLLER_MUTEX_ACQUIRE_FAILED";
      return false;
     }
   GlobalVariableSet(heartbeatKey, (double)now);
   GlobalVariablesFlush();
   g_controllerLockHeld = true;
   return true;
  }

void RefreshControllerLock()
  {
   if(InpControlMode != SMC_CONTROL_ENABLED || !g_controllerLockHeld) return;
   string ownerKey = ControllerLockKey("OWNER");
   if(!GlobalVariableCheck(ownerKey) ||
      GlobalVariableGet(ownerKey) != g_instanceToken)
     {
      g_controllerLockHeld = false;
      g_controlState = SMC_CONTROL_ERROR;
      g_lastControlError = "CONTROLLER_MUTEX_LOST";
      AuditEvent("CCBSN_COMMAND_ERROR", g_lastControlError);
      return;
     }
   GlobalVariableSet(ControllerLockKey("HEARTBEAT"),
                     (double)TimeLocal());
  }

void ReleaseControllerLock()
  {
   if(!g_controllerLockHeld) return;
   string ownerKey = ControllerLockKey("OWNER");
   if(GlobalVariableCheck(ownerKey) &&
      GlobalVariableSetOnCondition(ownerKey, 0.0, g_instanceToken))
      GlobalVariableSet(ControllerLockKey("HEARTBEAT"), 0.0);
   g_controllerLockHeld = false;
  }

int VolumeDigits(const double step)
  {
   int digits = 0;
   double scaled = step;
   while(digits < 8 && MathAbs(scaled - MathRound(scaled)) > 1e-8)
     {
      scaled *= 10.0;
      digits++;
     }
   return digits;
  }

double NormalizedCommandVolume()
  {
   double minimum = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double maximum = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   double step = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   if(minimum <= 0.0 || maximum < minimum || step <= 0.0) return 0.0;
   return NormalizeDouble(minimum, VolumeDigits(step));
  }

double NormalizedCommandPrice()
  {
   double tickSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   if(tickSize <= 0.0) tickSize = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   if(tickSize <= 0.0) return 0.0;
   return NormalizeDouble(MathRound(COMMAND_PRICE / tickSize) * tickSize,
                          (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS));
  }

bool ValidateCommandGeometry(const double price)
  {
   MqlTick tick;
   if(!SymbolInfoTick(_Symbol, tick) || tick.ask <= 0.0)
     {
      g_lastControlError = "NO_LIVE_SYMBOL_TICK";
      return false;
     }
   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   long stopsLevel = SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL);
   double safeDistance = MathMax((double)stopsLevel * point,
                                 100.0 * point);
   if(price <= tick.ask + safeDistance)
     {
      g_lastControlError = "COMMAND_PRICE_NOT_SAFELY_ABOVE_ASK";
      return false;
     }
   return true;
  }

bool IsControlTradeAllowed()
  {
   if(!TerminalInfoInteger(TERMINAL_CONNECTED))
     {
      g_lastControlError = "TERMINAL_NOT_CONNECTED";
      return false;
     }
   if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED))
     {
      g_lastControlError = "TERMINAL_AUTOTRADING_OFF";
      return false;
     }
   if(!MQLInfoInteger(MQL_TRADE_ALLOWED))
     {
      g_lastControlError = "EA_TRADING_NOT_ALLOWED";
      return false;
     }
   if(!AccountInfoInteger(ACCOUNT_TRADE_ALLOWED) ||
      !AccountInfoInteger(ACCOUNT_TRADE_EXPERT))
     {
      g_lastControlError = "ACCOUNT_EXPERT_TRADING_BLOCKED";
      return false;
     }
   return true;
  }

bool IsRetryableEnvironmentError()
  {
   return g_lastControlError == "TERMINAL_NOT_CONNECTED" ||
          g_lastControlError == "TERMINAL_AUTOTRADING_OFF" ||
          g_lastControlError == "EA_TRADING_NOT_ALLOWED" ||
          g_lastControlError == "ACCOUNT_EXPERT_TRADING_BLOCKED";
  }

bool IsAnyControllerComment(const string comment)
  {
   return StringFind(comment, "SMC_CTRL:") == 0 ||
          StringFind(comment, "CCBSN_LITE:") == 0 ||
          StringFind(comment, "CCBSN_CTRL:") == 0;
  }

ENUM_SMC_COMMAND SelectedOrderCommand()
  {
   ENUM_ORDER_TYPE type = (ENUM_ORDER_TYPE)OrderGetInteger(ORDER_TYPE);
   if(type == ORDER_TYPE_SELL_LIMIT) return SMC_COMMAND_NEW_CYCLE_ON;
   if(type == ORDER_TYPE_BUY_STOP) return SMC_COMMAND_NEW_CYCLE_OFF;
   return SMC_COMMAND_NONE;
  }

void ClearPendingCommand()
  {
   g_commandTicket = 0;
   g_commandSentTime = 0;
   g_pendingCommand = SMC_COMMAND_NONE;
   g_commandCancelRequested = false;
  }

void SetControlError(const string reason)
  {
   g_controlState = SMC_CONTROL_ERROR;
   g_lastControlError = reason;
   AuditEvent("CCBSN_COMMAND_ERROR", reason);
   Print("SMC CONTROL ERROR | " + reason);
  }

bool RecoverPendingControllerOrder()
  {
   int matches = 0;
   int ownMatches = 0;
   ulong recoveredTicket = 0;
   datetime recoveredTime = 0;
   ENUM_SMC_COMMAND recoveredCommand = SMC_COMMAND_NONE;
   for(int index = OrdersTotal() - 1; index >= 0; index--)
     {
      ulong ticket = OrderGetTicket(index);
      if(ticket == 0 || OrderGetString(ORDER_SYMBOL) != _Symbol ||
         !IsAnyControllerComment(OrderGetString(ORDER_COMMENT))) continue;
      matches++;
      if((ulong)OrderGetInteger(ORDER_MAGIC) == InpControllerMagic &&
         StringFind(OrderGetString(ORDER_COMMENT), "SMC_CTRL:") == 0)
        {
         ownMatches++;
         recoveredTicket = ticket;
         recoveredTime = (datetime)OrderGetInteger(ORDER_TIME_SETUP);
         recoveredCommand = SelectedOrderCommand();
        }
     }
   if(matches > 1)
     {
      SetControlError("MULTIPLE_CONTROLLER_COMMANDS_FOUND");
      return false;
     }
   if(matches == 1 && ownMatches == 0)
     {
      SetControlError("FOREIGN_CONTROLLER_COMMAND_FOUND");
      return false;
     }
   if(ownMatches == 1 && recoveredCommand != SMC_COMMAND_NONE)
     {
      g_commandTicket = recoveredTicket;
      g_commandSentTime = recoveredTime;
      g_pendingCommand = recoveredCommand;
      g_controlState = recoveredCommand == SMC_COMMAND_NEW_CYCLE_ON
                       ? SMC_CONTROL_ON_PENDING
                       : SMC_CONTROL_OFF_PENDING;
      AuditEvent("CCBSN_COMMAND_RECOVERED",
                 CommandToString(recoveredCommand));
     }
   return true;
  }

void MarkCommandConfirmed(const ENUM_SMC_COMMAND command)
  {
   g_controlState = command == SMC_COMMAND_NEW_CYCLE_ON
                    ? SMC_CONTROL_ON_CONFIRMED
                    : SMC_CONTROL_OFF_CONFIRMED;
   g_lastControlError = "NONE";
   AuditEvent(command == SMC_COMMAND_NEW_CYCLE_ON
              ? "CCBSN_ON_CONFIRMED" : "CCBSN_OFF_CONFIRMED",
              "COMMAND_ORDER_CONSUMED");
   if(command == SMC_COMMAND_NEW_CYCLE_ON)
     {
      if(g_policyState == SMC_STATE_ENTRY_WINDOW && !g_setupConsumed)
         StartTradingZone(TimeCurrent(), g_lastClose, true);
      else
         AuditEvent("STALE_ON_ACK_REQUIRES_OFF",
                    "POLICY_NO_LONGER_ALLOWS_NEW_CYCLE");
     }
   else
      CloseTradingZone(TimeCurrent(), "NEW_CYCLE_OFF_CONFIRMED");
  }

void ReconcilePendingCommand()
  {
   if(g_commandTicket == 0 || g_pendingCommand == SMC_COMMAND_NONE) return;
   if(OrderSelect(g_commandTicket))
     {
      if(TimeCurrent() - g_commandSentTime < InpCommandTimeoutSeconds) return;
      g_commandCancelRequested = true;
      bool deleted = g_trade.OrderDelete(g_commandTicket);
      uint retcode = g_trade.ResultRetcode();
      bool stillActive = OrderSelect(g_commandTicket);
      if(!deleted || retcode != TRADE_RETCODE_DONE || stillActive)
        {
         SetControlError("COMMAND_TIMEOUT_ORDER_LEFT_ACTIVE");
         return;
        }
      ClearPendingCommand();
      SetControlError("COMMAND_CONSUMPTION_TIMEOUT_SELF_CANCELED");
      return;
     }
   if(!HistoryOrderSelect(g_commandTicket))
     {
      if(TimeCurrent() - g_commandSentTime >= InpCommandTimeoutSeconds)
        {
         ClearPendingCommand();
         SetControlError("COMMAND_MISSING_FROM_ORDER_AND_HISTORY");
        }
      return;
     }
   ENUM_ORDER_STATE orderState =
      (ENUM_ORDER_STATE)HistoryOrderGetInteger(g_commandTicket, ORDER_STATE);
   ENUM_SMC_COMMAND completedCommand = g_pendingCommand;
   bool selfCanceled = g_commandCancelRequested;
   if(orderState == ORDER_STATE_CANCELED && !selfCanceled)
     {
      ClearPendingCommand();
      MarkCommandConfirmed(completedCommand);
      return;
     }
   if(orderState == ORDER_STATE_CANCELED && selfCanceled)
     {
      ClearPendingCommand();
      g_controlState = SMC_CONTROL_UNKNOWN;
      return;
     }
   if(orderState == ORDER_STATE_FILLED || orderState == ORDER_STATE_PARTIAL)
     {
      ClearPendingCommand();
      SetControlError("COMMAND_ORDER_EXECUTED");
      Alert("SMC Controller: command order executed. Check account immediately.");
      return;
     }
   ClearPendingCommand();
   SetControlError("UNEXPECTED_COMMAND_HISTORY_STATE:" + EnumToString(orderState));
  }

bool IsConfirmedForCommand(const ENUM_SMC_COMMAND command)
  {
   if(command == SMC_COMMAND_NEW_CYCLE_ON)
      return g_controlState == SMC_CONTROL_ON_CONFIRMED;
   if(command == SMC_COMMAND_NEW_CYCLE_OFF)
      return g_controlState == SMC_CONTROL_OFF_CONFIRMED;
   return false;
  }

bool SendCCBSNCommand(const ENUM_SMC_COMMAND command)
  {
   if(command == SMC_COMMAND_NONE) return false;
   if(!IsControlTradeAllowed())
     {
      g_controlState = SMC_CONTROL_ERROR;
      AuditEvent("CCBSN_COMMAND_ERROR", g_lastControlError);
      return false;
     }
   double price = NormalizedCommandPrice();
   double volume = NormalizedCommandVolume();
   if(price <= 0.0 || volume <= 0.0 || !ValidateCommandGeometry(price))
     {
      SetControlError(g_lastControlError == "NONE"
                      ? "INVALID_COMMAND_PRICE_OR_VOLUME"
                      : g_lastControlError);
      return false;
     }
   string action = command == SMC_COMMAND_NEW_CYCLE_ON ? "ON" : "OFF";
   string comment = "SMC_CTRL:" + action + ":" +
                    IntegerToString((long)TimeCurrent());
   ResetLastError();
   bool requestOk = command == SMC_COMMAND_NEW_CYCLE_ON
                    ? g_trade.SellLimit(volume, price, _Symbol, 0.0, 0.0,
                                        ORDER_TIME_GTC, 0, comment)
                    : g_trade.BuyStop(volume, price, _Symbol, 0.0, 0.0,
                                      ORDER_TIME_GTC, 0, comment);
   uint retcode = g_trade.ResultRetcode();
   ulong ticket = g_trade.ResultOrder();
   if(ticket == 0)
     {
      g_controlState = SMC_CONTROL_UNKNOWN;
      g_lastControlError = "COMMAND_SEND_RETRY:" +
                           g_trade.ResultRetcodeDescription();
      g_nextCommandAttemptTick = GetTickCount64() +
                                 (ulong)InpCommandRetryMilliseconds;
      PrintFormat("SMC CONTROL RETRY | %s request=%s retcode=%u %s",
                  action, requestOk ? "true" : "false", retcode,
                  g_trade.ResultRetcodeDescription());
      return false;
     }
   g_commandTicket = ticket;
   g_commandSentTime = TimeCurrent();
   g_pendingCommand = command;
   g_commandCancelRequested = false;
   g_controlState = command == SMC_COMMAND_NEW_CYCLE_ON
                    ? SMC_CONTROL_ON_PENDING : SMC_CONTROL_OFF_PENDING;
   g_lastControlError = "WAITING_FOR_CCBSN_CONSUMPTION";
   g_nextCommandAttemptTick = 0;
   AuditEvent("CCBSN_COMMAND_SENT", CommandToString(command));
   PrintFormat("SMC CONTROL SENT | %s ticket=%I64u request=%s retcode=%u",
               action, ticket, requestOk ? "true" : "false", retcode);
   ReconcilePendingCommand();
   return true;
  }

bool SupersedePendingIfNeeded(const ENUM_SMC_COMMAND desired)
  {
   if(g_commandTicket == 0 || g_pendingCommand == SMC_COMMAND_NONE ||
      g_pendingCommand == desired) return true;
   if(!OrderSelect(g_commandTicket))
     {
      ReconcilePendingCommand();
      return g_commandTicket == 0;
     }
   g_commandCancelRequested = true;
   bool deleted = g_trade.OrderDelete(g_commandTicket);
   if(!deleted || g_trade.ResultRetcode() != TRADE_RETCODE_DONE)
     {
      SetControlError("SUPERSEDED_COMMAND_DELETE_FAILED");
      return false;
     }
   AuditEvent("CCBSN_COMMAND_SUPERSEDED",
              CommandToString(g_pendingCommand) + "->" +
              CommandToString(desired));
   ClearPendingCommand();
   g_controlState = SMC_CONTROL_UNKNOWN;
   return true;
  }

void ProcessCCBSNControl()
  {
   if(InpControlMode != SMC_CONTROL_ENABLED) return;
   if(!g_controllerLockHeld || g_controlState == SMC_CONTROL_ERROR)
     {
      if(g_controlState == SMC_CONTROL_ERROR &&
         IsRetryableEnvironmentError() && IsControlTradeAllowed())
        {
         g_controlState = SMC_CONTROL_UNKNOWN;
         g_lastControlError = "NONE";
         AuditEvent("CONTROL_ENVIRONMENT_RECOVERED", "RETRY_ALLOWED");
        }
      else return;
     }
   ReconcilePendingCommand();
   ENUM_SMC_COMMAND desired = DesiredCommand();
   if(!SupersedePendingIfNeeded(desired)) return;
   if(g_commandTicket != 0 || g_controlState == SMC_CONTROL_ERROR) return;
   if(IsConfirmedForCommand(desired)) return;
   if(g_nextCommandAttemptTick > 0 &&
      GetTickCount64() < g_nextCommandAttemptTick) return;
   SendCCBSNCommand(desired);
  }

void CancelPendingOnRemove()
  {
   if(!InpDeletePendingOnRemove || g_commandTicket == 0) return;
   if(OrderSelect(g_commandTicket) &&
      (ulong)OrderGetInteger(ORDER_MAGIC) == InpControllerMagic &&
      StringFind(OrderGetString(ORDER_COMMENT), "SMC_CTRL:") == 0)
     {
      g_commandCancelRequested = true;
      bool deleted = g_trade.OrderDelete(g_commandTicket);
      PrintFormat("SMC DEINIT | pending #%I64u delete=%s retcode=%u",
                  g_commandTicket, deleted ? "true" : "false",
                  g_trade.ResultRetcode());
     }
  }

bool ValidateInputs()
  {
   if(InpExpectedSymbolPrefix != "" &&
      StringFind(_Symbol, InpExpectedSymbolPrefix) != 0)
     {
      g_configurationError = "UNEXPECTED_SYMBOL:" + _Symbol;
      return false;
     }
   if(PeriodSeconds(InpDecisionTimeframe) <= 0 ||
      PeriodSeconds(InpContextTimeframe) < PeriodSeconds(InpDecisionTimeframe))
     {
      g_configurationError = "INVALID_TIMEFRAME_PAIR";
      return false;
     }
   if(InpATRPeriod < 2 || InpATRPeriod > 200 ||
      InpHistoryBars < 100 || InpHistoryBars > 5000)
     {
      g_configurationError = "INVALID_ATR_OR_HISTORY";
      return false;
     }
   if(InpContextSwingBars < 1 || InpContextSwingBars > 10 ||
      InpDecisionSwingBars < 1 || InpDecisionSwingBars > 10 ||
      InpSwingSearchBars < 20 || InpSwingSearchBars > InpHistoryBars)
     {
      g_configurationError = "INVALID_SWING_CONFIGURATION";
      return false;
     }
   if(InpLiquidityMemoryBars < 1 || InpLiquidityMemoryBars > 100 ||
      InpBreakToleranceATR < 0.0 || InpBreakToleranceATR > 2.0)
     {
      g_configurationError = "INVALID_LIQUIDITY_OR_BREAK_CONFIGURATION";
      return false;
     }
   if(InpBullDisplacementBodyATR <= 0.0 ||
      InpBearDisplacementBodyATR <= 0.0 ||
      InpBullMinCloseLocation < 0.5 || InpBullMinCloseLocation > 1.0 ||
      InpBearMaxCloseLocation < 0.0 || InpBearMaxCloseLocation > 0.5 ||
      InpMinFVGATR < 0.0 || InpMinFVGATR > 2.0)
     {
      g_configurationError = "INVALID_INTENT_THRESHOLDS";
      return false;
     }
   if(InpSetupExpiryBars < 1 || InpSetupExpiryBars > 200 ||
      InpEntryWindowBars < 1 || InpEntryWindowBars > 100 ||
      InpRiskLockBars < 0 || InpRiskLockBars > 1000 ||
      InpRetestMinCloseLocation < 0.0 ||
      InpRetestMinCloseLocation > 1.0 || InpMinResearchRR < 0.0)
     {
      g_configurationError = "INVALID_LIFECYCLE_CONFIGURATION";
      return false;
     }
   if(!IsValidHHMM(InpSessionStartHHMM) ||
      !IsValidHHMM(InpSessionEndHHMM) ||
      InpMaxSpreadATRRatio <= 0.0 || InpMaxTickAgeSeconds < 0)
     {
      g_configurationError = "INVALID_SESSION_OR_RUNTIME_GUARD";
      return false;
     }
   if(InpCCBSNMagic == 0 || InpControllerMagic == 0 ||
      InpCCBSNMagic == InpControllerMagic)
     {
      g_configurationError = "INVALID_OR_CONFLICTING_MAGIC";
      return false;
     }
   if(InpCommandTimeoutSeconds < 5 ||
      InpCommandRetryMilliseconds < 250 ||
      InpControllerLockStaleSeconds < 5)
     {
      g_configurationError = "INVALID_CONTROL_TIMING";
      return false;
     }
   if(InpTradingZoneHistoryBars < 1 ||
      InpTradingZoneHistoryBars > 100000 ||
      InpMaxStoredTradingZones < 1 || InpMaxStoredTradingZones > 500 ||
       InpMaxHistoricalEventMarkers < 10 ||
       InpMaxHistoricalEventMarkers > 2000 ||
       InpZoneOpacityPercent < 0 || InpZoneOpacityPercent > 100 ||
       InpMaxActiveBearFVGZones != 3 ||
       InpBearFVGOpacityPercent < 0 || InpBearFVGOpacityPercent > 100 ||
       InpBuySideFVGMaxAgeBars < 1 ||
       InpBuySideFVGMaxAgeBars > 500 ||
       InpBuySideFVGOpacityPercent < 0 ||
       InpBuySideFVGOpacityPercent > 100 ||
       InpDashboardX < 0 || InpTopDashboardY < 0 ||
       InpBottomDashboardY < 0 ||
       InpDashboardWidth < 300 || InpDashboardWidth > 900 ||
       InpTopDashboardHeight < 300 ||
       InpTopDashboardHeight > 600 ||
       InpOffDashboardHeight < 210 || InpOffDashboardHeight > 500 ||
       InpDashboardFontSize < 7 || InpDashboardFontSize > 16 ||
       InpDashboardOpacityPercent < 0 ||
       InpDashboardOpacityPercent > 100)
     {
      g_configurationError = "INVALID_HISTORY_VISUAL_CONFIGURATION";
      return false;
     }
   if(InpLabelBearFVGFill == "" || InpLabelBuySideFVG == "" ||
      InpLabelSSLSweep == "" ||
      InpLabelBSLSweep == "" || InpLabelBullDisplacement == "" ||
      InpLabelBearBreak == "" || InpLabelBullBreak == "" ||
      InpLabelBullFVG == "" || InpLabelFVGTouch == "" ||
      InpLabelOnTrigger == "" || InpLabelZoneOn == "" ||
      InpLabelZoneOff == "" || InpLabelBearLock == "" ||
      InpLabelChainStart == "")
     {
      g_configurationError = "EVENT_LABEL_MUST_NOT_BE_EMPTY";
      return false;
     }
   if(InpControlMode == SMC_CONTROL_ENABLED && InpRequireHedgingAccount &&
      (ENUM_ACCOUNT_MARGIN_MODE)AccountInfoInteger(ACCOUNT_MARGIN_MODE) !=
      ACCOUNT_MARGIN_MODE_RETAIL_HEDGING)
     {
      g_configurationError = "HEDGING_ACCOUNT_REQUIRED";
      return false;
     }
   return true;
  }

string ConfiguredVetoText(const bool enabled, const bool active)
  {
   if(!enabled) return "DISABLED";
   return active ? "OFF" : "--";
  }

bool ApplyChartTheme()
  {
   if(!InpApplyChartTheme) return true;
   bool success = true;
   if(!ChartSetInteger(0, CHART_COLOR_BACKGROUND,
                       (long)InpChartBackgroundColor)) success = false;
   if(!ChartSetInteger(0, CHART_COLOR_FOREGROUND,
                       (long)InpChartForegroundColor)) success = false;
   if(!ChartSetInteger(0, CHART_COLOR_GRID,
                       (long)InpChartGridColor)) success = false;
   if(!ChartSetInteger(0, CHART_COLOR_CHART_UP,
                       (long)InpChartBullColor)) success = false;
   if(!ChartSetInteger(0, CHART_COLOR_CHART_DOWN,
                       (long)InpChartBearColor)) success = false;
   if(!ChartSetInteger(0, CHART_COLOR_CANDLE_BULL,
                       (long)InpChartBullColor)) success = false;
   if(!ChartSetInteger(0, CHART_COLOR_CANDLE_BEAR,
                       (long)InpChartBearColor)) success = false;
   if(!ChartSetInteger(0, CHART_COLOR_CHART_LINE,
                       (long)InpChartLineColor)) success = false;
   if(!ChartSetInteger(0, CHART_COLOR_VOLUME,
                       (long)InpChartVolumeColor)) success = false;
   if(!ChartSetInteger(0, CHART_COLOR_BID,
                       (long)InpChartBidColor)) success = false;
   if(!ChartSetInteger(0, CHART_COLOR_ASK,
                       (long)InpChartAskColor)) success = false;
   if(!ChartSetInteger(0, CHART_COLOR_LAST,
                       (long)InpChartLastColor)) success = false;
   if(!ChartSetInteger(0, CHART_COLOR_STOP_LEVEL,
                       (long)InpChartStopLevelColor)) success = false;
   ChartRedraw(0);
   if(!success)
      PrintFormat("UI ERROR | Cannot apply Controller Lite chart theme | error=%d",
                  GetLastError());
   return success;
  }

void SetDashboardBackground(const string panelPrefix,
                            const ENUM_BASE_CORNER corner,
                            const int yDistance,
                            const int height)
  {
   string name = g_objectPrefix + panelPrefix + "BACKGROUND";
   if(ObjectFind(0, name) < 0 &&
      !ObjectCreate(0, name, OBJ_RECTANGLE_LABEL, 0, 0, 0)) return;
   ObjectSetInteger(0, name, OBJPROP_CORNER, corner);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, InpDashboardX);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, yDistance);
   ObjectSetInteger(0, name, OBJPROP_XSIZE, InpDashboardWidth);
   ObjectSetInteger(0, name, OBJPROP_YSIZE, height);
   ObjectSetInteger(0, name, OBJPROP_BGCOLOR,
                    ColorWithOpacity(InpDashboardBackgroundColor,
                                     InpDashboardOpacityPercent));
   ObjectSetInteger(0, name, OBJPROP_BORDER_COLOR, InpPanelBorderColor);
   ObjectSetInteger(0, name, OBJPROP_BORDER_TYPE, BORDER_FLAT);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_SELECTED, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, false);
   ObjectSetInteger(0, name, OBJPROP_BACK, false);
  }

void SetDashboardLine(const string panelPrefix,
                      const ENUM_BASE_CORNER corner,
                      const int yDistance,
                      const int panelHeight,
                      const int lineCount,
                      const int index,
                      const string value,
                      const color textColor)
  {
   string name = g_objectPrefix + panelPrefix + "LINE." +
                 IntegerToString(index);
   if(ObjectFind(0, name) < 0 &&
      !ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0)) return;
   int lineHeight = MathMax(16, (panelHeight - 28) / lineCount);
   int y = corner == CORNER_LEFT_UPPER
           ? yDistance + 14 + index * lineHeight
           : yDistance + panelHeight - 18 - index * lineHeight;
   ObjectSetInteger(0, name, OBJPROP_CORNER, corner);
   ObjectSetInteger(0, name, OBJPROP_ANCHOR,
                    corner == CORNER_LEFT_UPPER
                    ? ANCHOR_LEFT_UPPER : ANCHOR_LEFT_LOWER);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, InpDashboardX + 12);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, name, OBJPROP_COLOR, textColor);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, InpDashboardFontSize);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_SELECTED, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, false);
   ObjectSetString(0, name, OBJPROP_FONT, "Consolas");
   ObjectSetString(0, name, OBJPROP_TEXT, value);
  }

void UpdateTopDashboard()
  {
   string panelPrefix = "DASH.ON.";
   string objectPrefix = g_objectPrefix + panelPrefix;
   if(!InpShowTopDashboard)
     {
      ObjectsDeleteAll(0, objectPrefix);
      return;
     }
   const int lineCount = 19;
   SetDashboardBackground(panelPrefix, CORNER_LEFT_UPPER,
                          InpTopDashboardY,
                          InpTopDashboardHeight);
   bool systemReady = SystemReadinessPass();
   bool anyOn = g_latestBearFVGFillEvent || g_sslSweepOnEvent;
   bool onChecklistReady = EventChecklistPass();
   bool cycleOn = DesiredCommand() == SMC_COMMAND_NEW_CYCLE_ON;
   color watchoutColor = g_context == SMC_CONTEXT_BULLISH
                         ? InpDashboardPassColor
                         : (g_context == SMC_CONTEXT_BEARISH
                            ? InpDashboardOffColor
                            : InpDashboardTextColor);
   string mode = InpControlMode == SMC_VISUAL_ONLY
                 ? "VISUAL" : "CONTROL";
   SetDashboardLine(panelPrefix, CORNER_LEFT_UPPER, InpTopDashboardY,
                    InpTopDashboardHeight, lineCount, 0,
                    "SMC CONTROLLER | SYSTEM + WATCHOUT + ON  v" +
                    SMC_CONTROLLER_VERSION, InpTradingZoneColor);
   SetDashboardLine(panelPrefix, CORNER_LEFT_UPPER, InpTopDashboardY,
                    InpTopDashboardHeight, lineCount, 1,
                    "MODE: " + mode + " | STATE: " +
                    PolicyStateToString(g_policyState),
                    InpDashboardTextColor);
   SetDashboardLine(panelPrefix, CORNER_LEFT_UPPER, InpTopDashboardY,
                    InpTopDashboardHeight, lineCount, 2,
                    "SYSTEM READINESS  [AND]", InpTradingZoneColor);
   SetDashboardLine(panelPrefix, CORNER_LEFT_UPPER, InpTopDashboardY,
                    InpTopDashboardHeight, lineCount, 3,
                    "DATA: " + GateText(g_onDataGate) + " | " +
                    g_dataBlockReason,
                    g_onDataGate ? InpDashboardPassColor
                                 : InpDashboardTextColor);
   SetDashboardLine(panelPrefix, CORNER_LEFT_UPPER, InpTopDashboardY,
                    InpTopDashboardHeight, lineCount, 4,
                    "OPS : " + GateText(g_onOperationalGate) + " | " +
                    g_operationalBlockReason,
                    g_onOperationalGate ? InpDashboardPassColor
                                        : InpDashboardTextColor);
   SetDashboardLine(panelPrefix, CORNER_LEFT_UPPER, InpTopDashboardY,
                    InpTopDashboardHeight, lineCount, 5,
                    "CCBSN FLAT: " + GateText(g_onFlatGate) +
                    " | positions=" + IntegerToString(g_ccbsnPositionCount),
                    g_onFlatGate ? InpDashboardPassColor
                                 : InpDashboardTextColor);
   SetDashboardLine(panelPrefix, CORNER_LEFT_UPPER, InpTopDashboardY,
                    InpTopDashboardHeight, lineCount, 6,
                    "SYSTEM READY: " + GateText(systemReady),
                    systemReady ? InpDashboardPassColor
                                : InpDashboardTextColor);
   SetDashboardLine(panelPrefix, CORNER_LEFT_UPPER, InpTopDashboardY,
                    InpTopDashboardHeight, lineCount, 7,
                    "SMC STRUCTURE WATCHOUT  [NO CYCLE EFFECT]",
                    InpTradingZoneColor);
   SetDashboardLine(panelPrefix, CORNER_LEFT_UPPER, InpTopDashboardY,
                    InpTopDashboardHeight, lineCount, 8,
                    TimeframeText(InpContextTimeframe) +
                    " CONTEXT: " + ContextToString(g_context),
                    watchoutColor);
   SetDashboardLine(panelPrefix, CORNER_LEFT_UPPER, InpTopDashboardY,
                    InpTopDashboardHeight, lineCount, 9,
                    "M15 SWINGS: " + g_m15StructureWatchout,
                    InpDashboardTextColor);
   SetDashboardLine(panelPrefix, CORNER_LEFT_UPPER, InpTopDashboardY,
                    InpTopDashboardHeight, lineCount, 10,
                    "LOCATION: HL=" +
                    (g_watchoutContinuationHL ? "YES" : "--") +
                    " | SSL=" +
                    (g_watchoutRecentSSLSweep ? "YES" : "--"),
                    (g_watchoutContinuationHL || g_watchoutRecentSSLSweep)
                    ? InpDashboardPassColor : InpDashboardTextColor);
   SetDashboardLine(panelPrefix, CORNER_LEFT_UPPER, InpTopDashboardY,
                    InpTopDashboardHeight, lineCount, 11,
                    "BULL BREAK: " +
                    (g_watchoutBullBreak ? "YES" : "--"),
                    g_watchoutBullBreak ? InpDashboardPassColor
                                        : InpDashboardTextColor);
   SetDashboardLine(panelPrefix, CORNER_LEFT_UPPER, InpTopDashboardY,
                    InpTopDashboardHeight, lineCount, 12,
                    "DISPLACEMENT: " +
                    (g_watchoutBullDisplacement ? "YES" : "--"),
                    g_watchoutBullDisplacement ? InpDashboardPassColor
                                               : InpDashboardTextColor);
   SetDashboardLine(panelPrefix, CORNER_LEFT_UPPER, InpTopDashboardY,
                    InpTopDashboardHeight, lineCount, 13,
                    "ON CHECKLIST  [BUY FVG AND EVENT]",
                    InpDashboardPassColor);
   SetDashboardLine(panelPrefix, CORNER_LEFT_UPPER, InpTopDashboardY,
                    InpTopDashboardHeight, lineCount, 14,
                    InpLabelBuySideFVG + " <=" +
                    IntegerToString(InpBuySideFVGMaxAgeBars) + " : " +
                    GateText(g_onBuySideFVGGate),
                    g_onBuySideFVGGate ? InpDashboardPassColor
                                       : InpDashboardTextColor);
   SetDashboardLine(panelPrefix, CORNER_LEFT_UPPER, InpTopDashboardY,
                    InpTopDashboardHeight, lineCount, 15,
                    InpLabelBearFVGFill + " : " +
                    GateText(g_latestBearFVGFillEvent),
                    g_latestBearFVGFillEvent ? InpDashboardPassColor
                                             : InpDashboardTextColor);
   SetDashboardLine(panelPrefix, CORNER_LEFT_UPPER, InpTopDashboardY,
                    InpTopDashboardHeight, lineCount, 16,
                    InpLabelSSLSweep + " : " + GateText(g_sslSweepOnEvent),
                    g_sslSweepOnEvent ? InpDashboardPassColor
                                      : InpDashboardTextColor);
   SetDashboardLine(panelPrefix, CORNER_LEFT_UPPER, InpTopDashboardY,
                    InpTopDashboardHeight, lineCount, 17,
                    "ON READY: " + GateText(onChecklistReady) +
                    " (EVENT " + GateText(anyOn) + ") | CYCLE: " +
                    CommandToString(DesiredCommand()),
                    cycleOn ? InpDashboardPassColor
                            : InpDashboardTextColor);
   SetDashboardLine(panelPrefix, CORNER_LEFT_UPPER, InpTopDashboardY,
                    InpTopDashboardHeight, lineCount, 18,
                    "LAST: " + g_lastEvent + " | " + g_lastReason,
                    InpDashboardTextColor);
  }

void UpdateOffDashboard()
  {
   string panelPrefix = "DASH.OFF.";
   string objectPrefix = g_objectPrefix + panelPrefix;
   if(!InpShowOffDashboard)
     {
      ObjectsDeleteAll(0, objectPrefix);
      return;
     }
   const int lineCount = 11;
   SetDashboardBackground(panelPrefix, CORNER_LEFT_LOWER,
                          InpBottomDashboardY, InpOffDashboardHeight);
   bool anyOff = g_offOperational || g_offCausalLow ||
                 g_offBearBreak || g_offBSLSweep ||
                 g_offBearFVG || g_offTarget || g_offTimeout ||
                 g_offTokenConsumed;
   SetDashboardLine(panelPrefix, CORNER_LEFT_LOWER, InpBottomDashboardY,
                    InpOffDashboardHeight, lineCount, 0,
                    "OFF CHECKLIST  [OR / FIRST VETO WINS]",
                    InpDashboardOffColor);
   SetDashboardLine(panelPrefix, CORNER_LEFT_LOWER, InpBottomDashboardY,
                    InpOffDashboardHeight, lineCount, 1,
                    "OPERATIONAL BLOCK : " + VetoText(g_offOperational),
                    g_offOperational ? InpDashboardOffColor
                                     : InpDashboardTextColor);
   SetDashboardLine(panelPrefix, CORNER_LEFT_LOWER, InpBottomDashboardY,
                    InpOffDashboardHeight, lineCount, 2,
                    "CAUSAL LOW        : " +
                    ConfiguredVetoText(InpOffOnCausalLow,
                                       g_offCausalLow),
                    g_offCausalLow ? InpDashboardOffColor
                                   : InpDashboardTextColor);
   SetDashboardLine(panelPrefix, CORNER_LEFT_LOWER, InpBottomDashboardY,
                    InpOffDashboardHeight, lineCount, 3,
                    InpLabelBearBreak + " : " +
                    ConfiguredVetoText(InpOffOnBearishBreak,
                                       g_offBearBreak),
                    g_offBearBreak ? InpDashboardOffColor
                                   : InpDashboardTextColor);
   SetDashboardLine(panelPrefix, CORNER_LEFT_LOWER, InpBottomDashboardY,
                    InpOffDashboardHeight, lineCount, 4,
                    InpLabelBSLSweep + " : " +
                    ConfiguredVetoText(InpOffOnBuySideSweep,
                                       g_offBSLSweep),
                    g_offBSLSweep ? InpDashboardOffColor
                                  : InpDashboardTextColor);
   SetDashboardLine(panelPrefix, CORNER_LEFT_LOWER, InpBottomDashboardY,
                    InpOffDashboardHeight, lineCount, 5,
                    "BEAR FVG          : " +
                    ConfiguredVetoText(InpOffOnBearishFVG,
                                       g_offBearFVG),
                    g_offBearFVG ? InpDashboardOffColor
                                 : InpDashboardTextColor);
   SetDashboardLine(panelPrefix, CORNER_LEFT_LOWER, InpBottomDashboardY,
                    InpOffDashboardHeight, lineCount, 6,
                    "TARGET REACHED    : " +
                    ConfiguredVetoText(InpOffOnTargetReached,
                                       g_offTarget),
                    g_offTarget ? InpDashboardOffColor
                                : InpDashboardTextColor);
   SetDashboardLine(panelPrefix, CORNER_LEFT_LOWER, InpBottomDashboardY,
                    InpOffDashboardHeight, lineCount, 7,
                    "ENTRY TIMEOUT     : " + VetoText(g_offTimeout),
                    g_offTimeout ? InpDashboardOffColor
                                 : InpDashboardTextColor);
   SetDashboardLine(panelPrefix, CORNER_LEFT_LOWER, InpBottomDashboardY,
                    InpOffDashboardHeight, lineCount, 8,
                    "ONE-SHOT TOKEN    : " + VetoText(g_offTokenConsumed),
                    g_offTokenConsumed ? InpDashboardOffColor
                                       : InpDashboardTextColor);
   SetDashboardLine(panelPrefix, CORNER_LEFT_LOWER, InpBottomDashboardY,
                    InpOffDashboardHeight, lineCount, 9,
                    "OFF RESULT        : " +
                    (anyOff ? "VETO ACTIVE" : "CLEAR"),
                    anyOff ? InpDashboardOffColor
                           : InpDashboardPassColor);
   SetDashboardLine(panelPrefix, CORNER_LEFT_LOWER, InpBottomDashboardY,
                    InpOffDashboardHeight, lineCount, 10,
                    "LAST: " + g_lastEvent + " | " + g_lastReason,
                    InpDashboardTextColor);
  }

void UpdateDashboard()
  {
   // Remove the v0.7 combined checklist once, including objects retained by
   // InpKeepObjectsOnRemove during an in-place upgrade.
   ObjectsDeleteAll(0, g_objectPrefix + "CHECKLIST.");
   UpdateTopDashboard();
   UpdateOffDashboard();
   if(InpShowTopDashboard || InpShowOffDashboard)
      Comment("");
   else
      Comment("SMC CONTROLLER ", SMC_CONTROLLER_VERSION, " | ",
              PolicyStateToString(g_policyState), " | ",
              CommandToString(DesiredCommand()));
  }

int OnInit()
  {
   g_objectPrefix = "SMC_CTRL." + IntegerToString(ChartID()) + ".";
   if(!ValidateInputs())
     {
      Comment("SMC CONTROLLER CONFIG ERROR\n", g_configurationError);
      Print("SMC CONTROLLER CONFIG ERROR | " + g_configurationError);
      return INIT_PARAMETERS_INCORRECT;
     }
   if(!ApplyChartTheme())
     {
      g_configurationError = "CHART_THEME_APPLY_FAILED";
      Comment("SMC CONTROLLER UI ERROR\n", g_configurationError);
      return INIT_FAILED;
     }
   if(!InitializeAudit())
     {
      Comment("SMC CONTROLLER AUDIT ERROR\n", g_configurationError);
      return INIT_FAILED;
     }

   g_atrHandle = iATR(_Symbol, InpDecisionTimeframe, InpATRPeriod);
   if(g_atrHandle == INVALID_HANDLE)
     {
      g_configurationError = "ATR_HANDLE_CREATE_FAILED";
      return INIT_FAILED;
     }
   g_trade.SetExpertMagicNumber(InpControllerMagic);
   g_trade.SetAsyncMode(false);
   g_trade.SetTypeFillingBySymbol(_Symbol);
   RefreshCCBSNPositions(true);

   if(InpControlMode == SMC_CONTROL_ENABLED)
     {
      g_controlState = SMC_CONTROL_UNKNOWN;
      if(!AcquireControllerLock())
        {
         Print("SMC CONTROL ERROR | " + g_lastControlError);
         return INIT_FAILED;
        }
      if(!RecoverPendingControllerOrder())
        {
         ReleaseControllerLock();
         return INIT_FAILED;
        }
     }
   else
      g_controlState = SMC_CONTROL_DISABLED;

   if(!BuildHistoricalZones())
     {
      g_currentOpenBarTime = iTime(_Symbol, InpDecisionTimeframe, 0);
      datetime latestClosed = iTime(_Symbol, InpDecisionTimeframe, 1);
      if(latestClosed > 0)
         g_lastDecisionTime = latestClosed +
                              PeriodSeconds(InpDecisionTimeframe);
      g_context = EvaluateContext();
     }

   if(!EventSetMillisecondTimer(TIMER_MILLISECONDS))
     {
      g_configurationError = "TIMER_CREATE_FAILED";
      ReleaseControllerLock();
      return INIT_FAILED;
     }
   g_configurationValid = true;
   AuditEvent("EA_STARTED", InpControlMode == SMC_VISUAL_ONLY
              ? "VISUAL_ONLY" : "CONTROL_ENABLED_FAIL_CLOSED");
   ProcessCCBSNControl();
   UpdateDashboard();
   return INIT_SUCCEEDED;
  }

void OnDeinit(const int reason)
  {
   EventKillTimer();
   if(g_configurationValid)
      AuditEvent("EA_STOPPED", "DEINIT_REASON=" + IntegerToString(reason));
   CancelPendingOnRemove();
   ReleaseControllerLock();
   if(g_atrHandle != INVALID_HANDLE) IndicatorRelease(g_atrHandle);
   if(!InpKeepObjectsOnRemove && g_objectPrefix != "")
      ObjectsDeleteAll(0, g_objectPrefix);
   Comment("");
  }

void OnTick()
  {
   // Policy uses closed bars. Timer owns policy and transport reconciliation.
  }

void OnTimer()
  {
   if(!g_configurationValid) return;
   RefreshControllerLock();
   RefreshCCBSNPositions(false);
   ProcessLatestClosedBar();
   if(InpWriteCsvAudit && !g_auditReady &&
      (g_policyState == SMC_STATE_WAIT_RETEST ||
       g_policyState == SMC_STATE_ENTRY_WINDOW))
      CancelSetup(TimeCurrent(), "AUDIT_RUNTIME_FAILURE", false);
   ProcessCCBSNControl();
   if(g_zoneStartTime > 0) UpdateLiveTradingZoneExtent();
   UpdateActiveBearFVGZones(TimeCurrent());
   UpdateLatestBuySideFVG(TimeCurrent());
   UpdateDashboard();
   ChartRedraw();
  }

void OnTradeTransaction(const MqlTradeTransaction &transaction,
                        const MqlTradeRequest &request,
                        const MqlTradeResult &result)
  {
   if(!g_configurationValid || InpControlMode != SMC_CONTROL_ENABLED) return;
   RefreshCCBSNPositions(false);
   if(g_commandTicket != 0) ReconcilePendingCommand();
  }
//+------------------------------------------------------------------+
