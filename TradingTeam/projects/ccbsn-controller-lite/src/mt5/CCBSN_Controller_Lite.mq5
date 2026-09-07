//+------------------------------------------------------------------+
//|                         CCBSN_Controller_Lite.mq5 v0.1.0-alpha   |
//| ATR Regime Band controller for closed M5 bars                    |
//+------------------------------------------------------------------+
#property copyright "TradingTeam"
#property version   "1.000"
#property strict

#include <Trade/Trade.mqh>

#define LITE_VERSION "0.1.0-alpha"
#define POLICY_VERSION "atr-m5-band-v0.1"

const ENUM_TIMEFRAMES DECISION_TIMEFRAME = PERIOD_M5;
const double COMMAND_PRICE = 888888.0;
const int TIMER_MILLISECONDS = 500;

enum ENUM_LITE_CONTROL_MODE
  {
   LITE_VISUAL_ONLY = 0,
   LITE_CONTROL_ENABLED = 1
  };

enum ENUM_LITE_POLICY_STATE
  {
   LITE_STATE_OFF = 0,
   LITE_STATE_ARMING = 1,
   LITE_STATE_ACTIVE = 2,
   LITE_STATE_RISK_LOCK = 3,
   LITE_STATE_ERROR = 4
  };

enum ENUM_LITE_COMMAND
  {
   LITE_COMMAND_NONE = 0,
   LITE_COMMAND_NEW_CYCLE_ON = 1,
   LITE_COMMAND_NEW_CYCLE_OFF = 2
  };

enum ENUM_LITE_CONTROL_STATE
  {
   LITE_CONTROL_DISABLED = 0,
   LITE_CONTROL_UNKNOWN = 1,
   LITE_CONTROL_ON_PENDING = 2,
   LITE_CONTROL_ON_CONFIRMED = 3,
   LITE_CONTROL_OFF_PENDING = 4,
   LITE_CONTROL_OFF_CONFIRMED = 5,
   LITE_CONTROL_ERROR = 6
  };

input group "01. Symbol"
input string InpExpectedSymbolPrefix = "XAUUSD";

input group "02. ATR M5 Regime"
input int    InpATRPeriod                 = 14;
input int    InpATRBaselineBars           = 48;
input double InpEntryATRRatioMin          = 0.65;
input double InpEntryATRRatioMax          = 1.65;
input double InpHoldATRRatioMin           = 0.45;
input double InpHoldATRRatioMax           = 2.10;
input double InpEntryMaxRangeATR          = 1.80;
input double InpSoftExpansionRangeATR     = 2.00;
input int    InpEnableConfirmBars         = 2;
input int    InpSoftExitConfirmBars       = 2;
input int    InpMinimumZoneBars           = 4;

input group "03. Bearish ATR Shock"
input double InpHardBearShockRangeATR     = 2.80;
input double InpHardBearMinBodyShare      = 0.60;
input double InpHardBearMaxCloseLocation  = 0.25;
input int    InpRiskLockBars              = 6;
input int    InpRecoveryConfirmBars       = 2;

input group "04. Continuous Session - Broker Server Time"
input bool   InpEnableSession             = true;
input int    InpSessionStartHHMM           = 600;
input int    InpSessionEndHHMM             = 300;
input int    InpSessionTimeShiftMinutes    = 0;

input group "05. Liquidity Guard"
input bool   InpEnableSpreadATRGuard      = true;
input double InpMaxSpreadATRRatio         = 0.15;
input int    InpMaxTickAgeSeconds         = 30;

input group "06. CCBSN Control"
input ENUM_LITE_CONTROL_MODE InpControlMode = LITE_VISUAL_ONLY;
input ulong  InpCCBSNMagic                = 9696;
input ulong  InpControllerMagic           = 996969;
input bool   InpRequireHedgingAccount      = true;
input int    InpCommandTimeoutSeconds      = 30;
input int    InpCommandRetryMilliseconds   = 2000;
input int    InpControllerLockStaleSeconds = 15;
input bool   InpDeletePendingOnRemove      = true;

input group "07. Display & Audit"
input bool   InpDrawActiveZone            = true;
input color  InpActiveZoneColor           = clrPaleGreen;
input color  InpRiskEventColor            = clrTomato;
input double InpZonePaddingATR             = 0.25;
input bool   InpKeepObjectsOnRemove        = true;
input bool   InpWriteCsvAudit              = true;
input string InpAuditFileName              = "CCBSN_Controller_Lite_Events_v0_1.csv";

CTrade g_trade;
int g_atrHandle = INVALID_HANDLE;
bool g_configurationValid = false;
string g_configurationError = "NONE";

ENUM_LITE_POLICY_STATE g_policyState = LITE_STATE_OFF;
ENUM_LITE_CONTROL_STATE g_controlState = LITE_CONTROL_DISABLED;
ENUM_LITE_COMMAND g_pendingCommand = LITE_COMMAND_NONE;

datetime g_currentOpenBarTime = 0;
datetime g_lastDecisionTime = 0;
datetime g_zoneStartTime = 0;
datetime g_commandSentTime = 0;
datetime g_lastDataErrorBar = 0;
ulong g_commandTicket = 0;
ulong g_nextCommandAttemptTick = 0;

int g_entryConfirmCount = 0;
int g_softExitCount = 0;
int g_zoneBars = 0;
int g_riskLockRemaining = 0;
int g_recoveryCount = 0;

double g_lastATR = 0.0;
double g_lastATRBaseline = 0.0;
double g_lastATRRatio = 0.0;
double g_lastRangeATR = 0.0;
double g_lastSpreadATR = 0.0;
double g_lastBodyShare = 0.0;
double g_lastCloseLocation = 0.0;
double g_lastClose = 0.0;
double g_zoneHigh = 0.0;
double g_zoneLow = 0.0;

