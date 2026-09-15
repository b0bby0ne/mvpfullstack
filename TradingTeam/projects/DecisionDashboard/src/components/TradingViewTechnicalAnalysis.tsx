import { useEffect, useRef, useState } from "react";
import type { Market, Timeframe } from "../domain/markets";

type TradingViewTechnicalAnalysisProps = {
  market: Market;
  timeframe: Timeframe;
};

const TRADING_VIEW_ANALYSIS_SCRIPT =
  "https://s3.tradingview.com/external-embedding/embed-widget-technical-analysis.js";

export const TRADING_VIEW_ANALYSIS_INTERVALS: Record<Timeframe, string> = {
  "15": "15m",
  "60": "1h",
  "240": "4h",
  D: "1D",
};

export function TradingViewTechnicalAnalysis({
  market,
  timeframe,
}: TradingViewTechnicalAnalysisProps) {
  const containerRef = useRef<HTMLDivElement>(null);
  const [loading, setLoading] = useState(true);
  const [failed, setFailed] = useState(false);

  useEffect(() => {
    const container = containerRef.current;
    if (!container) return;

    setLoading(true);
    setFailed(false);
    container.replaceChildren();

    const widgetMount = document.createElement("div");
    widgetMount.className = "tradingview-widget-container__widget";
    widgetMount.style.height = "100%";
    widgetMount.style.width = "100%";

    const script = document.createElement("script");
    script.type = "text/javascript";
    script.src = TRADING_VIEW_ANALYSIS_SCRIPT;
    script.async = true;
    script.innerHTML = JSON.stringify({
      interval: TRADING_VIEW_ANALYSIS_INTERVALS[timeframe],
      width: "100%",
      height: "100%",
      isTransparent: true,
      symbol: market.tradingViewSymbol,
      showIntervalTabs: false,
      displayMode: "single",
      locale: "en",
      colorTheme: "dark",
    });

    let settled = false;
    let fallbackTimer = 0;

    const markReady = () => {
      if (settled || !container.querySelector("iframe")) return;
      settled = true;
      window.clearTimeout(fallbackTimer);
      observer.disconnect();
      setLoading(false);
      setFailed(false);
    };

    const observer = new MutationObserver(markReady);
    observer.observe(container, { childList: true, subtree: true });

    script.addEventListener("load", markReady);
    script.addEventListener("error", () => {
      settled = true;
      window.clearTimeout(fallbackTimer);
      observer.disconnect();
      setLoading(false);
      setFailed(true);
    });

    container.append(widgetMount, script);

    fallbackTimer = window.setTimeout(() => {
      if (settled) return;
      settled = true;
      observer.disconnect();
      setLoading(false);
      setFailed(true);
    }, 4500);

    return () => {
      window.clearTimeout(fallbackTimer);
      observer.disconnect();
      container.replaceChildren();
    };
  }, [market.tradingViewSymbol, timeframe]);

  return (
    <div
      className="tv-analysis-shell"
      data-testid="tradingview-technical-analysis"
      aria-label={`Phân tích kỹ thuật TradingView ${market.displayName}`}
    >
      {loading && (
        <div className="tv-analysis-state" role="status">
          <span className="loader" aria-hidden="true" />
          <p>Đang tải technical snapshot</p>
          <small>{market.tradingViewSymbol}</small>
        </div>
      )}

      {failed && (
        <div className="tv-analysis-state tv-analysis-state--error" role="alert">
          <p>Không thể tải bộ phân tích TradingView.</p>
          <small>Kiểm tra kết nối hoặc content blocker rồi thử lại.</small>
        </div>
      )}

      <div ref={containerRef} className="tradingview-widget-container" />
    </div>
  );
}
