import { useEffect, useId, useRef, useState } from "react";
import type { Market, Timeframe } from "../domain/markets";

type TradingViewChartProps = {
  market: Market;
  timeframe: Timeframe;
};

const TRADING_VIEW_SCRIPT =
  "https://s3.tradingview.com/external-embedding/embed-widget-advanced-chart.js";

export function TradingViewChart({ market, timeframe }: TradingViewChartProps) {
  const containerRef = useRef<HTMLDivElement>(null);
  const instanceId = useId();
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
    script.src = TRADING_VIEW_SCRIPT;
    script.async = true;
    script.innerHTML = JSON.stringify({
      autosize: true,
      symbol: market.tradingViewSymbol,
      interval: timeframe,
      timezone: "Asia/Ho_Chi_Minh",
      theme: "dark",
      style: "1",
      locale: "en",
      backgroundColor: "#090b0d",
      gridColor: "rgba(255, 255, 255, 0.045)",
      allow_symbol_change: false,
      calendar: false,
      details: false,
      hide_side_toolbar: false,
      hide_top_toolbar: false,
      hide_legend: false,
      hide_volume: false,
      hotlist: false,
      save_image: true,
      withdateranges: true,
      support_host: "https://www.tradingview.com",
    });

    script.addEventListener("load", () => setLoading(false));
    script.addEventListener("error", () => {
      setLoading(false);
      setFailed(true);
    });

    container.append(widgetMount, script);

    const fallbackTimer = window.setTimeout(() => setLoading(false), 4500);

    return () => {
      window.clearTimeout(fallbackTimer);
      container.replaceChildren();
    };
  }, [market.tradingViewSymbol, timeframe]);

  return (
    <div
      className="chart-shell"
      aria-label={`Biểu đồ TradingView ${market.displayName}`}
      data-testid="tradingview-chart"
    >
      {loading && (
        <div className="chart-state" role="status">
          <span className="loader" aria-hidden="true" />
          <p>Đang kết nối TradingView</p>
          <small>{market.tradingViewSymbol}</small>
        </div>
      )}

      {failed && (
        <div className="chart-state chart-state--error" role="alert">
          <p>Không thể tải biểu đồ TradingView.</p>
          <small>Kiểm tra kết nối mạng hoặc content blocker rồi tải lại trang.</small>
        </div>
      )}

      <div
        ref={containerRef}
        id={`tradingview-${instanceId.replaceAll(":", "")}`}
        className="tradingview-widget-container"
      />
    </div>
  );
}