bool g_lastHardBearShock = false;
bool g_auditReady = false;
bool g_controllerLockHeld = false;
bool g_commandCancelRequested = false;
double g_instanceToken = 0.0;

string g_lastEvent = "INIT";
string g_lastReason = "WAITING_FOR_FIRST_M5_CLOSE";
string g_lastControlError = "NONE";
string g_previousOperationalBlock = "";
string g_activeZoneObject = "";
string g_objectPrefix = "";

//+------------------------------------------------------------------+
//| Formatting                                                       |
//+------------------------------------------------------------------+
string PolicyStateToString(const ENUM_LITE_POLICY_STATE state)
  {
   if(state == LITE_STATE_OFF) return "OFF";
   if(state == LITE_STATE_ARMING) return "ARMING";
   if(state == LITE_STATE_ACTIVE) return "ACTIVE";
   if(state == LITE_STATE_RISK_LOCK) return "RISK_LOCK";
   if(state == LITE_STATE_ERROR) return "ERROR";
   return "UNKNOWN";
  }

string ControlStateToString(const ENUM_LITE_CONTROL_STATE state)
  {
   if(state == LITE_CONTROL_DISABLED) return "DISABLED";
   if(state == LITE_CONTROL_UNKNOWN) return "UNKNOWN";
   if(state == LITE_CONTROL_ON_PENDING) return "ON_PENDING";
   if(state == LITE_CONTROL_ON_CONFIRMED) return "ON_CONFIRMED";
   if(state == LITE_CONTROL_OFF_PENDING) return "OFF_PENDING";
   if(state == LITE_CONTROL_OFF_CONFIRMED) return "OFF_CONFIRMED";
   if(state == LITE_CONTROL_ERROR) return "ERROR";
   return "UNKNOWN";
  }

string CommandToString(const ENUM_LITE_COMMAND command)
  {
   if(command == LITE_COMMAND_NEW_CYCLE_ON) return "NEW_CYCLE_ON";
   if(command == LITE_COMMAND_NEW_CYCLE_OFF) return "NEW_CYCLE_OFF";
   return "NONE";
  }

string FormatMetric(const double value, const int digits = 3)
  {
   if(!MathIsValidNumber(value)) return "n/a";
   return DoubleToString(value, digits);
  }

//+------------------------------------------------------------------+
//| Audit                                                            |
//+------------------------------------------------------------------+
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
                "policy_version", "symbol", "policy_state", "event",
                "reason", "atr", "atr_baseline", "atr_ratio",
                "range_atr", "spread_atr", "entry_count",
                "soft_exit_count", "zone_bars", "risk_lock_remaining",
                "recovery_count", "desired_cycle", "control_state",
                "command_ticket");
   FileFlush(handle);
   FileClose(handle);
   g_auditReady = true;
   return true;
  }

ENUM_LITE_COMMAND DesiredCommand()
  {
   if(g_policyState == LITE_STATE_ACTIVE)
      return LITE_COMMAND_NEW_CYCLE_ON;
   return LITE_COMMAND_NEW_CYCLE_OFF;
  }

void AuditEvent(const string eventType, const string reason)
  {
   g_lastEvent = eventType;
   g_lastReason = reason;
   if(!InpWriteCsvAudit || !g_auditReady)
      return;

   int handle = FileOpen(InpAuditFileName,
                         FILE_READ | FILE_WRITE | FILE_CSV |
                         FILE_ANSI | FILE_SHARE_READ, ';');
   if(handle == INVALID_HANDLE)
     {
      g_auditReady = false;
      PrintFormat("AUDIT ERROR | Cannot append %s | error=%d",
                  InpAuditFileName, GetLastError());
      return;
     }
   FileSeek(handle, 0, SEEK_END);
   FileWrite(handle,
             TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS),
             TimeToString(g_lastDecisionTime, TIME_DATE | TIME_MINUTES),
             LITE_VERSION, POLICY_VERSION, _Symbol,
             PolicyStateToString(g_policyState), eventType, reason,
             DoubleToString(g_lastATR, 6),
             DoubleToString(g_lastATRBaseline, 6),
             DoubleToString(g_lastATRRatio, 6),
             DoubleToString(g_lastRangeATR, 6),
             DoubleToString(g_lastSpreadATR, 6),
             g_entryConfirmCount, g_softExitCount, g_zoneBars,
             g_riskLockRemaining, g_recoveryCount,
             CommandToString(DesiredCommand()),
             ControlStateToString(g_controlState),
             StringFormat("%I64u", g_commandTicket));
   FileFlush(handle);
   FileClose(handle);
  }

//+------------------------------------------------------------------+
//| Session and policy feature calculation                           |
//+------------------------------------------------------------------+
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
   if(!InpEnableSession)
      return true;
   MqlDateTime parts;
   TimeToStruct(decisionTime + InpSessionTimeShiftMinutes * 60, parts);
   int minuteOfDay = parts.hour * 60 + parts.min;
   int startMinute = HHMMToMinute(InpSessionStartHHMM);
   int endMinute = HHMMToMinute(InpSessionEndHHMM);
   if(startMinute == endMinute)
      return true;
   if(startMinute < endMinute)
      return minuteOfDay >= startMinute && minuteOfDay < endMinute;
   return minuteOfDay >= startMinute || minuteOfDay < endMinute;
  }

