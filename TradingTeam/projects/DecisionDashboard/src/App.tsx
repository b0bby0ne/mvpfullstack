import { useEffect, useMemo, useState } from "react";
import { GoldMacroDashboard } from "./components/GoldMacroDashboard";
import { LiquidityDashboard } from "./components/LiquidityDashboard";
import { TradingViewChart } from "./components/TradingViewChart";
import {
  getMarket,
  getTradingViewUrl,
  MARKETS,
  TIMEFRAMES,
  type MarketId,
  type Timeframe,
} from "./domain/markets";
import { useDailyGoldMacro } from "./hooks/useDailyGoldMacro";
import "./styles.css";

const STORAGE_PREFIX = "decision-dashboard:analysis-note:";
type Section = "macro" | "chart" | "liquidity";

function ChartIcon() {
  return <svg viewBox="0 0 24 24" aria-hidden="true"><path d="M4 19V9m5 10V5m5 14v-7m5 7V3" /></svg>;
}

function MacroIcon() {
  return <svg viewBox="0 0 24 24" aria-hidden="true"><path d="M4 17 9 12l3 3 7-8" /><path d="M14 7h5v5" /></svg>;
}

function GridIcon() {
  return <svg viewBox="0 0 24 24" aria-hidden="true"><rect x="4" y="4" width="6" height="6" rx="1" /><rect x="14" y="4" width="6" height="6" rx="1" /><rect x="4" y="14" width="6" height="6" rx="1" /><rect x="14" y="14" width="6" height="6" rx="1" /></svg>;
}

function LiquidityIcon() {
  return <svg viewBox="0 0 24 24" aria-hidden="true"><path d="M5 7h14M7 12h10M9 17h6" /><circle cx="5" cy="7" r="1" /><circle cx="19" cy="7" r="1" /></svg>;
}

function sectionLabel(section: Section) {
  if (section === "macro") return "Vĩ mô";
  if (section === "liquidity") return "Liquid";
  return "Chart";
}

function initialMarket(): MarketId {
  const market = new URLSearchParams(window.location.search).get("market");
  return market === "BTC_USD" ? "BTC_USD" : "XAU_USD";
}

function initialSection(): Section {
  const section = new URLSearchParams(window.location.search).get("section");
  return section === "chart" || section === "liquidity" ? section : "macro";
}

function MarketWorkspace({ marketId }: { marketId: MarketId }) {
  const [timeframe, setTimeframe] = useState<Timeframe>("15");
  const market = useMemo(() => getMarket(marketId), [marketId]);
  const noteKey = `${STORAGE_PREFIX}${marketId}`;
  const [note, setNote] = useState(() => localStorage.getItem(noteKey) ?? "");
  const [saved, setSaved] = useState(false);

  useEffect(() => {
    setNote(localStorage.getItem(noteKey) ?? "");
    setSaved(false);
  }, [noteKey]);

  function saveNote() {
    localStorage.setItem(noteKey, note.trim());
    setSaved(true);
    window.setTimeout(() => setSaved(false), 1800);
  }

  return (
    <section className="chart-page" aria-label={`Chart ${market.shortName}/USD`}>
      <div className="market-header">
        <div className="market-heading">
          <span className={`hero-token hero-token--${market.accent}`}>{market.shortName.slice(0, 1)}</span>
          <div>
            <div className="heading-line"><h2>{market.displayName}</h2><span className="market-code">{market.shortName}/USD</span></div>
            <p>{market.tradingViewSymbol} · Reference chart feed</p>
          </div>
        </div>
        <div className="timeframes" aria-label="Chọn khung thời gian">
          {TIMEFRAMES.map((item) => (
            <button key={item.value} className={item.value === timeframe ? "is-active" : ""} onClick={() => setTimeframe(item.value)} type="button">{item.label}</button>
          ))}
        </div>
      </div>

      <div className="workspace-grid">
        <section className="chart-card">
          <div className="chart-toolbar"><div className="chart-status"><span className="status-pulse" />TradingView connected</div><p>Dùng thanh công cụ bên trái để vẽ phân tích trực tiếp</p></div>
          <TradingViewChart market={market} timeframe={timeframe} />
        </section>
        <aside className="analysis-panel" id="analysis-note">
          <div className="panel-heading"><div><p className="eyebrow">Working note</p><h3>Phân tích kỹ thuật</h3></div><span className="draft-badge">Local draft</span></div>
          <div className="guide-card"><span className="guide-number">01</span><div><strong>Vẽ trên biểu đồ</strong><p>Trendline, Fibonacci, vùng giá và ghi chú nằm trong toolbar TradingView.</p></div></div>
          <label className="note-field"><span>Ghi chú cho {market.shortName}/USD</span><textarea value={note} onChange={(event) => { setNote(event.target.value); setSaved(false); }} placeholder="Bias, vùng quan sát, điều kiện xác nhận và invalidation…" /></label>
          <button className="save-button" onClick={saveNote} type="button">{saved ? "Đã lưu trên thiết bị" : "Lưu ghi chú"}</button>
          <div className="data-note"><span>i</span><p>Giá hiển thị do TradingView cung cấp. Feed này chưa phải nguồn dữ liệu xác nhận cho detector.</p></div>
        </aside>
      </div>
    </section>
  );
}

