//+------------------------------------------------------------------+
//|                         CCBSN_Trading_Zone_Visualizer.mq5         |
//|            Trading-zone and New Cycle controller for MT5        |
//+------------------------------------------------------------------+
#property strict
#property copyright "TradingTeam"
#property version   "3.290"
#property description "CCBSN M15 configurable ATR + EMA Trading Zone Controller"
#property description "Resilient command persistence and mutex-safe BOT1 handover."

#include <Trade/Trade.mqh>

enum ENUM_VISUAL_STATE
  {
   VISUAL_STATE_OFF = 0,
   VISUAL_STATE_ARMING,
   VISUAL_STATE_ACTIVE,
   VISUAL_STATE_DATA_ERROR
  };

enum ENUM_ZONE_BRANCH
  {
   ZONE_BRANCH_NONE = 0,
   ZONE_BRANCH_ABOVE_EMA,
   ZONE_BRANCH_DEEP_BELOW_EMA
  };

enum ENUM_CCBSN_CONTROL_MODE
  {
   CCBSN_CONTROL_VISUAL_ONLY = 0,
   CCBSN_CONTROL_ENABLED,
   CCBSN_CONTROL_MANUAL_HANDOVER
  };

enum ENUM_CCBSN_COMMAND
  {
   CCBSN_COMMAND_NONE = 0,
   CCBSN_COMMAND_NEW_CYCLE_ON,
   CCBSN_COMMAND_NEW_CYCLE_OFF
  };

enum ENUM_COMMAND_CANCEL_REASON
  {
   COMMAND_CANCEL_NONE = 0,
   COMMAND_CANCEL_SUPERSEDED,
   COMMAND_CANCEL_TIMEOUT
  };

enum ENUM_XAU_QUOTE_DIGITS
  {
   XAU_QUOTE_2_DIGITS = 2,
   XAU_QUOTE_3_DIGITS = 3
  };

enum ENUM_CCBSN_CONTROL_STATE
  {
   CCBSN_CONTROL_DISABLED = 0,
   CCBSN_CONTROL_BOT1_MANUAL,
   CCBSN_CONTROL_UNKNOWN,
   CCBSN_CONTROL_ON_PENDING,
   CCBSN_CONTROL_OFF_PENDING,
   CCBSN_CONTROL_ON_CONFIRMED,
   CCBSN_CONTROL_OFF_CONFIRMED,
   CCBSN_CONTROL_ERROR
  };

input group "01. Symbol & Quote"
input string InpExpectedSymbolPrefix  = "XAUUSD"; // Allows broker suffixes such as XAUUSDm
input ENUM_XAU_QUOTE_DIGITS InpXAUQuoteDigits = XAU_QUOTE_2_DIGITS;

input group "02. ATR Filter"
input int    InpATRPeriod             = 20;
input double InpMinATRPrice           = 3.0;      // Raw symbol price, not pip/point

input group "03. EMA Distance Filter"
input int    InpEMAPeriod             = 23;
input double InpMaxAboveEMAPrice      = 20.0;     // PASS: 0 <= Close-EMA <= this value
input double InpMinBelowEMAPrice      = 20.0;     // PASS: Close-EMA < -this value

input group "04. Ownership & CCBSN Control"
input ENUM_CCBSN_CONTROL_MODE InpControlMode = CCBSN_CONTROL_ENABLED;
input ulong  InpCCBSNMagic            = 9196;     // Must match the target CCBSN instance
input ulong  InpControllerMagic       = 99196;    // Must differ from CCBSN Magic
input bool   InpForceSyncOnInit        = false;    // Explicit troubleshooting only

input group "05. Display"
input bool   InpApplyChartTheme       = true;
input color  InpDashboardBackgroundColor = clrWhite;
input color  InpDashboardTextColor       = C'45,55,70';
input bool   InpShowEMAOnChart        = true;
input bool   InpDrawHistory           = true;
input int    InpHistoryBars           = 1500;
input bool   InpDrawCandidateEvents   = true;

input group "06. Audit"
input bool   InpWriteCsvAudit         = true;

// Fixed policy and protocol values are intentionally not user inputs.
// This keeps the MT5 Inputs tab operational, safe, and reproducible.
const int    InpEnableConfirmBars         = 2;
const double InpCommandPrice              = 888888.0;
const double InpCommandVolume             = 0.0; // Always use symbol minimum volume
const int    InpCommandTimeoutSeconds     = 30;
const bool   InpDeleteCommandOnTimeout    = true;
const bool   InpPersistConfirmedState     = true;
const bool   InpSingleControllerLock      = true;
const int    InpControllerLockStaleSeconds = 15;
const bool   InpManualHandoverOnRemove    = true;
const int    InpDriftAlertCooldownSeconds = 30;

const color InpChartBackgroundColor = clrLightYellow;
const color InpChartForegroundColor = C'25,30,40';
const color InpChartGridColor       = C'230,233,238';
const color InpChartBullColor       = C'0,145,105';
const color InpChartBearColor       = C'215,65,75';
const color InpChartLineColor       = C'55,65,81';
const color InpChartVolumeColor     = C'150,158,170';
const color InpChartBidColor        = C'65,105,170';
const color InpChartAskColor        = C'205,65,75';
const color InpChartLastColor       = C'110,85,165';
const color InpChartStopLevelColor  = C'190,65,90';
const color InpPanelBorderColor     = C'205,210,218';
const int InpEMADisplayBars         = 400;
const color InpEMALineColor         = C'45,90,190';
const ENUM_LINE_STYLE InpEMALineStyle = STYLE_DASH;
const int InpEMALineWidth           = 1;
const int InpEMAOpacityPercent      = 70;

const int InpMaxClosedZones         = 100;
const int InpMaxEventMarkers        = 250;
const double InpZonePaddingATR      = 0.25;
const color InpAboveEMAZoneColor    = clrLinen;
const color InpDeepBelowZoneColor   = clrLavender;
const color InpOffEventColor        = C'190,55,70';
const int InpZoneOpacityPercent     = 50;
const int InpEventOpacityPercent    = 50;

const string InpTextPanelTitle      = "CCBSN CONTROLLER v3.29";
const string InpTextMode            = "NEW CYCLE CONTROL";
const string InpTextOwner           = "Owner";
const string InpTextState           = "Policy";
const string InpTextConfirm         = "Confirm";
const string InpTextZone            = "Policy Zone";
const string InpTextControl         = "NC Command ACK";
const string InpTextDesired         = "Desired NC";
const string InpTextCommand         = "Ticket";
const string InpTextChecklist       = "Checklist";
const string InpTextReason          = "Reason";
const string InpTextDecision        = "Decision";
const string InpTextArming          = "ARM";
const string InpTextZoneOn          = "POLICY ALLOW";
const string InpTextZoneOff         = "POLICY BLOCK";

const int InpTimerMilliseconds      = 250;
const string InpCsvFileName         = "CCBSN_Trading_Zone_Events_v3_29.csv";
const bool InpKeepObjectsOnRemove   = false;
const ulong TICKET_STORAGE_BASE     = 1000000000;

const ENUM_TIMEFRAMES DECISION_TIMEFRAME = PERIOD_M15;
const string POLICY_ID      = "ccbsn-m15-atr-ema-gate";
const string POLICY_VERSION = "1.4.1-event-driven-drift-guard";

CTrade g_trade;

int g_atrHandle = INVALID_HANDLE;
int g_emaHandle = INVALID_HANDLE;

string g_objectPrefix = "";
datetime g_lastM15BarTime = 0;
datetime g_lastDecisionTime = 0;

ENUM_VISUAL_STATE g_state = VISUAL_STATE_OFF;
int g_consecutivePassCount = 0;

double g_lastClose = 0.0;
double g_lastATR = 0.0;
double g_lastEMA = 0.0;
double g_lastDistance = 0.0;
bool g_lastChecklistPass = false;
string g_lastReason = "WAITING_FOR_DATA";

datetime g_activeZoneStart = 0;
double g_activeZoneHigh = 0.0;
double g_activeZoneLow = 0.0;
double g_activeZoneATR = 0.0;
ENUM_ZONE_BRANCH g_activeZoneBranch = ZONE_BRANCH_NONE;
string g_activeZoneBaseName = "";

string g_eventObjectNames[];
string g_closedZoneObjectNames[];
string g_emaObjectNames[];

ENUM_CCBSN_CONTROL_STATE g_controlState = CCBSN_CONTROL_UNKNOWN;
ENUM_CCBSN_COMMAND g_pendingCommand = CCBSN_COMMAND_NONE;
ulong g_commandTicket = 0;
datetime g_commandSentTime = 0;
bool g_commandCancelRequested = false;
string g_lastControlError = "NONE";
string g_commandCancelReason = "";
ENUM_COMMAND_CANCEL_REASON g_commandCancelCode = COMMAND_CANCEL_NONE;
double g_instanceToken = 0.0;
bool g_controllerLockHeld = false;
bool g_manualHandoverComplete = false;

int g_ccbsnPositionCount = 0;
double g_ccbsnPositionVolume = 0.0;
bool g_positionSnapshotReady = false;
bool g_offFlatGuardArmed = false;
bool g_offReassertRequested = false;
bool g_driftDetectedCurrentChain = false;
bool g_positionSyncRequested = false;
int g_driftCount = 0;
datetime g_lastDriftAlertTime = 0;
ENUM_CCBSN_COMMAND g_lastSyncDesired = CCBSN_COMMAND_NONE;
string g_syncState = "INITIALIZING";
string g_lastSyncReason = "WAITING_FOR_POSITION_SNAPSHOT";

//+------------------------------------------------------------------+
//| String helpers                                                   |
//+------------------------------------------------------------------+
string StateToString(const ENUM_VISUAL_STATE state)
  {
   switch(state)
     {
      case VISUAL_STATE_OFF:        return "OFF";
      case VISUAL_STATE_ARMING:     return "ARMING";
      case VISUAL_STATE_ACTIVE:     return "ACTIVE";
      case VISUAL_STATE_DATA_ERROR: return "DATA_ERROR";
     }
   return "UNKNOWN";
  }

string ControlModeToString(const ENUM_CCBSN_CONTROL_MODE mode)
  {
   switch(mode)
     {
      case CCBSN_CONTROL_VISUAL_ONLY:   return "VISUAL ONLY";
      case CCBSN_CONTROL_ENABLED:       return "CONTROL ENABLED";
      case CCBSN_CONTROL_MANUAL_HANDOVER:return "MANUAL HANDOVER";
     }
   return "UNKNOWN MODE";
  }

string ControlOwnerToString()
  {
   if(InpControlMode == CCBSN_CONTROL_ENABLED)
      return "BOT2 CONTROLLER";
   if(InpControlMode == CCBSN_CONTROL_MANUAL_HANDOVER)
      return g_manualHandoverComplete ? "BOT1 MANUAL" : "HANDOVER PENDING";
   return "NO OWNER (VISUAL)";
  }

string DeinitReasonToString(const int reason)
  {
   switch(reason)
     {
      case REASON_PROGRAM:     return "PROGRAM";
      case REASON_REMOVE:      return "REMOVE";
      case REASON_RECOMPILE:   return "RECOMPILE";
      case REASON_CHARTCHANGE: return "CHART_CHANGE";
      case REASON_CHARTCLOSE:  return "CHART_CLOSE";
      case REASON_PARAMETERS:  return "PARAMETERS";
      case REASON_ACCOUNT:     return "ACCOUNT";
      case REASON_TEMPLATE:    return "TEMPLATE";
      case REASON_INITFAILED:  return "INIT_FAILED";
      case REASON_CLOSE:       return "TERMINAL_CLOSE";
     }
   return "UNKNOWN";
  }

string CommandToString(const ENUM_CCBSN_COMMAND command)
  {
   switch(command)
     {
      case CCBSN_COMMAND_NEW_CYCLE_ON:  return "ENABLE NEW CYCLE";
      case CCBSN_COMMAND_NEW_CYCLE_OFF: return "DISABLE NEW CYCLE";
      default:                          return "NONE";
     }
  }