bool LoadLatestClosedSnapshot(MqlRates &bar, datetime &decisionTime)
  {
   MqlRates rates[1];
   if(CopyRates(_Symbol, DECISION_TIMEFRAME, 1, 1, rates) != 1)
      return false;
   bar = rates[0];
   decisionTime = bar.time + PeriodSeconds(DECISION_TIMEFRAME);

   double currentATR[1];
   if(CopyBuffer(g_atrHandle, 0, 1, 1, currentATR) != 1)
      return false;
   if(!MathIsValidNumber(currentATR[0]) || currentATR[0] <= 0.0)
      return false;

   double baselineValues[];
   ArrayResize(baselineValues, InpATRBaselineBars);
   if(CopyBuffer(g_atrHandle, 0, 1, InpATRBaselineBars,
                 baselineValues) != InpATRBaselineBars)
      return false;
   double baselineTotal = 0.0;
   int baselineCount = 0;
   for(int index = 0; index < ArraySize(baselineValues); index++)
     {
      if(MathIsValidNumber(baselineValues[index]) &&
         baselineValues[index] > 0.0)
        {
         baselineTotal += baselineValues[index];
         baselineCount++;
        }
     }
   if(baselineCount != InpATRBaselineBars)
      return false;

   MqlTick tick;
   if(!SymbolInfoTick(_Symbol, tick) || tick.ask <= 0.0 || tick.bid <= 0.0)
      return false;

   g_lastATR = currentATR[0];
   g_lastATRBaseline = baselineTotal / baselineCount;
   if(g_lastATRBaseline <= 0.0)
      return false;
   g_lastATRRatio = g_lastATR / g_lastATRBaseline;
   g_lastClose = bar.close;

   double candleRange = bar.high - bar.low;
   g_lastRangeATR = candleRange > 0.0 ? candleRange / g_lastATR : 0.0;
   g_lastBodyShare = candleRange > 0.0
                     ? MathAbs(bar.close - bar.open) / candleRange : 0.0;
   g_lastCloseLocation = candleRange > 0.0
                         ? (bar.close - bar.low) / candleRange : 0.5;
   g_lastSpreadATR = (tick.ask - tick.bid) / g_lastATR;
   g_lastHardBearShock = bar.close < bar.open &&
                         g_lastRangeATR >= InpHardBearShockRangeATR &&
                         g_lastBodyShare >= InpHardBearMinBodyShare &&
                         g_lastCloseLocation <=
                         InpHardBearMaxCloseLocation;
   return true;
  }

string OperationalBlockReason(const datetime decisionTime)
  {
   if(InpWriteCsvAudit && !g_auditReady)
      return "AUDIT_NOT_READY";
   if(!IsSessionAllowed(decisionTime))
      return "SESSION_BLOCK";

   MqlTick tick;
   if(!SymbolInfoTick(_Symbol, tick))
      return "TICK_NOT_READY";
   int tickAge = (int)MathMax(0, TimeCurrent() - tick.time);
   if(InpMaxTickAgeSeconds > 0 && tickAge > InpMaxTickAgeSeconds)
      return "TICK_STALE";
   if(InpEnableSpreadATRGuard &&
      g_lastSpreadATR > InpMaxSpreadATRRatio)
      return "SPREAD_STRESS";
   return "";
  }

bool EntryCandidate(const string operationalBlock)
  {
   return operationalBlock == "" && !g_lastHardBearShock &&
          g_lastATRRatio >= InpEntryATRRatioMin &&
          g_lastATRRatio <= InpEntryATRRatioMax &&
          g_lastRangeATR <= InpEntryMaxRangeATR;
  }

bool ActiveHoldPass(const string operationalBlock)
  {
   return operationalBlock == "" &&
          g_lastATRRatio >= InpHoldATRRatioMin &&
          g_lastATRRatio <= InpHoldATRRatioMax &&
          g_lastRangeATR < InpSoftExpansionRangeATR;
  }

//+------------------------------------------------------------------+
//| Minimal chart visualization                                      |
//+------------------------------------------------------------------+
void CreateEventLine(const string eventType, const datetime eventTime,
                     const color lineColor)
  {
   string name = g_objectPrefix + "EVENT." + eventType + "." +
                 IntegerToString((long)eventTime);
   if(ObjectCreate(0, name, OBJ_VLINE, 0, eventTime, 0.0))
     {
      ObjectSetInteger(0, name, OBJPROP_COLOR, lineColor);
      ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_DOT);
      ObjectSetInteger(0, name, OBJPROP_WIDTH, 1);
      ObjectSetString(0, name, OBJPROP_TOOLTIP,
                      eventType + "\n" +
                      TimeToString(eventTime, TIME_DATE | TIME_MINUTES));
     }
  }

void UpdateActiveZoneObject(const datetime endTime)
  {
   if(!InpDrawActiveZone || g_zoneStartTime <= 0 ||
      g_activeZoneObject == "")
      return;
   double padding = g_lastATR * InpZonePaddingATR;
   double top = g_zoneHigh + padding;
   double bottom = g_zoneLow - padding;
   datetime safeEnd = endTime > g_zoneStartTime
                      ? endTime
                      : g_zoneStartTime + PeriodSeconds(DECISION_TIMEFRAME);
   if(ObjectFind(0, g_activeZoneObject) < 0)
     {
      if(!ObjectCreate(0, g_activeZoneObject, OBJ_RECTANGLE, 0,
                       g_zoneStartTime, top, safeEnd, bottom))
         return;
      ObjectSetInteger(0, g_activeZoneObject, OBJPROP_COLOR,
                       InpActiveZoneColor);
      ObjectSetInteger(0, g_activeZoneObject, OBJPROP_FILL, true);
      ObjectSetInteger(0, g_activeZoneObject, OBJPROP_BACK, true);
     }
   else
     {
      ObjectMove(0, g_activeZoneObject, 0, g_zoneStartTime, top);
      ObjectMove(0, g_activeZoneObject, 1, safeEnd, bottom);
     }
   ObjectSetString(0, g_activeZoneObject, OBJPROP_TOOLTIP,
                   "CCBSN LITE POLICY ZONE\nStart=" +
                   TimeToString(g_zoneStartTime,
                                TIME_DATE | TIME_MINUTES) +
                   "\nATR ratio=" + FormatMetric(g_lastATRRatio, 2));
  }

