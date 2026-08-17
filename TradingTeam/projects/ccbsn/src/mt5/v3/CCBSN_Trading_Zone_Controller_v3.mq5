//+------------------------------------------------------------------+
//|                  CCBSN_Trading_Zone_Controller_v3.mq5 v3.1.4     |
//|        Pine v3.1.3 dual policy + fast-ACK New Cycle control      |
//+------------------------------------------------------------------+
#property strict
#property copyright "TradingTeam"
#property version   "3.140"
#property description "CCBSN Controller v3 - MT5 port of TradingView policy v3.1.3"
#property description "Dual Policy, BearTwo, ATR streak, Downside EMA OFF and New Cycle control."

#include <Trade/Trade.mqh>

enum ENUM_VISUAL_STATE
  {
   VISUAL_STATE_OFF = 0,
   VISUAL_STATE_ARMING,
   VISUAL_STATE_ACTIVE,
   VISUAL_STATE_RISK_LOCK,
   VISUAL_STATE_DATA_ERROR
  };

enum ENUM_POLICY_SESSION
  {
   POLICY_SESSION_OUTSIDE = 0,
   POLICY_SESSION_1,
   POLICY_SESSION_2,
   POLICY_SESSION_3
  };

enum ENUM_POLICY_FAMILY
  {
   POLICY_FAMILY_NONE = 0,
   POLICY_FAMILY_UPSIDE,
   POLICY_FAMILY_DOWNSIDE
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

input group "02. Common M15 Gate"
input int    InpATRPeriod             = 20;
input double InpMinATRPrice           = 3.0;      // Raw symbol price, not pip/point
input int    InpEMAPeriod             = 23;

input group "03. UpsidePolicy"
input bool   InpEnableUpsidePolicy       = true;
input double InpUpsideMaxAboveEMAPrice   = 20.0; // Entry/hold: 0 <= D <= maximum
input int    InpUpsideConfirmBars        = 2;
input int    InpUpsideRiskLockBars       = 2;

input group "04. DownsidePolicy"
input bool   InpEnableDownsidePolicy       = true;
input double InpDownsideMinATRPrice         = 7.0;
input double InpDownsideBandBoundary        = 20.0;
input bool   InpEnableDownsideNearEntry      = true;  // -Boundary < D < 0
input bool   InpEnableDownsideDeepEntry      = true;  // D <= -Boundary
input double InpDownsideHoldMaxAboveEMA       = 5.0;
input int    InpDownsideConfirmBars           = 2;
input bool   InpDownsideRequireDRising        = true;
input bool   InpDownsideRequireEMANonDown     = false;
input int    InpDownsideEMASlopeBars          = 3;
input double InpDownsideBearDropMultiplier    = 1.25;
input int    InpDownsideRiskLockBars          = 1;
input bool   InpEnableDownsideEMAApproachBlock = true;
input double InpDownsideEMAApproachTolerance   = 0.2;

input group "05. Bear Drop Protection"
input bool   InpEnableBearDrop             = true;
input bool   InpEnableLegacyBearDrop       = true;
input int    InpBearDropLookback           = 8;
input double InpMinRelativeDropPrice       = 30.0;
input int    InpBearishWindow              = 3;
input int    InpMinBearishBars             = 2;
input bool   InpRequireDistanceFalling     = true;
input bool   InpEnableTwoBarBearDrop       = true;
input double InpMinTwoBarDropPrice         = 30.0;

input group "06. Active Zone Candle OFF"
input bool   InpEnableConsecutiveRedBlock  = true;
input int    InpConsecutiveRedBars         = 3;
input bool   InpEnableBearTwoBlock          = true;
input double InpBearTwoATRThreshold         = 10.0; // Strictly above on both red bars
input bool   InpEnableActiveLowATRBlock     = true;
input double InpActiveLowATRThreshold       = 7.0;  // Strictly below
input int    InpActiveLowATRBars            = 3;
input bool   InpEnableBearishPatternBlock  = true;
input double InpBearishBodyMultiplier      = 2.0;  // Current body >= multiplier * previous body
input bool   InpEnableDenyBlock             = true;
input int    InpDenyLookback                = 8;    // Prior candles before the upthrust
input double InpDenySweepBufferATR          = 0.05; // Upthrust High above prior High
input double InpDenyMinUpperWickBody        = 0.50; // Upthrust upper wick/body
input double InpDenyBodyMultiplier          = 1.00; // Deny body/upthrust body
input double InpDenyMinBodyOverlapPercent   = 60.0; // Deny overlap of upthrust body
input bool   InpDenyRequireCloseBelowHigh   = true; // Deny Close returns below prior High
input bool   InpEnableReverseBlock          = true;
input double InpReversePinMinUpperWickBody  = 2.0;  // Prior pin upper wick/body
input double InpReversePinMaxLowerWickBody  = 1.0;  // Prior pin lower wick/body
input double InpReverseBodyMultiplier       = 1.0;  // Red body must be strictly larger
input bool   InpEnableFallBlock             = true;
input double InpFallRangeMultiplier         = 1.00; // High-Low range vs prior 3-bar cluster

input group "07. New Cycle Sessions (broker server time)"
input int    InpSessionTimeShiftMinutes    = 0;       // Shift applied to broker bar time
input bool   InpEnableSession1             = true;
input string InpSession1                   = "0600-1200";
input bool   InpEnableSession2             = true;
input string InpSession2                   = "1200-1800";
input bool   InpEnableSession3             = true;
input string InpSession3                   = "1800-0300";

input group "08. Bear Drop Recovery"
input int    InpRecoveryBars               = 1;
input double InpRecoveryBufferATR          = 0.0;
input bool   InpRequireRecoveryDRising     = true;
input bool   InpRequireRecoveryEMANonDown  = false;
input int    InpRecoveryEMASlopeBars       = 3;
input bool   InpEnableBullishSCOBRecovery  = true; // OR path, evaluated only in RISK_LOCK

input group "09. Ownership & CCBSN Control"
input ENUM_CCBSN_CONTROL_MODE InpControlMode = CCBSN_CONTROL_ENABLED;
input ulong  InpCCBSNMagic            = 9696;     // Editable; must match the target CCBSN instance
input ulong  InpControllerMagic       = 99196;    // Must differ from CCBSN Magic
input bool   InpForceSyncOnInit        = false;    // Explicit troubleshooting only

input group "10. Display - Chart & Dashboard"
input bool   InpApplyChartTheme       = true;
input bool   InpShowDashboard         = false;
input color  InpDashboardBackgroundColor = clrWhite;
input color  InpDashboardTextColor       = C'45,55,70';

input group "11. Trading Zone History (Visual Only)"
input bool   InpDrawTradingZoneHistory = true;   // Draw closed Trading Zone history
input int    InpTradingZoneHistoryBars = 1500;   // Trading Zone history bars (M15)
input int    InpMaxStoredTradingZones  = 100;    // Max stored Trading Zones (1..500)

input group "12. Display - Risk Lock History"
input bool   InpDrawRiskLockShade     = true;
input color  InpRiskLockColor         = clrLightPink;
input bool   InpDrawRiskLockHistory   = true;
input int    InpRiskLockHistoryBars   = 1500;    // Closed M15 decisions to render
input int    InpMaxStoredRiskLocks    = 100;     // Valid range 1..500

input group "13. Display - EMA History"
input bool   InpShowEMAOnChart        = true;
input int    InpEMADisplayBars        = 400;

input group "14. Display - Event History & Visibility"
input bool   InpDrawEventHistory         = true;  // History gate; categories remain OFF by default
input int    InpEventHistoryBars         = 1500;
input int    InpMaxEventMarkers          = 250;
input bool   InpShowAllChartEvents       = false; // Show every category; individual switches also work alone
input bool   InpShowArmEvents            = false;
input bool   InpShowPolicyAllowEvents    = false;
input bool   InpShowPolicyBlockEvents    = false;
input bool   InpShowBearDropEvents       = false;
input bool   InpShowConsecutiveRedEvents = false;
input bool   InpShowBearTwoEvents        = false;
input bool   InpShowDownsideEMAEvents    = false;
input bool   InpShowActiveLowATREvents   = false;
input bool   InpShowBearishPatternEvents = false;
input bool   InpShowDenyEvents           = false;
input bool   InpShowReverseEvents        = false;
input bool   InpShowFallEvents           = false;
input bool   InpShowSessionEndEvents     = false;
input bool   InpShowRecoveryEvents       = false;
input bool   InpShowControlAckEvents     = false;
input bool   InpShowDriftEvents          = false;

input group "15. Text - Dashboard"
input string InpTextPanelTitle      = "CCBSN CONTROLLER v3.1.4";
input string InpTextMode            = "NEW CYCLE CONTROL";
input string InpTextOwner           = "Owner";
input string InpTextState           = "Policy";
input string InpTextConfirm         = "Confirm";
input string InpTextZone            = "Policy Zone";
input string InpTextControl         = "NC Command ACK";
input string InpTextDesired         = "Desired NC";
input string InpTextCommand         = "Ticket";
input string InpTextChecklist       = "Checklist";
input string InpTextReason          = "Reason";
input string InpTextDecision        = "Decision";

input group "16. Chart Event Names - Editable"
input string InpEventNameArm            = "ARM";             // ARM name; count N/Total is added
input string InpEventNamePolicyAllow    = "pAllow";     // New Cycle policy ON name
input string InpEventNamePolicyBlock    = "pBlock";     // New Cycle policy OFF name
input string InpEventNameBearDrop       = "BearD";      // Bear Drop protection name
input string InpEventNameRiskLock       = "rLock";      // Risk Lock state name
input string InpEventNameConsecutiveRed = "cRed";       // Consecutive red block name
input string InpEventNameBearTwo       = "BearTwo";
input string InpEventNameDownsideEMA   = "dEma";
input string InpEventNameActiveLowATR  = "atr3";
input string InpEventNameBearishEngulfing = "bEngulf";  // Bearish engulfing block name
input string InpEventNameBearishPinBar    = "bPin";     // Bearish pin bar block name
input string InpEventNameDeny             = "bDeny";    // Upthrust rejection block name
input string InpEventNameReverse          = "bReverse"; // Pin bar then larger bearish body
input string InpEventNameFall             = "bFall";    // 3-bar cluster downside break
input string InpEventNameSessionEnd     = "sEnd";       // Session boundary name
input string InpEventNameRecovered      = "pRecovered"; // Recovery name
input string InpEventNameNCEnabled      = "ncEnabled";  // CCBSN ON ACK name
input string InpEventNameNCDisabled     = "ncDisabled"; // CCBSN OFF ACK name
input string InpEventNameNCDrift        = "ncDrift";    // OFF drift warning name

input group "17. Audit"
input bool   InpWriteCsvAudit         = true;

// Fixed policy and protocol values are intentionally not user inputs.
// This keeps the MT5 Inputs tab operational, safe, and reproducible.
const double InpCommandPrice              = 888888.0;
const double InpCommandVolume             = 0.0; // Always use symbol minimum volume
const int    InpCommandTimeoutSeconds     = 30;
const int    InpCommandRetryMilliseconds  = 2000;
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
const color InpEMALineColor         = C'45,90,190';
const ENUM_LINE_STYLE InpEMALineStyle = STYLE_DASH;
const int InpEMALineWidth           = 1;
const int InpEMAOpacityPercent      = 70;

const double InpZonePaddingATR      = 0.25;
const color InpUpsideZoneColor      = clrLinen;
const color InpDownsideZoneColor    = clrLavender;
const color InpOffEventColor        = C'190,55,70';
const color InpBearDropEventColor   = C'225,125,65';
const color InpConsecutiveRedColor  = C'210,70,70';
const double BEARISH_PIN_UPPER_WICK_BODY_RATIO = 2.0;
const int InpZoneOpacityPercent     = 50;
const int InpEventOpacityPercent    = 50;
const int InpRiskLockOpacityPercent = 22;

const int InpTimerMilliseconds      = 250;
const string InpCsvFileName         = "CCBSN_Trading_Zone_Events_v3_1_4.csv";
const bool InpKeepObjectsOnRemove   = false;
const ulong TICKET_STORAGE_BASE     = 1000000000;

const ENUM_TIMEFRAMES DECISION_TIMEFRAME = PERIOD_M15;
const string POLICY_ID      = "ccbsn-m15-pine-v3-controller";
const string POLICY_VERSION = "3.1.4-mt5-fast-ack-handshake";

CTrade g_trade;

int g_atrHandle = INVALID_HANDLE;
int g_emaHandle = INVALID_HANDLE;
bool g_configurationValid = true;
string g_configurationError = "NONE";

string g_objectPrefix = "";
datetime g_lastM15BarTime = 0;
datetime g_lastDecisionTime = 0;
int g_historicalShift = 0;
datetime g_tradingZoneHistoryCutoff = 0;
datetime g_riskLockHistoryCutoff = 0;

ENUM_VISUAL_STATE g_state = VISUAL_STATE_OFF;
int g_consecutivePassCount = 0;
ENUM_POLICY_FAMILY g_armingPolicy = POLICY_FAMILY_NONE;
ENUM_POLICY_FAMILY g_activePolicy = POLICY_FAMILY_NONE;
ENUM_POLICY_FAMILY g_riskPolicy = POLICY_FAMILY_NONE;
ENUM_POLICY_SESSION g_armingSession = POLICY_SESSION_OUTSIDE;
ENUM_POLICY_SESSION g_activeSession = POLICY_SESSION_OUTSIDE;
int g_activeConsecutiveRedCount = 0;
int g_activeBearTwoCount = 0;
int g_activeLowATRCount = 0;
int g_riskLockRemaining = 0;
int g_consecutiveRecoveryBars = 0;
bool g_previousBearDropVeto = false;

int g_sessionStartMinutes[3];
int g_sessionEndMinutes[3];

double g_distanceHistory[];
double g_openHistory[];
double g_closeHistory[];
double g_highHistory[];
double g_lowHistory[];
double g_emaHistory[];
int g_bearishHistory[];

double g_lastClose = 0.0;
double g_lastATR = 0.0;
double g_lastEMA = 0.0;
double g_lastDistance = 0.0;
bool g_lastChecklistPass = false;
string g_lastReason = "WAITING_FOR_DATA";
double g_lastPeakDistance = 0.0;
double g_lastRelativeDrop = 0.0;
double g_lastPeakClose = 0.0;
double g_lastPriceDrop = 0.0;
int g_lastBearishBarCount = 0;
bool g_lastDistanceFalling = false;
double g_lastPreviousHigh = 0.0;
double g_lastCurrentLow = 0.0;
double g_lastTwoBarDrop = 0.0;
bool g_lastLegacyBearDrop = false;
bool g_lastTwoBarBearDrop = false;
bool g_lastBearDropVeto = false;
string g_lastBearDropSource = "NONE";
int g_lastConsecutiveRedCount = 0;
bool g_lastConsecutiveRedBlock = false;
int g_lastBearTwoCount = 0;
bool g_lastBearTwoBlock = false;
int g_lastActiveLowATRCount = 0;
bool g_lastActiveLowATRBlock = false;
bool g_lastDownsideEMAApproachBlock = false;
bool g_lastBearishEngulfing = false;
bool g_lastBearishPinBar = false;
bool g_lastBearishPatternBlock = false;
double g_lastCurrentBody = 0.0;
double g_lastPreviousBody = 0.0;
string g_lastBearishPatternSource = "NONE";
bool g_lastUpthrustSweep = false;
bool g_lastDenyBlock = false;
double g_lastDenyPriorHigh = 0.0;
double g_lastDenySweepSize = 0.0;
double g_lastDenyUpperWickBody = 0.0;
double g_lastDenyBody = 0.0;
double g_lastUpthrustBody = 0.0;
double g_lastDenyBodyOverlapPercent = 0.0;
bool g_lastReversePinBar = false;
bool g_lastReverseBlock = false;
double g_lastReversePinBody = 0.0;
double g_lastReverseRedBody = 0.0;
double g_lastReverseUpperWickBody = 0.0;
double g_lastReverseLowerWickBody = 0.0;
bool g_lastFallBlock = false;
double g_lastFallBody = 0.0;
double g_lastFallRange = 0.0;
double g_lastFallPriorRange = 0.0;
double g_lastFallPriorHigh = 0.0;
double g_lastFallPriorLow = 0.0;
bool g_lastFallOpenInside = false;
bool g_lastFallCloseBreak = false;
ENUM_POLICY_SESSION g_lastDecisionSession = POLICY_SESSION_OUTSIDE;
bool g_lastPolicyRecoveryCandidate = false;
bool g_lastBullishSCOB = false;
bool g_lastRecoveryCandidate = false;
string g_lastRecoverySource = "NONE";

datetime g_activeZoneStart = 0;
double g_activeZoneHigh = 0.0;
double g_activeZoneLow = 0.0;
double g_activeZoneATR = 0.0;
ENUM_POLICY_FAMILY g_activeZoneBranch = POLICY_FAMILY_NONE;
string g_activeZoneBaseName = "";

datetime g_riskLockStart = 0;
double g_riskLockHigh = 0.0;
double g_riskLockLow = 0.0;
double g_riskLockATR = 0.0;
string g_riskLockBaseName = "";

string g_eventObjectNames[];
string g_closedZoneObjectNames[];
string g_closedRiskLockObjectNames[];
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
bool g_controlReconcileRequested = false;
int g_driftCount = 0;
datetime g_lastDriftAlertTime = 0;
ENUM_CCBSN_COMMAND g_lastSyncDesired = CCBSN_COMMAND_NONE;
string g_syncState = "INITIALIZING";
string g_lastSyncReason = "WAITING_FOR_POSITION_SNAPSHOT";
ulong g_nextCommandAttemptTick = 0;

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
      case VISUAL_STATE_RISK_LOCK:  return "RISK_LOCK";
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

string PolicyFamilyToString(const ENUM_POLICY_FAMILY policy)
  {
   switch(policy)
     {
      case POLICY_FAMILY_UPSIDE:   return "UpsidePolicy";
      case POLICY_FAMILY_DOWNSIDE: return "DownsidePolicy";
      default:                     return "NONE";
     }
  }

string TimeKey(const datetime value)
  {
   return IntegerToString((long)value);
  }

color PolicyFamilyColor(const ENUM_POLICY_FAMILY policy)
  {
   if(policy == POLICY_FAMILY_DOWNSIDE)
      return InpDownsideZoneColor;
   return InpUpsideZoneColor;
  }

string SessionToString(const ENUM_POLICY_SESSION session)
  {
   switch(session)
     {
      case POLICY_SESSION_1: return "SESSION 1";
      case POLICY_SESSION_2: return "SESSION 2";
      case POLICY_SESSION_3: return "SESSION 3";
      default:               return "OUTSIDE";
     }
  }

string BearDropSource(const bool legacyVeto, const bool twoBarVeto)
  {
   if(legacyVeto && twoBarVeto) return "BOTH";
   if(legacyVeto) return "LEGACY";
   if(twoBarVeto) return "2-BAR";
   return "NONE";
  }

bool ParseSessionText(const string value, int &startMinute, int &endMinute)
  {
   if(StringLen(value) != 9 || StringSubstr(value, 4, 1) != "-")
      return false;
   for(int index = 0; index < 9; index++)
     {
      if(index == 4)
         continue;
      ushort character = StringGetCharacter(value, index);
      if(character < 48 || character > 57)
         return false;
     }
   int startHour = (int)StringToInteger(StringSubstr(value, 0, 2));
   int startMin = (int)StringToInteger(StringSubstr(value, 2, 2));
   int endHour = (int)StringToInteger(StringSubstr(value, 5, 2));
   int endMin = (int)StringToInteger(StringSubstr(value, 7, 2));
   if(startHour < 0 || startHour > 23 || endHour < 0 || endHour > 23 ||
      startMin < 0 || startMin > 59 || endMin < 0 || endMin > 59)
      return false;
   startMinute = startHour * 60 + startMin;
   endMinute = endHour * 60 + endMin;
   return startMinute != endMinute;
  }

bool IsMinuteInSession(const int minuteOfDay,
                       const int startMinute,
                       const int endMinute)
  {
   if(startMinute < endMinute)
      return minuteOfDay >= startMinute && minuteOfDay < endMinute;
   return minuteOfDay >= startMinute || minuteOfDay < endMinute;
  }

bool SessionEnabledByIndex(const int index)
  {
   if(index == 0) return InpEnableSession1;
   if(index == 1) return InpEnableSession2;
   if(index == 2) return InpEnableSession3;
   return false;
  }

ENUM_POLICY_SESSION PolicySessionAt(const datetime brokerTime)
  {
   MqlDateTime parts;
   TimeToStruct(brokerTime + InpSessionTimeShiftMinutes * 60, parts);
   int minuteOfDay = parts.hour * 60 + parts.min;
   for(int index = 0; index < 3; index++)
     {
      if(SessionEnabledByIndex(index) &&
         IsMinuteInSession(minuteOfDay,
                           g_sessionStartMinutes[index],
                           g_sessionEndMinutes[index]))
         return (ENUM_POLICY_SESSION)(index + 1);
     }
   return POLICY_SESSION_OUTSIDE;
  }

bool ValidateSessionConfiguration()
  {
   if(!ParseSessionText(InpSession1, g_sessionStartMinutes[0], g_sessionEndMinutes[0]))
     {
      g_configurationError = "InpSession1=" + InpSession1 +
                             " (expected HHMM-HHMM with different start/end)";
      PrintFormat("CONFIG ERROR | %s", g_configurationError);
      return false;
     }
   if(!ParseSessionText(InpSession2, g_sessionStartMinutes[1], g_sessionEndMinutes[1]))
     {
      g_configurationError = "InpSession2=" + InpSession2 +
                             " (expected HHMM-HHMM with different start/end)";
      PrintFormat("CONFIG ERROR | %s", g_configurationError);
      return false;
     }
   if(!ParseSessionText(InpSession3, g_sessionStartMinutes[2], g_sessionEndMinutes[2]))
     {
      g_configurationError = "InpSession3=" + InpSession3 +
                             " (expected HHMM-HHMM with different start/end)";
      PrintFormat("CONFIG ERROR | %s", g_configurationError);
      return false;
     }
   for(int minute = 0; minute < 1440; minute++)
     {
      int matches = 0;
      for(int index = 0; index < 3; index++)
         if(SessionEnabledByIndex(index) &&
            IsMinuteInSession(minute,
                              g_sessionStartMinutes[index],
                              g_sessionEndMinutes[index]))
            matches++;
      if(matches > 1)
        {
         g_configurationError = "InpSession1..3 overlap at minute " +
                                IntegerToString(minute) +
                                " (expected enabled sessions not to overlap)";
         PrintFormat("CONFIG ERROR | %s", g_configurationError);
         return false;
        }
     }
   return true;
  }

int FeatureHistoryCapacity()
  {
   int capacity = MathMax(InpBearDropLookback, InpBearishWindow);
   capacity = MathMax(capacity, InpRecoveryEMASlopeBars + 1);
   // Deny uses [0]=deny, [1]=upthrust and [2..lookback+1]=prior range.
   capacity = MathMax(capacity, InpDenyLookback + 1);
   capacity = MathMax(capacity, 3);
   return capacity + 1;
  }

void PushDoubleHistory(double &values[], const double value, const int maximum)
  {
   int oldSize = ArraySize(values);
   int newSize = MathMin(oldSize + 1, maximum);
   ArrayResize(values, newSize);
   for(int index = newSize - 1; index >= 1; index--)
      values[index] = values[index - 1];
   values[0] = value;
  }

void PushIntHistory(int &values[], const int value, const int maximum)
  {
   int oldSize = ArraySize(values);
   int newSize = MathMin(oldSize + 1, maximum);
   ArrayResize(values, newSize);
   for(int index = newSize - 1; index >= 1; index--)
      values[index] = values[index - 1];
   values[0] = value;
  }

void PushFeatureSample(const MqlRates &bar, const double emaValue)
  {
   int capacity = FeatureHistoryCapacity();
   PushDoubleHistory(g_distanceHistory, bar.close - emaValue, capacity);
   PushDoubleHistory(g_openHistory, bar.open, capacity);
   PushDoubleHistory(g_closeHistory, bar.close, capacity);
   PushDoubleHistory(g_highHistory, bar.high, capacity);
   PushDoubleHistory(g_lowHistory, bar.low, capacity);
   PushDoubleHistory(g_emaHistory, emaValue, capacity);
   PushIntHistory(g_bearishHistory, bar.close < bar.open ? 1 : 0, capacity);
  }

bool EvaluateBullishSCOB()
  {
   if(!InpEnableBullishSCOBRecovery ||
      ArraySize(g_openHistory) < 3 || ArraySize(g_closeHistory) < 3 ||
      ArraySize(g_highHistory) < 2 || ArraySize(g_lowHistory) < 3)
      return false;

   // Bullish Single Candle Order Block (SCOB), confirmed on bar [0]:
   // [2] bearish; [1] bullish and sweeps Low[2]; [0] bullish and
   // closes above High[1]. This function is called only in RISK_LOCK.
   return g_openHistory[2] > g_closeHistory[2] &&
          g_closeHistory[1] > g_openHistory[1] &&
          g_closeHistory[0] > g_openHistory[0] &&
          g_lowHistory[1] < g_lowHistory[2] &&
           g_closeHistory[0] > g_highHistory[1];
  }

void ResetBearishPatternSnapshot()
  {
   g_lastBearishEngulfing = false;
   g_lastBearishPinBar = false;
   g_lastBearishPatternBlock = false;
   g_lastCurrentBody = 0.0;
   g_lastPreviousBody = 0.0;
   g_lastBearishPatternSource = "NONE";
  }

bool EvaluateBearishPattern()
  {
   ResetBearishPatternSnapshot();
   if(!InpEnableBearishPatternBlock ||
      ArraySize(g_openHistory) < 2 || ArraySize(g_closeHistory) < 2 ||
      ArraySize(g_highHistory) < 1 || ArraySize(g_lowHistory) < 1)
      return false;

   double currentOpen = g_openHistory[0];
   double currentClose = g_closeHistory[0];
   double previousOpen = g_openHistory[1];
   double previousClose = g_closeHistory[1];
   g_lastCurrentBody = MathAbs(currentClose - currentOpen);
   g_lastPreviousBody = MathAbs(previousClose - previousOpen);

   bool currentBearish = currentClose < currentOpen;
   bool previousBullish = previousClose > previousOpen;
   double minimumBody = MathMax(g_lastPreviousBody * InpBearishBodyMultiplier,
                                SymbolInfoDouble(_Symbol, SYMBOL_POINT));
   bool bodyRatioPass = g_lastCurrentBody >= minimumBody;

   // Standard real-body bearish engulfing. Wicks do not need to engulf.
   g_lastBearishEngulfing = currentBearish && previousBullish &&
                            currentOpen >= previousClose &&
                            currentClose <= previousOpen && bodyRatioPass;

   // Bearish pin bar: red body near the low, dominant upper rejection wick.
   double upperWick = g_highHistory[0] - MathMax(currentOpen, currentClose);
   double lowerWick = MathMin(currentOpen, currentClose) - g_lowHistory[0];
   g_lastBearishPinBar = currentBearish && g_lastCurrentBody > 0.0 &&
                         upperWick >= g_lastCurrentBody *
                                      BEARISH_PIN_UPPER_WICK_BODY_RATIO &&
                         lowerWick <= g_lastCurrentBody && bodyRatioPass;

   if(g_lastBearishEngulfing && g_lastBearishPinBar)
      g_lastBearishPatternSource = "ENGULFING+PIN_BAR";
   else if(g_lastBearishEngulfing)
      g_lastBearishPatternSource = "ENGULFING";
   else if(g_lastBearishPinBar)
      g_lastBearishPatternSource = "PIN_BAR";

   g_lastBearishPatternBlock = g_lastBearishEngulfing || g_lastBearishPinBar;
   return g_lastBearishPatternBlock;
  }

void ResetDenySnapshot()
  {
   g_lastUpthrustSweep = false;
   g_lastDenyBlock = false;
   g_lastDenyPriorHigh = 0.0;
   g_lastDenySweepSize = 0.0;
   g_lastDenyUpperWickBody = 0.0;
   g_lastDenyBody = 0.0;
   g_lastUpthrustBody = 0.0;
   g_lastDenyBodyOverlapPercent = 0.0;
  }

bool EvaluateDeny(const double atrValue)
  {
   ResetDenySnapshot();
   int required = InpDenyLookback + 2;
   if(!InpEnableDenyBlock || atrValue <= 0.0 ||
      ArraySize(g_openHistory) < required ||
      ArraySize(g_closeHistory) < required ||
      ArraySize(g_highHistory) < required ||
      ArraySize(g_lowHistory) < required)
      return false;

   // [0] is the closed bearish confirmation candle, named DENY.
   // [1] is the candidate upthrust; [2..lookback+1] form prior resistance.
   g_lastDenyPriorHigh = g_highHistory[2];
   for(int index = 3; index <= InpDenyLookback + 1; index++)
      g_lastDenyPriorHigh = MathMax(g_lastDenyPriorHigh,
                                    g_highHistory[index]);

   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   double upthrustOpen = g_openHistory[1];
   double upthrustClose = g_closeHistory[1];
   double upthrustHigh = g_highHistory[1];
   g_lastUpthrustBody = MathAbs(upthrustClose - upthrustOpen);
   double upthrustBodyFloor = MathMax(g_lastUpthrustBody, point);
   double upthrustUpperWick = upthrustHigh -
                              MathMax(upthrustOpen, upthrustClose);
   g_lastDenyUpperWickBody = upthrustUpperWick / upthrustBodyFloor;
   g_lastDenySweepSize = upthrustHigh - g_lastDenyPriorHigh;
   bool sweepPass = g_lastDenySweepSize >= atrValue * InpDenySweepBufferATR;
   bool wickPass = g_lastDenyUpperWickBody >= InpDenyMinUpperWickBody;
   g_lastUpthrustSweep = sweepPass && wickPass;

   double denyOpen = g_openHistory[0];
   double denyClose = g_closeHistory[0];
   g_lastDenyBody = MathAbs(denyClose - denyOpen);
   bool bearishDeny = denyClose < denyOpen;
   bool bodyPass = g_lastDenyBody >=
                   MathMax(g_lastUpthrustBody * InpDenyBodyMultiplier, point);
   bool closeBackPass = !InpDenyRequireCloseBelowHigh ||
                        denyClose < g_lastDenyPriorHigh;

   double upthrustBodyLow = MathMin(upthrustOpen, upthrustClose);
   double upthrustBodyHigh = MathMax(upthrustOpen, upthrustClose);
   double denyBodyLow = MathMin(denyOpen, denyClose);
   double denyBodyHigh = MathMax(denyOpen, denyClose);
   double overlap = MathMax(0.0,
                            MathMin(upthrustBodyHigh, denyBodyHigh) -
                            MathMax(upthrustBodyLow, denyBodyLow));
   if(g_lastUpthrustBody > point)
      g_lastDenyBodyOverlapPercent = overlap / g_lastUpthrustBody * 100.0;
   bool overlapPass = g_lastDenyBodyOverlapPercent >=
                      InpDenyMinBodyOverlapPercent;

   g_lastDenyBlock = g_lastUpthrustSweep && bearishDeny && bodyPass &&
                     overlapPass && closeBackPass;
   return g_lastDenyBlock;
  }

void ResetReverseSnapshot()
  {
   g_lastReversePinBar = false;
   g_lastReverseBlock = false;
   g_lastReversePinBody = 0.0;
   g_lastReverseRedBody = 0.0;
   g_lastReverseUpperWickBody = 0.0;
   g_lastReverseLowerWickBody = 0.0;
  }

bool EvaluateReverse()
  {
   ResetReverseSnapshot();
   if(!InpEnableReverseBlock ||
      ArraySize(g_openHistory) < 2 || ArraySize(g_closeHistory) < 2 ||
      ArraySize(g_highHistory) < 2 || ArraySize(g_lowHistory) < 2)
      return false;

   // [1] is an upper-rejection pin bar of either candle color.
   // [0] is a closed bearish candle with a strictly larger real body.
   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   double pinOpen = g_openHistory[1];
   double pinClose = g_closeHistory[1];
   double pinBody = MathAbs(pinClose - pinOpen);
   double pinBodyFloor = MathMax(pinBody, point);
   double pinUpperWick = g_highHistory[1] - MathMax(pinOpen, pinClose);
   double pinLowerWick = MathMin(pinOpen, pinClose) - g_lowHistory[1];

   g_lastReversePinBody = pinBody;
   g_lastReverseUpperWickBody = pinUpperWick / pinBodyFloor;
   g_lastReverseLowerWickBody = pinLowerWick / pinBodyFloor;
   g_lastReversePinBar = pinBody > 0.0 &&
      g_lastReverseUpperWickBody >= InpReversePinMinUpperWickBody &&
      g_lastReverseLowerWickBody <= InpReversePinMaxLowerWickBody;

   double redOpen = g_openHistory[0];
   double redClose = g_closeHistory[0];
   g_lastReverseRedBody = MathAbs(redClose - redOpen);
   bool bearishRed = redClose < redOpen;
   bool bodyLarger = g_lastReverseRedBody >
                     MathMax(g_lastReversePinBody *
                             InpReverseBodyMultiplier, point);
   g_lastReverseBlock = g_lastReversePinBar && bearishRed && bodyLarger;
   return g_lastReverseBlock;
  }

void ResetFallSnapshot()
  {
   g_lastFallBlock = false;
   g_lastFallBody = 0.0;
   g_lastFallRange = 0.0;
   g_lastFallPriorRange = 0.0;
   g_lastFallPriorHigh = 0.0;
   g_lastFallPriorLow = 0.0;
   g_lastFallOpenInside = false;
   g_lastFallCloseBreak = false;
  }

bool EvaluateFall()
  {
   ResetFallSnapshot();
   if(!InpEnableFallBlock ||
      ArraySize(g_openHistory) < 4 || ArraySize(g_closeHistory) < 4 ||
      ArraySize(g_highHistory) < 4 || ArraySize(g_lowHistory) < 4)
      return false;

   // [1..3] form the preceding cluster using complete High-Low ranges,
   // including all wicks. [0] must be bearish, open inside the cluster,
   // have a complete High-Low range large enough relative to the cluster,
   // and close below its lowest wick. High[0] does NOT have to reach
   // PriorHigh; Fall is a downside cluster break, not geometric engulfing.
   g_lastFallPriorHigh = g_highHistory[1];
   g_lastFallPriorLow = g_lowHistory[1];
   for(int index = 2; index <= 3; index++)
     {
      g_lastFallPriorHigh = MathMax(g_lastFallPriorHigh,
                                    g_highHistory[index]);
      g_lastFallPriorLow = MathMin(g_lastFallPriorLow,
                                   g_lowHistory[index]);
     }
   g_lastFallPriorRange = g_lastFallPriorHigh - g_lastFallPriorLow;

   double currentOpen = g_openHistory[0];
   double currentClose = g_closeHistory[0];
   double currentHigh = g_highHistory[0];
   double currentLow = g_lowHistory[0];
   g_lastFallBody = MathAbs(currentClose - currentOpen);
   g_lastFallRange = currentHigh - currentLow;

   bool bearish = currentClose < currentOpen;
   g_lastFallOpenInside = currentOpen >= g_lastFallPriorLow &&
                          currentOpen <= g_lastFallPriorHigh;
   bool rangeExpansion = g_lastFallPriorRange > 0.0 &&
      g_lastFallRange >= g_lastFallPriorRange * InpFallRangeMultiplier;
   g_lastFallCloseBreak = currentClose < g_lastFallPriorLow;
   g_lastFallBlock = bearish && g_lastFallOpenInside &&
                     rangeExpansion && g_lastFallCloseBreak;
   return g_lastFallBlock;
  }

bool EvaluateBearDrop(const MqlRates &bar,
                      const double thresholdMultiplier)
  {
   g_lastPeakDistance = g_lastDistance;
   g_lastRelativeDrop = 0.0;
   g_lastPeakClose = g_lastClose;
   g_lastPriceDrop = 0.0;
   g_lastBearishBarCount = 0;
   g_lastDistanceFalling = false;
   g_lastPreviousHigh = 0.0;
   g_lastCurrentLow = bar.low;
   g_lastTwoBarDrop = 0.0;

   bool legacyReady = ArraySize(g_distanceHistory) >= InpBearDropLookback &&
                      ArraySize(g_bearishHistory) >= InpBearishWindow;
   if(legacyReady)
     {
      g_lastPeakDistance = g_distanceHistory[0];
      g_lastPeakClose = g_closeHistory[0];
      for(int index = 1; index < InpBearDropLookback; index++)
        {
         g_lastPeakDistance = MathMax(g_lastPeakDistance, g_distanceHistory[index]);
         g_lastPeakClose = MathMax(g_lastPeakClose, g_closeHistory[index]);
        }
      for(int index = 0; index < InpBearishWindow; index++)
         g_lastBearishBarCount += g_bearishHistory[index];
      g_lastRelativeDrop = g_lastPeakDistance - g_lastDistance;
      g_lastPriceDrop = g_lastPeakClose - g_lastClose;
      g_lastDistanceFalling = ArraySize(g_distanceHistory) >= 3 &&
                              g_distanceHistory[0] < g_distanceHistory[1] &&
                              g_distanceHistory[1] < g_distanceHistory[2];
     }

   bool twoBarReady = ArraySize(g_highHistory) >= 2;
   if(twoBarReady)
     {
      g_lastPreviousHigh = g_highHistory[1];
      g_lastTwoBarDrop = g_lastPreviousHigh - g_lastCurrentLow;
     }

   int requiredBearishBars = (int)MathMin(InpMinBearishBars, InpBearishWindow);
    double effectiveMultiplier = MathMax(1.0, thresholdMultiplier);
    g_lastLegacyBearDrop = InpEnableLegacyBearDrop && legacyReady &&
                           g_lastRelativeDrop >=
                           InpMinRelativeDropPrice * effectiveMultiplier &&
                          g_lastBearishBarCount >= requiredBearishBars &&
                          (!InpRequireDistanceFalling || g_lastDistanceFalling);
    g_lastTwoBarBearDrop = InpEnableTwoBarBearDrop && twoBarReady &&
                           g_lastTwoBarDrop >=
                           InpMinTwoBarDropPrice * effectiveMultiplier;
   g_lastBearDropSource = BearDropSource(g_lastLegacyBearDrop,
                                         g_lastTwoBarBearDrop);
   g_lastBearDropVeto = InpEnableBearDrop &&
                        (g_lastLegacyBearDrop || g_lastTwoBarBearDrop);
   return g_lastBearDropVeto;
  }

//+------------------------------------------------------------------+
//| Configuration                                                    |
//+------------------------------------------------------------------+
bool ConfigurationError(const string inputName,
                        const string value,
                        const string supportedRange)
  {
   g_configurationError = inputName + "=" + value +
                          " (expected " + supportedRange + ")";
   PrintFormat("CONFIG ERROR | %s", g_configurationError);
   return false;
  }

bool ValidateInputs()
  {
   if(InpExpectedSymbolPrefix != "" && StringFind(_Symbol, InpExpectedSymbolPrefix) != 0)
      return ConfigurationError("InpExpectedSymbolPrefix",
                                InpExpectedSymbolPrefix,
                                "prefix of " + _Symbol);
   if(_Digits != (int)InpXAUQuoteDigits)
      return ConfigurationError("InpXAUQuoteDigits",
                                IntegerToString((int)InpXAUQuoteDigits),
                                IntegerToString(_Digits) + " for " + _Symbol);
   if(InpATRPeriod < 1 || InpATRPeriod > 1000)
      return ConfigurationError("InpATRPeriod", IntegerToString(InpATRPeriod), "1..1000");
   if(InpEMAPeriod < 1 || InpEMAPeriod > 1000)
      return ConfigurationError("InpEMAPeriod", IntegerToString(InpEMAPeriod), "1..1000");
   if(InpMinATRPrice <= 0.0)
      return ConfigurationError("InpMinATRPrice", DoubleToString(InpMinATRPrice, 4), "> 0");
   if(InpUpsideMaxAboveEMAPrice < 0.0)
      return ConfigurationError("InpUpsideMaxAboveEMAPrice",
                                DoubleToString(InpUpsideMaxAboveEMAPrice, 4), ">= 0");
   if(InpUpsideConfirmBars < 1 || InpUpsideConfirmBars > 20)
      return ConfigurationError("InpUpsideConfirmBars",
                                IntegerToString(InpUpsideConfirmBars), "1..20");
   if(InpUpsideRiskLockBars < 1 || InpUpsideRiskLockBars > 96)
      return ConfigurationError("InpUpsideRiskLockBars",
                                IntegerToString(InpUpsideRiskLockBars), "1..96");
   if(InpDownsideMinATRPrice <= 0.0)
      return ConfigurationError("InpDownsideMinATRPrice",
                                DoubleToString(InpDownsideMinATRPrice, 4), "> 0");
   if(InpDownsideBandBoundary < 0.0)
      return ConfigurationError("InpDownsideBandBoundary",
                                DoubleToString(InpDownsideBandBoundary, 4), ">= 0");
   if(InpEnableDownsidePolicy && !InpEnableDownsideNearEntry &&
      !InpEnableDownsideDeepEntry)
      return ConfigurationError("DownsideEntryModes", "both disabled",
                                "at least one enabled");
   if(InpDownsideHoldMaxAboveEMA < 0.0)
      return ConfigurationError("InpDownsideHoldMaxAboveEMA",
                                DoubleToString(InpDownsideHoldMaxAboveEMA, 4), ">= 0");
   if(InpDownsideConfirmBars < 1 || InpDownsideConfirmBars > 20)
      return ConfigurationError("InpDownsideConfirmBars",
                                IntegerToString(InpDownsideConfirmBars), "1..20");
   if(InpDownsideEMASlopeBars < 1 || InpDownsideEMASlopeBars > 20)
      return ConfigurationError("InpDownsideEMASlopeBars",
                                IntegerToString(InpDownsideEMASlopeBars), "1..20");
   if(InpDownsideBearDropMultiplier < 1.0 ||
      InpDownsideBearDropMultiplier > 5.0)
      return ConfigurationError("InpDownsideBearDropMultiplier",
                                DoubleToString(InpDownsideBearDropMultiplier, 4), "1..5");
   if(InpDownsideRiskLockBars < 1 || InpDownsideRiskLockBars > 96)
      return ConfigurationError("InpDownsideRiskLockBars",
                                IntegerToString(InpDownsideRiskLockBars), "1..96");
   if(InpDownsideEMAApproachTolerance < 0.0)
      return ConfigurationError("InpDownsideEMAApproachTolerance",
                                DoubleToString(InpDownsideEMAApproachTolerance, 4), ">= 0");
   if(InpBearDropLookback < 3 || InpBearDropLookback > 100)
      return ConfigurationError("InpBearDropLookback", IntegerToString(InpBearDropLookback), "3..100");
   if(InpMinRelativeDropPrice <= 0.0)
      return ConfigurationError("InpMinRelativeDropPrice", DoubleToString(InpMinRelativeDropPrice, 4), "> 0");
   if(InpBearishWindow < 2 || InpBearishWindow > 10)
      return ConfigurationError("InpBearishWindow", IntegerToString(InpBearishWindow), "2..10");
   if(InpMinBearishBars < 1 || InpMinBearishBars > InpBearishWindow)
      return ConfigurationError("InpMinBearishBars", IntegerToString(InpMinBearishBars),
                                "1..InpBearishWindow");
   if(InpMinTwoBarDropPrice <= 0.0)
      return ConfigurationError("InpMinTwoBarDropPrice", DoubleToString(InpMinTwoBarDropPrice, 4), "> 0");
   if(InpConsecutiveRedBars < 2 || InpConsecutiveRedBars > 10)
      return ConfigurationError("InpConsecutiveRedBars", IntegerToString(InpConsecutiveRedBars), "2..10");
   if(InpBearTwoATRThreshold <= 0.0)
      return ConfigurationError("InpBearTwoATRThreshold",
                                DoubleToString(InpBearTwoATRThreshold, 4), "> 0");
   if(InpActiveLowATRThreshold <= 0.0)
      return ConfigurationError("InpActiveLowATRThreshold",
                                DoubleToString(InpActiveLowATRThreshold, 4), "> 0");
   if(InpActiveLowATRBars < 1 || InpActiveLowATRBars > 20)
      return ConfigurationError("InpActiveLowATRBars",
                                IntegerToString(InpActiveLowATRBars), "1..20");
   if(InpBearishBodyMultiplier < 1.0 || InpBearishBodyMultiplier > 20.0)
      return ConfigurationError("InpBearishBodyMultiplier", DoubleToString(InpBearishBodyMultiplier, 4), "1..20");
   if(InpDenyLookback < 3 || InpDenyLookback > 100)
      return ConfigurationError("InpDenyLookback", IntegerToString(InpDenyLookback), "3..100");
   if(InpDenySweepBufferATR < 0.0 || InpDenySweepBufferATR > 10.0)
      return ConfigurationError("InpDenySweepBufferATR", DoubleToString(InpDenySweepBufferATR, 4), "0..10");
   if(InpDenyMinUpperWickBody < 0.0 || InpDenyMinUpperWickBody > 20.0)
      return ConfigurationError("InpDenyMinUpperWickBody", DoubleToString(InpDenyMinUpperWickBody, 4), "0..20");
   if(InpDenyBodyMultiplier <= 0.0 || InpDenyBodyMultiplier > 20.0)
      return ConfigurationError("InpDenyBodyMultiplier", DoubleToString(InpDenyBodyMultiplier, 4), "> 0 and <= 20");
   if(InpDenyMinBodyOverlapPercent < 0.0 || InpDenyMinBodyOverlapPercent > 100.0)
      return ConfigurationError("InpDenyMinBodyOverlapPercent",
                                DoubleToString(InpDenyMinBodyOverlapPercent, 2), "0..100");
   if(InpReversePinMinUpperWickBody <= 0.0 || InpReversePinMinUpperWickBody > 20.0)
      return ConfigurationError("InpReversePinMinUpperWickBody",
                                DoubleToString(InpReversePinMinUpperWickBody, 4), "> 0 and <= 20");
   if(InpReversePinMaxLowerWickBody < 0.0 || InpReversePinMaxLowerWickBody > 20.0)
      return ConfigurationError("InpReversePinMaxLowerWickBody",
                                DoubleToString(InpReversePinMaxLowerWickBody, 4), "0..20");
   if(InpReverseBodyMultiplier <= 0.0 || InpReverseBodyMultiplier > 20.0)
      return ConfigurationError("InpReverseBodyMultiplier",
                                DoubleToString(InpReverseBodyMultiplier, 4), "> 0 and <= 20");
   if(InpFallRangeMultiplier <= 0.0 || InpFallRangeMultiplier > 20.0)
      return ConfigurationError("InpFallRangeMultiplier",
                                DoubleToString(InpFallRangeMultiplier, 4), "> 0 and <= 20");
   if(InpRecoveryBars < 1 || InpRecoveryBars > 20)
      return ConfigurationError("InpRecoveryBars", IntegerToString(InpRecoveryBars), "1..20");
   if(InpRecoveryBufferATR < 0.0)
      return ConfigurationError("InpRecoveryBufferATR", DoubleToString(InpRecoveryBufferATR, 4), ">= 0");
   if(InpRecoveryEMASlopeBars < 1 || InpRecoveryEMASlopeBars > 20)
      return ConfigurationError("InpRecoveryEMASlopeBars", IntegerToString(InpRecoveryEMASlopeBars), "1..20");
   if(InpSessionTimeShiftMinutes < -1440 || InpSessionTimeShiftMinutes > 1440)
      return ConfigurationError("InpSessionTimeShiftMinutes",
                                IntegerToString(InpSessionTimeShiftMinutes), "-1440..1440");
   if(!ValidateSessionConfiguration())
      return false;
   if(InpTradingZoneHistoryBars < 1 || InpTradingZoneHistoryBars > 100000)
      return ConfigurationError("InpTradingZoneHistoryBars", IntegerToString(InpTradingZoneHistoryBars), "1..100000");
   if(InpRiskLockHistoryBars < 1 || InpRiskLockHistoryBars > 100000)
      return ConfigurationError("InpRiskLockHistoryBars", IntegerToString(InpRiskLockHistoryBars), "1..100000");
   if(InpEventHistoryBars < 1 || InpEventHistoryBars > 100000)
      return ConfigurationError("InpEventHistoryBars", IntegerToString(InpEventHistoryBars), "1..100000");
   if(InpMaxStoredTradingZones < 1 || InpMaxStoredTradingZones > 500)
      return ConfigurationError("InpMaxStoredTradingZones", IntegerToString(InpMaxStoredTradingZones), "1..500");
   if(InpMaxStoredRiskLocks < 1 || InpMaxStoredRiskLocks > 500)
      return ConfigurationError("InpMaxStoredRiskLocks", IntegerToString(InpMaxStoredRiskLocks), "1..500");
   if(InpMaxEventMarkers < 1 || InpMaxEventMarkers > 1000)
      return ConfigurationError("InpMaxEventMarkers", IntegerToString(InpMaxEventMarkers), "1..1000");
   if(InpEMADisplayBars < 2 || InpEMADisplayBars > 5000)
      return ConfigurationError("InpEMADisplayBars", IntegerToString(InpEMADisplayBars), "2..5000");
   if(InpTimerMilliseconds < 100)
      return ConfigurationError("InpTimerMilliseconds", IntegerToString(InpTimerMilliseconds), ">= 100");
   if(InpEMALineWidth < 1 || InpEMALineWidth > 5)
      return ConfigurationError("InpEMALineWidth", IntegerToString(InpEMALineWidth), "1..5");
   if(InpZoneOpacityPercent < 0 || InpZoneOpacityPercent > 100)
      return ConfigurationError("InpZoneOpacityPercent", IntegerToString(InpZoneOpacityPercent), "0..100");
   if(InpEventOpacityPercent < 0 || InpEventOpacityPercent > 100)
      return ConfigurationError("InpEventOpacityPercent", IntegerToString(InpEventOpacityPercent), "0..100");
   if(InpEMAOpacityPercent < 0 || InpEMAOpacityPercent > 100)
      return ConfigurationError("InpEMAOpacityPercent", IntegerToString(InpEMAOpacityPercent), "0..100");
   if(InpCCBSNMagic == 0)
      return ConfigurationError("InpCCBSNMagic", IntegerToString((long)InpCCBSNMagic), "non-zero");
   if(InpControllerMagic == 0)
      return ConfigurationError("InpControllerMagic", IntegerToString((long)InpControllerMagic), "non-zero");
   if(InpControllerMagic == InpCCBSNMagic)
      return ConfigurationError("InpControllerMagic", IntegerToString((long)InpControllerMagic),
                                "different from InpCCBSNMagic");
   if(InpCommandPrice <= 0.0)
      return ConfigurationError("InpCommandPrice", DoubleToString(InpCommandPrice, 4), "> 0");
   if(InpCommandVolume < 0.0)
      return ConfigurationError("InpCommandVolume", DoubleToString(InpCommandVolume, 4), ">= 0");
   if(InpCommandTimeoutSeconds < 5)
      return ConfigurationError("InpCommandTimeoutSeconds", IntegerToString(InpCommandTimeoutSeconds), ">= 5");
   if(InpControllerLockStaleSeconds < 5)
      return ConfigurationError("InpControllerLockStaleSeconds",
                                IntegerToString(InpControllerLockStaleSeconds), ">= 5");
   g_configurationError = "NONE";
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
   // Some events contain both a text marker and a vertical line.
   PushBoundedObject(g_eventObjectNames, name, InpMaxEventMarkers * 2);
  }

void TrackClosedZoneObject(const string name)
  {
   // Each Trading Zone now owns exactly one lightweight filled rectangle.
   PushBoundedObject(g_closedZoneObjectNames, name,
                     InpMaxStoredTradingZones);
  }

void TrackClosedRiskLockObject(const string name)
  {
   PushBoundedObject(g_closedRiskLockObjectNames, name,
                     InpMaxStoredRiskLocks);
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
                           const bool filled,
                           const int opacityPercent = -1)
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
   int appliedOpacity = opacityPercent < 0 ? InpZoneOpacityPercent : opacityPercent;
   long objectColor = ColorWithOpacity(baseColor, appliedOpacity);
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

bool ShouldRenderEvent(const bool categoryEnabled)
  {
   // Show All is a shortcut, not a second gate. A category switch must be
   // sufficient by itself; otherwise every individual Show input appears broken.
   return InpShowAllChartEvents || categoryEnabled;
  }

bool ShouldRenderTradingZone(const bool historical)
  {
   return !historical ||
          (InpDrawTradingZoneHistory &&
           g_historicalShift > 0 &&
           g_historicalShift <= InpTradingZoneHistoryBars);
  }

bool ShouldRenderRiskLock(const bool historical)
  {
   return !historical ||
          (InpDrawRiskLockHistory &&
           g_historicalShift > 0 &&
           g_historicalShift <= InpRiskLockHistoryBars);
  }

bool ShouldRenderHistoricalEvent(const bool historical,
                                 const bool categoryEnabled)
  {
   if(!ShouldRenderEvent(categoryEnabled))
      return false;
   return !historical ||
          (InpDrawEventHistory &&
           g_historicalShift > 0 &&
           g_historicalShift <= InpEventHistoryBars);
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
   if(!InpShowDashboard)
      return;
   string background = g_objectPrefix + "PANEL.BG";
   if(ObjectFind(0, background) < 0)
      ObjectCreate(0, background, OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(0, background, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, background, OBJPROP_XDISTANCE, 10);
   ObjectSetInteger(0, background, OBJPROP_YDISTANCE, 15);
   ObjectSetInteger(0, background, OBJPROP_XSIZE, 650);
   ObjectSetInteger(0, background, OBJPROP_YSIZE, 460);
   ObjectSetInteger(0, background, OBJPROP_BGCOLOR,
                    (long)InpDashboardBackgroundColor);
   ObjectSetInteger(0, background, OBJPROP_BORDER_COLOR, InpPanelBorderColor);
   ObjectSetInteger(0, background, OBJPROP_BACK, false);
   ObjectSetInteger(0, background, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, background, OBJPROP_HIDDEN, false);
  }

void UpdatePanel()
  {
   if(!InpShowDashboard)
      return;
   CreatePanel();
   color stateColor = InpDashboardTextColor;
   if(g_state == VISUAL_STATE_ACTIVE) stateColor = PolicyFamilyColor(g_activeZoneBranch);
   if(g_state == VISUAL_STATE_ARMING) stateColor = C'160,110,0';
   if(g_state == VISUAL_STATE_RISK_LOCK) stateColor = C'215,90,35';
   if(g_state == VISUAL_STATE_DATA_ERROR) stateColor = C'190,50,60';
   ENUM_POLICY_FAMILY panelPolicy = g_activePolicy;
   if(panelPolicy == POLICY_FAMILY_NONE)
      panelPolicy = g_armingPolicy;
   if(panelPolicy == POLICY_FAMILY_NONE)
      panelPolicy = g_riskPolicy;
   int panelConfirmBars = ConfirmBarsForPolicy(panelPolicy);

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
                                     panelConfirmBars),
                       stateColor);
   SetPanelColumnLabel("ZONE", true, 62,
                       StringFormat("%s: %s | %s: %s",
                                     InpTextZone, PolicyFamilyToString(panelPolicy),
                                    InpTextChecklist,
                                    g_lastChecklistPass ? "PASS" : "FAIL"),
                       g_lastChecklistPass ? C'0,120,80' : C'190,50,60');
   SetPanelColumnLabel("ATR", false, 82,
                       StringFormat("Close: %s | ATR%d: %s",
                                    FormatPrice(g_lastClose), InpATRPeriod,
                                    FormatPrice(g_lastATR)),
                       InpDashboardTextColor);
   SetPanelColumnLabel("ATR_MIN", true, 82,
                        StringFormat("ATR Min: Up=%s Down=%s",
                                     FormatPrice(InpMinATRPrice),
                                     FormatPrice(InpDownsideMinATRPrice)),
                       InpDashboardTextColor);
   SetPanelColumnLabel("EMA", false, 102,
                       StringFormat("EMA%d: %s | D: %s",
                                    InpEMAPeriod, FormatPrice(g_lastEMA),
                                    FormatPrice(g_lastDistance)),
                       InpDashboardTextColor);
   SetPanelColumnLabel("GATE", true, 102,
                        StringFormat("Gate: Up[0,+%s] | Down D<0",
                                     FormatPrice(InpUpsideMaxAboveEMAPrice)),
                       InpDashboardTextColor);
   SetWrappedPanelLabel("REASON", 122,
                        InpTextReason + ": " + g_lastReason,
                        InpDashboardTextColor);
   SetPanelColumnLabel("BEAR_LEGACY", false, 162,
                       StringFormat("Legacy: DPeak=%s Drop=%s",
                                    FormatPrice(g_lastPeakDistance),
                                    FormatPrice(g_lastRelativeDrop)),
                       g_lastLegacyBearDrop ? C'215,90,35' : InpDashboardTextColor);
   SetPanelColumnLabel("BEAR_LEGACY_FILTER", true, 162,
                       StringFormat("Red=%d/%d | Dfall=%s",
                                    g_lastBearishBarCount, InpBearishWindow,
                                    g_lastDistanceFalling ? "YES" : "NO"),
                       g_lastLegacyBearDrop ? C'215,90,35' : InpDashboardTextColor);
   SetPanelColumnLabel("BEAR_2BAR", false, 182,
                       StringFormat("2-Bar: H1=%s L0=%s",
                                    FormatPrice(g_lastPreviousHigh),
                                    FormatPrice(g_lastCurrentLow)),
                       g_lastTwoBarBearDrop ? C'215,90,35' : InpDashboardTextColor);
   SetPanelColumnLabel("BEAR_2BAR_DROP", true, 182,
                       StringFormat("Drop=%s / Min=%s",
                                    FormatPrice(g_lastTwoBarDrop),
                                    FormatPrice(InpMinTwoBarDropPrice)),
                       g_lastTwoBarBearDrop ? C'215,90,35' : InpDashboardTextColor);
   SetPanelColumnLabel("PROTECTION", false, 202,
                       "Bear Drop: " + g_lastBearDropSource,
                       g_lastBearDropVeto ? C'215,90,35' : InpDashboardTextColor);
   SetPanelColumnLabel("RED_LOCK", true, 202,
                        StringFormat("RED=%d/%d B2=%d/2 ATR=%d/%d | Lock=%d",
                                     g_lastConsecutiveRedCount,
                                     InpConsecutiveRedBars,
                                     g_lastBearTwoCount,
                                     g_lastActiveLowATRCount,
                                     InpActiveLowATRBars,
                                     g_riskLockRemaining),
                        (g_lastConsecutiveRedBlock || g_lastBearTwoBlock ||
                         g_lastActiveLowATRBlock) ? C'190,50,60' :
                       (g_state == VISUAL_STATE_RISK_LOCK ? C'215,90,35' :
                        InpDashboardTextColor));
   SetPanelColumnLabel("SESSION", false, 222,
                       "Decision: " + SessionToString(g_lastDecisionSession),
                       g_lastDecisionSession == POLICY_SESSION_OUTSIDE
                       ? C'190,50,60' : C'0,120,80');
   SetPanelColumnLabel("ACTIVE_SESSION", true, 222,
                       "Active: " + SessionToString(g_activeSession) +
                       StringFormat(" | Shift=%d min", InpSessionTimeShiftMinutes),
                       InpDashboardTextColor);
   ENUM_CCBSN_COMMAND desired = DesiredCommand();
   color ownerColor = InpDashboardTextColor;
   if(InpControlMode == CCBSN_CONTROL_MANUAL_HANDOVER)
      ownerColor = g_manualHandoverComplete ? C'0,120,80' : C'180,110,0';
   SetPanelColumnLabel("OWNER", false, 242,
                       InpTextOwner + ": " + ControlOwnerToString(),
                       ownerColor);
   SetPanelColumnLabel("LOCK", true, 242,
                       "Lock: " + (g_controllerLockHeld ? "HELD" : "NONE"),
                       ownerColor);
   SetPanelColumnLabel("CCBSN_MAGIC", false, 262,
                       StringFormat("CCBSN Magic: %I64u", InpCCBSNMagic),
                       InpDashboardTextColor);
   SetPanelColumnLabel("CONTROLLER_MAGIC", true, 262,
                       StringFormat("Controller Magic: %I64u", InpControllerMagic),
                       InpDashboardTextColor);
   SetWrappedPanelLabel("CONTROL", 282,
                        InpTextControl + ": " + ControlStateToString(g_controlState),
                        g_controlState == CCBSN_CONTROL_ERROR ? C'190,50,60' :
                        InpDashboardTextColor);
   SetWrappedPanelLabel("DESIRED", 322,
                        InpTextDesired + ": " + CommandToString(desired),
                        InpDashboardTextColor);
   color syncColor = InpDashboardTextColor;
   if(g_driftDetectedCurrentChain)
      syncColor = C'190,50,60';
   else if(g_offFlatGuardArmed && !g_offReassertRequested)
      syncColor = C'0,120,80';
   else if(g_offReassertRequested)
      syncColor = C'180,110,0';
   SetPanelColumnLabel("POSITIONS", false, 362,
                       StringFormat("CCBSN Pos: %d | Lots: %.2f",
                                    g_ccbsnPositionCount,
                                    g_ccbsnPositionVolume),
                       g_ccbsnPositionCount > 0 ? C'180,110,0' :
                       InpDashboardTextColor);
   SetPanelColumnLabel("SYNC", true, 362,
                       "Sync: " + g_syncState,
                       syncColor);
   SetPanelColumnLabel("TICKET", false, 382,
                       StringFormat("%s: #%I64u", InpTextCommand, g_commandTicket),
                       InpDashboardTextColor);
   SetPanelColumnLabel("TIME", true, 382,
                       InpTextDecision + ": " +
                                    (g_lastDecisionTime > 0
                                       ? TimeToString(g_lastDecisionTime,
                                                      TIME_DATE | TIME_MINUTES)
                                       : "waiting"),
                       InpDashboardTextColor);
   SetWrappedPanelLabel("CONTROL_ERROR", 402,
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
       PrintFormat("CCBSN_V3 | %s | %s | state=%s session=%s | close=%s atr=%s ema=%s d=%s | bear=%s source=%s red=%d/%d pattern=%s body=%s/%s deny=%s sweep=%s overlap=%.1f%% fall=%s range=%s/%s reverse=%s body=%s/%s lock=%d recover=%s scob=%s | %s",
                   TimeToString(eventTime, TIME_DATE | TIME_MINUTES), eventType,
                   StateToString(g_state), SessionToString(g_lastDecisionSession),
                   FormatPrice(g_lastClose),
                   FormatPrice(g_lastATR), FormatPrice(g_lastEMA),
                   FormatPrice(g_lastDistance),
                    g_lastBearDropVeto ? "VETO" : "OK", g_lastBearDropSource,
                    g_lastConsecutiveRedCount, InpConsecutiveRedBars,
                    g_lastBearishPatternSource,
                    FormatPrice(g_lastCurrentBody),
                    FormatPrice(g_lastPreviousBody),
                    g_lastDenyBlock ? "BLOCK" :
                    (g_lastUpthrustSweep ? "SWEEP_ONLY" : "NONE"),
                    FormatPrice(g_lastDenySweepSize),
                    g_lastDenyBodyOverlapPercent,
                    g_lastFallBlock ? "BLOCK" : "NONE",
                    FormatPrice(g_lastFallRange),
                    FormatPrice(g_lastFallPriorRange),
                    g_lastReverseBlock ? "BLOCK" :
                    (g_lastReversePinBar ? "PIN_ONLY" : "NONE"),
                    FormatPrice(g_lastReverseRedBody),
                    FormatPrice(g_lastReversePinBody),
                    g_riskLockRemaining, g_lastRecoverySource,
                   g_lastBullishSCOB ? "true" : "false", reason);

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
                 "ema_period", "distance", "upside_max_above_ema", "downside_boundary",
                 "decision_session", "active_session", "policy_counter_snapshot",
                 "bear_drop", "bear_drop_source", "legacy_bear_drop",
                 "two_bar_bear_drop", "peak_d", "relative_drop",
                 "previous_high", "current_low", "two_bar_drop",
                 "bearish_count", "distance_falling", "consecutive_red_count",
                 "consecutive_red_block", "bearish_pattern",
                 "bearish_engulfing", "bearish_pin_bar",
                 "deny_block", "upthrust_sweep", "deny_prior_high",
                 "deny_sweep_size", "deny_upper_wick_body",
                  "deny_body", "upthrust_body", "deny_body_overlap_percent",
                  "reverse_snapshot", "fall_snapshot",
                  "risk_lock_remaining",
                 "recovery_count", "recovery_candidate", "recovery_source",
                 "policy_recovery_candidate", "bullish_scob",
                 "ccbsn_magic", "controller_magic", "control_mode",
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
              FormatPrice(InpUpsideMaxAboveEMAPrice),
              FormatPrice(InpDownsideBandBoundary),
              SessionToString(g_lastDecisionSession),
              SessionToString(g_activeSession),
              StringFormat("arm=%s|active=%s|risk=%s|pass=%d|bearTwo=%d:%s|lowATR=%d:%s|dEMA=%s",
                           PolicyFamilyToString(g_armingPolicy),
                           PolicyFamilyToString(g_activePolicy),
                           PolicyFamilyToString(g_riskPolicy),
                           g_consecutivePassCount, g_lastBearTwoCount,
                           g_lastBearTwoBlock ? "true" : "false",
                           g_lastActiveLowATRCount,
                           g_lastActiveLowATRBlock ? "true" : "false",
                           g_lastDownsideEMAApproachBlock ? "true" : "false"),
              g_lastBearDropVeto ? "true" : "false", g_lastBearDropSource,
              g_lastLegacyBearDrop ? "true" : "false",
              g_lastTwoBarBearDrop ? "true" : "false",
              FormatPrice(g_lastPeakDistance), FormatPrice(g_lastRelativeDrop),
              FormatPrice(g_lastPreviousHigh), FormatPrice(g_lastCurrentLow),
              FormatPrice(g_lastTwoBarDrop), g_lastBearishBarCount,
              g_lastDistanceFalling ? "true" : "false",
              g_lastConsecutiveRedCount,
              g_lastConsecutiveRedBlock ? "true" : "false",
              g_lastBearishPatternSource,
               g_lastBearishEngulfing ? "true" : "false",
               g_lastBearishPinBar ? "true" : "false",
               g_lastDenyBlock ? "true" : "false",
               g_lastUpthrustSweep ? "true" : "false",
               FormatPrice(g_lastDenyPriorHigh),
               FormatPrice(g_lastDenySweepSize),
               DoubleToString(g_lastDenyUpperWickBody, 2),
               FormatPrice(g_lastDenyBody),
                FormatPrice(g_lastUpthrustBody),
                DoubleToString(g_lastDenyBodyOverlapPercent, 2),
                StringFormat("block=%s|pin=%s|pinBody=%s|redBody=%s|upper=%.2f|lower=%.2f",
                             g_lastReverseBlock ? "true" : "false",
                             g_lastReversePinBar ? "true" : "false",
                             FormatPrice(g_lastReversePinBody),
                             FormatPrice(g_lastReverseRedBody),
                             g_lastReverseUpperWickBody,
                             g_lastReverseLowerWickBody),
                StringFormat("block=%s|body=%s|range=%s|priorRange=%s|priorHigh=%s|priorLow=%s|openInside=%s|closeBreak=%s",
                             g_lastFallBlock ? "true" : "false",
                             FormatPrice(g_lastFallBody),
                             FormatPrice(g_lastFallRange),
                             FormatPrice(g_lastFallPriorRange),
                             FormatPrice(g_lastFallPriorHigh),
                             FormatPrice(g_lastFallPriorLow),
                             g_lastFallOpenInside ? "true" : "false",
                             g_lastFallCloseBreak ? "true" : "false"),
                g_riskLockRemaining, g_consecutiveRecoveryBars,
              g_lastRecoveryCandidate ? "true" : "false",
              g_lastRecoverySource,
              g_lastPolicyRecoveryCandidate ? "true" : "false",
              g_lastBullishSCOB ? "true" : "false",
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
   if(ShouldRenderEvent(InpShowDriftEvents))
      CreateEventMarker("NC_DRIFT_DETECTED", now, markerPrice,
                        InpEventNameNCDrift,
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
bool PolicyDataReady(const double closePrice,
                     const double atrValue,
                     const double emaValue)
  {
   if(!MathIsValidNumber(closePrice) || !MathIsValidNumber(atrValue) ||
      !MathIsValidNumber(emaValue) || closePrice == EMPTY_VALUE ||
      atrValue == EMPTY_VALUE || emaValue == EMPTY_VALUE ||
      closePrice <= 0.0 || atrValue <= 0.0)
      return false;
   return true;
  }

int ConfirmBarsForPolicy(const ENUM_POLICY_FAMILY policy)
  {
   if(policy == POLICY_FAMILY_DOWNSIDE)
      return InpDownsideConfirmBars;
   return InpUpsideConfirmBars;
  }

int RiskLockBarsForPolicy(const ENUM_POLICY_FAMILY policy)
  {
   if(policy == POLICY_FAMILY_DOWNSIDE)
      return InpDownsideRiskLockBars;
   return InpUpsideRiskLockBars;
  }

bool EvaluatePolicyEntry(const double closePrice,
                         const double atrValue,
                         const double emaValue,
                         const ENUM_POLICY_FAMILY policy,
                         string &reason)
  {
   if(!PolicyDataReady(closePrice, atrValue, emaValue))
     {
      reason = "M15_DATA_NOT_READY";
      return false;
     }

   double distance = closePrice - emaValue;
   if(policy == POLICY_FAMILY_UPSIDE)
     {
      if(!InpEnableUpsidePolicy)
        {
         reason = "UPSIDE_POLICY_DISABLED";
         return false;
        }
      if(atrValue < InpMinATRPrice)
        {
         reason = "M15_UPSIDE_ATR_BELOW_MIN";
         return false;
        }
      if(distance >= 0.0 && distance <= InpUpsideMaxAboveEMAPrice)
        {
         reason = "M15_UPSIDE_ENTRY_PASS";
         return true;
        }
      reason = distance < 0.0 ? "M15_UPSIDE_BELOW_EMA" :
               "M15_UPSIDE_ABOVE_MAX";
      return false;
     }

   if(policy == POLICY_FAMILY_DOWNSIDE)
     {
      if(!InpEnableDownsidePolicy)
        {
         reason = "DOWNSIDE_POLICY_DISABLED";
         return false;
        }
      if(atrValue < InpMinATRPrice || atrValue < InpDownsideMinATRPrice)
        {
         reason = "M15_DOWNSIDE_ATR_BELOW_MIN";
         return false;
        }
      bool nearEntry = InpEnableDownsideNearEntry && distance < 0.0 &&
                       distance > -InpDownsideBandBoundary;
      bool deepEntry = InpEnableDownsideDeepEntry &&
                       distance <= -InpDownsideBandBoundary;
      if(!nearEntry && !deepEntry)
        {
         reason = "M15_DOWNSIDE_DISTANCE_ENTRY_FAIL";
         return false;
        }
      bool distanceRising = ArraySize(g_distanceHistory) >= 1 &&
                            distance > g_distanceHistory[0];
      if(InpDownsideRequireDRising && !distanceRising)
        {
         reason = "M15_DOWNSIDE_D_NOT_RISING";
         return false;
        }
      bool emaNonDown = ArraySize(g_emaHistory) >= InpDownsideEMASlopeBars &&
                        emaValue >=
                        g_emaHistory[InpDownsideEMASlopeBars - 1];
      if(InpDownsideRequireEMANonDown && !emaNonDown)
        {
         reason = "M15_DOWNSIDE_EMA_DOWN";
         return false;
        }
      reason = nearEntry ? "M15_DOWNSIDE_NEAR_ENTRY_PASS" :
                           "M15_DOWNSIDE_DEEP_ENTRY_PASS";
      return true;
     }

   reason = "M15_POLICY_NONE";
   return false;
  }

bool EvaluatePolicyHold(const double closePrice,
                        const double atrValue,
                        const double emaValue,
                        const ENUM_POLICY_FAMILY policy,
                        string &reason)
  {
   if(!PolicyDataReady(closePrice, atrValue, emaValue))
     {
      reason = "M15_DATA_NOT_READY";
      return false;
     }
   double distance = closePrice - emaValue;
   if(policy == POLICY_FAMILY_UPSIDE)
     {
      bool pass = InpEnableUpsidePolicy && atrValue >= InpMinATRPrice &&
                  distance >= 0.0 &&
                  distance <= InpUpsideMaxAboveEMAPrice;
      reason = pass ? "UPSIDE_ACTIVE_HOLD" : "UPSIDE_GATE_FAILED";
      return pass;
     }
   if(policy == POLICY_FAMILY_DOWNSIDE)
     {
      bool pass = InpEnableDownsidePolicy &&
                  distance <= InpDownsideHoldMaxAboveEMA;
      reason = pass ? "DOWNSIDE_ACTIVE_HOLD" :
                      "DOWNSIDE_HOLD_GATE_FAILED";
      return pass;
     }
   reason = "ACTIVE_POLICY_NONE";
   return false;
  }

string FeatureTooltip(const datetime decisionTime, const string eventType, const string reason)
  {
   return StringFormat("%s\n%s | %s\nClose=%s EMA%d=%s D=%s\nATR%d=%s MinATR=%s DownMinATR=%s"
                       "\nBearDrop=%s Source=%s Legacy=%s 2-Bar=%s"
                       "\nPeakD=%s RelativeDrop=%s | PrevHigh=%s CurrentLow=%s TwoBarDrop=%s"
                       "\nConsecutiveRED=%d/%d | BearishPattern=%s"
                       "\nBody=%s PrevBody=%s MinMultiplier=%.2f"
                        "\nDeny=%s Sweep=%s PriorHigh=%s SweepSize=%s"
                        "\nDenyBody=%s UpthrustBody=%s Wick/Body=%.2f Overlap=%.1f%%"
                        "\nReverse=%s PinBody=%s RedBody=%s Upper/Body=%.2f Lower/Body=%.2f"
                        "\nFall=%s Range=%s Prior3Range=%s PriorHigh=%s PriorLow=%s OpenInside=%s CloseBreak=%s"
                        "\nLock=%d Recovery=%d/%d"
                        "\nRecoverySource=%s PolicyCandidate=%s BullishSCOB=%s"
                        "\nPolicy Arm=%s Active=%s Risk=%s"
                        "\nBearTwo=%d/2 LowATR=%d/%d dEMA=%s\n%s",
                       eventType,
                       TimeToString(decisionTime, TIME_DATE | TIME_MINUTES),
                       SessionToString(g_lastDecisionSession),
                       FormatPrice(g_lastClose), InpEMAPeriod,
                       FormatPrice(g_lastEMA), FormatPrice(g_lastDistance),
                        InpATRPeriod, FormatPrice(g_lastATR),
                        FormatPrice(InpMinATRPrice),
                        FormatPrice(InpDownsideMinATRPrice),
                       g_lastBearDropVeto ? "VETO" : "OK",
                       g_lastBearDropSource,
                       g_lastLegacyBearDrop ? "YES" : "NO",
                       g_lastTwoBarBearDrop ? "YES" : "NO",
                       FormatPrice(g_lastPeakDistance),
                       FormatPrice(g_lastRelativeDrop),
                       FormatPrice(g_lastPreviousHigh),
                       FormatPrice(g_lastCurrentLow),
                        FormatPrice(g_lastTwoBarDrop),
                        g_activeConsecutiveRedCount, InpConsecutiveRedBars,
                        g_lastBearishPatternSource,
                        FormatPrice(g_lastCurrentBody),
                        FormatPrice(g_lastPreviousBody),
                        InpBearishBodyMultiplier,
                        g_lastDenyBlock ? "BLOCK" : "NO",
                        g_lastUpthrustSweep ? "YES" : "NO",
                        FormatPrice(g_lastDenyPriorHigh),
                        FormatPrice(g_lastDenySweepSize),
                        FormatPrice(g_lastDenyBody),
                        FormatPrice(g_lastUpthrustBody),
                         g_lastDenyUpperWickBody,
                         g_lastDenyBodyOverlapPercent,
                         g_lastReverseBlock ? "BLOCK" :
                         (g_lastReversePinBar ? "PIN_ONLY" : "NO"),
                         FormatPrice(g_lastReversePinBody),
                         FormatPrice(g_lastReverseRedBody),
                         g_lastReverseUpperWickBody,
                         g_lastReverseLowerWickBody,
                         g_lastFallBlock ? "BLOCK" : "NO",
                         FormatPrice(g_lastFallRange),
                         FormatPrice(g_lastFallPriorRange),
                         FormatPrice(g_lastFallPriorHigh),
                         FormatPrice(g_lastFallPriorLow),
                         g_lastFallOpenInside ? "YES" : "NO",
                         g_lastFallCloseBreak ? "YES" : "NO",
                         g_riskLockRemaining, g_consecutiveRecoveryBars,
                        InpRecoveryBars, g_lastRecoverySource,
                        g_lastPolicyRecoveryCandidate ? "YES" : "NO",
                        g_lastBullishSCOB ? "YES" : "NO",
                        PolicyFamilyToString(g_armingPolicy),
                        PolicyFamilyToString(g_activePolicy),
                        PolicyFamilyToString(g_riskPolicy),
                        g_lastBearTwoCount, g_lastActiveLowATRCount,
                        InpActiveLowATRBars,
                        g_lastDownsideEMAApproachBlock ? "YES" : "NO", reason);
  }

void UpdateRiskLockObjects(const datetime endTime)
  {
   if(!InpDrawRiskLockShade || g_riskLockStart <= 0 || g_riskLockBaseName == "")
      return;
   double padding = MathMax(g_riskLockATR * InpZonePaddingATR,
                            SymbolInfoDouble(_Symbol, SYMBOL_POINT) * 10.0);
   string fillName = g_riskLockBaseName + ".FILL";
   string tooltip = StringFormat("BEAR DROP RISK LOCK\nPolicy=%s\nStart=%s\nHigh=%s Low=%s\nSource=%s",
                                  PolicyFamilyToString(g_riskPolicy),
                                  TimeToString(g_riskLockStart,
                                              TIME_DATE | TIME_MINUTES),
                                 FormatPrice(g_riskLockHigh),
                                 FormatPrice(g_riskLockLow),
                                 g_lastBearDropSource);
   datetime renderStart = g_riskLockStart;
   if(g_riskLockHistoryCutoff > 0 && renderStart < g_riskLockHistoryCutoff)
      renderStart = g_riskLockHistoryCutoff;
   CreateOrMoveRectangle(fillName, renderStart,
                         g_riskLockHigh + padding, endTime,
                         g_riskLockLow - padding, InpRiskLockColor, true,
                         InpRiskLockOpacityPercent);
   SetObjectTooltip(fillName, tooltip);
  }

void StartOrRefreshRiskLock(const MqlRates &bar,
                            const double atrValue,
                            const datetime decisionTime,
                            const ENUM_POLICY_FAMILY policy,
                            const string reason,
                            const bool historical,
                            const bool createEvent,
                            const bool blockedActiveZone)
  {
   if(g_riskLockStart <= 0)
     {
      g_riskLockStart = decisionTime;
      g_riskLockHigh = bar.high;
      g_riskLockLow = bar.low;
      g_riskLockBaseName = g_objectPrefix + "RISK." + TimeKey(decisionTime);
     }
   else
     {
      g_riskLockHigh = MathMax(g_riskLockHigh, bar.high);
      g_riskLockLow = MathMin(g_riskLockLow, bar.low);
     }
   g_riskLockATR = atrValue;
   g_state = VISUAL_STATE_RISK_LOCK;
   g_riskPolicy = policy;
   g_riskLockRemaining = RiskLockBarsForPolicy(policy);
   g_consecutiveRecoveryBars = 0;
   g_consecutivePassCount = 0;
   g_armingPolicy = POLICY_FAMILY_NONE;
   g_activePolicy = POLICY_FAMILY_NONE;
   g_armingSession = POLICY_SESSION_OUTSIDE;
   g_activeSession = POLICY_SESSION_OUTSIDE;
   g_activeConsecutiveRedCount = 0;
   g_activeBearTwoCount = 0;
   g_activeLowATRCount = 0;
   if(ShouldRenderRiskLock(historical))
      UpdateRiskLockObjects(decisionTime + PeriodSeconds(DECISION_TIMEFRAME));
   if(createEvent &&
      ShouldRenderHistoricalEvent(historical, InpShowBearDropEvents))
     {
      string eventText = InpEventNameBearDrop + "\n" +
                         (blockedActiveZone ? InpEventNamePolicyBlock :
                          InpEventNameRiskLock);
      CreateEventMarker("BEAR_DROP", decisionTime,
                        bar.high + atrValue * 0.35, eventText,
                        FeatureTooltip(decisionTime, eventText, reason));
     }
   if(createEvent)
      AuditEvent("BEAR_DROP_RISK_LOCK", decisionTime, reason, historical);
  }

void EndRiskLockVisual(const datetime endTime,
                       const bool historical)
  {
   if(g_riskLockStart <= 0)
      return;
   if(ShouldRenderRiskLock(historical))
     {
      UpdateRiskLockObjects(endTime);
      TrackClosedRiskLockObject(g_riskLockBaseName + ".FILL");
     }
   g_riskLockStart = 0;
   g_riskLockHigh = 0.0;
   g_riskLockLow = 0.0;
   g_riskLockATR = 0.0;
   g_riskLockBaseName = "";
   g_riskPolicy = POLICY_FAMILY_NONE;
  }

void UpdateActiveZoneObjects(const datetime endTime)
  {
   if(g_activeZoneStart <= 0 || g_activeZoneBaseName == "")
      return;

   double padding = MathMax(g_activeZoneATR * InpZonePaddingATR,
                            SymbolInfoDouble(_Symbol, SYMBOL_POINT) * 10.0);
   double top = g_activeZoneHigh + padding;
   double bottom = g_activeZoneLow - padding;
   color zoneColor = PolicyFamilyColor(g_activeZoneBranch);
   string fillName = g_activeZoneBaseName + ".FILL";
   string tooltip = StringFormat("SIMULATED TRADING ZONE\n%s\nStart=%s\nHigh=%s Low=%s",
                                  PolicyFamilyToString(g_activeZoneBranch),
                                 TimeToString(g_activeZoneStart, TIME_DATE | TIME_MINUTES),
                                 FormatPrice(g_activeZoneHigh),
                                 FormatPrice(g_activeZoneLow));

   datetime renderStart = g_activeZoneStart;
   if(g_tradingZoneHistoryCutoff > 0 && renderStart < g_tradingZoneHistoryCutoff)
       renderStart = g_tradingZoneHistoryCutoff;
   CreateOrMoveRectangle(fillName, renderStart, top, endTime, bottom, zoneColor, true);
   SetObjectTooltip(fillName, tooltip);
  }

void StartActiveZone(const datetime startTime,
                     const double startPrice,
                     const double atrValue,
                     const ENUM_POLICY_FAMILY policy,
                     const string reason,
                     const bool historical)
  {
   g_state = VISUAL_STATE_ACTIVE;
   g_consecutivePassCount = 0;
   g_armingPolicy = POLICY_FAMILY_NONE;
   g_riskPolicy = POLICY_FAMILY_NONE;
   g_armingSession = POLICY_SESSION_OUTSIDE;
   g_activeSession = g_lastDecisionSession;
   g_activeConsecutiveRedCount = 0;
   g_activeBearTwoCount = 0;
   g_activeLowATRCount = 0;
   g_activeZoneStart = startTime;
   g_activeZoneHigh = startPrice;
   g_activeZoneLow = startPrice;
   g_activeZoneATR = atrValue;
   g_activePolicy = policy;
   g_activeZoneBranch = policy;
   g_activeZoneBaseName = g_objectPrefix + "ZONE." + TimeKey(startTime);

   string allowText = InpEventNamePolicyAllow + "\n" +
                      PolicyFamilyToString(policy);
   string tooltip = FeatureTooltip(startTime, "TRADING " +
                                   allowText, reason);
   if(ShouldRenderTradingZone(historical))
      UpdateActiveZoneObjects(startTime + PeriodSeconds(DECISION_TIMEFRAME));
   if(ShouldRenderHistoricalEvent(historical,
                                  InpShowPolicyAllowEvents))
     {
      color zoneColor = PolicyFamilyColor(policy);
      string startLine = g_activeZoneBaseName + ".START";
      CreateVerticalLine(startLine, startTime, zoneColor, STYLE_DASH, tooltip);
      TrackEventObject(startLine);
      CreateEventMarker("ON", startTime, startPrice - atrValue * 0.35,
                        allowText, tooltip);
     }
   AuditEvent("TRADING_ZONE_STARTED", startTime, reason, historical);
  }

void EndActiveZone(const datetime endTime,
                   const double endPrice,
                   const string reason,
                   const bool historical,
                   const string markerText,
                   const string eventType,
                   const bool showChartEvent)
  {
   if(g_activeZoneStart <= 0)
      return;

   string fillName = g_activeZoneBaseName + ".FILL";
   string endLine = g_activeZoneBaseName + ".END";
   string tooltip = FeatureTooltip(endTime, "TRADING " +
                                   InpEventNamePolicyBlock, reason);
   if(ShouldRenderTradingZone(historical))
      {
       UpdateActiveZoneObjects(endTime);
       TrackClosedZoneObject(fillName);
      }
   if(ShouldRenderHistoricalEvent(historical, showChartEvent))
     {
      CreateVerticalLine(endLine, endTime, InpOffEventColor, STYLE_DASH, tooltip);
      TrackEventObject(endLine);
      string renderedText = markerText == "" ?
                            InpEventNamePolicyBlock : markerText;
      CreateEventMarker(eventType, endTime,
                        endPrice + g_activeZoneATR * 0.35,
                        renderedText, tooltip);
     }
   AuditEvent("TRADING_ZONE_ENDED", endTime, reason, historical);

   g_state = VISUAL_STATE_OFF;
   g_consecutivePassCount = 0;
   g_armingPolicy = POLICY_FAMILY_NONE;
   g_riskPolicy = POLICY_FAMILY_NONE;
   g_armingSession = POLICY_SESSION_OUTSIDE;
   g_activeSession = POLICY_SESSION_OUTSIDE;
   g_activeConsecutiveRedCount = 0;
   g_activeBearTwoCount = 0;
   g_activeLowATRCount = 0;
   g_activeZoneStart = 0;
   g_activeZoneHigh = 0.0;
   g_activeZoneLow = 0.0;
   g_activeZoneATR = 0.0;
   g_activePolicy = POLICY_FAMILY_NONE;
   g_activeZoneBranch = POLICY_FAMILY_NONE;
   g_activeZoneBaseName = "";
  }

// Fall is a candle classification as well as a Soft OFF branch. When a
// higher-priority protection owns the state transition, preserve the Fall
// classification on the same candle instead of hiding it behind that branch.
void RecordOverlappingFall(const MqlRates &bar,
                           const double atrValue,
                           const datetime decisionTime,
                           const string primaryEvent,
                           const string reason,
                           const bool historical)
  {
   if(!g_lastFallBlock)
      return;

   string eventText = InpEventNameFall + " + " + primaryEvent;
   if(ShouldRenderHistoricalEvent(historical, InpShowFallEvents))
      CreateEventMarker("FALL_OVERLAP_" + primaryEvent, decisionTime,
                        bar.low - atrValue * 0.35, eventText,
                        FeatureTooltip(decisionTime, eventText, reason));

   AuditEvent("FALL_OVERLAP_CLASSIFIED", decisionTime,
              reason + "|PRIMARY=" + primaryEvent, historical);
  }

void ProcessDecisionBar(const MqlRates &bar,
                        const double atrValue,
                        const double emaValue,
                        const datetime decisionTime,
                        const bool historical)
  {
   bool wasActive = g_state == VISUAL_STATE_ACTIVE;
   bool wasRiskLock = g_state == VISUAL_STATE_RISK_LOCK;
   g_lastPolicyRecoveryCandidate = false;
   g_lastBullishSCOB = false;
   g_lastRecoveryCandidate = false;
   g_lastRecoverySource = "NONE";

   if(wasActive)
     {
      g_activeZoneHigh = MathMax(g_activeZoneHigh, bar.high);
      g_activeZoneLow = MathMin(g_activeZoneLow, bar.low);
      g_activeZoneATR = atrValue;
     }
   if(wasRiskLock)
     {
      g_riskLockHigh = MathMax(g_riskLockHigh, bar.high);
      g_riskLockLow = MathMin(g_riskLockLow, bar.low);
      g_riskLockATR = atrValue;
     }

   g_lastClose = bar.close;
   g_lastATR = atrValue;
   g_lastEMA = emaValue;
   g_lastDistance = bar.close - emaValue;
   g_lastDecisionTime = decisionTime;
   g_lastDecisionSession = PolicySessionAt(decisionTime);

   string upsideReason = "";
   string downsideReason = "";
   bool upsideEntryPass = EvaluatePolicyEntry(bar.close, atrValue, emaValue,
                                               POLICY_FAMILY_UPSIDE,
                                               upsideReason);
   bool downsideEntryPass = EvaluatePolicyEntry(bar.close, atrValue, emaValue,
                                                 POLICY_FAMILY_DOWNSIDE,
                                                 downsideReason);
   ENUM_POLICY_FAMILY candidatePolicy = POLICY_FAMILY_NONE;
   string candidateReason = g_lastDistance < 0.0 ? downsideReason : upsideReason;
   if(upsideEntryPass)
     {
      candidatePolicy = POLICY_FAMILY_UPSIDE;
      candidateReason = upsideReason;
     }
   else if(downsideEntryPass)
     {
      candidatePolicy = POLICY_FAMILY_DOWNSIDE;
      candidateReason = downsideReason;
     }
   bool candidatePass = candidatePolicy != POLICY_FAMILY_NONE;
   bool dataReady = PolicyDataReady(bar.close, atrValue, emaValue);

   // Entry gates compare current D/EMA against prior samples. Push the current
   // candle only after those gates have been frozen for this decision.
   if(dataReady)
      PushFeatureSample(bar, emaValue);

   ENUM_POLICY_FAMILY decisionPolicy =
      g_lastDistance < 0.0 ? POLICY_FAMILY_DOWNSIDE :
                             POLICY_FAMILY_UPSIDE;
   if(wasActive)
      decisionPolicy = g_activePolicy;
   else if(wasRiskLock && g_riskPolicy != POLICY_FAMILY_NONE)
      decisionPolicy = g_riskPolicy;
   else if(g_armingPolicy != POLICY_FAMILY_NONE)
      decisionPolicy = g_armingPolicy;
   else if(candidatePolicy != POLICY_FAMILY_NONE)
      decisionPolicy = candidatePolicy;

   double bearDropMultiplier =
      decisionPolicy == POLICY_FAMILY_DOWNSIDE
      ? InpDownsideBearDropMultiplier : 1.0;
   bool bearDropVeto = dataReady &&
                       EvaluateBearDrop(bar, bearDropMultiplier);
   if(!dataReady)
     {
      g_lastLegacyBearDrop = false;
      g_lastTwoBarBearDrop = false;
      g_lastBearDropVeto = false;
      g_lastBearDropSource = "NONE";
     }

   ENUM_POLICY_SESSION barSession = PolicySessionAt(bar.time);
   bool activePolicyBar = wasActive && barSession == g_activeSession;
   bool currentBearish = bar.close < bar.open;

   if(activePolicyBar)
      g_activeConsecutiveRedCount = currentBearish
                                    ? g_activeConsecutiveRedCount + 1 : 0;
   else
      g_activeConsecutiveRedCount = 0;

   if(activePolicyBar)
      g_activeBearTwoCount = currentBearish &&
                             atrValue > InpBearTwoATRThreshold
                             ? g_activeBearTwoCount + 1 : 0;
   else
      g_activeBearTwoCount = 0;

   if(activePolicyBar)
      g_activeLowATRCount = atrValue < InpActiveLowATRThreshold
                            ? g_activeLowATRCount + 1 : 0;
   else
      g_activeLowATRCount = 0;

   bool consecutiveRedBlock = InpEnableConsecutiveRedBlock &&
                              activePolicyBar &&
                              g_activeConsecutiveRedCount >=
                              InpConsecutiveRedBars;
   bool bearTwoBlock = InpEnableBearTwoBlock && activePolicyBar &&
                       g_activeBearTwoCount >= 2;
   bool activeLowATRBlock = InpEnableActiveLowATRBlock &&
                            activePolicyBar &&
                            g_activeLowATRCount >= InpActiveLowATRBars;
   bool downsideEMAApproachBlock =
      InpEnableDownsideEMAApproachBlock && activePolicyBar &&
      g_activePolicy == POLICY_FAMILY_DOWNSIDE && dataReady &&
      bar.high >= emaValue - InpDownsideEMAApproachTolerance &&
      bar.low <= emaValue + InpDownsideEMAApproachTolerance;

   ResetBearishPatternSnapshot();
   ResetDenySnapshot();
   ResetReverseSnapshot();
   ResetFallSnapshot();
   bool bearishPatternBlock = false;
   bool denyBlock = false;
   bool reverseBlock = false;
   bool fallBlock = false;
   if(activePolicyBar)
     {
      bearishPatternBlock = EvaluateBearishPattern();
      denyBlock = EvaluateDeny(atrValue);
      reverseBlock = EvaluateReverse();
      fallBlock = EvaluateFall();
     }

   string holdReason = "";
   bool activeHoldPass = wasActive &&
      EvaluatePolicyHold(bar.close, atrValue, emaValue,
                         g_activePolicy, holdReason);
   bool sessionExit = wasActive &&
      (g_lastDecisionSession == POLICY_SESSION_OUTSIDE ||
       g_lastDecisionSession != g_activeSession);
   bool sessionCandidatePass = candidatePass &&
      g_lastDecisionSession != POLICY_SESSION_OUTSIDE;

   string reason = candidateReason;
   if(!dataReady)
      reason = "M15_DATA_NOT_READY";
   else if(sessionExit)
      reason = "M15_NEW_CYCLE_SESSION_ENDED";
   else if(bearDropVeto)
      reason = "M15_BEAR_DROP_" + g_lastBearDropSource + "_" +
               PolicyFamilyToString(decisionPolicy);
   else if(bearTwoBlock)
      reason = "M15_BEAR_TWO_HIGH_ATR_POLICY_BLOCK_" +
               PolicyFamilyToString(g_activePolicy);
   else if(downsideEMAApproachBlock)
      reason = "M15_DOWNSIDE_EMA_APPROACH_POLICY_BLOCK";
   else if(activeLowATRBlock)
      reason = "M15_LOW_ATR_SEQUENCE_POLICY_BLOCK_" +
               PolicyFamilyToString(g_activePolicy);
   else if(denyBlock)
      reason = "M15_DENY_UPTHRUST_REJECTION_POLICY_BLOCK_" +
               PolicyFamilyToString(g_activePolicy);
   else if(fallBlock)
      reason = "M15_FALL_3_BAR_CLUSTER_DOWNSIDE_BREAK_POLICY_BLOCK_" +
               PolicyFamilyToString(g_activePolicy);
   else if(reverseBlock)
      reason = "M15_REVERSE_PIN_THEN_LARGER_BEARISH_BODY_POLICY_BLOCK_" +
               PolicyFamilyToString(g_activePolicy);
   else if(bearishPatternBlock)
      reason = "M15_BEARISH_PATTERN_" + g_lastBearishPatternSource +
               "_POLICY_BLOCK_" + PolicyFamilyToString(g_activePolicy);
   else if(consecutiveRedBlock)
      reason = "M15_CONSECUTIVE_RED_POLICY_BLOCK_" +
               PolicyFamilyToString(g_activePolicy);
   else if(wasActive)
      reason = holdReason;
   else if(g_lastDecisionSession == POLICY_SESSION_OUTSIDE)
      reason = "M15_OUTSIDE_NEW_CYCLE_SESSION";

   g_lastChecklistPass = wasActive
      ? activeHoldPass && !sessionExit && !bearDropVeto &&
        !bearTwoBlock && !downsideEMAApproachBlock &&
        !activeLowATRBlock && !denyBlock && !fallBlock &&
        !reverseBlock && !bearishPatternBlock && !consecutiveRedBlock
      : sessionCandidatePass && !bearDropVeto;
   g_lastReason = reason;
   g_lastConsecutiveRedCount = g_activeConsecutiveRedCount;
   g_lastConsecutiveRedBlock = consecutiveRedBlock;
   g_lastBearTwoCount = g_activeBearTwoCount;
   g_lastBearTwoBlock = bearTwoBlock;
   g_lastActiveLowATRCount = g_activeLowATRCount;
   g_lastActiveLowATRBlock = activeLowATRBlock;
   g_lastDownsideEMAApproachBlock = downsideEMAApproachBlock;

   bool newBearDropEpisode = bearDropVeto && !g_previousBearDropVeto;
   g_previousBearDropVeto = bearDropVeto;

   // The active session boundary always owns the first OFF transition.
   if(sessionExit)
     {
      EndActiveZone(decisionTime, bar.close, reason, historical,
                    InpEventNameSessionEnd + "\n" +
                    InpEventNamePolicyBlock,
                    "SESSION_END", InpShowSessionEndEvents);
      g_riskLockRemaining = 0;
      g_consecutiveRecoveryBars = 0;
      AuditEvent("SESSION_END_POLICY_BLOCK", decisionTime, reason, historical);
      return;
     }

   // Bear Drop is the only transition into RISK LOCK.
   if(bearDropVeto)
     {
      bool enteringRiskLock = !wasRiskLock;
      if(wasActive)
         EndActiveZone(decisionTime, bar.close, reason, historical,
                       "", "BEAR_DROP_ZONE_END", false);
      RecordOverlappingFall(bar, atrValue, decisionTime,
                            InpEventNameBearDrop, reason, historical);
      StartOrRefreshRiskLock(bar, atrValue, decisionTime, decisionPolicy,
                             reason, historical,
                             enteringRiskLock || newBearDropEpisode, wasActive);
      return;
     }

   // BearTwo: two consecutive bearish ACTIVE candles, each ATR > threshold.
   if(bearTwoBlock)
     {
      EndActiveZone(decisionTime, bar.close, reason, historical,
                    InpEventNameBearTwo + "\n" + InpEventNamePolicyBlock,
                    "BEAR_TWO", InpShowBearTwoEvents);
      g_riskLockRemaining = 0;
      g_consecutiveRecoveryBars = 0;
      AuditEvent("BEAR_TWO_POLICY_BLOCK", decisionTime, reason, historical);
      return;
     }

   // The current Downside candle range touches/intersects EMA +/- tolerance.
   if(downsideEMAApproachBlock)
     {
      EndActiveZone(decisionTime, bar.close, reason, historical,
                    InpEventNameDownsideEMA + "\n" +
                    InpEventNamePolicyBlock,
                    "DOWNSIDE_EMA", InpShowDownsideEMAEvents);
      g_riskLockRemaining = 0;
      g_consecutiveRecoveryBars = 0;
      AuditEvent("DOWNSIDE_EMA_POLICY_BLOCK", decisionTime, reason, historical);
      return;
     }

   // Three ACTIVE candles below the ATR threshold by default, either policy.
   if(activeLowATRBlock)
     {
      EndActiveZone(decisionTime, bar.close, reason, historical,
                    InpEventNameActiveLowATR + "\n" +
                    InpEventNamePolicyBlock,
                    "ACTIVE_LOW_ATR", InpShowActiveLowATREvents);
      g_riskLockRemaining = 0;
      g_consecutiveRecoveryBars = 0;
      AuditEvent("ACTIVE_LOW_ATR_POLICY_BLOCK", decisionTime, reason, historical);
      return;
     }

   if(denyBlock)
     {
      EndActiveZone(decisionTime, bar.close, reason, historical,
                    InpEventNameDeny + "\n" + InpEventNamePolicyBlock,
                    "DENY", InpShowDenyEvents);
      RecordOverlappingFall(bar, atrValue, decisionTime,
                            InpEventNameDeny, reason, historical);
      g_riskLockRemaining = 0;
      g_consecutiveRecoveryBars = 0;
      AuditEvent("DENY_POLICY_BLOCK", decisionTime, reason, historical);
      return;
     }

   if(fallBlock)
     {
      EndActiveZone(decisionTime, bar.close, reason, historical,
                    InpEventNameFall + "\n" + InpEventNamePolicyBlock,
                    "FALL", InpShowFallEvents);
      g_riskLockRemaining = 0;
      g_consecutiveRecoveryBars = 0;
      AuditEvent("FALL_POLICY_BLOCK", decisionTime, reason, historical);
      return;
     }

   if(reverseBlock)
     {
      EndActiveZone(decisionTime, bar.close, reason, historical,
                    InpEventNameReverse + "\n" + InpEventNamePolicyBlock,
                    "REVERSE", InpShowReverseEvents);
      g_riskLockRemaining = 0;
      g_consecutiveRecoveryBars = 0;
      AuditEvent("REVERSE_POLICY_BLOCK", decisionTime, reason, historical);
      return;
     }

   if(bearishPatternBlock)
     {
      string patternText = g_lastBearishEngulfing && g_lastBearishPinBar
                           ? InpEventNameBearishEngulfing + "+" +
                             InpEventNameBearishPinBar
                           : (g_lastBearishEngulfing
                              ? InpEventNameBearishEngulfing
                              : InpEventNameBearishPinBar);
      EndActiveZone(decisionTime, bar.close, reason, historical,
                    patternText + "\n" + InpEventNamePolicyBlock,
                    "BEARISH_PATTERN", InpShowBearishPatternEvents);
      g_riskLockRemaining = 0;
      g_consecutiveRecoveryBars = 0;
      AuditEvent("BEARISH_PATTERN_POLICY_BLOCK", decisionTime,
                 reason, historical);
      return;
     }

   if(consecutiveRedBlock)
     {
      EndActiveZone(decisionTime, bar.close, reason, historical,
                    InpEventNameConsecutiveRed + "\n" +
                    InpEventNamePolicyBlock,
                    "CONSECUTIVE_RED", InpShowConsecutiveRedEvents);
      g_riskLockRemaining = 0;
      g_consecutiveRecoveryBars = 0;
      AuditEvent("CONSECUTIVE_RED_POLICY_BLOCK", decisionTime,
                 reason, historical);
      return;
     }

   if(wasRiskLock)
     {
      if(g_riskLockRemaining > 0)
         g_riskLockRemaining--;

      bool distanceRising = ArraySize(g_distanceHistory) >= 2 &&
                            g_distanceHistory[0] > g_distanceHistory[1];
      bool emaNonDown = ArraySize(g_emaHistory) > InpRecoveryEMASlopeBars &&
                        g_emaHistory[0] >=
                        g_emaHistory[InpRecoveryEMASlopeBars];
      bool riskEntryPass =
         (g_riskPolicy == POLICY_FAMILY_UPSIDE && upsideEntryPass) ||
         (g_riskPolicy == POLICY_FAMILY_DOWNSIDE && downsideEntryPass);
      bool commonRecovery =
         (!InpRequireRecoveryDRising || distanceRising) &&
         (!InpRequireRecoveryEMANonDown || emaNonDown);
      bool upsideBufferPass = g_riskPolicy != POLICY_FAMILY_UPSIDE ||
                              g_lastDistance >=
                              atrValue * InpRecoveryBufferATR;
      g_lastPolicyRecoveryCandidate =
         g_lastDecisionSession != POLICY_SESSION_OUTSIDE &&
         riskEntryPass && commonRecovery && upsideBufferPass;
      g_lastBullishSCOB = EvaluateBullishSCOB();
      g_lastRecoveryCandidate =
         g_lastDecisionSession != POLICY_SESSION_OUTSIDE &&
         (g_lastPolicyRecoveryCandidate || g_lastBullishSCOB);
      if(g_lastPolicyRecoveryCandidate && g_lastBullishSCOB)
         g_lastRecoverySource = "POLICY+SCOB";
      else if(g_lastBullishSCOB)
         g_lastRecoverySource = "SCOB";
      else if(g_lastPolicyRecoveryCandidate)
         g_lastRecoverySource = "POLICY";
      else
         g_lastRecoverySource = "NONE";

      if(g_riskLockRemaining == 0)
        {
         if(g_lastRecoveryCandidate)
            g_consecutiveRecoveryBars++;
         else
            g_consecutiveRecoveryBars = 0;

         if(g_consecutiveRecoveryBars >= InpRecoveryBars)
           {
            ENUM_POLICY_FAMILY recoveredPolicy = g_riskPolicy;
            int confirmBars = ConfirmBarsForPolicy(recoveredPolicy);
            EndRiskLockVisual(decisionTime, historical);
            g_state = VISUAL_STATE_ARMING;
            g_armingPolicy = recoveredPolicy;
            g_riskPolicy = POLICY_FAMILY_NONE;
            g_consecutiveRecoveryBars = 0;
            g_consecutivePassCount = confirmBars > 1 ? 1 : 0;
            g_armingSession = g_lastDecisionSession;
            g_lastReason = "M15_POLICY_RECOVERED_ARMING_" +
                           g_lastRecoverySource + "_" +
                           PolicyFamilyToString(recoveredPolicy);
            string recoveryText = StringFormat("%s\n%s %d/%d",
                                               InpEventNameRecovered,
                                               InpEventNameArm,
                                               g_consecutivePassCount,
                                               confirmBars);
            if(ShouldRenderHistoricalEvent(historical,
                                           InpShowRecoveryEvents))
               CreateEventMarker("RECOVERED", decisionTime,
                                 bar.low - atrValue * 0.35,
                                 recoveryText,
                                 FeatureTooltip(decisionTime, recoveryText,
                                                g_lastReason));
            AuditEvent("POLICY_RECOVERED_ARMING", decisionTime,
                       g_lastReason, historical);
            return;
           }
        }
      if(ShouldRenderRiskLock(historical))
         UpdateRiskLockObjects(decisionTime);
      return;
     }

   if(wasActive)
     {
      if(!activeHoldPass)
         EndActiveZone(decisionTime, bar.close, holdReason, historical,
                       InpEventNamePolicyBlock, "POLICY_BLOCK",
                       InpShowPolicyBlockEvents);
      else if(ShouldRenderTradingZone(historical))
         UpdateActiveZoneObjects(decisionTime);
      return;
     }

   if(sessionCandidatePass)
     {
      if(g_state != VISUAL_STATE_ARMING ||
         g_armingPolicy != candidatePolicy ||
         g_armingSession != g_lastDecisionSession)
        {
         g_consecutivePassCount = 0;
         g_armingPolicy = candidatePolicy;
         g_armingSession = g_lastDecisionSession;
        }
      g_consecutivePassCount++;
      g_state = VISUAL_STATE_ARMING;
      int confirmBars = ConfirmBarsForPolicy(g_armingPolicy);
      if(g_consecutivePassCount >= confirmBars)
         StartActiveZone(decisionTime, bar.close, atrValue,
                         g_armingPolicy, candidateReason, historical);
      else
        {
         string armText = StringFormat("%s %d/%d\n%s",
                                       InpEventNameArm,
                                       g_consecutivePassCount,
                                       confirmBars,
                                       PolicyFamilyToString(g_armingPolicy));
         if(ShouldRenderHistoricalEvent(historical, InpShowArmEvents))
           {
            string tooltip = FeatureTooltip(decisionTime, armText,
                                            candidateReason);
            CreateEventMarker("ARM" +
                              IntegerToString(g_consecutivePassCount),
                              decisionTime, bar.low - atrValue * 0.20,
                              armText, tooltip);
           }
         AuditEvent("ENABLE_CANDIDATE_STARTED", decisionTime,
                    candidateReason, historical);
        }
     }
   else
     {
      if(g_state == VISUAL_STATE_ARMING && !historical)
         AuditEvent("ENABLE_CANDIDATE_CANCELLED", decisionTime,
                    candidateReason, historical);
      g_consecutivePassCount = 0;
      g_armingPolicy = POLICY_FAMILY_NONE;
      g_armingSession = POLICY_SESSION_OUTSIDE;
      g_activeConsecutiveRedCount = 0;
      g_activeBearTwoCount = 0;
      g_activeLowATRCount = 0;
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
   g_armingPolicy = POLICY_FAMILY_NONE;
   g_activePolicy = POLICY_FAMILY_NONE;
   g_riskPolicy = POLICY_FAMILY_NONE;
   g_armingSession = POLICY_SESSION_OUTSIDE;
   g_activeSession = POLICY_SESSION_OUTSIDE;
   g_activeConsecutiveRedCount = 0;
   g_activeBearTwoCount = 0;
   g_activeLowATRCount = 0;
   g_lastConsecutiveRedCount = 0;
   g_lastConsecutiveRedBlock = false;
   g_lastBearTwoCount = 0;
   g_lastBearTwoBlock = false;
   g_lastActiveLowATRCount = 0;
   g_lastActiveLowATRBlock = false;
   g_lastDownsideEMAApproachBlock = false;
   ResetBearishPatternSnapshot();
   ResetDenySnapshot();
   ResetReverseSnapshot();
   ResetFallSnapshot();
   g_riskLockRemaining = 0;
   g_consecutiveRecoveryBars = 0;
   g_previousBearDropVeto = false;
   g_lastPolicyRecoveryCandidate = false;
   g_lastBullishSCOB = false;
   g_lastRecoveryCandidate = false;
   g_lastRecoverySource = "NONE";
   g_activeZoneStart = 0;
   g_activeZoneHigh = 0.0;
   g_activeZoneLow = 0.0;
   g_activeZoneATR = 0.0;
   g_activeZoneBranch = POLICY_FAMILY_NONE;
   g_activeZoneBaseName = "";
   g_riskLockStart = 0;
   g_riskLockHigh = 0.0;
   g_riskLockLow = 0.0;
   g_riskLockATR = 0.0;
   g_riskLockBaseName = "";
   ArrayResize(g_distanceHistory, 0);
   ArrayResize(g_openHistory, 0);
   ArrayResize(g_closeHistory, 0);
   ArrayResize(g_highHistory, 0);
   ArrayResize(g_lowHistory, 0);
   ArrayResize(g_emaHistory, 0);
   ArrayResize(g_bearishHistory, 0);
   ArrayResize(g_eventObjectNames, 0);
   ArrayResize(g_closedZoneObjectNames, 0);
   ArrayResize(g_closedRiskLockObjectNames, 0);
   ArrayResize(g_emaObjectNames, 0);
   g_historicalShift = 0;
   g_tradingZoneHistoryCutoff = 0;
   g_riskLockHistoryCutoff = 0;
  }

int MaximumPolicyHistoryBars()
  {
   // Preserve state reconstruction depth when a renderer is toggled OFF.
   int maximum = 1500;
   maximum = MathMax(maximum, InpTradingZoneHistoryBars);
   maximum = MathMax(maximum, InpRiskLockHistoryBars);
   maximum = MathMax(maximum, InpEventHistoryBars);
   return maximum;
  }

bool BuildHistoricalZones()
  {
   ObjectsDeleteAll(0, g_objectPrefix);
   ResetRuntimeState();

   int longestPeriod = InpATRPeriod;
   if(InpEMAPeriod > longestPeriod)
      longestPeriod = InpEMAPeriod;
   longestPeriod = MathMax(longestPeriod, InpBearDropLookback);
   longestPeriod = MathMax(longestPeriod, InpBearishWindow);
   longestPeriod = MathMax(longestPeriod, InpRecoveryEMASlopeBars + 1);
   longestPeriod = MathMax(longestPeriod, InpDownsideEMASlopeBars + 1);
   // Extra bars are loaded only as policy warm-up. Render helpers independently
   // enforce each visual history depth without changing the reconstructed state.
   int requested = MaximumPolicyHistoryBars() + longestPeriod + 5;
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

   if(InpDrawTradingZoneHistory)
     {
      int cutoffIndex = MathMin(InpTradingZoneHistoryBars - 1, available - 1);
      g_tradingZoneHistoryCutoff = rates[cutoffIndex].time;
     }
   if(InpDrawRiskLockHistory)
     {
      int cutoffIndex = MathMin(InpRiskLockHistoryBars - 1, available - 1);
      g_riskLockHistoryCutoff = rates[cutoffIndex].time;
     }

   int oldestShift = available - 1;
   for(int shift = oldestShift; shift >= 1; shift--)
     {
      g_historicalShift = shift;
      datetime decisionTime = rates[shift - 1].time;
      ProcessDecisionBar(rates[shift], atrValues[shift], emaValues[shift],
                         decisionTime, true);
     }
   g_historicalShift = 0;

   if(!InpDrawTradingZoneHistory && g_state == VISUAL_STATE_ACTIVE)
      UpdateActiveZoneObjects(TimeCurrent());
   if(!InpDrawRiskLockHistory && g_state == VISUAL_STATE_RISK_LOCK)
      UpdateRiskLockObjects(TimeCurrent());

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
   if(g_state != VISUAL_STATE_ACTIVE && g_state != VISUAL_STATE_RISK_LOCK)
      return;
   double currentHigh = iHigh(_Symbol, DECISION_TIMEFRAME, 0);
   double currentLow = iLow(_Symbol, DECISION_TIMEFRAME, 0);
   if(g_state == VISUAL_STATE_ACTIVE)
     {
      if(currentHigh > 0.0) g_activeZoneHigh = MathMax(g_activeZoneHigh, currentHigh);
      if(currentLow > 0.0)  g_activeZoneLow = MathMin(g_activeZoneLow, currentLow);
      UpdateActiveZoneObjects(TimeCurrent());
     }
   else
     {
      if(currentHigh > 0.0) g_riskLockHigh = MathMax(g_riskLockHigh, currentHigh);
      if(currentLow > 0.0)  g_riskLockLow = MathMin(g_riskLockLow, currentLow);
      UpdateRiskLockObjects(TimeCurrent());
     }
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
             EndActiveZone(currentM15Bar, g_lastClose, g_lastReason, false,
                           InpEventNamePolicyBlock, "DATA_ERROR_BLOCK",
                           InpShowPolicyBlockEvents);
          else if(g_state == VISUAL_STATE_RISK_LOCK)
            {
             EndRiskLockVisual(currentM15Bar, false);
             g_state = VISUAL_STATE_DATA_ERROR;
            }
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
         // CCBSN can consume the command while CTrade is still returning.
         // A command that is no longer active is already safe for handover.
         if(IsControllerOrderSelected(ticket))
           {
            allDeleted = false;
            PrintFormat("HANDOVER ERROR | Cannot delete controller command #%I64u | %s | %u %s",
                        ticket, context, retcode,
                        g_trade.ResultRetcodeDescription());
           }
         else
            PrintFormat("HANDOVER NORMALIZED | Command #%I64u already removed | %s",
                        ticket, context);
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
                      ? InpEventNameNCEnabled : InpEventNameNCDisabled;
    color eventColor = command == CCBSN_COMMAND_NEW_CYCLE_ON
                       ? PolicyFamilyColor(g_activeZoneBranch) : InpOffEventColor;
   if(ShouldRenderEvent(InpShowControlAckEvents))
     {
      CreateVerticalLine(g_objectPrefix + "CONTROL." + eventName + "." +
                         TimeKey(confirmedTime), confirmedTime, eventColor,
                         STYLE_DOT, eventName);
      CreateEventMarker(eventName, confirmedTime, markerPrice,
                        eventText,
                        "Pending command was removed; CCBSN consumption assumed.");
     }
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
      // A fast CCBSN ACK removes the order before CTrade exposes its final
      // result. Let ReconcilePendingCommand classify the history state.
      if(!IsControllerOrderSelected(g_commandTicket))
        {
         g_lastControlError = "COMMAND_DELETE_ALREADY_COMPLETED";
         PrintFormat("CONTROL NORMALIZED | Delete already completed | ticket=%I64u retcode=%u %s",
                     g_commandTicket, retcode,
                     g_trade.ResultRetcodeDescription());
         return true;
        }
      g_lastControlError = "COMMAND_DELETE_RETRY:" +
                           g_trade.ResultRetcodeDescription();
      PrintFormat("CONTROL RETRY | Cannot delete ticket=%I64u yet | retcode=%u %s",
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
   ResetLastError();
   bool requestOk = false;
   if(command == CCBSN_COMMAND_NEW_CYCLE_ON)
      requestOk = g_trade.SellLimit(volume, price, _Symbol, 0.0, 0.0,
                                    ORDER_TIME_GTC, 0, comment);
   else
      requestOk = g_trade.BuyStop(volume, price, _Symbol, 0.0, 0.0,
                                  ORDER_TIME_GTC, 0, comment);

   uint retcode = g_trade.ResultRetcode();
   ulong ticket = g_trade.ResultOrder();
   int terminalError = GetLastError();
   if(ticket == 0)
     {
      // With no ticket there is nothing that CCBSN can consume. Keep the
      // controller retryable instead of latching ERROR forever.
      g_controlState = CCBSN_CONTROL_UNKNOWN;
      g_lastControlError = "COMMAND_SEND_RETRY:" +
                           g_trade.ResultRetcodeDescription();
      g_nextCommandAttemptTick = GetTickCount64() +
                                 (ulong)InpCommandRetryMilliseconds;
      PrintFormat("CONTROL RETRY | Send %s has no ticket | request=%s retcode=%u %s error=%d",
                  action, requestOk ? "true" : "false", retcode,
                  g_trade.ResultRetcodeDescription(), terminalError);
      return false;
     }

   // ResultOrder is authoritative. CCBSN may cancel the command during the
   // synchronous CTrade call, producing requestOk=false/retcode=0 even though
   // the server accepted the order and returned a valid ticket.
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
   g_nextCommandAttemptTick = 0;
   SavePendingCommand();
   AuditEvent("CCBSN_COMMAND_SENT", g_commandSentTime,
              CommandToString(command), false);
   PrintFormat("CONTROL SENT | %s | ticket=%I64u price=%s volume=%.2f request=%s retcode=%u",
               CommandToString(command), ticket,
               FormatPrice(price), volume,
               requestOk ? "true" : "false", retcode);
   if(!requestOk ||
      (retcode != TRADE_RETCODE_DONE && retcode != TRADE_RETCODE_PLACED))
      PrintFormat("CONTROL NORMALIZED | Fast ACK candidate | ticket=%I64u retcode=%u %s error=%d",
                  ticket, retcode, g_trade.ResultRetcodeDescription(),
                  terminalError);
   ReconcilePendingCommand();
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
   if(g_nextCommandAttemptTick > 0 &&
      GetTickCount64() < g_nextCommandAttemptTick)
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
   g_configurationValid = ValidateInputs();
   if(!g_configurationValid)
     {
      g_controlState = CCBSN_CONTROL_DISABLED;
      g_lastControlError = "CONFIG_SAFE_MODE: " + g_configurationError;
      g_objectPrefix = "CCBSN_TZ_V3." + IntegerToString(ChartID()) + ".";
      EventSetMillisecondTimer(InpTimerMilliseconds);
      Comment("CCBSN Controller CONFIG SAFE MODE\n",
              g_configurationError,
              "\nNo policy evaluation or New Cycle command is active.",
              "\nCorrect Inputs and press OK to resume.");
      PrintFormat("INIT SAFE MODE | %s | EA remains attached; control disabled.",
                  g_configurationError);
      return INIT_SUCCEEDED;
     }
   if(!ValidateControlEnvironment())
      return INIT_PARAMETERS_INCORRECT;

   g_trade.SetExpertMagicNumber(InpControllerMagic);
   g_trade.SetAsyncMode(false);
   g_trade.SetTypeFillingBySymbol(_Symbol);
   g_trade.SetMarginMode();

   g_objectPrefix = "CCBSN_TZ_V3." + IntegerToString(ChartID()) + ".";
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
      ReconcilePendingCommand();
      ProcessCCBSNControl();
      AuditEvent("CONTROL_STARTUP_SYNC_CHECK", TimeCurrent(),
                 CommandToString(DesiredCommand()), false);
      PrintFormat("CONTROL STARTUP CHECK | desired=%s state=%s pending=%s ticket=%I64u",
                  CommandToString(DesiredCommand()),
                  ControlStateToString(g_controlState),
                  CommandToString(g_pendingCommand), g_commandTicket);
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
   if(g_configurationValid && InpControlMode == CCBSN_CONTROL_ENABLED)
     {
      ReconcilePendingCommand();
      AuditEvent("CONTROL_SHUTDOWN_SYNC_CHECK", TimeCurrent(),
                 DeinitReasonToString(reason), false);
      PrintFormat("CONTROL SHUTDOWN CHECK | reason=%s desired=%s state=%s pending=%s ticket=%I64u",
                  DeinitReasonToString(reason),
                  CommandToString(DesiredCommand()),
                  ControlStateToString(g_controlState),
                  CommandToString(g_pendingCommand), g_commandTicket);
     }
   bool explicitHandover =
      (reason == REASON_PROGRAM || reason == REASON_REMOVE ||
       reason == REASON_CHARTCLOSE || reason == REASON_TEMPLATE);
   bool handoverRequested = InpManualHandoverOnRemove && explicitHandover &&
                            g_configurationValid &&
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
   if(!g_configurationValid)
      return;
   ProcessRuntime();
   if((g_positionSyncRequested || g_controlReconcileRequested) &&
      InpControlMode == CCBSN_CONTROL_ENABLED)
     {
      g_positionSyncRequested = false;
      g_controlReconcileRequested = false;
      ProcessCCBSNControl();
      UpdatePanel();
     }
  }

void OnTradeTransaction(const MqlTradeTransaction &transaction,
                        const MqlTradeRequest &request,
                        const MqlTradeResult &result)
  {
   if(!g_configurationValid)
      return;
   if(InpControlMode != CCBSN_CONTROL_ENABLED)
      return;
   if(transaction.type == TRADE_TRANSACTION_DEAL_ADD ||
      transaction.type == TRADE_TRANSACTION_POSITION)
     {
      RefreshCCBSNPositionSync("TRADE_TRANSACTION");
      g_positionSyncRequested = true;
     }
   if(transaction.type == TRADE_TRANSACTION_ORDER_ADD ||
      transaction.type == TRADE_TRANSACTION_ORDER_UPDATE ||
      transaction.type == TRADE_TRANSACTION_ORDER_DELETE ||
      transaction.type == TRADE_TRANSACTION_HISTORY_ADD)
      g_controlReconcileRequested = true;
  }

void OnTimer()
  {
   if(!g_configurationValid)
     {
      Comment("CCBSN Controller CONFIG SAFE MODE\n",
              g_configurationError,
              "\nNo policy evaluation or New Cycle command is active.",
              "\nCorrect Inputs and press OK to resume.");
      return;
     }
   RefreshControllerLock();
   if(InpControlMode == CCBSN_CONTROL_MANUAL_HANDOVER &&
      !g_manualHandoverComplete)
      PerformManualHandover("MANUAL_HANDOVER_RETRY");
   ProcessRuntime();
   g_positionSyncRequested = false;
   g_controlReconcileRequested = false;
   ProcessCCBSNControl();
   UpdatePanel();
   ChartRedraw(0);
  }

//+------------------------------------------------------------------+