string ControlStateToString(const ENUM_CCBSN_CONTROL_STATE state)
  {
   switch(state)
     {
      case CCBSN_CONTROL_DISABLED:      return "DISABLED";
      case CCBSN_CONTROL_BOT1_MANUAL:   return "BOT1 MANUAL (NC UNTRACKED)";
      case CCBSN_CONTROL_UNKNOWN:       return "UNKNOWN";
      case CCBSN_CONTROL_ON_PENDING:    return "ENABLE PENDING";
      case CCBSN_CONTROL_OFF_PENDING:   return "DISABLE PENDING";
      case CCBSN_CONTROL_ON_CONFIRMED:  return "NC ENABLED";
      case CCBSN_CONTROL_OFF_CONFIRMED: return "NC DISABLED";
      case CCBSN_CONTROL_ERROR:         return "ERROR";
     }
   return "UNKNOWN";
  }

ENUM_CCBSN_COMMAND DesiredCommand()
  {
   if(InpControlMode != CCBSN_CONTROL_ENABLED)
      return CCBSN_COMMAND_NONE;
   if(g_state == VISUAL_STATE_ACTIVE)
      return CCBSN_COMMAND_NEW_CYCLE_ON;
   return CCBSN_COMMAND_NEW_CYCLE_OFF;
  }

bool IsConfirmedForCommand(const ENUM_CCBSN_COMMAND command)
  {
   if(command == CCBSN_COMMAND_NEW_CYCLE_ON)
      return g_controlState == CCBSN_CONTROL_ON_CONFIRMED;
   if(command == CCBSN_COMMAND_NEW_CYCLE_OFF)
      return g_controlState == CCBSN_CONTROL_OFF_CONFIRMED;
   return false;
  }

string FormatPrice(const double value)
  {
   return DoubleToString(value, (int)InpXAUQuoteDigits);
  }

ENUM_COMMAND_CANCEL_REASON CancelReasonCode(const string reason)
  {
   if(reason == "SUPERSEDED_BY_NEW_POLICY_STATE")
      return COMMAND_CANCEL_SUPERSEDED;
   if(reason == "CCBSN_CONSUMPTION_TIMEOUT")
      return COMMAND_CANCEL_TIMEOUT;
   return COMMAND_CANCEL_NONE;
  }

string CancelReasonText(const ENUM_COMMAND_CANCEL_REASON code)
  {
   if(code == COMMAND_CANCEL_SUPERSEDED)
      return "SUPERSEDED_BY_NEW_POLICY_STATE";
   if(code == COMMAND_CANCEL_TIMEOUT)
      return "CCBSN_CONSUMPTION_TIMEOUT";
   return "RESTORED_CANCEL_REQUEST";
  }

string BranchToString(const ENUM_ZONE_BRANCH branch)
  {
   switch(branch)
     {
      case ZONE_BRANCH_ABOVE_EMA:      return "ABOVE_EMA";
      case ZONE_BRANCH_DEEP_BELOW_EMA: return "DEEP_BELOW_EMA";
      default:                         return "NONE";
     }
  }

string TimeKey(const datetime value)
  {
   return IntegerToString((long)value);
  }

color BranchColor(const ENUM_ZONE_BRANCH branch)
  {
   if(branch == ZONE_BRANCH_DEEP_BELOW_EMA)
      return InpDeepBelowZoneColor;
   return InpAboveEMAZoneColor;
  }

//+------------------------------------------------------------------+
//| Configuration                                                    |
//+------------------------------------------------------------------+
bool ValidateInputs()
  {
   if(InpExpectedSymbolPrefix != "" && StringFind(_Symbol, InpExpectedSymbolPrefix) != 0)
     {
      PrintFormat("CONFIG ERROR | Symbol %s does not start with %s",
                  _Symbol, InpExpectedSymbolPrefix);
      return false;
     }
   if(_Digits != (int)InpXAUQuoteDigits)
     {
      PrintFormat("CONFIG ERROR | Symbol %s has %d digits but input expects %d digits.",
                  _Symbol, _Digits, (int)InpXAUQuoteDigits);
      return false;
     }
   if(InpATRPeriod < 1 || InpATRPeriod > 1000 ||
      InpEMAPeriod < 1 || InpEMAPeriod > 1000 || InpEnableConfirmBars < 1)
     {
      Print("CONFIG ERROR | ATR/EMA periods must be 1..1000.");
      return false;
     }
   if(InpMinATRPrice <= 0.0 || InpMaxAboveEMAPrice < 0.0 || InpMinBelowEMAPrice < 0.0)
     {
      Print("CONFIG ERROR | Price thresholds are invalid. MinATR must be > 0.");
      return false;
     }
   if(InpHistoryBars < 50 || InpMaxClosedZones < 1 || InpMaxEventMarkers < 1 ||
      InpEMADisplayBars < 2)
     {
      Print("CONFIG ERROR | Visual history limits are too small.");
      return false;
     }
   int longestPeriod = MathMax(InpATRPeriod, InpEMAPeriod);
   if(InpDrawHistory && InpHistoryBars < longestPeriod + 3)
     {
      PrintFormat("CONFIG ERROR | History Bars must be at least %d for ATR/EMA warm-up.",
                  longestPeriod + 3);
      return false;
     }
   if(InpTimerMilliseconds < 100 || InpEMALineWidth < 1 || InpEMALineWidth > 5)
     {
      Print("CONFIG ERROR | Timer or EMA line width is invalid.");
      return false;
     }
   if(InpZoneOpacityPercent < 0 || InpZoneOpacityPercent > 100 ||
      InpEventOpacityPercent < 0 || InpEventOpacityPercent > 100 ||
      InpEMAOpacityPercent < 0 || InpEMAOpacityPercent > 100)
     {
      Print("CONFIG ERROR | Opacity must be between 0 and 100 percent.");
      return false;
     }
   if(InpCCBSNMagic == 0 || InpControllerMagic == InpCCBSNMagic ||
      InpControllerMagic == 0)
     {
      Print("CONFIG ERROR | Both Magic values must be non-zero and different.");
      return false;
     }
   if(InpCommandPrice <= 0.0 || InpCommandVolume < 0.0 ||
      InpCommandTimeoutSeconds < 5 || InpControllerLockStaleSeconds < 5)
     {
      Print("CONFIG ERROR | Command price, volume, or timeout is invalid.");
      return false;
     }
   return true;
  }

bool ValidateControlEnvironment()
  {
   if(InpControlMode != CCBSN_CONTROL_ENABLED)
     {
      g_controlState = CCBSN_CONTROL_DISABLED;
      return true;
     }

   g_controlState = CCBSN_CONTROL_UNKNOWN;
   return true;
  }

long ColorWithOpacity(const color baseColor, const int opacityPercent)
  {
   int boundedPercent = opacityPercent;
   if(boundedPercent < 0) boundedPercent = 0;
   if(boundedPercent > 100) boundedPercent = 100;
   uchar alpha = (uchar)MathRound(255.0 * boundedPercent / 100.0);
   return (long)ColorToARGB(baseColor, alpha);
  }

bool ApplyChartTheme()
  {
   if(!InpApplyChartTheme)
      return true;

   bool success = true;
   if(!ChartSetInteger(0, CHART_COLOR_BACKGROUND, (long)InpChartBackgroundColor)) success = false;
   if(!ChartSetInteger(0, CHART_COLOR_FOREGROUND, (long)InpChartForegroundColor)) success = false;
   if(!ChartSetInteger(0, CHART_COLOR_GRID, (long)InpChartGridColor)) success = false;
   if(!ChartSetInteger(0, CHART_COLOR_CHART_UP, (long)InpChartBullColor)) success = false;
   if(!ChartSetInteger(0, CHART_COLOR_CHART_DOWN, (long)InpChartBearColor)) success = false;
   if(!ChartSetInteger(0, CHART_COLOR_CANDLE_BULL, (long)InpChartBullColor)) success = false;
   if(!ChartSetInteger(0, CHART_COLOR_CANDLE_BEAR, (long)InpChartBearColor)) success = false;
   if(!ChartSetInteger(0, CHART_COLOR_CHART_LINE, (long)InpChartLineColor)) success = false;
   if(!ChartSetInteger(0, CHART_COLOR_VOLUME, (long)InpChartVolumeColor)) success = false;
   if(!ChartSetInteger(0, CHART_COLOR_BID, (long)InpChartBidColor)) success = false;
   if(!ChartSetInteger(0, CHART_COLOR_ASK, (long)InpChartAskColor)) success = false;
   if(!ChartSetInteger(0, CHART_COLOR_LAST, (long)InpChartLastColor)) success = false;
   if(!ChartSetInteger(0, CHART_COLOR_STOP_LEVEL, (long)InpChartStopLevelColor)) success = false;
   ChartRedraw(0);
   if(!success)
     {
      PrintFormat("UI ERROR | Cannot apply chart theme | error=%d", GetLastError());
      return false;
     }
   return true;
  }

//+------------------------------------------------------------------+
//| Bounded chart-object queues                                      |
//+------------------------------------------------------------------+
void PushBoundedObject(string &items[], const string name, const int maximum)
  {
   int size = ArraySize(items);
   ArrayResize(items, size + 1);
   items[size] = name;

   while(ArraySize(items) > maximum)
     {
      string oldest = items[0];
      if(ObjectFind(0, oldest) >= 0)
         ObjectDelete(0, oldest);

      int currentSize = ArraySize(items);
      for(int i = 1; i < currentSize; i++)
         items[i - 1] = items[i];
      ArrayResize(items, currentSize - 1);
     }
  }

void TrackEventObject(const string name)
  {
   PushBoundedObject(g_eventObjectNames, name, InpMaxEventMarkers);
  }

void TrackClosedZoneObject(const string name)
  {
   PushBoundedObject(g_closedZoneObjectNames, name, InpMaxClosedZones * 4);
  }

void TrackEMAObject(const string name)
  {
   PushBoundedObject(g_emaObjectNames, name, InpEMADisplayBars);
  }

//+------------------------------------------------------------------+
//| Chart primitives                                                 |
//+------------------------------------------------------------------+
void SetObjectTooltip(const string name, const string tooltip)
  {
   ObjectSetString(0, name, OBJPROP_TOOLTIP, tooltip);
  }

bool CreateOrMoveRectangle(const string name,
                           const datetime time1,
                           const double price1,
                           const datetime time2,
                           const double price2,
                           const color baseColor,
                           const bool filled)
  {
   if(ObjectFind(0, name) < 0)
     {
      if(!ObjectCreate(0, name, OBJ_RECTANGLE, 0, time1, price1, time2, price2))
        {
         PrintFormat("UI ERROR | Cannot create rectangle %s | error=%d", name, GetLastError());
         return false;
        }
     }

   ObjectMove(0, name, 0, time1, price1);
   ObjectMove(0, name, 1, time2, price2);
   long objectColor = ColorWithOpacity(baseColor, InpZoneOpacityPercent);
   ObjectSetInteger(0, name, OBJPROP_COLOR, objectColor);
   ObjectSetInteger(0, name, OBJPROP_FILL, filled);
   ObjectSetInteger(0, name, OBJPROP_BACK, filled);
   ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_SOLID);
   ObjectSetInteger(0, name, OBJPROP_WIDTH, filled ? 1 : 2);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_SELECTED, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, false);
   return true;
  }

bool CreateVerticalLine(const string name,
                        const datetime eventTime,
                        const color lineColor,
                        const ENUM_LINE_STYLE style,
                        const string tooltip)
  {
   if(ObjectFind(0, name) < 0)
     {
      if(!ObjectCreate(0, name, OBJ_VLINE, 0, eventTime, 0.0))
         return false;
     }
   ObjectMove(0, name, 0, eventTime, 0.0);
   ObjectSetInteger(0, name, OBJPROP_COLOR,
                    ColorWithOpacity(lineColor, InpEventOpacityPercent));
   ObjectSetInteger(0, name, OBJPROP_STYLE, style);
   ObjectSetInteger(0, name, OBJPROP_WIDTH, 1);
   ObjectSetInteger(0, name, OBJPROP_BACK, true);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   SetObjectTooltip(name, tooltip);
   return true;
  }