void StartPolicyZone(const MqlRates &bar, const datetime decisionTime,
                     const string reason)
  {
   g_policyState = LITE_STATE_ACTIVE;
   g_zoneStartTime = decisionTime;
   g_zoneHigh = bar.high;
   g_zoneLow = bar.low;
   g_zoneBars = 1;
   g_entryConfirmCount = 0;
   g_softExitCount = 0;
   g_riskLockRemaining = 0;
   g_recoveryCount = 0;
   g_activeZoneObject = g_objectPrefix + "ZONE." +
                        IntegerToString((long)decisionTime);
   UpdateActiveZoneObject(decisionTime);
   CreateEventLine("ZONE_START", decisionTime, InpActiveZoneColor);
   AuditEvent("POLICY_ZONE_STARTED", reason);
  }

void EndPolicyZone(const datetime decisionTime, const string reason,
                   const bool enterRiskLock)
  {
   if(g_zoneStartTime > 0)
      UpdateActiveZoneObject(decisionTime);
   CreateEventLine(enterRiskLock ? "BEAR_SHOCK" : "ZONE_END",
                   decisionTime,
                   enterRiskLock ? InpRiskEventColor : clrOrangeRed);
   g_policyState = enterRiskLock ? LITE_STATE_RISK_LOCK : LITE_STATE_OFF;
   g_zoneStartTime = 0;
   g_activeZoneObject = "";
   g_zoneHigh = 0.0;
   g_zoneLow = 0.0;
   g_zoneBars = 0;
   g_entryConfirmCount = 0;
   g_softExitCount = 0;
   g_recoveryCount = 0;
   if(enterRiskLock)
      g_riskLockRemaining = InpRiskLockBars;
   else
      g_riskLockRemaining = 0;
   AuditEvent(enterRiskLock ? "BEAR_SHOCK_RISK_LOCK" :
              "POLICY_ZONE_ENDED", reason);
  }

void EnterRiskLockFromOutside(const datetime decisionTime,
                              const string reason)
  {
   g_policyState = LITE_STATE_RISK_LOCK;
   g_entryConfirmCount = 0;
   g_softExitCount = 0;
   g_recoveryCount = 0;
   g_riskLockRemaining = InpRiskLockBars;
   CreateEventLine("BEAR_SHOCK", decisionTime, InpRiskEventColor);
   AuditEvent("BEAR_SHOCK_RISK_LOCK", reason);
  }

void ForcePolicyOff(const datetime decisionTime, const string reason)
  {
   if(g_policyState == LITE_STATE_ACTIVE)
      EndPolicyZone(decisionTime, reason, false);
   else
     {
      g_policyState = LITE_STATE_OFF;
      g_entryConfirmCount = 0;
      g_softExitCount = 0;
      g_recoveryCount = 0;
      g_riskLockRemaining = 0;
      AuditEvent("POLICY_FORCED_OFF", reason);
     }
  }

//+------------------------------------------------------------------+
//| ATR policy state machine                                         |
//+------------------------------------------------------------------+
void ProcessDecisionBar(const MqlRates &bar, const datetime decisionTime)
  {
   g_lastDecisionTime = decisionTime;
   string operationalBlock = OperationalBlockReason(decisionTime);
   if(operationalBlock != g_previousOperationalBlock)
     {
      if(operationalBlock == "")
         AuditEvent("OPERATIONAL_BLOCK_CLEARED",
                    g_previousOperationalBlock);
      else
         AuditEvent(operationalBlock, operationalBlock);
      g_previousOperationalBlock = operationalBlock;
     }

   bool entryCandidate = EntryCandidate(operationalBlock);
   bool holdPass = ActiveHoldPass(operationalBlock);

   if(g_policyState == LITE_STATE_ACTIVE)
     {
      g_zoneHigh = MathMax(g_zoneHigh, bar.high);
      g_zoneLow = MathMin(g_zoneLow, bar.low);
      g_zoneBars++;

      if(g_lastHardBearShock)
        {
         EndPolicyZone(decisionTime,
                       "M5_BEAR_SHOCK_RANGE_ATR=" +
                       FormatMetric(g_lastRangeATR, 2), true);
         return;
        }

      if(operationalBlock != "")
        {
         EndPolicyZone(decisionTime, operationalBlock, false);
         return;
        }

      if(holdPass)
        {
         if(g_softExitCount > 0)
            AuditEvent("SOFT_EXIT_CLEARED", "ATR_HOLD_RECOVERED");
         g_softExitCount = 0;
         UpdateActiveZoneObject(decisionTime);
         return;
        }

      if(g_zoneBars < InpMinimumZoneBars)
        {
         g_softExitCount = 0;
         AuditEvent("SOFT_EXIT_SUPPRESSED",
                    "MINIMUM_ZONE_BARS=" + IntegerToString(g_zoneBars));
         UpdateActiveZoneObject(decisionTime);
         return;
        }

      g_softExitCount++;
      if(g_softExitCount == 1)
         AuditEvent("SOFT_EXIT_STARTED",
                    "ATR_HOLD_FAILED_RATIO=" +
                    FormatMetric(g_lastATRRatio, 2));
      if(g_softExitCount >= InpSoftExitConfirmBars)
        {
         EndPolicyZone(decisionTime,
                       "SOFT_EXIT_CONFIRMED_RATIO=" +
                       FormatMetric(g_lastATRRatio, 2), false);
         return;
        }
      UpdateActiveZoneObject(decisionTime);
      return;
     }

   if(g_policyState == LITE_STATE_RISK_LOCK)
     {
      if(g_lastHardBearShock)
        {
         g_riskLockRemaining = InpRiskLockBars;
         g_recoveryCount = 0;
         AuditEvent("RISK_LOCK_REFRESHED", "NEW_BEAR_SHOCK");
         return;
        }
      if(g_riskLockRemaining > 0)
        {
         g_riskLockRemaining--;
         g_recoveryCount = 0;
         return;
        }
      if(entryCandidate)
        {
         g_recoveryCount++;
         if(g_recoveryCount == 1)
            AuditEvent("RISK_LOCK_RECOVERY_STARTED",
                       "ATR_ENTRY_CANDIDATE");
         if(g_recoveryCount >= InpRecoveryConfirmBars)
           {
            AuditEvent("RISK_LOCK_RECOVERED",
                       "RECOVERY_CONFIRM=" +
                       IntegerToString(g_recoveryCount));
            StartPolicyZone(bar, decisionTime,
                            "RISK_LOCK_RECOVERY_CONFIRMED");
           }
        }
      else
         g_recoveryCount = 0;
      return;
     }

   if(g_lastHardBearShock)
     {
      EnterRiskLockFromOutside(decisionTime,
                               "M5_BEAR_SHOCK_RANGE_ATR=" +
                               FormatMetric(g_lastRangeATR, 2));
      return;
     }

   if(entryCandidate)
     {
      if(g_policyState != LITE_STATE_ARMING)
        {
         g_policyState = LITE_STATE_ARMING;
         g_entryConfirmCount = 0;
         AuditEvent("ENTRY_ARM_STARTED", "ATR_ENTRY_BAND_PASS");
        }
      g_entryConfirmCount++;
      if(g_entryConfirmCount >= InpEnableConfirmBars)
         StartPolicyZone(bar, decisionTime,
                         "ATR_ENTRY_CONFIRMED_RATIO=" +
                         FormatMetric(g_lastATRRatio, 2));
      return;
     }

   if(g_policyState == LITE_STATE_ARMING)
      AuditEvent("ENTRY_ARM_CANCELLED",
                 operationalBlock != "" ? operationalBlock :
                 "ATR_ENTRY_BAND_FAILED");
   g_policyState = LITE_STATE_OFF;
   g_entryConfirmCount = 0;
  }