function EmptyMacroState({ onOpenChart }: { onOpenChart: () => void }) {
  return (
    <section className="macro-empty" aria-labelledby="btc-macro-title">
      <span className="empty-token market-token--orange">B</span>
      <p className="eyebrow">BTC macro intelligence</p>
      <h2 id="btc-macro-title">Macro BTC đang chờ nguồn dữ liệu</h2>
      <p>Flow đã sẵn sàng, nhưng phase hiện tại mới thu thập và xác minh evidence cho vàng. Dashboard không tái sử dụng dữ liệu XAU hoặc tạo nhận định BTC chưa có nguồn.</p>
      <div className="empty-actions">
        <button type="button" onClick={onOpenChart}>Mở chart BTC/USD</button>
        <span>Planned: ETF · on-chain · liquidity · macro beta</span>
      </div>
    </section>
  );
}

function App() {
  const [marketId, setMarketId] = useState<MarketId>(initialMarket);
  const [section, setSection] = useState<Section>(initialSection);
  const market = getMarket(marketId);
  const goldMacroOperations = useDailyGoldMacro();

  useEffect(() => {
    const url = new URL(window.location.href);
    url.searchParams.set("market", marketId);
    url.searchParams.set("section", section);
    window.history.replaceState(null, "", url);
  }, [marketId, section]);

  return (
    <div className={`app-shell app-shell--${section}`}>
      <aside className="sidebar">
        <div className="brand" aria-label="DecisionDashboard"><span className="brand-mark"><ChartIcon /></span><span>Decision<span>Dashboard</span></span></div>
        <div className="flow-rail" aria-label="Decision flow">
          <p className="section-label">Decision flow</p>
          <div className="flow-step flow-step--done"><span>01</span><div><strong>Market</strong><small>{market.shortName}/USD</small></div></div>
          <div className="flow-line" />
          <div className="flow-step flow-step--active"><span>02</span><div><strong>Section</strong><small>{sectionLabel(section)}</small></div></div>
          <div className="flow-line" />
          <div className="flow-step"><span>03</span><div><strong>Thesis</strong><small>Evidence first</small></div></div>
        </div>
        <div className="sidebar-foot"><span className="status-pulse" /><div><strong>Research mode</strong><small>Không gửi lệnh broker</small></div></div>
      </aside>

      <main className="workspace" id="workspace">
        <header className="topbar">
          <div><p className="eyebrow">Decision workspace</p><h1>{market.shortName}/USD · {sectionLabel(section)}</h1></div>
          <div className="topbar-actions">
            <span className="timezone">UTC+7 · Hồ Chí Minh</span>
            {section === "chart" ? <a className="external-button" href={getTradingViewUrl(market)} target="_blank" rel="noreferrer">Mở trên TradingView <span aria-hidden="true">↗</span></a> : <span className={`research-badge research-badge--${market.accent}`}>{market.shortName} · {section === "liquidity" ? "Liquid" : "Macro"}</span>}
          </div>
        </header>

        <section className="decision-switcher" aria-label="Chọn market và section">
          <div className="switch-group">
            <div className="switch-label"><span>01</span><div><strong>Chọn market</strong><small>Context phân tích</small></div></div>
            <div className="market-pills">
              {MARKETS.map((item) => (
                <button key={item.id} type="button" aria-pressed={marketId === item.id} aria-label={`Chọn market ${item.shortName}/USD`} className={`market-pill ${marketId === item.id ? "is-active" : ""}`} onClick={() => setMarketId(item.id)}>
                  <span className={`market-token market-token--${item.accent}`}>{item.shortName.slice(0, 1)}</span>
                  <span><strong>{item.shortName}/USD</strong><small>{item.marketHours}</small></span>
                </button>
              ))}
            </div>
          </div>
          <div className="switch-divider"><span>›</span></div>
          <div className="switch-group switch-group--section">
            <div className="switch-label"><span>02</span><div><strong>Chọn section</strong><small>Cùng một workspace</small></div></div>
            <div className="section-pills">
              <button type="button" aria-pressed={section === "macro"} className={section === "macro" ? "is-active" : ""} onClick={() => setSection("macro")}><MacroIcon /><span><strong>Vĩ mô</strong><small>Flows &amp; events</small></span></button>
              <button type="button" aria-pressed={section === "chart"} className={section === "chart" ? "is-active" : ""} onClick={() => setSection("chart")}><GridIcon /><span><strong>Chart</strong><small>TradingView</small></span></button>
              <button type="button" aria-pressed={section === "liquidity"} className={section === "liquidity" ? "is-active" : ""} onClick={() => setSection("liquidity")}><LiquidityIcon /><span><strong>Liquid</strong><small>Futures &amp; options</small></span></button>
            </div>
          </div>
        </section>

        {section === "macro" && (marketId === "XAU_USD" ? <GoldMacroDashboard operations={goldMacroOperations} /> : <EmptyMacroState onOpenChart={() => setSection("chart")} />)}
        {section === "chart" && <MarketWorkspace marketId={marketId} />}
        {section === "liquidity" && <LiquidityDashboard marketId={marketId} />}

        <footer className="workspace-footer"><span>DECISION DASHBOARD · MVP 0.4</span><span>Market → Section → Evidence</span></footer>
      </main>
    </div>
  );
}

export default App;