void CreateEventMarker(const string eventType,
                       const datetime eventTime,
                       const double price,
                       const string text,
                       const string tooltip)
  {
   string name = g_objectPrefix + "EVENT." + eventType + "." + TimeKey(eventTime);
   if(ObjectFind(0, name) < 0)
     {
      if(!ObjectCreate(0, name, OBJ_TEXT, 0, eventTime, price))
         return;
      TrackEventObject(name);
     }
   ObjectMove(0, name, 0, eventTime, price);
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetString(0, name, OBJPROP_FONT, "Arial");
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 8);
   // All chart event labels use one high-contrast color by UI policy.
   ObjectSetInteger(0, name, OBJPROP_COLOR, clrBlack);
   ObjectSetInteger(0, name, OBJPROP_ANCHOR, ANCHOR_LOWER);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, false);
   SetObjectTooltip(name, tooltip);
  }

string FitPanelText(const string value, const int maxCharacters)
  {
   if(maxCharacters <= 0 || StringLen(value) <= maxCharacters)
      return value;
   if(maxCharacters <= 3)
      return StringSubstr(value, 0, maxCharacters);
   return StringSubstr(value, 0, maxCharacters - 3) + "...";
  }

void SetPanelLabelAt(const string suffix,
                     const int x,
                     const int y,
                     const string value,
                     const color textColor,
                     const int maxCharacters)
  {
   string name = g_objectPrefix + "PANEL." + suffix;
   if(ObjectFind(0, name) < 0)
      ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, name, OBJPROP_COLOR, textColor);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 9);
   ObjectSetString(0, name, OBJPROP_FONT, "Consolas");
   ObjectSetString(0, name, OBJPROP_TEXT, FitPanelText(value, maxCharacters));
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, false);
  }

void SetPanelLabel(const string suffix, const int y, const string value, const color textColor)
  {
   SetPanelLabelAt(suffix, 20, y, value, textColor, 82);
  }

void SetPanelColumnLabel(const string suffix,
                         const bool rightColumn,
                         const int y,
                         const string value,
                         const color textColor)
  {
   SetPanelLabelAt(suffix, rightColumn ? 340 : 20, y, value, textColor, 41);
  }

void SetWrappedPanelLabel(const string suffix,
                          const int y,
                          const string value,
                          const color textColor,
                          const int maxCharacters = 82)
  {
   string firstLine = value;
   string secondLine = "";
   if(StringLen(value) > maxCharacters)
     {
      int splitAt = maxCharacters;
      for(int index = maxCharacters; index >= 1; index--)
        {
         if(StringSubstr(value, index, 1) == " ")
           {
            splitAt = index;
            break;
           }
        }
      firstLine = StringSubstr(value, 0, splitAt);
      int nextCharacter = splitAt;
      if(StringSubstr(value, splitAt, 1) == " ")
         nextCharacter++;
      secondLine = "  " + FitPanelText(StringSubstr(value, nextCharacter),
                                        maxCharacters - 2);
     }
   SetPanelLabel(suffix + ".1", y, firstLine, textColor);
   SetPanelLabel(suffix + ".2", y + 20, secondLine, textColor);
  }

void CreatePanel()
  {
   string background = g_objectPrefix + "PANEL.BG";
   if(ObjectFind(0, background) < 0)
      ObjectCreate(0, background, OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(0, background, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, background, OBJPROP_XDISTANCE, 10);
   ObjectSetInteger(0, background, OBJPROP_YDISTANCE, 15);
   ObjectSetInteger(0, background, OBJPROP_XSIZE, 650);
   ObjectSetInteger(0, background, OBJPROP_YSIZE, 360);
   ObjectSetInteger(0, background, OBJPROP_BGCOLOR,
                    (long)InpDashboardBackgroundColor);
   ObjectSetInteger(0, background, OBJPROP_BORDER_COLOR, InpPanelBorderColor);
   ObjectSetInteger(0, background, OBJPROP_BACK, false);
   ObjectSetInteger(0, background, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, background, OBJPROP_HIDDEN, false);
  }

void UpdatePanel()
  {
   CreatePanel();
   color stateColor = InpDashboardTextColor;
   if(g_state == VISUAL_STATE_ACTIVE) stateColor = BranchColor(g_activeZoneBranch);
   if(g_state == VISUAL_STATE_ARMING) stateColor = C'160,110,0';
   if(g_state == VISUAL_STATE_DATA_ERROR) stateColor = C'190,50,60';

   SetPanelLabel("TITLE", 22,
                 InpTextPanelTitle + " | " + ControlModeToString(InpControlMode),
                 InpDashboardTextColor);
   SetPanelLabel("MODE", 42,
                 InpTextMode + " | Decision timeframe: M15",
                 InpDashboardTextColor);
   SetPanelColumnLabel("STATE", false, 62,
                       StringFormat("%s: %s | %s: %d/%d",
                                    InpTextState,
                                    StateToString(g_state),
                                    InpTextConfirm, g_consecutivePassCount,
                                    InpEnableConfirmBars),
                       stateColor);
   SetPanelColumnLabel("ZONE", true, 62,
                       StringFormat("%s: %s | %s: %s",
                                    InpTextZone, BranchToString(g_activeZoneBranch),
                                    InpTextChecklist,
                                    g_lastChecklistPass ? "PASS" : "FAIL"),
                       g_lastChecklistPass ? C'0,120,80' : C'190,50,60');
   SetPanelColumnLabel("ATR", false, 82,
                       StringFormat("Close: %s | ATR%d: %s",
                                    FormatPrice(g_lastClose), InpATRPeriod,
                                    FormatPrice(g_lastATR)),
                       InpDashboardTextColor);
   SetPanelColumnLabel("ATR_MIN", true, 82,
                       "ATR Min: " + FormatPrice(InpMinATRPrice),
                       InpDashboardTextColor);
   SetPanelColumnLabel("EMA", false, 102,
                       StringFormat("EMA%d: %s | D: %s",
                                    InpEMAPeriod, FormatPrice(g_lastEMA),
                                    FormatPrice(g_lastDistance)),
                       InpDashboardTextColor);
   SetPanelColumnLabel("GATE", true, 102,
                       StringFormat("Gate: [0,+%s] or below -%s",
                                    FormatPrice(InpMaxAboveEMAPrice),
                                    FormatPrice(InpMinBelowEMAPrice)),
                       InpDashboardTextColor);
   SetWrappedPanelLabel("REASON", 122,
                        InpTextReason + ": " + g_lastReason,
                        InpDashboardTextColor);
   ENUM_CCBSN_COMMAND desired = DesiredCommand();
   color ownerColor = InpDashboardTextColor;
   if(InpControlMode == CCBSN_CONTROL_MANUAL_HANDOVER)
      ownerColor = g_manualHandoverComplete ? C'0,120,80' : C'180,110,0';
   SetPanelColumnLabel("OWNER", false, 162,
                       InpTextOwner + ": " + ControlOwnerToString(),
                       ownerColor);
   SetPanelColumnLabel("LOCK", true, 162,
                       "Lock: " + (g_controllerLockHeld ? "HELD" : "NONE"),
                       ownerColor);
   SetPanelColumnLabel("CCBSN_MAGIC", false, 182,
                       StringFormat("CCBSN Magic: %I64u", InpCCBSNMagic),
                       InpDashboardTextColor);
   SetPanelColumnLabel("CONTROLLER_MAGIC", true, 182,
                       StringFormat("Controller Magic: %I64u", InpControllerMagic),
                       InpDashboardTextColor);
   SetWrappedPanelLabel("CONTROL", 202,
                        InpTextControl + ": " + ControlStateToString(g_controlState),
                        g_controlState == CCBSN_CONTROL_ERROR ? C'190,50,60' :
                        InpDashboardTextColor);
   SetWrappedPanelLabel("DESIRED", 242,
                        InpTextDesired + ": " + CommandToString(desired),
                        InpDashboardTextColor);
   color syncColor = InpDashboardTextColor;
   if(g_driftDetectedCurrentChain)
      syncColor = C'190,50,60';
   else if(g_offFlatGuardArmed && !g_offReassertRequested)
      syncColor = C'0,120,80';
   else if(g_offReassertRequested)
      syncColor = C'180,110,0';
   SetPanelColumnLabel("POSITIONS", false, 282,
                       StringFormat("CCBSN Pos: %d | Lots: %.2f",
                                    g_ccbsnPositionCount,
                                    g_ccbsnPositionVolume),
                       g_ccbsnPositionCount > 0 ? C'180,110,0' :
                       InpDashboardTextColor);
   SetPanelColumnLabel("SYNC", true, 282,
                       "Sync: " + g_syncState,
                       syncColor);
   SetPanelColumnLabel("TICKET", false, 302,
                       StringFormat("%s: #%I64u", InpTextCommand, g_commandTicket),
                       InpDashboardTextColor);
   SetPanelColumnLabel("TIME", true, 302,
                       InpTextDecision + ": " +
                                    (g_lastDecisionTime > 0
                                       ? TimeToString(g_lastDecisionTime,
                                                      TIME_DATE | TIME_MINUTES)
                                       : "waiting"),
                       InpDashboardTextColor);
   SetWrappedPanelLabel("CONTROL_ERROR", 322,
                        "Control info: " + g_lastControlError +
                        " | Sync info: " + g_lastSyncReason,
                        g_controlState == CCBSN_CONTROL_ERROR ? C'190,50,60' :
                        InpDashboardTextColor);
  }

//+------------------------------------------------------------------+
//| EMA23 M15 line visualization                                     |
//+------------------------------------------------------------------+
void DeleteEMAVisualization()
  {
   ObjectsDeleteAll(0, g_objectPrefix + "EMA.");
   ArrayResize(g_emaObjectNames, 0);
  }

bool CreateOrMoveEMASegment(const string name,
                            const datetime time1,
                            const double price1,
                            const datetime time2,
                            const double price2,
                            const bool trackObject)
  {
   bool created = false;
   if(ObjectFind(0, name) < 0)
     {
      if(!ObjectCreate(0, name, OBJ_TREND, 0, time1, price1, time2, price2))
        {
         PrintFormat("UI ERROR | Cannot create EMA segment %s | error=%d",
                     name, GetLastError());
         return false;
        }
      created = true;
     }

   ObjectMove(0, name, 0, time1, price1);
   ObjectMove(0, name, 1, time2, price2);
   ObjectSetInteger(0, name, OBJPROP_COLOR,
                    ColorWithOpacity(InpEMALineColor, InpEMAOpacityPercent));
   ObjectSetInteger(0, name, OBJPROP_STYLE, InpEMALineStyle);
   ObjectSetInteger(0, name, OBJPROP_WIDTH, InpEMALineWidth);
   ObjectSetInteger(0, name, OBJPROP_RAY_RIGHT, false);
   ObjectSetInteger(0, name, OBJPROP_BACK, false);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_SELECTED, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, false);
   SetObjectTooltip(name,
                    StringFormat("EMA%d M15\n%s -> %s",
                                 InpEMAPeriod,
                                 TimeToString(time1, TIME_DATE | TIME_MINUTES),
                                 TimeToString(time2, TIME_DATE | TIME_MINUTES)));
   if(created && trackObject)
      TrackEMAObject(name);
   return true;
  }