bool ProcessLatestClosedBar()
  {
   datetime currentOpen = iTime(_Symbol, DECISION_TIMEFRAME, 0);
   if(currentOpen <= 0 || currentOpen == g_currentOpenBarTime)
      return false;

   MqlRates bar;
   datetime decisionTime = 0;
   if(!LoadLatestClosedSnapshot(bar, decisionTime))
     {
      if(g_lastDataErrorBar != currentOpen)
        {
         g_lastDataErrorBar = currentOpen;
         g_lastDecisionTime = currentOpen;
         ForcePolicyOff(currentOpen, "M5_DATA_NOT_READY");
        }
      return false;
     }

   g_lastDataErrorBar = 0;
   g_currentOpenBarTime = currentOpen;
   ProcessDecisionBar(bar, decisionTime);
   return true;
  }

//+------------------------------------------------------------------+
//| Controller lock compatible with the existing CCBSN controller   |
//+------------------------------------------------------------------+
string ControllerLockKey(const string suffix)
  {
   return "CCBSN.NC.LOCK." +
          IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN)) + "." +
          _Symbol + "." + IntegerToString((long)InpCCBSNMagic) + "." +
          suffix;
  }

bool AcquireControllerLock()
  {
   if(InpControlMode == LITE_VISUAL_ONLY)
      return true;

   ulong rawChart = (ulong)ChartID();
   ulong rawTick = GetTickCount64();
   ulong exactToken = (rawChart % 9000000000) * 1000000 +
                      (rawTick % 1000000);
   if(exactToken == 0) exactToken = 1;
   g_instanceToken = (double)exactToken;

   string ownerKey = ControllerLockKey("OWNER");
   string heartbeatKey = ControllerLockKey("HEARTBEAT");
   if(!GlobalVariableCheck(ownerKey))
      GlobalVariableSet(ownerKey, 0.0);

   double currentOwner = GlobalVariableGet(ownerKey);
   datetime heartbeat = GlobalVariableCheck(heartbeatKey)
                        ? (datetime)MathRound(
                           GlobalVariableGet(heartbeatKey)) : 0;
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
   if(InpControlMode != LITE_CONTROL_ENABLED || !g_controllerLockHeld)
      return;
   string ownerKey = ControllerLockKey("OWNER");
   if(!GlobalVariableCheck(ownerKey) ||
      GlobalVariableGet(ownerKey) != g_instanceToken)
     {
      g_controllerLockHeld = false;
      g_controlState = LITE_CONTROL_ERROR;
      g_lastControlError = "CONTROLLER_MUTEX_LOST";
      AuditEvent("CCBSN_COMMAND_ERROR", g_lastControlError);
      return;
     }
   GlobalVariableSet(ControllerLockKey("HEARTBEAT"),
                     (double)TimeLocal());
  }

void ReleaseControllerLock()
  {
   if(!g_controllerLockHeld)
      return;
   string ownerKey = ControllerLockKey("OWNER");
   if(GlobalVariableCheck(ownerKey) &&
      GlobalVariableSetOnCondition(ownerKey, 0.0, g_instanceToken))
      GlobalVariableSet(ControllerLockKey("HEARTBEAT"), 0.0);
   g_controllerLockHeld = false;
  }

//+------------------------------------------------------------------+
//| CCBSN New Cycle command transport                                |
//+------------------------------------------------------------------+
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
   if(minimum <= 0.0 || maximum < minimum || step <= 0.0)
      return 0.0;
   return NormalizeDouble(minimum, VolumeDigits(step));
  }

