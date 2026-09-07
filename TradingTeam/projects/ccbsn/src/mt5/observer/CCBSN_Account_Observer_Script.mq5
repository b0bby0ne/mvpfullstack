//+------------------------------------------------------------------+
//| CCBSN Account Observer Script v1.1.0                            |
//| Persistent read-only heartbeat for an MT5 investor login        |
//+------------------------------------------------------------------+
#property strict
#property version "1.100"
#property script_show_inputs
#property description "Persistent read-only observer; contains no trade execution path."

input bool   InpRequireInvestorMode = true;
input ulong  InpCCBSNMagic          = 9696;
input string InpStatusFile          = "CCBSN\\account_observer_status_v1.json";
input int    InpHeartbeatSeconds    = 5;

const string SCHEMA_VERSION   = "ccbsn-monitor-status.v1";
const string OBSERVER_VERSION = "observer-script-1.1.0";
ulong g_sequence = 0;
ulong g_writeFailures = 0;
string g_lastWriteError = "NONE";

string JsonEscape(const string value)
  {
   string result = value;
   StringReplace(result, "\\", "\\\\");
   StringReplace(result, "\"", "\\\"");
   StringReplace(result, "\r", "\\r");
   StringReplace(result, "\n", "\\n");
   StringReplace(result, "\t", "\\t");
   return result;
  }

string JsonString(const string value) { return "\"" + JsonEscape(value) + "\""; }
string JsonBool(const bool value) { return value ? "true" : "false"; }

string UtcTimestamp(datetime value)
  {
   if(value <= 0) return "";
   string result = TimeToString(value, TIME_DATE | TIME_SECONDS);
   StringReplace(result, ".", "-");
   StringReplace(result, " ", "T");
   return result + "Z";
  }

string MaskedLogin()
  {
   string login = IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN));
   int length = StringLen(login);
   if(length <= 4) return "****";
   return "****" + StringSubstr(login, length - 4);
  }

string AccountModeText()
  {
   ENUM_ACCOUNT_TRADE_MODE mode =
      (ENUM_ACCOUNT_TRADE_MODE)AccountInfoInteger(ACCOUNT_TRADE_MODE);
   if(mode == ACCOUNT_TRADE_MODE_REAL) return "REAL";
   if(mode == ACCOUNT_TRADE_MODE_DEMO) return "DEMO";
   if(mode == ACCOUNT_TRADE_MODE_CONTEST) return "CONTEST";
   return "UNKNOWN";
  }

void ReadExposure(int &magicPositions, double &magicVolume,
                  double &magicProfit, int &accountPositions,
                  double &accountProfit)
  {
   magicPositions = 0;
   magicVolume = 0.0;
   magicProfit = 0.0;
   accountPositions = 0;
   accountProfit = 0.0;
   for(int index = PositionsTotal() - 1; index >= 0; index--)
     {
      if(PositionGetTicket(index) == 0) continue;
      double profit = PositionGetDouble(POSITION_PROFIT) +
                      PositionGetDouble(POSITION_SWAP);
      accountPositions++;
      accountProfit += profit;
      if((ulong)PositionGetInteger(POSITION_MAGIC) != InpCCBSNMagic) continue;
      magicPositions++;
      magicVolume += PositionGetDouble(POSITION_VOLUME);
      magicProfit += profit;
     }
  }