void UpdateLiveEMAVisualization()
  {
   if(!InpShowEMAOnChart || g_emaHandle == INVALID_HANDLE)
      return;

   MqlRates rates[];
   double emaValues[];
   ArraySetAsSeries(rates, true);
   ArraySetAsSeries(emaValues, true);
   if(CopyRates(_Symbol, DECISION_TIMEFRAME, 0, 2, rates) != 2)
      return;
   if(CopyBuffer(g_emaHandle, 0, 0, 2, emaValues) != 2)
      return;
   if(emaValues[0] == EMPTY_VALUE || emaValues[1] == EMPTY_VALUE)
      return;

   datetime liveEnd = TimeCurrent();
   if(liveEnd <= rates[1].time)
      liveEnd = rates[0].time;
   CreateOrMoveEMASegment(g_objectPrefix + "EMA.LIVE",
                          rates[1].time, emaValues[1],
                          liveEnd, emaValues[0], false);
  }

void RebuildEMAVisualization()
  {
   DeleteEMAVisualization();
   if(!InpShowEMAOnChart || g_emaHandle == INVALID_HANDLE)
      return;

   int requested = InpEMADisplayBars + 2;
   MqlRates rates[];
   double emaValues[];
   ArraySetAsSeries(rates, true);
   ArraySetAsSeries(emaValues, true);
   int ratesCopied = CopyRates(_Symbol, DECISION_TIMEFRAME, 0, requested, rates);
   int emaCopied = CopyBuffer(g_emaHandle, 0, 0, requested, emaValues);
   int available = ratesCopied;
   if(emaCopied < available) available = emaCopied;
   if(available < 3)
     {
      Print("EMA DISPLAY WAIT | M15 EMA data is not ready.");
      return;
     }

   int oldestShift = available - 1;
   for(int shift = oldestShift; shift >= 2; shift--)
     {
      string name = g_objectPrefix + "EMA." + TimeKey(rates[shift - 1].time);
      CreateOrMoveEMASegment(name,
                             rates[shift].time, emaValues[shift],
                             rates[shift - 1].time, emaValues[shift - 1], true);
     }
   UpdateLiveEMAVisualization();
  }

//+------------------------------------------------------------------+
//| Audit                                                            |
//+------------------------------------------------------------------+
void AuditEvent(const string eventType,
                const datetime eventTime,
                const string reason,
                const bool historical)
  {
   if(!historical)
      PrintFormat("CCBSN_TZ | %s | %s | state=%s | close=%s atr=%s ema=%s d=%s | %s",
                  TimeToString(eventTime, TIME_DATE | TIME_MINUTES), eventType,
                  StateToString(g_state), FormatPrice(g_lastClose),
                  FormatPrice(g_lastATR), FormatPrice(g_lastEMA),
                  FormatPrice(g_lastDistance), reason);

   if(historical || !InpWriteCsvAudit)
      return;

   int handle = FileOpen(InpCsvFileName,
                         FILE_READ | FILE_WRITE | FILE_CSV | FILE_ANSI | FILE_SHARE_READ,
                         ';');
   if(handle == INVALID_HANDLE)
     {
      PrintFormat("AUDIT ERROR | FileOpen failed | file=%s error=%d",
                  InpCsvFileName, GetLastError());
      return;
     }

   if(FileSize(handle) == 0)
      FileWrite(handle, "policy", "version", "symbol", "event_time", "event",
                "state", "close", "atr", "atr_period", "min_atr", "ema",
                "ema_period", "distance", "max_above_ema", "min_below_ema",
                "pass_count", "ccbsn_magic", "controller_magic", "control_mode",
                 "control_state", "desired_command", "pending_command",
                 "ticket", "cancel_requested", "ccbsn_positions",
                 "ccbsn_volume", "sync_state", "drift_count", "reason");
   FileSeek(handle, 0, SEEK_END);
   FileWrite(handle, POLICY_ID, POLICY_VERSION, _Symbol,
             TimeToString(eventTime, TIME_DATE | TIME_MINUTES | TIME_SECONDS),
             eventType, StateToString(g_state),
             FormatPrice(g_lastClose), FormatPrice(g_lastATR),
             InpATRPeriod, FormatPrice(InpMinATRPrice), FormatPrice(g_lastEMA),
             InpEMAPeriod, FormatPrice(g_lastDistance),
             FormatPrice(InpMaxAboveEMAPrice),
             FormatPrice(InpMinBelowEMAPrice), g_consecutivePassCount,
             StringFormat("%I64u", InpCCBSNMagic),
             StringFormat("%I64u", InpControllerMagic),
             ControlModeToString(InpControlMode),
             ControlStateToString(g_controlState),
             CommandToString(DesiredCommand()),
              CommandToString(g_pendingCommand),
              StringFormat("%I64u", g_commandTicket),
              g_commandCancelRequested ? "true" : "false",
              g_ccbsnPositionCount, DoubleToString(g_ccbsnPositionVolume, 2),
              g_syncState, g_driftCount, reason);
   FileFlush(handle);
   FileClose(handle);
  }

int ReadCCBSNPositionSnapshot(double &totalVolume)
  {
   totalVolume = 0.0;
   int count = 0;
   for(int index = PositionsTotal() - 1; index >= 0; index--)
     {
      ulong ticket = PositionGetTicket(index);
      if(ticket == 0)
         continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol)
         continue;
      if((ulong)PositionGetInteger(POSITION_MAGIC) != InpCCBSNMagic)
         continue;
      count++;
      totalVolume += PositionGetDouble(POSITION_VOLUME);
     }
   return count;
  }

void RaisePositionDriftAlert(const string context)
  {
   datetime now = TimeCurrent();
   g_driftCount++;
   g_driftDetectedCurrentChain = true;
   g_offReassertRequested = true;
   g_syncState = "DRIFT: NEW CCBSN POSITION";
   g_lastSyncReason = "POSITION_OPENED_WHILE_OFF_FLAT_GUARDED:" + context;

   double markerPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   if(markerPrice <= 0.0)
      markerPrice = g_lastClose;
   CreateEventMarker("NC_DRIFT_DETECTED", now, markerPrice,
                     "NC DRIFT",
                     "CCBSN position appeared after policy OFF was flat-guarded.");
   AuditEvent("NC_DRIFT_DETECTED", now, g_lastSyncReason, false);
   PrintFormat("SYNC CRITICAL | New CCBSN position while policy OFF | positions=%d volume=%.2f | %s",
               g_ccbsnPositionCount, g_ccbsnPositionVolume, context);

   if(g_lastDriftAlertTime == 0 ||
      now - g_lastDriftAlertTime >= InpDriftAlertCooldownSeconds)
     {
      Alert(StringFormat("CCBSN SYNC DRIFT: policy OFF but a new Magic %I64u position appeared on %s.",
                         InpCCBSNMagic, _Symbol));
      g_lastDriftAlertTime = now;
     }
  }

void RefreshCCBSNPositionSync(const string context)
  {
   double currentVolume = 0.0;
   int currentCount = ReadCCBSNPositionSnapshot(currentVolume);
   int previousCount = g_ccbsnPositionCount;
   bool wasReady = g_positionSnapshotReady;

   g_ccbsnPositionCount = currentCount;
   g_ccbsnPositionVolume = currentVolume;
   g_positionSnapshotReady = true;

   if(InpControlMode != CCBSN_CONTROL_ENABLED)
     {
      g_syncState = "NOT CONTROLLED";
      g_lastSyncReason = "CONTROL_MODE_NOT_ENABLED";
      g_offFlatGuardArmed = false;
      g_offReassertRequested = false;
      g_driftDetectedCurrentChain = false;
      return;
     }

   ENUM_CCBSN_COMMAND desired = DesiredCommand();
   if(!wasReady)
     {
      g_lastSyncDesired = desired;
      g_driftDetectedCurrentChain = false;
      if(desired == CCBSN_COMMAND_NEW_CYCLE_OFF)
        {
         g_offFlatGuardArmed = currentCount == 0;
         g_offReassertRequested =
            !IsConfirmedForCommand(CCBSN_COMMAND_NEW_CYCLE_OFF) &&
            g_commandTicket == 0;
         g_lastSyncReason = g_offReassertRequested
                            ? "INITIAL_OFF_ACK_MISSING:" + context
                            : "INITIAL_OFF_ACK_RESTORED:" + context;
        }
      else
        {
         g_offFlatGuardArmed = false;
         g_offReassertRequested = false;
         g_syncState = "POLICY ALLOW";
         g_lastSyncReason = "INITIAL_POLICY_ON:" + context;
        }
     }
   else if(desired != g_lastSyncDesired)
     {
      g_lastSyncDesired = desired;
      g_driftDetectedCurrentChain = false;
      if(desired == CCBSN_COMMAND_NEW_CYCLE_OFF)
        {
         g_offFlatGuardArmed = currentCount == 0;
         g_offReassertRequested = true;
         g_lastSyncReason = "POLICY_CHANGED_TO_OFF:" + context;
        }
      else
        {
         g_offFlatGuardArmed = false;
         g_offReassertRequested = false;
         g_syncState = "POLICY ALLOW";
         g_lastSyncReason = "POLICY_CHANGED_TO_ON:" + context;
        }
     }

   if(desired != CCBSN_COMMAND_NEW_CYCLE_OFF)
     {
      g_syncState = "POLICY ALLOW";
      return;
     }

   if(currentCount == 0)
     {
      bool newlyFlat = wasReady && previousCount > 0;
      if(newlyFlat || !g_offFlatGuardArmed)
        {
         g_offFlatGuardArmed = true;
         g_offReassertRequested = true;
         g_driftDetectedCurrentChain = false;
         g_lastSyncReason = newlyFlat
                            ? "CCBSN_CHAIN_BECAME_FLAT:" + context
                            : "OFF_FLAT_GUARD_ARMED:" + context;
         if(newlyFlat)
            AuditEvent("OFF_FLAT_GUARD_ARMED", TimeCurrent(),
                       g_lastSyncReason, false);
        }
      g_syncState = g_offReassertRequested
                    ? "OFF FLAT: REASSERT PENDING"
                    : "OFF FLAT GUARDED";
     }
   else
     {
      if(wasReady && previousCount == 0 && g_offFlatGuardArmed &&
         !g_driftDetectedCurrentChain)
         RaisePositionDriftAlert(context);
      else if(g_driftDetectedCurrentChain)
         g_syncState = "DRIFT: ACTIVE CHAIN";
      else
         g_syncState = "OFF: EXISTING CHAIN";
     }
  }

//+------------------------------------------------------------------+
//| Policy calculation                                               |
//+------------------------------------------------------------------+
bool EvaluateChecklist(const double closePrice,
                       const double atrValue,
                       const double emaValue,
                       ENUM_ZONE_BRANCH &branch,
                       string &reason)
  {
   branch = ZONE_BRANCH_NONE;
   if(!MathIsValidNumber(closePrice) || !MathIsValidNumber(atrValue) ||
      !MathIsValidNumber(emaValue) || closePrice == EMPTY_VALUE ||
      atrValue == EMPTY_VALUE || emaValue == EMPTY_VALUE ||
      closePrice <= 0.0 || atrValue <= 0.0)
     {
      reason = "M15_DATA_NOT_READY";
      return false;
     }

   if(atrValue < InpMinATRPrice)
     {
      reason = "M15_ATR_BELOW_MIN";
      return false;
     }

   double distance = closePrice - emaValue;
   if(distance >= 0.0 && distance <= InpMaxAboveEMAPrice)
     {
      branch = ZONE_BRANCH_ABOVE_EMA;
      reason = "M15_EMA_ABOVE_WITHIN_MAX";
      return true;
     }
   if(distance < -InpMinBelowEMAPrice)
     {
      branch = ZONE_BRANCH_DEEP_BELOW_EMA;
      reason = "M15_EMA_BELOW_MORE_THAN_MIN";
      return true;
     }

   if(distance < 0.0)
      reason = "M15_EMA_BELOW_WITHIN_MIN";
   else
      reason = "M15_EMA_ABOVE_MORE_THAN_MAX";
   return false;
  }

