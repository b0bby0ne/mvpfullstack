import { useEffect, useMemo, useState } from "react";
import { TradingViewChart } from "./components/TradingViewChart";
import {
  getMarket,
  getTradingViewUrl,
  MARKETS,
  TIMEFRAMES,
  type MarketId,
  type Timeframe,
} from "./domain/markets";
import "./styles.css";

const STORAGE_PREFIX = "decision-dashboard:analysis-note:";

function ChartIcon() {
  return (
    <svg viewBox="0 0 24 24" aria-hidden="true">
      <path d="M4 19V9m5 10V5m5 14v-7m5 7V3" />
    </svg>
  );
}

function GridIcon() {
  return (
    <svg viewBox="0 0 24 24" aria-hidden="true">
      <rect x="4" y="4" width="6" height="6" rx="1" />
      <rect x="14" y="4" width="6" height="6" rx="1" />
      <rect x="4" y="14" width="6" height="6" rx="1" />
      <rect x="14" y="14" width="6" height="6" rx="1" />
    </svg>
  );
}

function NoteIcon() {
  return (
    <svg viewBox="0 0 24 24" aria-hidden="true">
      <path d="M6 4h12a2 2 0 0 1 2 2v9l-5 5H6a2 2 0 0 1-2-2V6a2 2 0 0 1 2-2Z" />
      <path d="M15 20v-5h5M8 9h8M8 13h5" />
    </svg>
  );
}

function App() {
  const [marketId, setMarketId] = useState<MarketId>("XAU_USD");
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
    <div className="app-shell">
      <aside className="sidebar">
        <div className="brand" aria-label="DecisionDashboard">
          <span className="brand-mark"><ChartIcon /></span>
          <span>Decision<span>Dashboard</span></span>
        </div>

        <nav className="primary-nav" aria-label="Điều hướng chính">
          <a className="nav-item nav-item--active" href="#workspace">
            <GridIcon />
            <span>Workspace</span>
          </a>
          <a className="nav-item" href="#analysis-note">
            <NoteIcon />
            <span>Thesis notes</span>
          </a>
        </nav>

        <div className="watchlist">
          <div className="section-label">
            <span>Markets</span>
            <span className="live-dot">Live</span>
          </div>

          {MARKETS.map((item) => (
            <button
              key={item.id}
              className={`market-row ${item.id === marketId ? "market-row--active" : ""}`}
              onClick={() => setMarketId(item.id)}
              type="button"
            >
              <span className={`market-token market-token--${item.accent}`}>
                {item.shortName.slice(0, 1)}
              </span>
              <span className="market-copy">
                <strong>{item.shortName}/USD</strong>
                <small>{item.marketHours} · TradingView</small>
              </span>
              <span className="market-chevron">›</span>
            </button>
          ))}
        </div>

        <div className="sidebar-foot">
          <span className="status-pulse" />
          <div>
            <strong>Research mode</strong>
            <small>Không gửi lệnh broker</small>
          </div>
        </div>
      </aside>

      <main className="workspace" id="workspace">
        <header className="topbar">
          <div>
            <p className="eyebrow">Decision workspace</p>
            <h1>Market analysis</h1>
          </div>
          <div className="topbar-actions">
            <span className="timezone">UTC+7 · Hồ Chí Minh</span>
            <a
              className="external-button"
              href={getTradingViewUrl(market)}
              target="_blank"
              rel="noreferrer"
            >
              Mở trên TradingView
              <span aria-hidden="true">↗</span>
            </a>
          </div>
        </header>

        <section className="market-header">
          <div className="market-heading">
            <span className={`hero-token hero-token--${market.accent}`}>
              {market.shortName.slice(0, 1)}
            </span>
            <div>
              <div className="heading-line">
                <h2>{market.displayName}</h2>
                <span className="market-code">{market.shortName}/USD</span>
              </div>
              <p>{market.tradingViewSymbol} · Reference chart feed</p>
            </div>
          </div>

          <div className="timeframes" aria-label="Chọn khung thời gian">
            {TIMEFRAMES.map((item) => (
              <button
                key={item.value}
                className={item.value === timeframe ? "is-active" : ""}
                onClick={() => setTimeframe(item.value)}
                type="button"
              >
                {item.label}
              </button>
            ))}
          </div>
        </section>

        <div className="workspace-grid">
          <section className="chart-card">
            <div className="chart-toolbar">
              <div className="chart-status">
                <span className="status-pulse" />
                TradingView connected
              </div>
              <p>Dùng thanh công cụ bên trái để vẽ phân tích trực tiếp</p>
            </div>
            <TradingViewChart market={market} timeframe={timeframe} />
          </section>

          <aside className="analysis-panel" id="analysis-note">
            <div className="panel-heading">
              <div>
                <p className="eyebrow">Working note</p>
                <h3>Phân tích kỹ thuật</h3>
              </div>
              <span className="draft-badge">Local draft</span>
            </div>

            <div className="guide-card">
              <span className="guide-number">01</span>
              <div>
                <strong>Vẽ trên biểu đồ</strong>
                <p>Trendline, Fibonacci, vùng giá và ghi chú nằm trong toolbar TradingView.</p>
              </div>
            </div>

            <label className="note-field">
              <span>Ghi chú cho {market.shortName}/USD</span>
              <textarea
                value={note}
                onChange={(event) => {
                  setNote(event.target.value);
                  setSaved(false);
                }}
                placeholder="Bias, vùng quan sát, điều kiện xác nhận và invalidation…"
              />
            </label>

            <button className="save-button" onClick={saveNote} type="button">
              {saved ? "Đã lưu trên thiết bị" : "Lưu ghi chú"}
            </button>

            <div className="data-note">
              <span>i</span>
              <p>
                Giá hiển thị do TradingView cung cấp. Feed này chưa phải nguồn dữ liệu xác nhận cho detector.
              </p>
            </div>
          </aside>
        </div>

        <footer className="workspace-footer">
          <span>DECISION DASHBOARD · MVP 0.1</span>
          <span>Research &amp; paper validation only</span>
        </footer>
      </main>
    </div>
  );
}

export default App;