double NormalizedCommandPrice()
  {
   double tickSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   if(tickSize <= 0.0)
      tickSize = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   if(tickSize <= 0.0)
      return 0.0;
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

bool IsControlComment(const string comment)
  {
   return StringFind(comment, "CCBSN_LITE:") == 0 ||
          StringFind(comment, "CCBSN_CTRL:") == 0;
  }

ENUM_LITE_COMMAND SelectedOrderCommand()
  {
   ENUM_ORDER_TYPE type = (ENUM_ORDER_TYPE)OrderGetInteger(ORDER_TYPE);
   if(type == ORDER_TYPE_SELL_LIMIT)
      return LITE_COMMAND_NEW_CYCLE_ON;
   if(type == ORDER_TYPE_BUY_STOP)
      return LITE_COMMAND_NEW_CYCLE_OFF;
   return LITE_COMMAND_NONE;
  }

void ClearPendingCommand()
  {
   g_commandTicket = 0;
   g_commandSentTime = 0;
   g_pendingCommand = LITE_COMMAND_NONE;
   g_commandCancelRequested = false;
  }

void SetControlError(const string reason)
  {
   g_controlState = LITE_CONTROL_ERROR;
   g_lastControlError = reason;
   AuditEvent("CCBSN_COMMAND_ERROR", reason);
   Print("CCBSN LITE CONTROL ERROR | " + reason);
  }

bool RecoverPendingControllerOrder()
  {
   int matches = 0;
   int ownMatches = 0;
   ulong recoveredTicket = 0;
   datetime recoveredTime = 0;
   ENUM_LITE_COMMAND recoveredCommand = LITE_COMMAND_NONE;

   for(int index = OrdersTotal() - 1; index >= 0; index--)
     {
      ulong ticket = OrderGetTicket(index);
      if(ticket == 0 || OrderGetString(ORDER_SYMBOL) != _Symbol ||
         !IsControlComment(OrderGetString(ORDER_COMMENT)))
         continue;
      matches++;
      if((ulong)OrderGetInteger(ORDER_MAGIC) == InpControllerMagic &&
         StringFind(OrderGetString(ORDER_COMMENT), "CCBSN_LITE:") == 0)
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
   if(ownMatches == 1 && recoveredCommand != LITE_COMMAND_NONE)
     {
      g_commandTicket = recoveredTicket;
      g_commandSentTime = recoveredTime;
      g_pendingCommand = recoveredCommand;
      g_controlState = recoveredCommand == LITE_COMMAND_NEW_CYCLE_ON
                       ? LITE_CONTROL_ON_PENDING
                       : LITE_CONTROL_OFF_PENDING;
      AuditEvent("CCBSN_COMMAND_RECOVERED",
                 CommandToString(recoveredCommand));
     }
   return true;
  }

void MarkCommandConfirmed(const ENUM_LITE_COMMAND command)
  {
   g_controlState = command == LITE_COMMAND_NEW_CYCLE_ON
                    ? LITE_CONTROL_ON_CONFIRMED
                    : LITE_CONTROL_OFF_CONFIRMED;
   g_lastControlError = "NONE";
   AuditEvent(command == LITE_COMMAND_NEW_CYCLE_ON
              ? "CCBSN_ON_CONFIRMED" : "CCBSN_OFF_CONFIRMED",
              "COMMAND_ORDER_CANCELED");
  }

void ReconcilePendingCommand()
  {
   if(g_commandTicket == 0 || g_pendingCommand == LITE_COMMAND_NONE)
      return;

   if(OrderSelect(g_commandTicket))
     {
      if(TimeCurrent() - g_commandSentTime < InpCommandTimeoutSeconds)
         return;

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
   ENUM_LITE_COMMAND completedCommand = g_pendingCommand;
   if(orderState == ORDER_STATE_CANCELED && !g_commandCancelRequested)
     {
      ClearPendingCommand();
      MarkCommandConfirmed(completedCommand);
      return;
     }
   if(orderState == ORDER_STATE_FILLED || orderState == ORDER_STATE_PARTIAL)
     {
      ClearPendingCommand();
      SetControlError("COMMAND_ORDER_EXECUTED");
      Alert("CCBSN LITE: command order executed. Check account immediately.");
      return;
     }
   ClearPendingCommand();
   SetControlError("UNEXPECTED_COMMAND_HISTORY_STATE:" +
                   EnumToString(orderState));
  }

bool IsConfirmedForCommand(const ENUM_LITE_COMMAND command)
  {
   if(command == LITE_COMMAND_NEW_CYCLE_ON)
      return g_controlState == LITE_CONTROL_ON_CONFIRMED;
   if(command == LITE_COMMAND_NEW_CYCLE_OFF)
      return g_controlState == LITE_CONTROL_OFF_CONFIRMED;
   return false;
  }

bool SendCCBSNCommand(const ENUM_LITE_COMMAND command)
  {
   if(!IsControlTradeAllowed())
     {
      g_controlState = LITE_CONTROL_ERROR;
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

   string action = command == LITE_COMMAND_NEW_CYCLE_ON ? "ON" : "OFF";
   string comment = "CCBSN_LITE:" + action + ":" +
                    IntegerToString((long)TimeCurrent());
   ResetLastError();
   bool requestOk = command == LITE_COMMAND_NEW_CYCLE_ON
                    ? g_trade.SellLimit(volume, price, _Symbol, 0.0, 0.0,
                                        ORDER_TIME_GTC, 0, comment)
                    : g_trade.BuyStop(volume, price, _Symbol, 0.0, 0.0,
                                      ORDER_TIME_GTC, 0, comment);
   uint retcode = g_trade.ResultRetcode();
   ulong ticket = g_trade.ResultOrder();
   if(ticket == 0)
     {
      g_controlState = LITE_CONTROL_UNKNOWN;
      g_lastControlError = "COMMAND_SEND_RETRY:" +
                           g_trade.ResultRetcodeDescription();
      g_nextCommandAttemptTick = GetTickCount64() +
                                 (ulong)InpCommandRetryMilliseconds;
      PrintFormat("CCBSN LITE RETRY | %s request=%s retcode=%u %s",
                  action, requestOk ? "true" : "false", retcode,
                  g_trade.ResultRetcodeDescription());
      return false;
     }

   g_commandTicket = ticket;
   g_commandSentTime = TimeCurrent();
   g_pendingCommand = command;
   g_commandCancelRequested = false;
   g_controlState = command == LITE_COMMAND_NEW_CYCLE_ON
                    ? LITE_CONTROL_ON_PENDING
                    : LITE_CONTROL_OFF_PENDING;
   g_lastControlError = "WAITING_FOR_CCBSN_CONSUMPTION";
   g_nextCommandAttemptTick = 0;
   AuditEvent("CCBSN_COMMAND_SENT", CommandToString(command));
   PrintFormat("CCBSN LITE SENT | %s ticket=%I64u request=%s retcode=%u",
               action, ticket, requestOk ? "true" : "false", retcode);
   ReconcilePendingCommand();
   return true;
  }

void ProcessCCBSNControl()
  {
   if(InpControlMode != LITE_CONTROL_ENABLED)
      return;
   if(!g_controllerLockHeld || g_controlState == LITE_CONTROL_ERROR)
     {
      if(g_controlState == LITE_CONTROL_ERROR &&
         IsRetryableEnvironmentError() && IsControlTradeAllowed())
        {
         g_controlState = LITE_CONTROL_UNKNOWN;
         g_lastControlError = "NONE";
         AuditEvent("CONTROL_ENVIRONMENT_RECOVERED", "RETRY_ALLOWED");
        }
      else
         return;
     }

   ReconcilePendingCommand();
   if(g_commandTicket != 0 || g_controlState == LITE_CONTROL_ERROR)
      return;
   ENUM_LITE_COMMAND desired = DesiredCommand();
   if(IsConfirmedForCommand(desired))
      return;
   if(g_nextCommandAttemptTick > 0 &&
      GetTickCount64() < g_nextCommandAttemptTick)
      return;
   SendCCBSNCommand(desired);
  }

void CancelPendingOnRemove()
  {
   if(!InpDeletePendingOnRemove || g_commandTicket == 0)
      return;
   if(OrderSelect(g_commandTicket) &&
      (ulong)OrderGetInteger(ORDER_MAGIC) == InpControllerMagic &&
      StringFind(OrderGetString(ORDER_COMMENT), "CCBSN_LITE:") == 0)
     {
      g_commandCancelRequested = true;
      bool deleted = g_trade.OrderDelete(g_commandTicket);
      PrintFormat("CCBSN LITE DEINIT | pending #%I64u delete=%s retcode=%u",
                  g_commandTicket, deleted ? "true" : "false",
                  g_trade.ResultRetcode());
     }
  }

//+------------------------------------------------------------------+
//| Validation and dashboard                                         |
//+------------------------------------------------------------------+
bool ValidateInputs()
  {
   if(InpExpectedSymbolPrefix != "" &&
      StringFind(_Symbol, InpExpectedSymbolPrefix) != 0)
     {
      g_configurationError = "UNEXPECTED_SYMBOL:" + _Symbol;
      return false;
     }
   if(InpATRPeriod < 2 || InpATRPeriod > 200 ||
      InpATRBaselineBars < 10 || InpATRBaselineBars > 2000)
     {
      g_configurationError = "INVALID_ATR_PERIOD_OR_BASELINE";
      return false;
     }
   if(InpEntryATRRatioMin <= 0.0 ||
      InpEntryATRRatioMax <= InpEntryATRRatioMin ||
      InpHoldATRRatioMin <= 0.0 ||
      InpHoldATRRatioMin > InpEntryATRRatioMin ||
      InpHoldATRRatioMax < InpEntryATRRatioMax)
     {
      g_configurationError = "INVALID_ATR_RATIO_HYSTERESIS";
      return false;
     }
   if(InpEntryMaxRangeATR <= 0.0 ||
      InpSoftExpansionRangeATR < InpEntryMaxRangeATR ||
      InpHardBearShockRangeATR <= InpSoftExpansionRangeATR)
     {
      g_configurationError = "INVALID_RANGE_ATR_THRESHOLDS";
      return false;
     }
   if(InpHardBearMinBodyShare < 0.0 ||
      InpHardBearMinBodyShare > 1.0 ||
      InpHardBearMaxCloseLocation < 0.0 ||
      InpHardBearMaxCloseLocation > 1.0)
     {
      g_configurationError = "INVALID_BEAR_SHOCK_MORPHOLOGY";
      return false;
     }
   if(InpEnableConfirmBars < 1 || InpEnableConfirmBars > 20 ||
      InpSoftExitConfirmBars < 1 || InpSoftExitConfirmBars > 20 ||
      InpMinimumZoneBars < 1 || InpMinimumZoneBars > 1000 ||
      InpRiskLockBars < 0 || InpRiskLockBars > 1000 ||
      InpRecoveryConfirmBars < 1 || InpRecoveryConfirmBars > 20)
     {
      g_configurationError = "INVALID_CONFIRM_OR_DURATION_INPUT";
      return false;
     }
   if(!IsValidHHMM(InpSessionStartHHMM) ||
      !IsValidHHMM(InpSessionEndHHMM))
     {
      g_configurationError = "INVALID_SESSION_HHMM";
      return false;
     }
   if(InpMaxSpreadATRRatio <= 0.0 || InpMaxTickAgeSeconds < 0)
     {
      g_configurationError = "INVALID_LIQUIDITY_GUARD";
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
   if(InpControlMode == LITE_CONTROL_ENABLED &&
      InpRequireHedgingAccount &&
      (ENUM_ACCOUNT_MARGIN_MODE)AccountInfoInteger(ACCOUNT_MARGIN_MODE) !=
      ACCOUNT_MARGIN_MODE_RETAIL_HEDGING)
     {
      g_configurationError = "HEDGING_ACCOUNT_REQUIRED";
      return false;
     }
   return true;
  }

void UpdateDashboard()
  {
   string mode = InpControlMode == LITE_VISUAL_ONLY
                 ? "VISUAL_ONLY" : "CONTROL_ENABLED";
   string sessionState = IsSessionAllowed(TimeCurrent())
                         ? "ALLOWED" : "BLOCKED";
   Comment("CCBSN CONTROLLER LITE ", LITE_VERSION, "\n",
           "M5 ATR POLICY: ", PolicyStateToString(g_policyState), "\n",
           "MODE: ", mode, " | SESSION: ", sessionState, "\n",
           "ATR: ", FormatMetric(g_lastATR),
           " | BASE: ", FormatMetric(g_lastATRBaseline),
           " | RATIO: ", FormatMetric(g_lastATRRatio, 2), "\n",
           "RANGE/ATR: ", FormatMetric(g_lastRangeATR, 2),
           " | SPREAD/ATR: ", FormatMetric(g_lastSpreadATR, 3), "\n",
           "ARM: ", g_entryConfirmCount, "/", InpEnableConfirmBars,
           " | SOFT OFF: ", g_softExitCount, "/",
           InpSoftExitConfirmBars,
           " | ZONE BARS: ", g_zoneBars, "\n",
           "RISK LOCK: ", g_riskLockRemaining,
           " | RECOVERY: ", g_recoveryCount, "/",
           InpRecoveryConfirmBars, "\n",
           "DESIRED: ", CommandToString(DesiredCommand()),
           " | CONTROL: ", ControlStateToString(g_controlState), "\n",
           "LAST: ", g_lastEvent, " | ", g_lastReason, "\n",
           "CONTROL ERROR: ", g_lastControlError);
  }

//+------------------------------------------------------------------+
//| EA lifecycle                                                     |
//+------------------------------------------------------------------+
int OnInit()
  {
   g_objectPrefix = "CCBSN_LITE." + IntegerToString(ChartID()) + ".";
   if(!ValidateInputs())
     {
      Comment("CCBSN LITE CONFIG ERROR\n", g_configurationError);
      Print("CCBSN LITE CONFIG ERROR | " + g_configurationError);
      return INIT_PARAMETERS_INCORRECT;
     }
   if(!InitializeAudit())
     {
      Comment("CCBSN LITE CONFIG ERROR\n", g_configurationError);
      Print("CCBSN LITE CONFIG ERROR | " + g_configurationError);
      return INIT_FAILED;
     }

   g_atrHandle = iATR(_Symbol, DECISION_TIMEFRAME, InpATRPeriod);
   if(g_atrHandle == INVALID_HANDLE)
     {
      g_configurationError = "ATR_HANDLE_CREATE_FAILED";
      return INIT_FAILED;
     }
   g_trade.SetExpertMagicNumber(InpControllerMagic);
   g_trade.SetAsyncMode(false);

   if(InpControlMode == LITE_CONTROL_ENABLED)
     {
      g_controlState = LITE_CONTROL_UNKNOWN;
      if(!AcquireControllerLock())
        {
         Print("CCBSN LITE CONTROL ERROR | " + g_lastControlError);
         return INIT_FAILED;
        }
      if(!RecoverPendingControllerOrder())
        {
         ReleaseControllerLock();
         return INIT_FAILED;
        }
     }
   else
      g_controlState = LITE_CONTROL_DISABLED;

   g_currentOpenBarTime = iTime(_Symbol, DECISION_TIMEFRAME, 0);
   MqlRates snapshotBar;
   datetime snapshotTime = 0;
   if(LoadLatestClosedSnapshot(snapshotBar, snapshotTime))
      g_lastDecisionTime = snapshotTime;

   if(!EventSetMillisecondTimer(TIMER_MILLISECONDS))
     {
      g_configurationError = "TIMER_CREATE_FAILED";
      ReleaseControllerLock();
      return INIT_FAILED;
     }

   g_configurationValid = true;
   AuditEvent("EA_STARTED", InpControlMode == LITE_VISUAL_ONLY
              ? "VISUAL_ONLY" : "CONTROL_ENABLED_FAIL_CLOSED");
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
   if(g_atrHandle != INVALID_HANDLE)
      IndicatorRelease(g_atrHandle);
   if(!InpKeepObjectsOnRemove && g_objectPrefix != "")
      ObjectsDeleteAll(0, g_objectPrefix);
   Comment("");
  }

void OnTick()
  {
   // Policy and command reconciliation are timer-driven. OnTick stays empty.
  }

void OnTimer()
  {
   if(!g_configurationValid)
      return;
   RefreshControllerLock();
   ProcessLatestClosedBar();
   if(InpWriteCsvAudit && !g_auditReady &&
      g_policyState != LITE_STATE_OFF)
      ForcePolicyOff(g_lastDecisionTime, "AUDIT_RUNTIME_FAILURE");
   ProcessCCBSNControl();
   UpdateDashboard();
  }

void OnTradeTransaction(const MqlTradeTransaction &transaction,
                        const MqlTradeRequest &request,
                        const MqlTradeResult &result)
  {
   if(InpControlMode == LITE_CONTROL_ENABLED && g_commandTicket != 0)
      ReconcilePendingCommand();
  }
//+------------------------------------------------------------------+