string FeatureTooltip(const datetime decisionTime, const string eventType, const string reason)
  {
   return StringFormat("%s\n%s\nClose=%s EMA%d=%s D=%s\nATR%d=%s MinATR=%s\n%s",
                       eventType,
                       TimeToString(decisionTime, TIME_DATE | TIME_MINUTES),
                       FormatPrice(g_lastClose), InpEMAPeriod,
                       FormatPrice(g_lastEMA), FormatPrice(g_lastDistance),
                       InpATRPeriod, FormatPrice(g_lastATR),
                       FormatPrice(InpMinATRPrice), reason);
  }

void UpdateActiveZoneObjects(const datetime endTime)
  {
   if(g_activeZoneStart <= 0 || g_activeZoneBaseName == "")
      return;

   double padding = MathMax(g_activeZoneATR * InpZonePaddingATR,
                            SymbolInfoDouble(_Symbol, SYMBOL_POINT) * 10.0);
   double top = g_activeZoneHigh + padding;
   double bottom = g_activeZoneLow - padding;
   color zoneColor = BranchColor(g_activeZoneBranch);
   string fillName = g_activeZoneBaseName + ".FILL";
   string borderName = g_activeZoneBaseName + ".BORDER";
   string tooltip = StringFormat("SIMULATED TRADING ZONE\n%s\nStart=%s\nHigh=%s Low=%s",
                                 BranchToString(g_activeZoneBranch),
                                 TimeToString(g_activeZoneStart, TIME_DATE | TIME_MINUTES),
                                 FormatPrice(g_activeZoneHigh),
                                 FormatPrice(g_activeZoneLow));

   CreateOrMoveRectangle(fillName, g_activeZoneStart, top, endTime, bottom, zoneColor, true);
   CreateOrMoveRectangle(borderName, g_activeZoneStart, top, endTime, bottom, zoneColor, false);
   SetObjectTooltip(fillName, tooltip);
   SetObjectTooltip(borderName, tooltip);
  }

void StartActiveZone(const datetime startTime,
                     const double startPrice,
                     const double atrValue,
                     const ENUM_ZONE_BRANCH branch,
                     const string reason,
                     const bool historical)
  {
   g_state = VISUAL_STATE_ACTIVE;
   g_consecutivePassCount = 0;
   g_activeZoneStart = startTime;
   g_activeZoneHigh = startPrice;
   g_activeZoneLow = startPrice;
   g_activeZoneATR = atrValue;
   g_activeZoneBranch = branch;
   g_activeZoneBaseName = g_objectPrefix + "ZONE." + TimeKey(startTime);

   if(!historical || InpDrawHistory)
     {
      color zoneColor = BranchColor(branch);
      string startLine = g_activeZoneBaseName + ".START";
      string tooltip = FeatureTooltip(startTime, "SIMULATED " + InpTextZoneOn, reason);
      CreateVerticalLine(startLine, startTime, zoneColor, STYLE_DASH, tooltip);
      CreateEventMarker("ON", startTime, startPrice - atrValue * 0.35,
                        InpTextZoneOn, tooltip);
      UpdateActiveZoneObjects(startTime + PeriodSeconds(DECISION_TIMEFRAME));
     }
   AuditEvent("SIMULATED_ZONE_STARTED", startTime, reason, historical);
  }

void EndActiveZone(const datetime endTime,
                   const double endPrice,
                   const string reason,
                   const bool historical)
  {
   if(g_activeZoneStart <= 0)
      return;

   if(!historical || InpDrawHistory)
     {
      UpdateActiveZoneObjects(endTime);
      string fillName = g_activeZoneBaseName + ".FILL";
      string borderName = g_activeZoneBaseName + ".BORDER";
      string startLine = g_activeZoneBaseName + ".START";
      string endLine = g_activeZoneBaseName + ".END";
      string tooltip = FeatureTooltip(endTime, "SIMULATED " + InpTextZoneOff, reason);
      CreateVerticalLine(endLine, endTime, InpOffEventColor, STYLE_DASH, tooltip);
      CreateEventMarker("OFF", endTime, endPrice + g_activeZoneATR * 0.35,
                        InpTextZoneOff, tooltip);

      TrackClosedZoneObject(fillName);
      TrackClosedZoneObject(borderName);
      TrackClosedZoneObject(startLine);
      TrackClosedZoneObject(endLine);
     }
   AuditEvent("SIMULATED_ZONE_ENDED", endTime, reason, historical);

   g_state = VISUAL_STATE_OFF;
   g_consecutivePassCount = 0;
   g_activeZoneStart = 0;
   g_activeZoneHigh = 0.0;
   g_activeZoneLow = 0.0;
   g_activeZoneATR = 0.0;
   g_activeZoneBranch = ZONE_BRANCH_NONE;
   g_activeZoneBaseName = "";
  }

void ProcessDecisionBar(const MqlRates &bar,
                        const double atrValue,
                        const double emaValue,
                        const datetime decisionTime,
                        const bool historical)
  {
   if(g_state == VISUAL_STATE_ACTIVE)
     {
      g_activeZoneHigh = MathMax(g_activeZoneHigh, bar.high);
      g_activeZoneLow = MathMin(g_activeZoneLow, bar.low);
      g_activeZoneATR = atrValue;
     }

   g_lastClose = bar.close;
   g_lastATR = atrValue;
   g_lastEMA = emaValue;
   g_lastDistance = bar.close - emaValue;
   g_lastDecisionTime = decisionTime;

   ENUM_ZONE_BRANCH branch = ZONE_BRANCH_NONE;
   string reason = "";
   bool checklistPass = EvaluateChecklist(bar.close, atrValue, emaValue, branch, reason);
   g_lastChecklistPass = checklistPass;
   g_lastReason = reason;

   if(g_state == VISUAL_STATE_ACTIVE)
     {
      if(!checklistPass)
         EndActiveZone(decisionTime, bar.close, reason, historical);
      else if(!historical || InpDrawHistory)
         UpdateActiveZoneObjects(decisionTime);
      return;
     }

   if(checklistPass)
     {
      g_consecutivePassCount++;
      g_state = VISUAL_STATE_ARMING;
      if(g_consecutivePassCount >= InpEnableConfirmBars)
        {
         StartActiveZone(decisionTime, bar.close, atrValue, branch, reason, historical);
        }
      else if(InpDrawCandidateEvents && (!historical || InpDrawHistory))
        {
         string armText = StringFormat("%s %d/%d", InpTextArming,
                                       g_consecutivePassCount, InpEnableConfirmBars);
         string tooltip = FeatureTooltip(decisionTime, armText, reason);
         CreateEventMarker("ARM" + IntegerToString(g_consecutivePassCount),
                           decisionTime, bar.low - atrValue * 0.20,
                           armText, tooltip);
         AuditEvent("ENABLE_CANDIDATE_STARTED", decisionTime, reason, historical);
        }
     }
   else
     {
      if(g_state == VISUAL_STATE_ARMING && !historical)
         AuditEvent("ENABLE_CANDIDATE_CANCELLED", decisionTime, reason, historical);
      g_consecutivePassCount = 0;
      g_state = VISUAL_STATE_OFF;
     }
  }

//+------------------------------------------------------------------+
//| Data and history                                                 |
//+------------------------------------------------------------------+
void ResetRuntimeState()
  {
   g_state = VISUAL_STATE_OFF;
   g_consecutivePassCount = 0;
   g_activeZoneStart = 0;
   g_activeZoneHigh = 0.0;
   g_activeZoneLow = 0.0;
   g_activeZoneATR = 0.0;
   g_activeZoneBranch = ZONE_BRANCH_NONE;
   g_activeZoneBaseName = "";
   ArrayResize(g_eventObjectNames, 0);
   ArrayResize(g_closedZoneObjectNames, 0);
   ArrayResize(g_emaObjectNames, 0);
  }

bool BuildHistoricalZones()
  {
   ObjectsDeleteAll(0, g_objectPrefix);
   ResetRuntimeState();

   int longestPeriod = InpATRPeriod;
   if(InpEMAPeriod > longestPeriod)
      longestPeriod = InpEMAPeriod;
   int requested = InpDrawHistory ? InpHistoryBars + 1 : longestPeriod + 5;
   MqlRates rates[];
   double atrValues[];
   double emaValues[];
   ArraySetAsSeries(rates, true);
   ArraySetAsSeries(atrValues, true);
   ArraySetAsSeries(emaValues, true);

   int ratesCopied = CopyRates(_Symbol, DECISION_TIMEFRAME, 0, requested, rates);
   int atrCopied = CopyBuffer(g_atrHandle, 0, 0, requested, atrValues);
   int emaCopied = CopyBuffer(g_emaHandle, 0, 0, requested, emaValues);
   int available = ratesCopied;
   if(atrCopied < available) available = atrCopied;
   if(emaCopied < available) available = emaCopied;
   int minimum = longestPeriod + 3;
   if(available < minimum)
     {
      PrintFormat("DATA WAIT | Need at least %d M15 values, available=%d", minimum, available);
      g_state = VISUAL_STATE_DATA_ERROR;
      g_lastReason = "M15_DATA_NOT_READY";
      UpdatePanel();
      return false;
     }

   int oldestShift = available - 1;
   for(int shift = oldestShift; shift >= 1; shift--)
     {
      datetime decisionTime = rates[shift - 1].time;
      ProcessDecisionBar(rates[shift], atrValues[shift], emaValues[shift],
                         decisionTime, true);
     }

   if(!InpDrawHistory && g_state == VISUAL_STATE_ACTIVE)
      UpdateActiveZoneObjects(TimeCurrent());

   g_lastM15BarTime = rates[0].time;
   RebuildEMAVisualization();
   UpdatePanel();
   ChartRedraw(0);
   return true;
  }

bool ReadLatestClosedBar(MqlRates &closedBar,
                         double &atrValue,
                         double &emaValue,
                         datetime &decisionTime)
  {
   MqlRates rates[];
   ArraySetAsSeries(rates, true);
   if(CopyRates(_Symbol, DECISION_TIMEFRAME, 0, 2, rates) != 2)
      return false;

   double atrBuffer[1];
   double emaBuffer[1];
   if(CopyBuffer(g_atrHandle, 0, 1, 1, atrBuffer) != 1)
      return false;
   if(CopyBuffer(g_emaHandle, 0, 1, 1, emaBuffer) != 1)
      return false;

   closedBar = rates[1];
   decisionTime = rates[0].time;
   atrValue = atrBuffer[0];
   emaValue = emaBuffer[0];
   return true;
  }

void UpdateLiveZoneExtent()
  {
   if(g_state != VISUAL_STATE_ACTIVE)
      return;
   double currentHigh = iHigh(_Symbol, DECISION_TIMEFRAME, 0);
   double currentLow = iLow(_Symbol, DECISION_TIMEFRAME, 0);
   if(currentHigh > 0.0) g_activeZoneHigh = MathMax(g_activeZoneHigh, currentHigh);
   if(currentLow > 0.0)  g_activeZoneLow = MathMin(g_activeZoneLow, currentLow);
   UpdateActiveZoneObjects(TimeCurrent());
  }

void ProcessRuntime()
  {
   datetime currentM15Bar = iTime(_Symbol, DECISION_TIMEFRAME, 0);
   if(currentM15Bar <= 0)
     {
      g_state = VISUAL_STATE_DATA_ERROR;
      g_lastReason = "M15_DATA_NOT_READY";
      UpdatePanel();
      return;
     }

   if(g_lastM15BarTime == 0)
     {
      BuildHistoricalZones();
      return;
     }

   if(currentM15Bar != g_lastM15BarTime)
     {
      int elapsed = (int)(currentM15Bar - g_lastM15BarTime);
      if(elapsed != PeriodSeconds(DECISION_TIMEFRAME))
        {
         PrintFormat("DATA RECONCILE | M15 sequence gap=%d sec. Rebuilding all visual state.",
                     elapsed);
         BuildHistoricalZones();
         return;
        }

      MqlRates closedBar;
      double atrValue = 0.0;
      double emaValue = 0.0;
      datetime decisionTime = 0;
      if(!ReadLatestClosedBar(closedBar, atrValue, emaValue, decisionTime))
        {
         g_lastReason = "M15_DATA_NOT_READY";
         g_lastChecklistPass = false;
         if(g_state == VISUAL_STATE_ACTIVE)
            EndActiveZone(currentM15Bar, g_lastClose, g_lastReason, false);
         else
            g_state = VISUAL_STATE_DATA_ERROR;
         AuditEvent("DATA_NOT_READY", currentM15Bar, g_lastReason, false);
         UpdatePanel();
         return;
        }

      ProcessDecisionBar(closedBar, atrValue, emaValue, decisionTime, false);
      g_lastM15BarTime = currentM15Bar;
      RebuildEMAVisualization();
      UpdatePanel();
      ChartRedraw(0);
     }

   UpdateLiveZoneExtent();
   UpdateLiveEMAVisualization();
  }