string BuildStatus(const ulong sequence)
  {
   datetime nowUtc = TimeGMT();
   if(nowUtc <= 0) nowUtc = TimeCurrent();
   bool connected = (bool)TerminalInfoInteger(TERMINAL_CONNECTED);
   bool tradeAllowed = (bool)AccountInfoInteger(ACCOUNT_TRADE_ALLOWED);
   bool expertAllowed = (bool)AccountInfoInteger(ACCOUNT_TRADE_EXPERT);
   bool investorConfirmed = connected && !tradeAllowed;
   bool configurationValid = !InpRequireInvestorMode || investorConfirmed;
   string runtime = connected ? (investorConfirmed ? "RUNNING" : "UNSAFE_MASTER_LOGIN") : "STARTING";
   string reason = connected ? (investorConfirmed ? "INVESTOR_READ_ONLY_CONFIRMED" : "ACCOUNT_TRADE_ALLOWED_TRUE") : "WAITING_FOR_CONNECTION";
   string configurationError = (connected && !investorConfirmed) ? "INVESTOR_MODE_REQUIRED" : "NONE";

   int magicPositions, accountPositions;
   double magicVolume, magicProfit, accountProfit;
   ReadExposure(magicPositions, magicVolume, magicProfit,
                accountPositions, accountProfit);

   string json = "{\n";
   json += "  \"schema_version\": " + JsonString(SCHEMA_VERSION) + ",\n";
   json += "  \"sequence\": " + StringFormat("%I64u", sequence) + ",\n";
   json += "  \"generated_at_utc\": " + JsonString(UtcTimestamp(nowUtc)) + ",\n";
   json += "  \"runtime_state\": " + JsonString(runtime) + ",\n";
   json += "  \"ea_version\": " + JsonString(OBSERVER_VERSION) + ",\n";
   json += "  \"policy_version\": \"account-observer-read-only-v1\",\n";
   json += "  \"symbol\": " + JsonString(_Symbol) + ",\n";
   json += "  \"ccbsn_magic\": " + StringFormat("%I64u", InpCCBSNMagic) + ",\n";
   json += "  \"controller_magic\": 0,\n";
   json += "  \"terminal_connected\": " + JsonBool(connected) + ",\n";
   json += "  \"last_tick_time_utc\": " + JsonString(connected ? UtcTimestamp(nowUtc) : "") + ",\n";
   json += "  \"last_m15_decision_server\": \"\",\n";
   json += "  \"last_m15_decision_age_seconds\": -1,\n";
   json += "  \"visual_state\": \"OBSERVER\",\n";
   json += "  \"policy_family\": \"NONE\",\n";
   json += "  \"desired_cycle\": \"NONE\",\n";
   json += "  \"control_state\": \"DISABLED\",\n";
   json += "  \"pending_command\": \"NONE\",\n";
   json += "  \"drift\": false,\n";
   json += "  \"session\": \"OUTSIDE\",\n";
   json += "  \"atr\": 0.0,\n";
   json += "  \"ema\": 0.0,\n";
   json += "  \"distance_d\": 0.0,\n";
   json += "  \"last_event\": \"ACCOUNT_OBSERVER\",\n";
   json += "  \"last_reason\": " + JsonString(reason) + ",\n";
   json += "  \"positions\": " + IntegerToString(magicPositions) + ",\n";
   json += "  \"volume\": " + DoubleToString(magicVolume, 2) + ",\n";
   json += "  \"floating_profit\": " + DoubleToString(magicProfit, 2) + ",\n";
   json += "  \"margin_level\": " + DoubleToString(AccountInfoDouble(ACCOUNT_MARGIN_LEVEL), 2) + ",\n";
   json += "  \"configuration_valid\": " + JsonBool(configurationValid) + ",\n";
   json += "  \"configuration_error\": " + JsonString(configurationError) + ",\n";
   json += "  \"control_error\": \"NONE\",\n";
   json += "  \"monitor_error\": " + JsonString(g_lastWriteError) + ",\n";
   json += "  \"monitor_write_failures\": " + StringFormat("%I64u", g_writeFailures) + ",\n";
   json += "  \"account_login_masked\": " + JsonString(MaskedLogin()) + ",\n";
   json += "  \"account_server\": " + JsonString(AccountInfoString(ACCOUNT_SERVER)) + ",\n";
   json += "  \"account_mode\": " + JsonString(AccountModeText()) + ",\n";
   json += "  \"account_trade_allowed\": " + JsonBool(tradeAllowed) + ",\n";
   json += "  \"account_expert_allowed\": " + JsonBool(expertAllowed) + ",\n";
   json += "  \"account_balance\": " + DoubleToString(AccountInfoDouble(ACCOUNT_BALANCE), 2) + ",\n";
   json += "  \"account_equity\": " + DoubleToString(AccountInfoDouble(ACCOUNT_EQUITY), 2) + ",\n";
   json += "  \"account_positions\": " + IntegerToString(accountPositions) + ",\n";
   json += "  \"account_floating_profit\": " + DoubleToString(accountProfit, 2) + "\n";
   json += "}\n";
   return json;
  }

bool PublishStatus()
  {
   string temporary = InpStatusFile + ".tmp";
   string payload = BuildStatus(g_sequence + 1);
   int handle = FileOpen(temporary, FILE_WRITE | FILE_TXT | FILE_ANSI |
                         FILE_COMMON | FILE_SHARE_READ, 0, CP_UTF8);
   if(handle == INVALID_HANDLE)
     {
      g_lastWriteError = "TEMP_OPEN_FAILED:" + IntegerToString(GetLastError());
      g_writeFailures++;
      Print("OBSERVER SCRIPT WRITE ERROR | ", g_lastWriteError);
      return false;
     }
   uint written = FileWriteString(handle, payload);
   FileFlush(handle);
   FileClose(handle);
   if(written == 0 && StringLen(payload) > 0)
     {
      FileDelete(temporary, FILE_COMMON);
      g_lastWriteError = "TEMP_WRITE_FAILED";
      g_writeFailures++;
      return false;
     }
   if(!FileMove(temporary, FILE_COMMON, InpStatusFile,
                FILE_COMMON | FILE_REWRITE))
     {
      FileDelete(temporary, FILE_COMMON);
      g_lastWriteError = "ATOMIC_REPLACE_FAILED:" + IntegerToString(GetLastError());
      g_writeFailures++;
      Print("OBSERVER SCRIPT WRITE ERROR | ", g_lastWriteError);
      return false;
     }
   g_sequence++;
   g_lastWriteError = "NONE";
   return true;
  }

void OnStart()
  {
   if(InpStatusFile == "" || StringFind(InpStatusFile, "..") >= 0 ||
      InpHeartbeatSeconds < 1 || InpHeartbeatSeconds > 60)
     {
      Print("OBSERVER SCRIPT PARAMETER ERROR");
      return;
     }
   Print("OBSERVER SCRIPT START | persistent read-only heartbeat");
   while(!IsStopped())
     {
      PublishStatus();
      Sleep(InpHeartbeatSeconds * 1000);
     }
   Print("OBSERVER SCRIPT STOP");
  }
//+------------------------------------------------------------------+