//+------------------------------------------------------------------+
//| CCBSN New Cycle command transport                               |
//+------------------------------------------------------------------+
int VolumeDigits(const double step)
  {
   for(int digits = 0; digits <= 8; digits++)
     {
      if(MathAbs(NormalizeDouble(step, digits) - step) < 0.00000001)
         return digits;
     }
   return 8;
  }

double NormalizedCommandVolume()
  {
   double minimum = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double maximum = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   double step = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   if(minimum <= 0.0 || maximum < minimum || step <= 0.0)
      return 0.0;

   double requested = InpCommandVolume <= 0.0 ? minimum : InpCommandVolume;
   requested = MathMax(minimum, MathMin(maximum, requested));
   double steps = MathFloor((requested - minimum) / step + 0.0000001);
   return NormalizeDouble(minimum + steps * step, VolumeDigits(step));
  }

double NormalizedCommandPrice()
  {
   double tickSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   if(tickSize <= 0.0)
      tickSize = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   if(tickSize <= 0.0)
      return 0.0;
   return NormalizeDouble(MathRound(InpCommandPrice / tickSize) * tickSize,
                          (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS));
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

bool RecoverRetryableControlError()
  {
   if(g_controlState != CCBSN_CONTROL_ERROR || g_commandTicket != 0 ||
      !IsRetryableEnvironmentError())
      return g_controlState != CCBSN_CONTROL_ERROR;

   string previousError = g_lastControlError;
   if(!IsControlTradeAllowed())
      return false;

   g_controlState = CCBSN_CONTROL_UNKNOWN;
   g_lastControlError = "RECOVERED_FROM:" + previousError;
   Print("CONTROL RECOVER | " + previousError + " cleared; synchronization will retry.");
   AuditEvent("CONTROL_ENVIRONMENT_RECOVERED", TimeCurrent(),
              previousError, false);
   return true;
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
   double safeDistance = MathMax((double)stopsLevel * point, 100.0 * point);
   if(price <= tick.ask + safeDistance)
     {
      g_lastControlError = "COMMAND_PRICE_NOT_SAFELY_ABOVE_ASK";
      return false;
     }
   return true;
  }

bool IsControllerOrderSelected(const ulong ticket)
  {
   if(ticket == 0 || !OrderSelect(ticket))
      return false;
   if(OrderGetString(ORDER_SYMBOL) != _Symbol)
      return false;
   if((ulong)OrderGetInteger(ORDER_MAGIC) != InpControllerMagic)
      return false;
   return StringFind(OrderGetString(ORDER_COMMENT), "CCBSN_CTRL:") == 0;
  }

ENUM_CCBSN_COMMAND SelectedOrderCommand()
  {
   ENUM_ORDER_TYPE type = (ENUM_ORDER_TYPE)OrderGetInteger(ORDER_TYPE);
   if(type == ORDER_TYPE_SELL_LIMIT)
      return CCBSN_COMMAND_NEW_CYCLE_ON;
   if(type == ORDER_TYPE_BUY_STOP)
      return CCBSN_COMMAND_NEW_CYCLE_OFF;
   return CCBSN_COMMAND_NONE;
  }

string ControlStorageKey(const string suffix)
  {
   return "CCBSN.NC." + IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN)) +
          "." + _Symbol + "." + IntegerToString((long)InpCCBSNMagic) +
          "." + IntegerToString((long)InpControllerMagic) + "." + suffix;
  }

string ControllerLockKey(const string suffix)
  {
   return "CCBSN.NC.LOCK." +
          IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN)) + "." +
          _Symbol + "." + IntegerToString((long)InpCCBSNMagic) + "." + suffix;
  }

bool AcquireControllerLock()
  {
   if(InpControlMode == CCBSN_CONTROL_VISUAL_ONLY || !InpSingleControllerLock)
      return true;

   ulong rawChart = (ulong)ChartID();
   ulong rawTick = GetTickCount64();
   ulong exactToken = (rawChart % 9000000000) * 1000000 +
                      (rawTick % 1000000);
   if(exactToken == 0) exactToken = 1;
   g_instanceToken = (double)exactToken; // Remains below the exact integer limit of double
   string ownerKey = ControllerLockKey("OWNER");
   string heartbeatKey = ControllerLockKey("HEARTBEAT");
   if(!GlobalVariableCheck(ownerKey))
      GlobalVariableSet(ownerKey, 0.0);

   double currentOwner = GlobalVariableGet(ownerKey);
   datetime heartbeat = GlobalVariableCheck(heartbeatKey)
                        ? (datetime)MathRound(GlobalVariableGet(heartbeatKey)) : 0;
   datetime now = TimeLocal();
   if(currentOwner == g_instanceToken)
     {
      GlobalVariableSet(heartbeatKey, (double)now);
      g_controllerLockHeld = true;
      return true;
     }

   if(currentOwner != 0.0 && heartbeat > 0 &&
      now - heartbeat <= InpControllerLockStaleSeconds)
     {
      PrintFormat("SAFETY BLOCK | Another Controller owns %s | owner=%.0f age=%d sec",
                  _Symbol, currentOwner, (int)(now - heartbeat));
      return false;
     }

   ResetLastError();
   if(!GlobalVariableSetOnCondition(ownerKey, g_instanceToken, currentOwner))
     {
      PrintFormat("SAFETY BLOCK | Cannot acquire Controller mutex | error=%d",
                  GetLastError());
      return false;
     }
   GlobalVariableSet(heartbeatKey, (double)now);
   GlobalVariablesFlush();
   g_controllerLockHeld = true;
   return true;
  }

void RefreshControllerLock()
  {
   if(!InpSingleControllerLock || !g_controllerLockHeld)
      return;
   string ownerKey = ControllerLockKey("OWNER");
   if(!GlobalVariableCheck(ownerKey) ||
      GlobalVariableGet(ownerKey) != g_instanceToken)
     {
      g_controllerLockHeld = false;
      g_controlState = CCBSN_CONTROL_ERROR;
      g_lastControlError = "CONTROLLER_MUTEX_LOST";
      Print("CONTROL ERROR | Controller mutex ownership was lost.");
      return;
     }
   GlobalVariableSet(ControllerLockKey("HEARTBEAT"), (double)TimeLocal());
  }

void ReleaseControllerLock()
  {
   if(!InpSingleControllerLock || !g_controllerLockHeld)
      return;
   string ownerKey = ControllerLockKey("OWNER");
   if(GlobalVariableCheck(ownerKey) &&
      GlobalVariableSetOnCondition(ownerKey, 0.0, g_instanceToken))
      GlobalVariableSet(ControllerLockKey("HEARTBEAT"), 0.0);
   g_controllerLockHeld = false;
  }

void SaveConfirmedControlState()
  {
   if(!InpPersistConfirmedState)
      return;
   double storedValue = 0.0;
   if(g_controlState == CCBSN_CONTROL_ON_CONFIRMED)
      storedValue = 1.0;
   else if(g_controlState == CCBSN_CONTROL_OFF_CONFIRMED)
      storedValue = 2.0;
   if(storedValue > 0.0)
     {
      GlobalVariableSet(ControlStorageKey("STATE"), storedValue);
      GlobalVariablesFlush();
     }
  }

void SaveStoredTicket(const ulong ticket)
  {
   ulong highPart = ticket / TICKET_STORAGE_BASE;
   ulong lowPart = ticket % TICKET_STORAGE_BASE;
   GlobalVariableSet(ControlStorageKey("P_TICKET_HI"), (double)highPart);
   GlobalVariableSet(ControlStorageKey("P_TICKET_LO"), (double)lowPart);
   GlobalVariableDel(ControlStorageKey("P_TICKET")); // v3.1 legacy key
  }

ulong LoadStoredTicket()
  {
   string highKey = ControlStorageKey("P_TICKET_HI");
   string lowKey = ControlStorageKey("P_TICKET_LO");
   if(GlobalVariableCheck(highKey) && GlobalVariableCheck(lowKey))
     {
      ulong highPart = (ulong)MathRound(GlobalVariableGet(highKey));
      ulong lowPart = (ulong)MathRound(GlobalVariableGet(lowKey));
      return highPart * TICKET_STORAGE_BASE + lowPart;
     }

   string legacyKey = ControlStorageKey("P_TICKET");
   if(GlobalVariableCheck(legacyKey))
      return (ulong)MathRound(GlobalVariableGet(legacyKey));
   return 0;
  }

void SavePendingCommand()
  {
   if(g_commandTicket == 0 || g_pendingCommand == CCBSN_COMMAND_NONE)
      return;
   SaveStoredTicket(g_commandTicket);
   GlobalVariableSet(ControlStorageKey("P_COMMAND"), (double)g_pendingCommand);
   GlobalVariableSet(ControlStorageKey("P_SENT"), (double)g_commandSentTime);
   GlobalVariableSet(ControlStorageKey("P_CANCEL"),
                     g_commandCancelRequested ? 1.0 : 0.0);
   GlobalVariableSet(ControlStorageKey("P_CANCEL_REASON"),
                     (double)g_commandCancelCode);
   GlobalVariablesFlush();
  }

void DeleteStoredPendingCommand()
  {
   GlobalVariableDel(ControlStorageKey("P_TICKET"));
   GlobalVariableDel(ControlStorageKey("P_TICKET_HI"));
   GlobalVariableDel(ControlStorageKey("P_TICKET_LO"));
   GlobalVariableDel(ControlStorageKey("P_COMMAND"));
   GlobalVariableDel(ControlStorageKey("P_SENT"));
   GlobalVariableDel(ControlStorageKey("P_CANCEL"));
   GlobalVariableDel(ControlStorageKey("P_CANCEL_REASON"));
  }

void ClearStoredControlOwnership()
  {
   GlobalVariableDel(ControlStorageKey("STATE"));
   DeleteStoredPendingCommand();
   GlobalVariablesFlush();
   g_commandTicket = 0;
   g_commandSentTime = 0;
   g_pendingCommand = CCBSN_COMMAND_NONE;
   g_commandCancelRequested = false;
   g_commandCancelReason = "";
   g_commandCancelCode = COMMAND_CANCEL_NONE;
  }

bool DeleteActiveControllerCommands(const string context)
  {
   bool allDeleted = true;
   for(int index = OrdersTotal() - 1; index >= 0; index--)
     {
      ulong ticket = OrderGetTicket(index);
      if(!IsControllerOrderSelected(ticket))
         continue;
      bool deleted = g_trade.OrderDelete(ticket);
      uint retcode = g_trade.ResultRetcode();
      if(!deleted ||
         (retcode != TRADE_RETCODE_DONE && retcode != TRADE_RETCODE_PLACED))
        {
         allDeleted = false;
         PrintFormat("HANDOVER ERROR | Cannot delete controller command #%I64u | %s | %u %s",
                     ticket, context, retcode,
                     g_trade.ResultRetcodeDescription());
        }
      else
         PrintFormat("HANDOVER | Deleted controller command #%I64u | %s",
                     ticket, context);
     }
   return allDeleted;
  }

void LoadStoredPendingForHandover()
  {
   if(g_commandTicket > 0)
      return;
   g_commandTicket = LoadStoredTicket();
   if(g_commandTicket == 0)
      return;
   string commandKey = ControlStorageKey("P_COMMAND");
   if(GlobalVariableCheck(commandKey))
      g_pendingCommand =
         (ENUM_CCBSN_COMMAND)(int)MathRound(GlobalVariableGet(commandKey));
  }

bool VerifyNoControllerCommandsRemain()
  {
   for(int index = OrdersTotal() - 1; index >= 0; index--)
     {
      ulong ticket = OrderGetTicket(index);
      if(IsControllerOrderSelected(ticket))
        {
         g_lastControlError = "HANDOVER_WAITING_ACTIVE_COMMAND_" +
                              IntegerToString((long)ticket);
         return false;
        }
     }

   if(g_commandTicket == 0)
      return true;
   if(OrderSelect(g_commandTicket))
     {
      g_lastControlError = "HANDOVER_WAITING_TRACKED_COMMAND";
      return false;
     }
   if(!HistoryOrderSelect(g_commandTicket))
     {
      g_lastControlError = "HANDOVER_CANNOT_VERIFY_COMMAND_HISTORY";
      return false;
     }

   ENUM_ORDER_STATE state =
      (ENUM_ORDER_STATE)HistoryOrderGetInteger(g_commandTicket, ORDER_STATE);
   if(state == ORDER_STATE_FILLED || state == ORDER_STATE_PARTIAL)
     {
      g_lastControlError = "CRITICAL_HANDOVER_COMMAND_EXECUTED";
      Alert("CCBSN HANDOVER ERROR: command order was executed. Check account immediately.");
      return false;
     }
   return true;
  }

bool PerformManualHandover(const string context)
  {
   if(g_manualHandoverComplete)
      return true;
   if(InpSingleControllerLock && !g_controllerLockHeld)
     {
      g_controlState = CCBSN_CONTROL_ERROR;
      g_lastControlError = "MANUAL_HANDOVER_REQUIRES_MUTEX";
      PrintFormat("HANDOVER BLOCK | Mutex not held | %s", context);
      return false;
     }
   LoadStoredPendingForHandover();
   if(!DeleteActiveControllerCommands(context))
     {
      g_controlState = CCBSN_CONTROL_ERROR;
      g_lastControlError = "MANUAL_HANDOVER_COMMAND_DELETE_FAILED";
      return false;
     }
   if(!VerifyNoControllerCommandsRemain())
     {
      g_controlState = CCBSN_CONTROL_ERROR;
      PrintFormat("HANDOVER WAIT | %s | %s", context, g_lastControlError);
      return false;
     }
   ClearStoredControlOwnership();
   g_controlState = CCBSN_CONTROL_BOT1_MANUAL;
   g_lastControlError = "MANUAL_HANDOVER_READY";
   g_manualHandoverComplete = true;
   AuditEvent("BOT1_MANUAL_HANDOVER_READY", TimeCurrent(), context, false);
   PrintFormat("HANDOVER READY | Bot 1 owns New Cycle manual control | %s",
               context);
   return true;
  }

void LoadStoredControlState()
  {
   string stateKey = ControlStorageKey("STATE");
   if(!InpPersistConfirmedState)
      GlobalVariableDel(stateKey);
   else if(InpForceSyncOnInit)
     {
      GlobalVariableDel(stateKey);
      g_controlState = CCBSN_CONTROL_UNKNOWN;
      g_lastControlError = "FORCE_SYNC_REQUESTED_STATE_CLEARED";
     }
   else if(!InpForceSyncOnInit && GlobalVariableCheck(stateKey))
     {
      int storedState = (int)MathRound(GlobalVariableGet(stateKey));
      if(storedState == 1)
        {
         g_controlState = CCBSN_CONTROL_ON_CONFIRMED;
         g_lastControlError = "RESTORED_NC_ENABLED";
        }
      else if(storedState == 2)
        {
         g_controlState = CCBSN_CONTROL_OFF_CONFIRMED;
         g_lastControlError = "RESTORED_NC_DISABLED";
        }
     }
   string commandKey = ControlStorageKey("P_COMMAND");
   ulong storedTicket = LoadStoredTicket();
   if(storedTicket > 0 && GlobalVariableCheck(commandKey))
     {
      ENUM_CCBSN_COMMAND storedCommand =
         (ENUM_CCBSN_COMMAND)(int)MathRound(GlobalVariableGet(commandKey));
      if(storedTicket > 0 &&
         (storedCommand == CCBSN_COMMAND_NEW_CYCLE_ON ||
          storedCommand == CCBSN_COMMAND_NEW_CYCLE_OFF))
        {
         g_commandTicket = storedTicket;
         g_pendingCommand = storedCommand;
         string sentKey = ControlStorageKey("P_SENT");
         g_commandSentTime = GlobalVariableCheck(sentKey)
                             ? (datetime)MathRound(GlobalVariableGet(sentKey)) : 0;
         string cancelKey = ControlStorageKey("P_CANCEL");
         g_commandCancelRequested = GlobalVariableCheck(cancelKey) &&
                                    GlobalVariableGet(cancelKey) > 0.5;
         string cancelReasonKey = ControlStorageKey("P_CANCEL_REASON");
         g_commandCancelCode = GlobalVariableCheck(cancelReasonKey)
            ? (ENUM_COMMAND_CANCEL_REASON)(int)MathRound(
                 GlobalVariableGet(cancelReasonKey))
            : COMMAND_CANCEL_NONE;
         if(g_commandCancelRequested)
            g_commandCancelReason = CancelReasonText(g_commandCancelCode);
         g_controlState = storedCommand == CCBSN_COMMAND_NEW_CYCLE_ON
                          ? CCBSN_CONTROL_ON_PENDING
                          : CCBSN_CONTROL_OFF_PENDING;
         g_lastControlError = g_commandCancelRequested
                              ? "RESTORED_PENDING_CANCELLATION"
                              : "RESTORED_PENDING_COMMAND";
        }
     }

   PrintFormat("CONTROL RESTORE | applied=%s pending=%s ticket=%I64u",
               ControlStateToString(g_controlState),
               CommandToString(g_pendingCommand), g_commandTicket);
  }

bool RecoverPendingControllerOrder()
  {
   ulong previouslyTrackedTicket = g_commandTicket;
   int matches = 0;
   ulong recoveredTicket = 0;
   datetime recoveredTime = 0;
   ENUM_CCBSN_COMMAND recoveredCommand = CCBSN_COMMAND_NONE;

   for(int index = OrdersTotal() - 1; index >= 0; index--)
     {
      ulong ticket = OrderGetTicket(index);
      if(!IsControllerOrderSelected(ticket))
         continue;
      ENUM_CCBSN_COMMAND command = SelectedOrderCommand();
      if(command == CCBSN_COMMAND_NONE)
         continue;
      matches++;
      recoveredTicket = ticket;
      recoveredTime = (datetime)OrderGetInteger(ORDER_TIME_SETUP);
      recoveredCommand = command;
     }

   if(matches > 1)
     {
      g_controlState = CCBSN_CONTROL_ERROR;
      g_lastControlError = "MULTIPLE_CONTROLLER_COMMANDS_FOUND";
      Print("CONTROL ERROR | Multiple active controller commands found; no new command will be sent.");
      return false;
     }
   if(matches == 1)
     {
      if(previouslyTrackedTicket != recoveredTicket)
        {
         g_commandCancelRequested = false;
         g_commandCancelReason = "";
         g_commandCancelCode = COMMAND_CANCEL_NONE;
        }
      g_commandTicket = recoveredTicket;
      g_commandSentTime = recoveredTime;
      g_pendingCommand = recoveredCommand;
      g_controlState = recoveredCommand == CCBSN_COMMAND_NEW_CYCLE_ON
                       ? CCBSN_CONTROL_ON_PENDING
                       : CCBSN_CONTROL_OFF_PENDING;
      g_lastControlError = "RECOVERED_PENDING_COMMAND";
      SavePendingCommand();
      PrintFormat("CONTROL RECOVER | ticket=%I64u command=%s",
                  g_commandTicket, CommandToString(g_pendingCommand));
     }
   return true;
  }

void MarkCommandConfirmed(const ENUM_CCBSN_COMMAND command)
  {
   datetime confirmedTime = TimeCurrent();
   double markerPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   if(markerPrice <= 0.0)
      markerPrice = g_lastClose;
   g_controlState = command == CCBSN_COMMAND_NEW_CYCLE_ON
                    ? CCBSN_CONTROL_ON_CONFIRMED
                    : CCBSN_CONTROL_OFF_CONFIRMED;
   g_lastControlError = "CCBSN_COMMAND_CONSUMED";
   if(command == CCBSN_COMMAND_NEW_CYCLE_OFF)
     {
      g_offReassertRequested = false;
      g_offFlatGuardArmed = g_ccbsnPositionCount == 0;
      if(g_driftDetectedCurrentChain)
         g_syncState = "DRIFT: OFF ACK RECEIVED";
      else if(g_ccbsnPositionCount == 0)
         g_syncState = "OFF FLAT GUARDED";
      else
         g_syncState = "OFF: EXISTING CHAIN";
      g_lastSyncReason = "OFF_COMMAND_CONSUMED";
     }
   else
     {
      g_offFlatGuardArmed = false;
      g_offReassertRequested = false;
      g_driftDetectedCurrentChain = false;
      g_syncState = "POLICY ALLOW";
      g_lastSyncReason = "ON_COMMAND_CONSUMED";
     }
   SaveConfirmedControlState();

   string eventName = command == CCBSN_COMMAND_NEW_CYCLE_ON
                      ? "CCBSN_ON_CONFIRMED" : "CCBSN_OFF_CONFIRMED";
   string eventText = command == CCBSN_COMMAND_NEW_CYCLE_ON
                      ? "NC ENABLED" : "NC DISABLED";
   color eventColor = command == CCBSN_COMMAND_NEW_CYCLE_ON
                      ? BranchColor(g_activeZoneBranch) : InpOffEventColor;
   CreateVerticalLine(g_objectPrefix + "CONTROL." + eventName + "." +
                      TimeKey(confirmedTime), confirmedTime, eventColor,
                      STYLE_DOT, eventName);
   CreateEventMarker(eventName, confirmedTime, markerPrice,
                     eventText,
                     "Pending command was removed; CCBSN consumption assumed.");
   AuditEvent(eventName, confirmedTime, "CCBSN_COMMAND_CONSUMED", false);
   PrintFormat("CONTROL CONFIRMED | %s | ticket=%I64u",
               CommandToString(command), g_commandTicket);
  }

void ClearPendingCommand()
  {
   DeleteStoredPendingCommand();
   g_commandTicket = 0;
   g_commandSentTime = 0;
   g_pendingCommand = CCBSN_COMMAND_NONE;
   g_commandCancelRequested = false;
   g_commandCancelReason = "";
   g_commandCancelCode = COMMAND_CANCEL_NONE;
  }

bool RequestCommandCancellation(const string reason)
  {
   if(g_commandTicket == 0)
      return true;
   if(!g_commandCancelRequested)
     {
      g_commandCancelRequested = true;
      g_commandCancelReason = reason;
      g_commandCancelCode = CancelReasonCode(reason);
      SavePendingCommand(); // Persist intent before the server-side delete.
     }
   bool ok = g_trade.OrderDelete(g_commandTicket);
   uint retcode = g_trade.ResultRetcode();
   if(!ok || (retcode != TRADE_RETCODE_DONE && retcode != TRADE_RETCODE_PLACED))
     {
      g_controlState = CCBSN_CONTROL_ERROR;
      g_lastControlError = "COMMAND_DELETE_FAILED:" +
                           g_trade.ResultRetcodeDescription();
      PrintFormat("CONTROL ERROR | Cannot delete ticket=%I64u | retcode=%u %s",
                  g_commandTicket, retcode, g_trade.ResultRetcodeDescription());
      return false;
     }
   g_lastControlError = "DELETE_REQUESTED:" + reason;
   return true;
  }

void ReconcilePendingCommand()
  {
   if(g_commandTicket == 0)
      return;

   if(IsControllerOrderSelected(g_commandTicket))
     {
      if(g_commandCancelRequested)
        {
         RequestCommandCancellation(g_commandCancelReason);
         return;
        }
      ENUM_CCBSN_COMMAND desired = DesiredCommand();
      if(desired != g_pendingCommand)
        {
         RequestCommandCancellation("SUPERSEDED_BY_NEW_POLICY_STATE");
         return;
        }

      datetime now = TimeCurrent();
      if(now > 0 && g_commandSentTime > 0 &&
         now - g_commandSentTime >= InpCommandTimeoutSeconds)
        {
         if(InpDeleteCommandOnTimeout)
            RequestCommandCancellation("CCBSN_CONSUMPTION_TIMEOUT");
         else
           {
            g_controlState = CCBSN_CONTROL_ERROR;
            g_lastControlError = "CCBSN_CONSUMPTION_TIMEOUT_ORDER_LEFT_ACTIVE";
           }
        }
      return;
     }

   if(!HistoryOrderSelect(g_commandTicket))
     {
      g_lastControlError = "WAITING_FOR_COMMAND_HISTORY";
      return;
     }

   ENUM_ORDER_STATE orderState =
      (ENUM_ORDER_STATE)HistoryOrderGetInteger(g_commandTicket, ORDER_STATE);
   ENUM_CCBSN_COMMAND completedCommand = g_pendingCommand;
   if(orderState == ORDER_STATE_FILLED || orderState == ORDER_STATE_PARTIAL)
     {
      g_controlState = CCBSN_CONTROL_ERROR;
      g_lastControlError = "CRITICAL_COMMAND_ORDER_EXECUTED";
      Alert("CCBSN CONTROL ERROR: command order was executed. Check account immediately.");
      PrintFormat("CONTROL CRITICAL | Command ticket=%I64u was executed.",
                  g_commandTicket);
      ClearPendingCommand();
      return;
     }

   if(g_commandCancelRequested)
     {
      string cancelReason = g_commandCancelReason;
      ClearPendingCommand();
      if(cancelReason == "SUPERSEDED_BY_NEW_POLICY_STATE")
        {
         g_controlState = CCBSN_CONTROL_UNKNOWN;
         g_lastControlError = "STALE_COMMAND_CANCELLED";
        }
      else
        {
         g_controlState = CCBSN_CONTROL_ERROR;
         g_lastControlError = cancelReason;
        }
      return;
     }

   if(orderState == ORDER_STATE_CANCELED)
     {
      MarkCommandConfirmed(completedCommand);
      ClearPendingCommand();
      return;
     }

   g_controlState = CCBSN_CONTROL_ERROR;
   g_lastControlError = "UNEXPECTED_COMMAND_HISTORY_STATE:" + EnumToString(orderState);
   ClearPendingCommand();
  }

bool SendCCBSNCommand(const ENUM_CCBSN_COMMAND command)
  {
   if(command == CCBSN_COMMAND_NONE)
      return false;
   if(!IsControlTradeAllowed())
     {
      g_controlState = CCBSN_CONTROL_ERROR;
      Print("CONTROL ERROR | " + g_lastControlError);
      return false;
     }

   double price = NormalizedCommandPrice();
   double volume = NormalizedCommandVolume();
   if(price <= 0.0 || volume <= 0.0 || !ValidateCommandGeometry(price))
     {
      g_controlState = CCBSN_CONTROL_ERROR;
      if(g_lastControlError == "NONE")
         g_lastControlError = "INVALID_COMMAND_PRICE_OR_VOLUME";
      return false;
     }

   string action = command == CCBSN_COMMAND_NEW_CYCLE_ON ? "ON" : "OFF";
   string comment = "CCBSN_CTRL:" + action + ":" +
                    IntegerToString((long)TimeCurrent());
   bool requestOk = false;
   if(command == CCBSN_COMMAND_NEW_CYCLE_ON)
      requestOk = g_trade.SellLimit(volume, price, _Symbol, 0.0, 0.0,
                                    ORDER_TIME_GTC, 0, comment);
   else
      requestOk = g_trade.BuyStop(volume, price, _Symbol, 0.0, 0.0,
                                  ORDER_TIME_GTC, 0, comment);

   uint retcode = g_trade.ResultRetcode();
   ulong ticket = g_trade.ResultOrder();
   if(!requestOk ||
      (retcode != TRADE_RETCODE_DONE && retcode != TRADE_RETCODE_PLACED) ||
      ticket == 0)
     {
      g_controlState = CCBSN_CONTROL_ERROR;
      g_lastControlError = "COMMAND_SEND_FAILED:" +
                           g_trade.ResultRetcodeDescription();
      PrintFormat("CONTROL ERROR | Send %s failed | retcode=%u %s order=%I64u",
                  action, retcode, g_trade.ResultRetcodeDescription(), ticket);
      return false;
     }

   g_commandTicket = ticket;
   g_commandSentTime = TimeCurrent();
   g_pendingCommand = command;
   g_commandCancelRequested = false;
   g_commandCancelReason = "";
   g_commandCancelCode = COMMAND_CANCEL_NONE;
   g_controlState = command == CCBSN_COMMAND_NEW_CYCLE_ON
                    ? CCBSN_CONTROL_ON_PENDING
                    : CCBSN_CONTROL_OFF_PENDING;
   g_lastControlError = "WAITING_FOR_CCBSN_CONSUMPTION";
   SavePendingCommand();
   AuditEvent("CCBSN_COMMAND_SENT", g_commandSentTime,
              CommandToString(command), false);
   PrintFormat("CONTROL SENT | %s | ticket=%I64u price=%s volume=%.2f",
               CommandToString(command), ticket,
               FormatPrice(price), volume);
   return true;
  }

void ProcessCCBSNControl()
  {
   if(InpControlMode != CCBSN_CONTROL_ENABLED)
      return;
   RefreshCCBSNPositionSync("CONTROL_LOOP");
   if(!RecoverRetryableControlError())
      return;

   ReconcilePendingCommand();
   if(g_commandTicket != 0 || g_controlState == CCBSN_CONTROL_ERROR)
      return;

   ENUM_CCBSN_COMMAND desired = DesiredCommand();
   bool forceOffReassert = desired == CCBSN_COMMAND_NEW_CYCLE_OFF &&
                           g_offReassertRequested;
   if(IsConfirmedForCommand(desired) && !forceOffReassert)
      return;
   string syncReason = g_lastSyncReason;
   if(!SendCCBSNCommand(desired))
      return;

   if(desired == CCBSN_COMMAND_NEW_CYCLE_OFF)
     {
      datetime reassertTime = TimeCurrent();
      g_offReassertRequested = false;
      g_syncState = g_driftDetectedCurrentChain
                    ? "DRIFT: OFF REASSERT SENT"
                    : "OFF REASSERT SENT";
      g_lastSyncReason = syncReason;
      AuditEvent("NC_OFF_REASSERT_SENT", reassertTime,
                 syncReason, false);
      PrintFormat("SYNC | OFF reassert sent | positions=%d volume=%.2f | %s",
                  g_ccbsnPositionCount, g_ccbsnPositionVolume, syncReason);
     }
  }

//+------------------------------------------------------------------+
//| EA lifecycle                                                     |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(!ValidateInputs())
      return INIT_PARAMETERS_INCORRECT;
   if(!ValidateControlEnvironment())
      return INIT_PARAMETERS_INCORRECT;

   g_trade.SetExpertMagicNumber(InpControllerMagic);
   g_trade.SetAsyncMode(false);
   g_trade.SetTypeFillingBySymbol(_Symbol);
   g_trade.SetMarginMode();

   g_objectPrefix = "CCBSN_TZ." + IntegerToString(ChartID()) + ".";
   if(!AcquireControllerLock())
      return INIT_FAILED;
   ApplyChartTheme();
   g_atrHandle = iATR(_Symbol, DECISION_TIMEFRAME, InpATRPeriod);
   g_emaHandle = iMA(_Symbol, DECISION_TIMEFRAME, InpEMAPeriod, 0,
                     MODE_EMA, PRICE_CLOSE);
   if(g_atrHandle == INVALID_HANDLE || g_emaHandle == INVALID_HANDLE)
     {
      PrintFormat("INIT ERROR | Cannot create indicator handles | error=%d", GetLastError());
      return INIT_FAILED;
     }

   if(!EventSetMillisecondTimer(InpTimerMilliseconds))
     {
      PrintFormat("INIT ERROR | EventSetMillisecondTimer failed | error=%d",
                  GetLastError());
      return INIT_FAILED;
     }
   CreatePanel();
   BuildHistoricalZones();
   if(InpControlMode == CCBSN_CONTROL_ENABLED)
     {
      LoadStoredControlState();
      RecoverPendingControllerOrder();
     }
   else if(InpControlMode == CCBSN_CONTROL_MANUAL_HANDOVER)
      PerformManualHandover("MANUAL_HANDOVER_MODE");
   PrintFormat("INIT OK | %s %s | symbol=%s | mode=%s",
               POLICY_ID, POLICY_VERSION, _Symbol,
               ControlModeToString(InpControlMode));
   return INIT_SUCCEEDED;
  }

void OnDeinit(const int reason)
  {
   EventKillTimer();
   bool explicitHandover =
      (reason == REASON_PROGRAM || reason == REASON_REMOVE ||
       reason == REASON_CHARTCLOSE || reason == REASON_TEMPLATE);
   bool handoverRequested = InpManualHandoverOnRemove && explicitHandover &&
                            InpControlMode != CCBSN_CONTROL_VISUAL_ONLY;
   bool handoverReady = g_manualHandoverComplete;
   if(handoverRequested)
      handoverReady = PerformManualHandover("EA_DEINIT_" +
                                            DeinitReasonToString(reason));
   PrintFormat("DEINIT | reason=%s | mode=%s | handover_requested=%s | handover_ready=%s",
               DeinitReasonToString(reason), ControlModeToString(InpControlMode),
               handoverRequested ? "true" : "false",
               handoverReady ? "true" : "false");
   ReleaseControllerLock();
   if(g_atrHandle != INVALID_HANDLE) IndicatorRelease(g_atrHandle);
   if(g_emaHandle != INVALID_HANDLE) IndicatorRelease(g_emaHandle);
   if(!InpKeepObjectsOnRemove && g_objectPrefix != "")
      ObjectsDeleteAll(0, g_objectPrefix);
   Comment("");
   ChartRedraw(0);
  }

void OnTick()
  {
   ProcessRuntime();
   if(g_positionSyncRequested && InpControlMode == CCBSN_CONTROL_ENABLED)
     {
      g_positionSyncRequested = false;
      ProcessCCBSNControl();
      UpdatePanel();
     }
  }

void OnTradeTransaction(const MqlTradeTransaction &transaction,
                        const MqlTradeRequest &request,
                        const MqlTradeResult &result)
  {
   if(InpControlMode != CCBSN_CONTROL_ENABLED)
      return;
   if(transaction.type == TRADE_TRANSACTION_DEAL_ADD ||
      transaction.type == TRADE_TRANSACTION_POSITION)
     {
      RefreshCCBSNPositionSync("TRADE_TRANSACTION");
      g_positionSyncRequested = true;
     }
  }

void OnTimer()
  {
   RefreshControllerLock();
   if(InpControlMode == CCBSN_CONTROL_MANUAL_HANDOVER &&
      !g_manualHandoverComplete)
      PerformManualHandover("MANUAL_HANDOVER_RETRY");
   ProcessRuntime();
   g_positionSyncRequested = false;
   ProcessCCBSNControl();
   UpdatePanel();
   ChartRedraw(0);
  }

//+------------------------------------------------------------------+
